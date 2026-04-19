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

wss.on("connection", (ws) => {
  try { ws.send(JSON.stringify({ type: "snapshot", inrRate: getInrRate(), ticks: getCache() })); } catch {}
  const unsub = subscribe((ticks) => {
    try { ws.send(JSON.stringify({ type: "tick", inrRate: getInrRate(), ticks })); } catch {}
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
