import http from "node:http";
import { WebSocketServer } from "ws";
import app from "./app";
import { logger } from "./lib/logger";
import { startPriceService, getCache, subscribe, getInrRate } from "./lib/price-service";

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

server.listen(port, () => {
  logger.info({ port }, "Server listening (HTTP + WS /api/ws/prices)");
  startPriceService(5000);
});
