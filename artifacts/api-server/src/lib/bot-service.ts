import { db, marketBotsTable, ordersTable, pairsTable, coinsTable, tradesTable, usersTable } from "@workspace/db";
import { and, eq, sql } from "drizzle-orm";
import { logger } from "./logger";
import { getCache } from "./price-service";
import { rZadd, rZrem, rSet, rDel, rLpush, rPublish } from "./redis";

// Mirror an order to Redis ZSET orderbook (same shape used by /api/orders)
async function bookAdd(symbol: string, o: any) {
  if (o.status !== "open" || o.type !== "limit") return;
  const score = (o.side === "buy" ? -1 : 1) * Number(o.price);
  const member = JSON.stringify({
    id: o.id, userId: o.userId, side: o.side, type: o.type,
    price: Number(o.price), qty: Number(o.qty), filledQty: Number(o.filledQty ?? 0),
    status: o.status, ts: Date.now(), bot: true,
  });
  await rZadd(`orderbook:${symbol}:${o.side}`, score, String(o.id));
  await rSet(`orderbook:${symbol}:order:${o.id}`, member, 86400);
  await rPublish(`orders.${symbol}`, { action: "new", order: JSON.parse(member) });
}

async function bookRemove(symbol: string, o: { id: number; side: string; userId?: number; price?: any; qty?: any; type?: string; filledQty?: any; status?: string }, action: "cancel" | "fill" = "cancel") {
  await rZrem(`orderbook:${symbol}:${o.side}`, String(o.id));
  await rDel(`orderbook:${symbol}:order:${o.id}`);
  const payload = {
    action,
    order: {
      id: o.id, userId: o.userId, side: o.side, type: o.type ?? "limit",
      price: Number(o.price ?? 0), qty: Number(o.qty ?? 0),
      filledQty: Number(o.filledQty ?? 0), status: o.status ?? action,
      ts: Date.now(), bot: true,
    },
  };
  await rPublish(`orders.${symbol}`, payload);
}

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

  // 1) Cancel stale bot orders (older than maxOrderAgeSec) — DB + Redis cleanup
  const ageMs = bot.maxOrderAgeSec * 1000;
  const cutoff = new Date(Date.now() - ageMs);
  const stale = await db.select().from(ordersTable).where(and(
    eq(ordersTable.botId, bot.id),
    eq(ordersTable.status, "open"),
    sql`${ordersTable.createdAt} < ${cutoff}`,
  ));
  if (stale.length) {
    await db.update(ordersTable).set({ status: "cancelled", updatedAt: new Date() }).where(and(
      eq(ordersTable.botId, bot.id),
      eq(ordersTable.status, "open"),
      sql`${ordersTable.createdAt} < ${cutoff}`,
    ));
    for (const s of stale) {
      try { await bookRemove(pair.symbol, s as any, "cancel"); } catch (e: any) {
        logger.warn({ err: e?.message, orderId: s.id }, "bot: failed to remove stale from redis");
      }
    }
  }

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
      const [trade] = await db.insert(tradesTable).values({
        orderId: o.id, userId: o.userId, pairId: o.pairId, side: o.side,
        price: String(mid.toFixed(8)), qty: String(qty.toFixed(8)),
        fee: "0",
      }).returning();
      // Remove filled order from Redis book + publish trade tape so UI updates live
      try {
        await bookRemove(pair.symbol, { ...o, status: "filled" } as any, "fill");
        const tradePayload = JSON.stringify({
          id: trade.id, pairId: o.pairId, side: o.side,
          price: Number(mid.toFixed(8)), qty: Number(qty.toFixed(8)),
          ts: Date.now(), bot: true,
        });
        await rLpush(`trades:${pair.symbol}`, tradePayload);
        await rLpush(`trades:user:${o.userId}`, tradePayload);
        await rPublish(`trades.${pair.symbol}`, JSON.parse(tradePayload));
      } catch (e: any) {
        logger.warn({ err: e?.message, orderId: o.id }, "bot: failed to publish fill");
      }
    }
  }

  // 3) Count current open bot orders, top-up to `levels` per side (with top-of-book boost on level 0)
  const existing = await db.select().from(ordersTable).where(and(
    eq(ordersTable.botId, bot.id), eq(ordersTable.status, "open"),
  ));
  const buyCount = existing.filter(o => o.side === "buy").length;
  const sellCount = existing.filter(o => o.side === "sell").length;
  const stepFrac = bot.priceStepBps / 10_000;
  const halfSpread = bot.spreadBps / 20_000;
  const baseSize = Number(bot.orderSize);
  const boostMult = 1 + (Number(bot.topOfBookBoostPct ?? 0) / 100);
  const sizeForLevel = (i: number) => i === 0 ? baseSize * boostMult : baseSize;
  const newOrders: any[] = [];
  for (let i = buyCount; i < bot.levels; i++) {
    const px = mid * (1 - halfSpread - stepFrac * i);
    if (px > 0) newOrders.push({ userId: uid, pairId: pair.id, side: "buy", type: "limit", price: String(px.toFixed(8)), qty: String(sizeForLevel(i).toFixed(8)), status: "open", isBot: 1, botId: bot.id });
  }
  for (let i = sellCount; i < bot.levels; i++) {
    const px = mid * (1 + halfSpread + stepFrac * i);
    newOrders.push({ userId: uid, pairId: pair.id, side: "sell", type: "limit", price: String(px.toFixed(8)), qty: String(sizeForLevel(i).toFixed(8)), status: "open", isBot: 1, botId: bot.id });
  }
  if (newOrders.length) {
    const inserted = await db.insert(ordersTable).values(newOrders).returning();
    for (const o of inserted) {
      try { await bookAdd(pair.symbol, o); } catch (e: any) {
        logger.warn({ err: e?.message, orderId: o.id }, "bot: failed to add to redis book");
      }
    }
  }

  // 4) MARKET-TAKER: fire synthetic market orders on price moves or against big user orders
  let marketReason: string | null = null;
  let marketSide: "buy" | "sell" | null = null;
  let marketQty = 0;
  if (bot.marketTakerEnabled) {
    const cooldownMs = bot.marketTakerCooldownSec * 1000;
    const lastMkt = bot.lastMarketOrderAt ? new Date(bot.lastMarketOrderAt).getTime() : 0;
    const cooledDown = Date.now() - lastMkt >= cooldownMs;
    const lastMid = bot.lastMidPrice ? Number(bot.lastMidPrice) : 0;

    // (a) Big-order detection: scan opposite-side user orders for any single qty exceeding threshold
    const bigThreshold = Number(bot.bigOrderTriggerQty ?? 0);
    if (cooledDown && bigThreshold > 0) {
      const opposite = await db.select().from(ordersTable).where(and(
        eq(ordersTable.pairId, pair.id),
        eq(ordersTable.status, "open"),
        eq(ordersTable.isBot, 0),
        sql`(CAST(${ordersTable.qty} AS DECIMAL) - CAST(${ordersTable.filledQty} AS DECIMAL)) >= ${bigThreshold}`,
      )).limit(5);
      if (opposite.length > 0) {
        // Aggregate biggest order; pick a side that absorbs it
        const biggest = opposite.reduce((a, b) => (Number(a.qty) - Number(a.filledQty)) > (Number(b.qty) - Number(b.filledQty)) ? a : b);
        // If user has big SELL → bot fires market BUY to absorb (price goes up). And vice versa.
        marketSide = biggest.side === "sell" ? "buy" : "sell";
        marketQty = baseSize * Number(bot.bigOrderAbsorbMult);
        marketReason = `absorb big ${biggest.side} #${biggest.id} qty=${(Number(biggest.qty) - Number(biggest.filledQty)).toFixed(4)}`;
      }
    }

    // (b) Price-move trigger: if mid moved beyond threshold since last tick → chase market in direction of move
    if (!marketSide && cooledDown && lastMid > 0 && bot.priceMoveTriggerBps > 0) {
      const moveBps = Math.abs(mid - lastMid) / lastMid * 10_000;
      if (moveBps >= bot.priceMoveTriggerBps) {
        marketSide = mid > lastMid ? "buy" : "sell"; // chase momentum
        marketQty = baseSize * Number(bot.marketTakerSizeMult);
        marketReason = `chase ${moveBps.toFixed(1)}bps move (${lastMid.toFixed(8)} → ${mid.toFixed(8)})`;
      }
    }

    if (marketSide && marketQty > 0) {
      // Synthetic market trade at current mid (no wallet movements; pure tape print + order record)
      const [mktOrder] = await db.insert(ordersTable).values({
        userId: uid, pairId: pair.id, side: marketSide, type: "market",
        price: String(mid.toFixed(8)), qty: String(marketQty.toFixed(8)),
        filledQty: String(marketQty.toFixed(8)), avgPrice: String(mid.toFixed(8)),
        status: "filled", isBot: 1, botId: bot.id,
      }).returning();
      const [trade] = await db.insert(tradesTable).values({
        orderId: mktOrder.id, userId: uid, pairId: pair.id, side: marketSide,
        price: String(mid.toFixed(8)), qty: String(marketQty.toFixed(8)), fee: "0",
      }).returning();
      try {
        const tradePayload = JSON.stringify({
          id: trade.id, pairId: pair.id, side: marketSide,
          price: Number(mid.toFixed(8)), qty: Number(marketQty.toFixed(8)),
          ts: Date.now(), bot: true, market: true,
        });
        await rLpush(`trades:${pair.symbol}`, tradePayload);
        await rPublish(`trades.${pair.symbol}`, JSON.parse(tradePayload));
      } catch (e: any) {
        logger.warn({ err: e?.message }, "bot: failed to publish market trade");
      }
      logger.info({ botId: bot.id, symbol: pair.symbol, side: marketSide, qty: marketQty, reason: marketReason }, "bot: fired market order");
    }
  }

  await db.update(marketBotsTable).set({
    status: "running",
    lastError: marketReason ? `market: ${marketReason}` : null,
    lastRunAt: new Date(),
    lastMidPrice: String(mid.toFixed(8)),
    ...(marketSide ? { lastMarketOrderAt: new Date() } : {}),
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
