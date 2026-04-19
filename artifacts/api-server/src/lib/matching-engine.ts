import { eq, sql, and, or, desc } from "drizzle-orm";
import { db, ordersTable, tradesTable, walletsTable, pairsTable, usersTable } from "@workspace/db";
import { logger } from "./logger";
import { getRedis, rZadd, rZrem, rSet, rDel, rLpush, rPublish, rGet } from "./redis";
import { getSpotFeeRates } from "../routes/fees";

let engineEnabled = true;
let engineStats = {
  matchesAttempted: 0,
  tradesExecuted: 0,
  totalVolumeQuote: 0,
  lastMatchAt: 0 as number,
  lastError: "" as string,
  perSymbol: {} as Record<string, { trades: number; volume: number; lastTs: number }>,
};

export function setEngineEnabled(on: boolean) { engineEnabled = on; }
export function getEngineStats() {
  return { enabled: engineEnabled, ...engineStats };
}
export function resetEngineStats() {
  engineStats = { matchesAttempted: 0, tradesExecuted: 0, totalVolumeQuote: 0, lastMatchAt: 0, lastError: "", perSymbol: {} };
}

async function bestOpposite(symbol: string, side: "buy" | "sell", limitPrice: number, isMarket: boolean) {
  const r = getRedis();
  if (!r) return null;
  // Buy taker hits SELL book (lowest ask). Sell taker hits BUY book (highest bid = most-negative score).
  const bookSide = side === "buy" ? "sell" : "buy";
  const key = `orderbook:${symbol}:${bookSide}`;
  const top = await r.zrange(key, 0, 0, "WITHSCORES");
  if (!top || top.length < 2) return null;
  const oppId = Number(top[0]);
  const oppScore = Number(top[1]);
  const oppPrice = bookSide === "sell" ? oppScore : -oppScore;
  if (!isMarket) {
    if (side === "buy" && oppPrice > limitPrice) return null;
    if (side === "sell" && oppPrice < limitPrice) return null;
  }
  return { id: oppId, price: oppPrice };
}

async function getOrderForUpdate(tx: any, id: number) {
  const [o] = await tx.select().from(ordersTable).where(eq(ordersTable.id, id)).for("update").limit(1);
  return o;
}

async function ensureWallet(tx: any, userId: number, coinId: number) {
  const [w] = await tx.select().from(walletsTable)
    .where(and(eq(walletsTable.userId, userId), eq(walletsTable.coinId, coinId), eq(walletsTable.walletType, "spot")))
    .for("update").limit(1);
  if (w) return w;
  const [c] = await tx.insert(walletsTable).values({ userId, coinId, walletType: "spot", balance: "0", locked: "0" }).returning();
  const [locked] = await tx.select().from(walletsTable).where(eq(walletsTable.id, c.id)).for("update").limit(1);
  return locked;
}

export async function tryMatch(takerOrderId: number, opts?: { takerVipTier?: number }): Promise<{ trades: number; remainingQty: number; status: string }> {
  if (!engineEnabled) return { trades: 0, remainingQty: 0, status: "disabled" };
  const r = getRedis();
  if (!r) return { trades: 0, remainingQty: 0, status: "no-redis" };

  let totalTrades = 0;
  let finalStatus = "open";
  let finalRemaining = 0;

  // Cap iterations to avoid infinite loops on weird data
  for (let iter = 0; iter < 50; iter++) {
    engineStats.matchesAttempted++;
    let matchExecuted = false;
    let stop = false;
    let symbolForPub = "";

    try {
      await db.transaction(async (tx) => {
        const taker = await getOrderForUpdate(tx, takerOrderId);
        if (!taker) { stop = true; return; }
        if (taker.status !== "open" && taker.status !== "partial") { stop = true; finalStatus = taker.status; return; }
        const remaining = Number(taker.qty) - Number(taker.filledQty ?? 0);
        if (remaining <= 0) { stop = true; finalStatus = "filled"; return; }
        finalRemaining = remaining;

        const [pair] = await tx.select().from(pairsTable).where(eq(pairsTable.id, taker.pairId)).limit(1);
        if (!pair) { stop = true; return; }
        const symbol = pair.symbol; symbolForPub = symbol;
        const isMarket = taker.type === "market";
        const limitPrice = Number(taker.price);

        const opp = await bestOpposite(symbol, taker.side as any, limitPrice, isMarket);
        if (!opp) { stop = true; return; }

        const maker = await getOrderForUpdate(tx, opp.id);
        if (!maker || (maker.status !== "open" && maker.status !== "partial")) {
          // Stale entry; drop and continue
          await rZrem(`orderbook:${symbol}:${maker?.side ?? (taker.side === "buy" ? "sell" : "buy")}`, String(opp.id));
          return;
        }
        if (maker.userId === taker.userId) {
          // Self-trade prevention: cancel the resting maker, refund, continue loop
          const makerRem = Number(maker.qty) - Number(maker.filledQty ?? 0);
          if (maker.side === "buy") {
            const release = makerRem * Number(maker.price);
            const w = await ensureWallet(tx, maker.userId, pair.quoteCoinId);
            await tx.update(walletsTable).set({
              balance: sql`${walletsTable.balance} + ${release}`,
              locked: sql`${walletsTable.locked} - ${release}`,
              updatedAt: new Date(),
            }).where(eq(walletsTable.id, w.id));
          } else {
            const w = await ensureWallet(tx, maker.userId, pair.baseCoinId);
            await tx.update(walletsTable).set({
              balance: sql`${walletsTable.balance} + ${makerRem}`,
              locked: sql`${walletsTable.locked} - ${makerRem}`,
              updatedAt: new Date(),
            }).where(eq(walletsTable.id, w.id));
          }
          await tx.update(ordersTable).set({ status: "cancelled", updatedAt: new Date() }).where(eq(ordersTable.id, maker.id));
          await rZrem(`orderbook:${symbol}:${maker.side}`, String(maker.id));
          await rDel(`orderbook:${symbol}:order:${maker.id}`);
          return;
        }

        const makerRem = Number(maker.qty) - Number(maker.filledQty ?? 0);
        const fillQty = Math.min(remaining, makerRem);
        const tradePrice = Number(maker.price); // price-time priority: maker price
        const notional = fillQty * tradePrice;

        // Load admin-configured fees (with GST baked in) for both taker and maker
        const takerRates = await getSpotFeeRates(opts?.takerVipTier ?? 0);
        const [makerUserRow] = await tx.select({ vipTier: usersTable.vipTier }).from(usersTable).where(eq(usersTable.id, maker.userId)).limit(1);
        const makerVipTier = Number(makerUserRow?.vipTier ?? 0);
        const makerRates = await getSpotFeeRates(makerVipTier);
        const takerFeeRate = takerRates.taker;
        const makerFeeRate = makerRates.maker;
        const tdsRate = takerRates.tds;
        const takerFee = notional * takerFeeRate;
        const makerFee = notional * makerFeeRate;
        const takerTds = taker.side === "sell" ? notional * tdsRate : 0;
        const makerTds = maker.side === "sell" ? notional * tdsRate : 0;

        if (taker.side === "buy") {
          // Taker BUY: pays quote, receives base. Locked quote on taker reduces by notional.
          // Maker SELL: locked base reduces by fillQty, receives quote (notional - makerFee).
          // For LIMIT taker, locked = remaining * limitPrice; effective spend = notional. Refund (limitPrice - tradePrice)*fillQty.
          const takerQuoteLocked = isMarket ? notional * (1 + takerFeeRate) : fillQty * limitPrice;
          const takerSpend = notional + takerFee; // what we actually take from locked
          const takerRefund = takerQuoteLocked - takerSpend; // could be 0 (market) or positive (limit at better price)
          const tQuote = await ensureWallet(tx, taker.userId, pair.quoteCoinId);
          await tx.update(walletsTable).set({
            locked: sql`${walletsTable.locked} - ${takerQuoteLocked}`,
            balance: takerRefund > 0 ? sql`${walletsTable.balance} + ${takerRefund}` : walletsTable.balance,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, tQuote.id));
          const tBase = await ensureWallet(tx, taker.userId, pair.baseCoinId);
          await tx.update(walletsTable).set({
            balance: sql`${walletsTable.balance} + ${fillQty}`,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, tBase.id));
          // Maker sell: release locked base, credit quote
          const mBase = await ensureWallet(tx, maker.userId, pair.baseCoinId);
          await tx.update(walletsTable).set({
            locked: sql`${walletsTable.locked} - ${fillQty}`,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, mBase.id));
          const mQuote = await ensureWallet(tx, maker.userId, pair.quoteCoinId);
          await tx.update(walletsTable).set({
            balance: sql`${walletsTable.balance} + ${notional - makerFee - makerTds}`,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, mQuote.id));
        } else {
          // Taker SELL: locked base = remaining (qty units). Spend fillQty base, get notional - takerFee quote.
          const tBase = await ensureWallet(tx, taker.userId, pair.baseCoinId);
          await tx.update(walletsTable).set({
            locked: sql`${walletsTable.locked} - ${fillQty}`,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, tBase.id));
          const tQuote = await ensureWallet(tx, taker.userId, pair.quoteCoinId);
          await tx.update(walletsTable).set({
            balance: sql`${walletsTable.balance} + ${notional - takerFee - takerTds}`,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, tQuote.id));
          // Maker buy: locked quote = makerRem * makerPrice; spend = notional + makerFee; refund leftover lock for this slice = (makerPrice * fillQty) - (notional + makerFee) = -makerFee since tradePrice = makerPrice
          const makerLockSlice = fillQty * tradePrice;
          const makerSpend = notional + makerFee;
          // Negative refund means we need to take fee from balance because we pre-locked exact notional only.
          // Strategy: reduce locked by makerLockSlice (release), then debit fee from balance.
          const mQuote = await ensureWallet(tx, maker.userId, pair.quoteCoinId);
          await tx.update(walletsTable).set({
            locked: sql`${walletsTable.locked} - ${makerLockSlice}`,
            balance: sql`${walletsTable.balance} - ${makerFee}`,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, mQuote.id));
          const mBase = await ensureWallet(tx, maker.userId, pair.baseCoinId);
          await tx.update(walletsTable).set({
            balance: sql`${walletsTable.balance} + ${fillQty}`,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, mBase.id));
        }

        // Insert trades (one row per side for accounting clarity? Use single row with taker side)
        const [trade] = await tx.insert(tradesTable).values({
          orderId: taker.id, userId: taker.userId, pairId: pair.id,
          side: taker.side, price: String(tradePrice), qty: String(fillQty), fee: String(takerFee),
        }).returning();
        await tx.insert(tradesTable).values({
          orderId: maker.id, userId: maker.userId, pairId: pair.id,
          side: maker.side, price: String(tradePrice), qty: String(fillQty), fee: String(makerFee),
        });

        // Update orders
        const newTakerFilled = Number(taker.filledQty ?? 0) + fillQty;
        const takerFinished = newTakerFilled >= Number(taker.qty) - 1e-12;
        const newMakerFilled = Number(maker.filledQty ?? 0) + fillQty;
        const makerFinished = newMakerFilled >= Number(maker.qty) - 1e-12;
        await tx.update(ordersTable).set({
          filledQty: String(newTakerFilled),
          avgPrice: String(tradePrice),
          fee: sql`${ordersTable.fee} + ${takerFee}`,
          status: takerFinished ? "filled" : "partial",
          updatedAt: new Date(),
        }).where(eq(ordersTable.id, taker.id));
        await tx.update(ordersTable).set({
          filledQty: String(newMakerFilled),
          avgPrice: String(tradePrice),
          fee: sql`${ordersTable.fee} + ${makerFee}`,
          status: makerFinished ? "filled" : "partial",
          updatedAt: new Date(),
        }).where(eq(ordersTable.id, maker.id));

        // Update pair lastPrice
        await tx.update(pairsTable).set({
          lastPrice: String(tradePrice),
          volume24h: sql`${pairsTable.volume24h} + ${fillQty}`,
          updatedAt: new Date(),
        }).where(eq(pairsTable.id, pair.id));

        // Update Redis book
        if (makerFinished) {
          await rZrem(`orderbook:${symbol}:${maker.side}`, String(maker.id));
          await rDel(`orderbook:${symbol}:order:${maker.id}`);
        } else {
          await rSet(`orderbook:${symbol}:order:${maker.id}`, JSON.stringify({
            id: maker.id, userId: maker.userId, side: maker.side, type: maker.type,
            price: Number(maker.price), qty: Number(maker.qty), filledQty: newMakerFilled,
            status: "partial", ts: Date.now(),
          }), 86400);
        }

        // Publish trade
        const tradePayload = JSON.stringify({
          id: trade.id, pairId: pair.id, side: taker.side,
          price: tradePrice, qty: fillQty, ts: Date.now(),
        });
        await rLpush(`trades:${symbol}`, tradePayload);
        await rLpush(`trades:user:${taker.userId}`, tradePayload);
        await rLpush(`trades:user:${maker.userId}`, tradePayload);
        await rPublish(`trades.${symbol}`, JSON.parse(tradePayload));
        await rSet(`pair:${symbol}:lastPrice`, String(tradePrice), 60);

        finalRemaining = remaining - fillQty;
        finalStatus = takerFinished ? "filled" : "partial";
        totalTrades++;
        matchExecuted = true;

        engineStats.tradesExecuted++;
        engineStats.totalVolumeQuote += notional;
        engineStats.lastMatchAt = Date.now();
        const ps = (engineStats.perSymbol[symbol] ||= { trades: 0, volume: 0, lastTs: 0 });
        ps.trades++; ps.volume += notional; ps.lastTs = Date.now();

        if (takerFinished) stop = true;
      });
    } catch (e: any) {
      engineStats.lastError = e?.message ?? String(e);
      logger.warn({ err: engineStats.lastError, takerOrderId }, "matching iteration failed");
      stop = true;
    }

    if (symbolForPub && matchExecuted) {
      await rPublish(`book.${symbolForPub}`, { type: "match", takerOrderId, ts: Date.now() });
    }
    if (stop) break;
    if (!matchExecuted) break; // safety
  }

  return { trades: totalTrades, remainingQty: finalRemaining, status: finalStatus };
}

// Read aggregated depth for a symbol (top N levels)
export async function getDepth(symbol: string, levels = 20) {
  const r = getRedis();
  if (!r) return { bids: [], asks: [] };
  const [buys, sells] = await Promise.all([
    r.zrange(`orderbook:${symbol}:buy`, 0, 200, "WITHSCORES"),
    r.zrange(`orderbook:${symbol}:sell`, 0, 200, "WITHSCORES"),
  ]);
  const aggBids: Record<string, number> = {};
  const aggAsks: Record<string, number> = {};
  for (let i = 0; i < buys.length; i += 2) {
    const id = buys[i]; const score = Number(buys[i + 1]);
    const price = -score;
    const raw = await r.get(`orderbook:${symbol}:order:${id}`);
    if (!raw) continue;
    const o = JSON.parse(raw);
    const rem = Number(o.qty) - Number(o.filledQty ?? 0);
    if (rem <= 0) continue;
    const k = price.toString();
    aggBids[k] = (aggBids[k] ?? 0) + rem;
  }
  for (let i = 0; i < sells.length; i += 2) {
    const id = sells[i]; const score = Number(sells[i + 1]);
    const price = score;
    const raw = await r.get(`orderbook:${symbol}:order:${id}`);
    if (!raw) continue;
    const o = JSON.parse(raw);
    const rem = Number(o.qty) - Number(o.filledQty ?? 0);
    if (rem <= 0) continue;
    const k = price.toString();
    aggAsks[k] = (aggAsks[k] ?? 0) + rem;
  }
  const bids = Object.entries(aggBids).map(([p, q]) => [Number(p), q] as [number, number]).sort((a, b) => b[0] - a[0]).slice(0, levels);
  const asks = Object.entries(aggAsks).map(([p, q]) => [Number(p), q] as [number, number]).sort((a, b) => a[0] - b[0]).slice(0, levels);
  return { bids, asks };
}

export async function getRecentTrades(symbol: string, limit = 50) {
  const r = getRedis();
  if (!r) return [];
  const raws = await r.lrange(`trades:${symbol}`, 0, limit - 1);
  return raws.map(s => { try { return JSON.parse(s); } catch { return null; } }).filter(Boolean);
}
