import { db, marketBotsTable, ordersTable, pairsTable, coinsTable, tradesTable, usersTable } from "@workspace/db";
import { and, eq, sql } from "drizzle-orm";
import { logger } from "./logger";
import { getCache } from "./price-service";

let started = false;
let ticking = false;
let botUserId: number | null = null;

async function getBotUserId(): Promise<number | null> {
  if (botUserId) return botUserId;
  const admins = await db.select().from(usersTable).where(sql`${usersTable.role} IN ('admin','superadmin')`).limit(1);
  if (!admins[0]) return null;
  botUserId = admins[0].id;
  return botUserId;
}

function midPriceForPair(pair: any, coinsBySymbol: Map<string, any>): number {
  const base = coinsBySymbol.get(pair._baseSymbol);
  const quote = coinsBySymbol.get(pair._quoteSymbol);
  if (!base || !quote) return Number(pair.lastPrice ?? 0);
  const c = getCache();
  const bTick = c.find(t => t.symbol === pair._baseSymbol);
  const qTick = c.find(t => t.symbol === pair._quoteSymbol);
  const bUsdt = bTick?.usdt ?? Number(base.currentPrice ?? 0);
  const qUsdt = qTick?.usdt ?? Number(quote.currentPrice ?? 1);
  if (bUsdt <= 0 || qUsdt <= 0) return Number(pair.lastPrice ?? 0);
  return bUsdt / qUsdt;
}

async function runBotForPair(bot: any, uid: number) {
  const [pair] = await db.select().from(pairsTable).where(eq(pairsTable.id, bot.pairId));
  if (!pair) return;
  const baseCoin = (await db.select().from(coinsTable).where(eq(coinsTable.id, pair.baseCoinId)))[0];
  const quoteCoin = (await db.select().from(coinsTable).where(eq(coinsTable.id, pair.quoteCoinId)))[0];
  if (!baseCoin || !quoteCoin) return;

  const enriched = { ...pair, _baseSymbol: baseCoin.symbol, _quoteSymbol: quoteCoin.symbol };
  const coinsBySymbol = new Map([[baseCoin.symbol, baseCoin], [quoteCoin.symbol, quoteCoin]]);
  const mid = midPriceForPair(enriched, coinsBySymbol);
  if (!(mid > 0)) {
    await db.update(marketBotsTable).set({ status: "no_price", lastError: "mid price unavailable", lastRunAt: new Date() }).where(eq(marketBotsTable.id, bot.id));
    return;
  }

  // 1) Cancel stale bot orders (older than maxOrderAgeSec)
  const ageMs = bot.maxOrderAgeSec * 1000;
  const cutoff = new Date(Date.now() - ageMs);
  await db.update(ordersTable).set({ status: "cancelled" }).where(and(
    eq(ordersTable.botId, bot.id),
    eq(ordersTable.status, "open"),
    sql`${ordersTable.createdAt} < ${cutoff}`,
  ));

  // 2) Match cross-able open orders against current mid (bot + user)
  if (bot.fillOnCross) {
    const open = await db.select().from(ordersTable).where(and(eq(ordersTable.pairId, pair.id), eq(ordersTable.status, "open")));
    for (const o of open) {
      const px = Number(o.price);
      const qty = Number(o.qty) - Number(o.filledQty);
      if (qty <= 0) continue;
      const crosses = (o.side === "buy" && mid <= px) || (o.side === "sell" && mid >= px);
      if (!crosses) continue;
      await db.update(ordersTable).set({
        status: "filled",
        filledQty: String((Number(o.filledQty) + qty).toFixed(8)),
        avgPrice: String(mid.toFixed(8)),
        updatedAt: new Date(),
      }).where(eq(ordersTable.id, o.id));
      await db.insert(tradesTable).values({
        orderId: o.id, userId: o.userId, pairId: o.pairId, side: o.side,
        price: String(mid.toFixed(8)), qty: String(qty.toFixed(8)),
        fee: "0",
      });
    }
  }

  // 3) Count current open bot orders, top-up to `levels` per side
  const existing = await db.select().from(ordersTable).where(and(
    eq(ordersTable.botId, bot.id), eq(ordersTable.status, "open"),
  ));
  const buyCount = existing.filter(o => o.side === "buy").length;
  const sellCount = existing.filter(o => o.side === "sell").length;
  const stepFrac = bot.priceStepBps / 10_000;
  const halfSpread = bot.spreadBps / 20_000;
  const newOrders: any[] = [];
  for (let i = buyCount; i < bot.levels; i++) {
    const px = mid * (1 - halfSpread - stepFrac * i);
    if (px > 0) newOrders.push({ userId: uid, pairId: pair.id, side: "buy", type: "limit", price: String(px.toFixed(8)), qty: String(Number(bot.orderSize).toFixed(8)), status: "open", isBot: 1, botId: bot.id });
  }
  for (let i = sellCount; i < bot.levels; i++) {
    const px = mid * (1 + halfSpread + stepFrac * i);
    newOrders.push({ userId: uid, pairId: pair.id, side: "sell", type: "limit", price: String(px.toFixed(8)), qty: String(Number(bot.orderSize).toFixed(8)), status: "open", isBot: 1, botId: bot.id });
  }
  if (newOrders.length) await db.insert(ordersTable).values(newOrders);

  await db.update(marketBotsTable).set({
    status: "running", lastError: null, lastRunAt: new Date(),
  }).where(eq(marketBotsTable.id, bot.id));
}

async function tick() {
  const bots = await db.select().from(marketBotsTable).where(eq(marketBotsTable.enabled, true));
  if (!bots.length) return;
  const uid = await getBotUserId();
  if (!uid) { logger.warn("bot: no admin user available, skipping tick"); return; }
  for (const bot of bots) {
    if (bot.startAt && new Date(bot.startAt).getTime() > Date.now()) {
      await db.update(marketBotsTable).set({ status: "scheduled", lastError: null }).where(eq(marketBotsTable.id, bot.id));
      continue;
    }
    if (!bot.spotEnabled && !bot.futuresEnabled) {
      await db.update(marketBotsTable).set({ status: "disabled", lastError: "neither spot nor futures enabled" }).where(eq(marketBotsTable.id, bot.id));
      continue;
    }
    const last = bot.lastRunAt ? new Date(bot.lastRunAt).getTime() : 0;
    if (Date.now() - last < bot.refreshSec * 1000) continue;
    try { await runBotForPair(bot, uid); }
    catch (e: any) {
      logger.warn({ err: e?.message, botId: bot.id }, "bot tick failed");
      await db.update(marketBotsTable).set({ status: "error", lastError: String(e?.message || e), lastRunAt: new Date() }).where(eq(marketBotsTable.id, bot.id));
    }
  }
}

async function safeTick() {
  if (ticking) return;
  ticking = true;
  try { await tick(); }
  catch (e: any) { logger.warn({ err: e?.message, stack: e?.stack }, "bot tick uncaught"); }
  finally { ticking = false; }
}

export function startBotService(intervalMs = 3000) {
  if (started) return;
  started = true;
  setInterval(() => { void safeTick(); }, intervalMs);
  logger.info({ intervalMs }, "bot service started");
}
