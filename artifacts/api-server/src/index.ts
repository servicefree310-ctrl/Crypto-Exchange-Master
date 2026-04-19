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
const wss = new WebSocketServer({ server, path: "/api/ws/prices" });

wss.on("connection", (ws) => {
  try { ws.send(JSON.stringify({ type: "snapshot", inrRate: getInrRate(), ticks: getCache() })); } catch {}
  const unsub = subscribe((ticks) => {
    try { ws.send(JSON.stringify({ type: "tick", inrRate: getInrRate(), ticks })); } catch {}
  });
  ws.on("close", () => unsub());
  ws.on("error", () => unsub());
});

server.listen(port, async () => {
  logger.info({ port }, "Server listening (HTTP + WS /api/ws/prices)");
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
