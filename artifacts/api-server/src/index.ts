import http from "node:http";
import { WebSocketServer } from "ws";
import app from "./app";
import { logger } from "./lib/logger";
import { startPriceService, getCache, subscribe, getInrRate } from "./lib/price-service";
import { startBotService } from "./lib/bot-service";
import { startDepositSweeper } from "./lib/deposit-sweeper";
import { startWithdrawalWatcher } from "./lib/withdrawal-watcher";
import { startFuturesEngine } from "./lib/futures-engine";
import { initRedis, shutdownRedis } from "./lib/redis";
import { seedCacheConfigs } from "./routes/redis-admin";
import { warmAllCaches, startWarmupRefresh } from "./lib/cache-warmup";
import { startPairStatsService } from "./lib/pair-stats";
import { startPriceHistory } from "./lib/price-history";
import { getPairStats } from "./lib/pair-stats";

const rawPort = process.env["PORT"];
if (!rawPort) throw new Error("PORT environment variable is required but was not provided.");
const port = Number(rawPort);
if (Number.isNaN(port) || port <= 0) throw new Error(`Invalid PORT value: "${rawPort}"`);

const server = http.createServer(app);

// Flutter UI hits several historical Bicrypto WS paths. Rather than create
// one WSS per path (each binds the upgrade handler), we attach one WSS with
// `noServer:true` and route HTTP `upgrade` events to it for each known path.
const PRICE_WS_PATHS = [
  "/api/ws/prices",          // current canonical
  "/api/exchange/ticker",    // Flutter spot exchange page
  "/api/exchange/ws",        // Flutter generic market socket
  "/api/exchange/market",    // Flutter trading_websocket_service
  "/api/futures/ws",         // Flutter futures page (price stream only for now)
  "/api/ws/exchange",        // additional alias seen in some Bicrypto builds
];
const wss = new WebSocketServer({ noServer: true });

server.on("upgrade", (req, socket, head) => {
  const url = req.url || "";
  // strip query string
  const path = url.split("?")[0];
  if (PRICE_WS_PATHS.includes(path)) {
    wss.handleUpgrade(req, socket, head, (ws) => wss.emit("connection", ws, req));
  } else {
    // No handler for this path — close the socket cleanly.
    socket.destroy();
  }
});

// Convert internal Tick[] → Bicrypto-style ticker map keyed by "BASE/QUOTE".
// Emits both BASE/USDT and BASE/INR entries so the Flutter MarketService
// (which keys cachedMarkets by full symbol) can match either pair.
function toTickersFrame(ticks: any[]): Record<string, any> {
  const out: Record<string, any> = {};
  for (const t of ticks) {
    if (!t || !t.symbol) continue;
    if (t.symbol === "USDT" || t.symbol === "INR") continue;
    const usdt = Number(t.usdt ?? 0);
    const inr = Number(t.inr ?? 0);
    const pctRawTick = Number(t.change24h ?? 0);
    const tickVol = Number(t.volume24h ?? 0);
    const build = (sym: string, feedPx: number) => {
      // Overlay authoritative DB pair-stats (volume / change / hi-lo / last)
      // when the pair has any real fills. Falls back to the synthetic
      // external-feed tick when the pair has never traded.
      const ps = getPairStats(sym);
      const hasFills = !!ps && ps.trades24h > 0;
      const px = hasFills ? (ps!.lastPrice || feedPx) : feedPx;
      const pctRaw = hasFills ? ps!.change24h : pctRawTick;
      const pct = pctRaw <= -100 ? -99.99 : pctRaw;
      const baseVol = hasFills ? ps!.baseVolume : tickVol;
      const quoteVol = hasFills ? ps!.quoteVolume : baseVol * px;
      const high = hasFills ? (ps!.high24h || px) : px * (1 + Math.max(pct, 0) / 100);
      const low = hasFills ? (ps!.low24h || px) : px * (1 + Math.min(pct, 0) / 100);
      return {
        last: px, change: pct, baseVolume: baseVol, quoteVolume: quoteVol,
        high, low, timestamp: Number(t.ts ?? Date.now()),
      };
    };
    if (usdt > 0) out[`${t.symbol}/USDT`] = build(`${t.symbol}/USDT`, usdt);
    if (inr > 0) out[`${t.symbol}/INR`] = build(`${t.symbol}/INR`, inr);
  }
  return out;
}

// Build a per-symbol ticker frame matching what TradingWebSocketService
// (._handleTickerData) expects: keys symbol/last/bid/ask/high/low/open/close/
// percentage/baseVolume/quoteVolume.
function tickerFrameFor(symbol: string, ticks: any[]) {
  const [base, quote = "USDT"] = symbol.split("/");
  const t = ticks.find((x) => x && x.symbol === base);
  if (!t) return null;
  const feedPx = quote === "INR" ? Number(t.inr ?? 0) : Number(t.usdt ?? 0);
  const ps = getPairStats(symbol);
  const hasFills = !!ps && ps.trades24h > 0;
  const px = hasFills ? (ps!.lastPrice || feedPx) : feedPx;
  if (!(px > 0)) return null;
  const pctRaw = hasFills ? ps!.change24h : Number(t.change24h ?? 0);
  const pct = pctRaw <= -100 ? -99.99 : pctRaw;
  const baseVol = hasFills ? ps!.baseVolume : Number(t.volume24h ?? 0);
  const quoteVol = hasFills ? ps!.quoteVolume : baseVol * px;
  const high = hasFills ? (ps!.high24h || px) : px * (1 + Math.max(pct, 0) / 100);
  const low = hasFills ? (ps!.low24h || px) : px * (1 + Math.min(pct, 0) / 100);
  return {
    symbol,
    last: px,
    bid: px,
    ask: px,
    high, low,
    open: px / (1 + pct / 100),
    close: px,
    percentage: pct,
    baseVolume: baseVol,
    quoteVolume: quoteVol,
    timestamp: Number(t.ts ?? Date.now()),
  };
}

wss.on("connection", (ws) => {
  // Per-connection subscription state. Trading widgets in Flutter send
  //   {action:"SUBSCRIBE", payload:{type:"orderbook"|"trades"|"ticker", symbol, limit}}
  // We track subscribed symbols per type and push fresh data on each price
  // tick (orderbook/trades are pulled from Redis via the matching engine).
  const subs: {
    tickerSymbols: Set<string>;
    orderbookSymbols: Map<string, number>; // symbol -> limit
    tradesSymbols: Set<string>;
  } = {
    tickerSymbols: new Set(),
    orderbookSymbols: new Map(),
    tradesSymbols: new Set(),
  };

  const safeSend = (payload: any) => {
    try {
      if (ws.readyState === ws.OPEN) ws.send(JSON.stringify(payload));
    } catch {}
  };

  // Push orderbook + trades for all subscribed symbols. Async so Redis I/O
  // doesn't block the price-tick loop.
  const pushBookAndTrades = async () => {
    if (subs.orderbookSymbols.size === 0 && subs.tradesSymbols.size === 0) return;
    try {
      const me = await import("./lib/matching-engine");
      for (const [sym, lim] of subs.orderbookSymbols) {
        try {
          const depth = await me.getDepth(sym, lim);
          safeSend({
            stream: `orderbook:${sym}`,
            data: { ...depth, symbol: sym, timestamp: Date.now() },
          });
        } catch {}
      }
      for (const sym of subs.tradesSymbols) {
        try {
          const trades = await me.getRecentTrades(sym, 50);
          safeSend({ stream: "trades", data: trades });
        } catch {}
      }
    } catch {}
  };

  // Initial snapshot (legacy + Bicrypto-style bulk tickers).
  try {
    const ticks = getCache();
    ws.send(JSON.stringify({ type: "snapshot", inrRate: getInrRate(), ticks }));
    ws.send(JSON.stringify({ stream: "tickers", data: toTickersFrame(ticks) }));
  } catch {}

  const unsub = subscribe((ticks) => {
    safeSend({ type: "tick", inrRate: getInrRate(), ticks });
    safeSend({ stream: "tickers", data: toTickersFrame(ticks) });
    // Per-symbol ticker frames for the trading WS clients.
    for (const sym of subs.tickerSymbols) {
      const frame = tickerFrameFor(sym, ticks);
      if (frame) safeSend({ stream: "ticker", data: frame });
    }
    // Fire-and-forget orderbook/trades push (do not await — keep tick loop tight).
    void pushBookAndTrades();
  });

  ws.on("message", (raw) => {
    let msg: any;
    try { msg = JSON.parse(raw.toString()); } catch { return; }
    if (!msg || typeof msg !== "object") return;
    if (msg.action === "PING") { safeSend({ action: "PONG", ts: Date.now() }); return; }
    const isSub = msg.action === "SUBSCRIBE";
    const isUnsub = msg.action === "UNSUBSCRIBE";
    if (!isSub && !isUnsub) return;
    const p = msg.payload || {};
    const type = String(p.type || "");
    const symbol = String(p.symbol || "");
    if (!type || !symbol) return;
    if (type === "ticker") {
      if (isSub) subs.tickerSymbols.add(symbol);
      else subs.tickerSymbols.delete(symbol);
      // Send an immediate frame so the UI doesn't wait for the next tick.
      if (isSub) {
        const frame = tickerFrameFor(symbol, getCache());
        if (frame) safeSend({ stream: "ticker", data: frame });
      }
    } else if (type === "orderbook") {
      const lim = Math.max(1, Math.min(200, Number(p.limit) || 50));
      if (isSub) subs.orderbookSymbols.set(symbol, lim);
      else subs.orderbookSymbols.delete(symbol);
      if (isSub) void pushBookAndTrades();
    } else if (type === "trades") {
      if (isSub) subs.tradesSymbols.add(symbol);
      else subs.tradesSymbols.delete(symbol);
      if (isSub) void pushBookAndTrades();
    }
    // Note: ohlcv subscriptions are still served by /api/exchange/chart REST.
  });

  ws.on("close", () => unsub());
  ws.on("error", () => unsub());
});

server.listen(port, async () => {
  logger.info({ port, wsPaths: PRICE_WS_PATHS }, "Server listening (HTTP + price WS aliases)");
  await initRedis();
  try { await seedCacheConfigs(); } catch (e: any) { logger.warn({ err: e?.message }, "cache config seed failed"); }
  try { await warmAllCaches(); } catch (e: any) { logger.warn({ err: e?.message }, "cache warmup failed"); }
  startWarmupRefresh(60000);
  startPriceService(1000);
  startPriceHistory();
  startBotService(3000);
  startDepositSweeper(30000);
  startWithdrawalWatcher();
  startFuturesEngine();
  startPairStatsService(5000);
});

const shutdown = async () => { await shutdownRedis(); process.exit(0); };
process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
