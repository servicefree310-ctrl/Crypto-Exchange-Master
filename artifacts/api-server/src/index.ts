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
    const pctRaw = Number(t.change24h ?? 0);
    const pct = pctRaw <= -100 ? -99.99 : pctRaw;
    const vol = Number(t.volume24h ?? 0);
    if (usdt > 0) {
      out[`${t.symbol}/USDT`] = {
        last: usdt, change: pct, baseVolume: vol, quoteVolume: vol * usdt,
        high: usdt * (1 + Math.max(pct, 0) / 100),
        low: usdt * (1 + Math.min(pct, 0) / 100),
        timestamp: Number(t.ts ?? Date.now()),
      };
    }
    if (inr > 0) {
      out[`${t.symbol}/INR`] = {
        last: inr, change: pct, baseVolume: vol, quoteVolume: vol * inr,
        high: inr * (1 + Math.max(pct, 0) / 100),
        low: inr * (1 + Math.min(pct, 0) / 100),
        timestamp: Number(t.ts ?? Date.now()),
      };
    }
  }
  return out;
}

wss.on("connection", (ws) => {
  try {
    const ticks = getCache();
    // Legacy frame for clients that consume the raw price feed
    ws.send(JSON.stringify({ type: "snapshot", inrRate: getInrRate(), ticks }));
    // Bicrypto-style frame for Flutter MarketService.updateMarketsWithTickers
    ws.send(JSON.stringify({ stream: "tickers", data: toTickersFrame(ticks) }));
  } catch {}
  const unsub = subscribe((ticks) => {
    try {
      ws.send(JSON.stringify({ type: "tick", inrRate: getInrRate(), ticks }));
      ws.send(JSON.stringify({ stream: "tickers", data: toTickersFrame(ticks) }));
    } catch {}
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
  startBotService(3000);
  startDepositSweeper(30000);
  startWithdrawalWatcher();
  startFuturesEngine();
  startPairStatsService(30000);
});

const shutdown = async () => { await shutdownRedis(); process.exit(0); };
process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
