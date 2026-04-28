import { Router, type IRouter } from "express";
import { eq, and, desc, sql } from "drizzle-orm";
import { z } from "zod";
import { db, ordersTable, tradesTable, pairsTable, walletsTable, coinsTable } from "@workspace/db";
import { requireAuth } from "../middlewares/auth";
import { rZadd, rZrem, rPublish, rLpush, rSet } from "../lib/redis";
import { tryMatch, getDepth, getRecentTrades } from "../lib/matching-engine";
import { getSpotFeeRates } from "./fees";

// ─── Zod schemas ─────────────────────────────────────────────────────────
// Stricter than the historical placeSpotOrder() guard — we validate types &
// finiteness here so a bad client sees a clean 400 instead of a 500 bubbling
// up from the inner engine. .strict() blocks mass-assignment of fields the
// engine doesn't expect (status, userId, fee overrides, etc).
const PlaceOrderBody = z.object({
  pairId: z.coerce.number().int().positive(),
  side: z.enum(["buy", "sell"]),
  type: z.enum(["limit", "market"]),
  qty: z.coerce.number().finite().positive(),
  price: z.coerce.number().finite().positive().optional(),
}).strict().superRefine((data, ctx) => {
  // Limit orders REQUIRE a price; market orders MUST NOT carry one (otherwise
  // the engine would silently ignore it and the user might think their limit
  // price was respected).
  if (data.type === "limit" && data.price == null) {
    ctx.addIssue({ code: "custom", path: ["price"], message: "price required for limit orders" });
  }
  if (data.type === "market" && data.price != null) {
    ctx.addIssue({ code: "custom", path: ["price"], message: "price not allowed for market orders" });
  }
});

async function pushOrderToRedis(o: any, pair: any, action: "new" | "cancel" | "fill") {
  const symbol = pair?.symbol ?? `pair-${o.pairId}`;
  const score = (o.side === "buy" ? -1 : 1) * Number(o.price);
  const member = JSON.stringify({ id: o.id, userId: o.userId, side: o.side, type: o.type, price: Number(o.price), qty: Number(o.qty), filledQty: Number(o.filledQty ?? 0), status: o.status, ts: Date.now() });
  if (action === "new" && o.status === "open" && o.type === "limit") {
    await rZadd(`orderbook:${symbol}:${o.side}`, score, String(o.id));
    await rSet(`orderbook:${symbol}:order:${o.id}`, member, 86400);
  }
  if (action === "cancel" || action === "fill") {
    await rZrem(`orderbook:${symbol}:${o.side}`, String(o.id));
  }
  await rLpush(`orders:user:${o.userId}`, member);
  await rPublish(`orders.${symbol}`, { action, order: JSON.parse(member) });
  await rPublish(`orders.user.${o.userId}`, { action, order: JSON.parse(member) });
}

async function pushTradeToRedis(trade: any, pair: any) {
  const symbol = pair?.symbol ?? `pair-${trade.pairId}`;
  const payload = JSON.stringify({ id: trade.id, pairId: trade.pairId, side: trade.side, price: Number(trade.price), qty: Number(trade.qty), fee: Number(trade.fee), userId: trade.userId, ts: Date.now() });
  await rLpush(`trades:${symbol}`, payload);
  await rLpush(`trades:user:${trade.userId}`, payload);
  await rPublish(`trades.${symbol}`, JSON.parse(payload));
}

const router: IRouter = Router();

async function ensureWallet(tx: any, userId: number, coinId: number, walletType: string) {
  const [w] = await tx.select().from(walletsTable)
    .where(and(eq(walletsTable.userId, userId), eq(walletsTable.coinId, coinId), eq(walletsTable.walletType, walletType)))
    .for("update").limit(1);
  if (w) return w;
  const [created] = await tx.insert(walletsTable).values({
    userId, coinId, walletType, balance: "0", locked: "0",
  }).returning();
  // Re-lock the just-created row
  const [locked] = await tx.select().from(walletsTable).where(eq(walletsTable.id, created.id)).for("update").limit(1);
  return locked;
}

// SECURITY: User-facing "My Orders" / "My Trades" must NEVER include bot rows.
// Bot orders are inserted under a real user_id (currently the admin's id) so the
// userId scope alone is not enough to keep them out of a user's personal view —
// without an explicit `is_bot = 0` filter, an admin (or any user that shares an
// id with the bot account) would see all market-making bot orders as if they
// placed them. Bot rows remain visible only via the admin endpoints in admin.ts.
router.get("/orders", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const status = (req.query.status as string) || "all";
  const conds = [eq(ordersTable.userId, userId), eq(ordersTable.isBot, 0)];
  if (status !== "all") conds.push(eq(ordersTable.status, status));
  const rows = await db.select().from(ordersTable)
    .where(and(...conds))
    .orderBy(desc(ordersTable.createdAt))
    .limit(200);
  res.json(rows);
});

router.get("/trades", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  // tradesTable has no is_bot column; filter via the parent order. NOT EXISTS
  // is faster than a subselect IN (...) because it short-circuits per row.
  const rows = await db.select().from(tradesTable)
    .where(and(
      eq(tradesTable.userId, userId),
      sql`NOT EXISTS (SELECT 1 FROM ${ordersTable} WHERE ${ordersTable.id} = ${tradesTable.orderId} AND ${ordersTable.isBot} = 1)`,
    ))
    .orderBy(desc(tradesTable.createdAt))
    .limit(200);
  res.json(rows);
});

/**
 * Shared spot-order placement. Used by `/api/orders` (modern client / admin) and
 * `/api/exchange/order` (Bicrypto Flutter mobile/web bridge). All param values
 * MUST be normalized lowercase strings; numeric `qty`/`price` finite > 0.
 *
 * Returns either a fully filled (market or auto-matched limit) order, or a
 * resting open/partial limit order. Throws an Error with `.code` (HTTP status)
 * on validation failure — callers should map to HTTP responses.
 */
export async function placeSpotOrder(opts: {
  userId: number;
  vipTier: number;
  pairId: number;
  side: "buy" | "sell";
  type: "limit" | "market";
  qty: number;
  price?: number;
}): Promise<{ order: any; matched: number }> {
  const { userId, vipTier, pairId, side, type, qty, price } = opts;
  if (!pairId || !["buy", "sell"].includes(side) || !["limit", "market"].includes(type)) {
    const e: any = new Error("pairId, side(buy/sell), type(limit/market) required");
    e.code = 400; throw e;
  }
  const qtyNum = Number(qty);
  if (!Number.isFinite(qtyNum) || qtyNum <= 0) {
    const e: any = new Error("qty must be positive"); e.code = 400; throw e;
  }

  const created = await db.transaction(async (tx) => {
      const [pair] = await tx.select().from(pairsTable).where(eq(pairsTable.id, Number(pairId))).limit(1);
      if (!pair) { const e: any = new Error("Pair not found"); e.code = 404; throw e; }
      if (!pair.tradingEnabled || pair.status !== "active") { const e: any = new Error("Trading disabled for this pair"); e.code = 400; throw e; }
      if (pair.tradingStartAt && pair.tradingStartAt.getTime() > Date.now()) {
        const e: any = new Error("Trading not yet started"); e.code = 400; throw e;
      }
      const minQty = Number(pair.minQty);
      if (minQty > 0 && qtyNum < minQty) { const e: any = new Error(`Min qty is ${minQty}`); e.code = 400; throw e; }

      // Determine effective price
      let effPrice: number;
      if (type === "market") {
        effPrice = Number(pair.lastPrice);
        if (!Number.isFinite(effPrice) || effPrice <= 0) { const e: any = new Error("Market price unavailable"); e.code = 400; throw e; }
      } else {
        effPrice = Number(price);
        if (!Number.isFinite(effPrice) || effPrice <= 0) { const e: any = new Error("limit price required"); e.code = 400; throw e; }
      }

      const fees = await getSpotFeeRates(vipTier);
      const isMarket = type === "market";
      const feeRate = isMarket ? fees.taker : fees.maker;
      const tdsRate = fees.tds;

      // Lock balances
      let baseW: any = null, quoteW: any = null;
      const notional = effPrice * qtyNum;

      if (side === "buy") {
        // Lock quote: notional + (taker fee on notional if market)
        const lockQuote = notional * (isMarket ? (1 + feeRate) : 1);
        quoteW = await ensureWallet(tx, userId, pair.quoteCoinId, "spot");
        const bal = Number(quoteW.balance);
        if (bal < lockQuote) { const e: any = new Error(`Insufficient quote balance (have ${bal.toFixed(8)}, need ${lockQuote.toFixed(8)})`); e.code = 400; throw e; }
        await tx.update(walletsTable).set({
          balance: sql`${walletsTable.balance} - ${lockQuote}`,
          locked: sql`${walletsTable.locked} + ${lockQuote}`,
          updatedAt: new Date(),
        }).where(eq(walletsTable.id, quoteW.id));
      } else {
        // Sell: lock base = qty
        baseW = await ensureWallet(tx, userId, pair.baseCoinId, "spot");
        const bal = Number(baseW.balance);
        if (bal < qtyNum) { const e: any = new Error(`Insufficient base balance (have ${bal.toFixed(8)}, need ${qtyNum.toFixed(8)})`); e.code = 400; throw e; }
        await tx.update(walletsTable).set({
          balance: sql`${walletsTable.balance} - ${qtyNum}`,
          locked: sql`${walletsTable.locked} + ${qtyNum}`,
          updatedAt: new Date(),
        }).where(eq(walletsTable.id, baseW.id));
      }

      const [o] = await tx.insert(ordersTable).values({
        userId, pairId: pair.id, side, type,
        price: String(effPrice), qty: String(qtyNum),
        status: isMarket ? "open" : "open",
      }).returning();

      // Market orders fill immediately at lastPrice
      if (isMarket) {
        const fee = notional * feeRate; // fee+GST in quote currency
        const tds = side === "sell" ? notional * tdsRate : 0; // 1% TDS on sell
        if (side === "buy") {
          // Debit locked quote (notional+fee), credit base (qty)
          const totalDebit = notional + fee;
          await tx.update(walletsTable).set({
            locked: sql`${walletsTable.locked} - ${totalDebit}`,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, quoteW.id));
          const recvBase = await ensureWallet(tx, userId, pair.baseCoinId, "spot");
          await tx.update(walletsTable).set({
            balance: sql`${walletsTable.balance} + ${qtyNum}`,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, recvBase.id));
        } else {
          // Sell: release locked base; credit quote (notional - fee - tds)
          const credit = notional - fee - tds;
          await tx.update(walletsTable).set({
            locked: sql`${walletsTable.locked} - ${qtyNum}`,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, baseW.id));
          const recvQuote = await ensureWallet(tx, userId, pair.quoteCoinId, "spot");
          await tx.update(walletsTable).set({
            balance: sql`${walletsTable.balance} + ${credit}`,
            updatedAt: new Date(),
          }).where(eq(walletsTable.id, recvQuote.id));
        }

        await tx.insert(tradesTable).values({
          orderId: o.id, userId, pairId: pair.id, side,
          price: String(effPrice), qty: String(qtyNum), fee: String(fee),
        });
        const [filled] = await tx.update(ordersTable).set({
          status: "filled", filledQty: String(qtyNum), avgPrice: String(effPrice),
          fee: String(fee), updatedAt: new Date(),
        }).where(eq(ordersTable.id, o.id)).returning();
        return { order: filled, pair, trade: { orderId: o.id, userId, pairId: pair.id, side, price: effPrice, qty: qtyNum, fee, id: 0 } };
      }
      return { order: o, pair, trade: null };
    });
  const { order, pair, trade } = created as any;
  if (order.status === "filled") {
    await pushOrderToRedis(order, pair, "fill");
    if (trade) await pushTradeToRedis(trade, pair);
    return { order, matched: 0 };
  }
  // Add limit order to book then run matching against existing book
  await pushOrderToRedis(order, pair, "new");
  const matchRes = await tryMatch(order.id, { takerVipTier: vipTier });
  if (matchRes.trades > 0) {
    const [refreshed] = await db.select().from(ordersTable).where(eq(ordersTable.id, order.id)).limit(1);
    if (refreshed && refreshed.status === "filled") {
      await pushOrderToRedis(refreshed, pair, "fill");
    } else if (refreshed) {
      // Update redis member to reflect partial fill
      await rSet(`orderbook:${pair.symbol}:order:${refreshed.id}`, JSON.stringify({
        id: refreshed.id, userId: refreshed.userId, side: refreshed.side, type: refreshed.type,
        price: Number(refreshed.price), qty: Number(refreshed.qty),
        filledQty: Number(refreshed.filledQty ?? 0), status: refreshed.status, ts: Date.now(),
      }), 86400);
    }
    return { order: refreshed ?? order, matched: matchRes.trades };
  }
  return { order, matched: 0 };
}

router.post("/orders", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const vipTier = Math.max(0, Math.min(5, req.user!.vipTier ?? 0));
  const parsed = PlaceOrderBody.safeParse(req.body ?? {});
  if (!parsed.success) {
    const first = parsed.error.issues[0];
    res.status(400).json({
      error: first?.message || "Invalid order",
      field: first?.path?.join(".") || "body",
      issues: parsed.error.issues.map((i) => ({ path: i.path.join("."), message: i.message })),
    });
    return;
  }
  const { pairId, side, type, price, qty } = parsed.data;
  try {
    const result = await placeSpotOrder({
      userId, vipTier, pairId, side, type, qty, price,
    });
    res.status(201).json(result.matched > 0 ? { ...result.order, matched: result.matched } : result.order);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

/**
 * Shared spot-order cancellation. Releases locked balance, marks order
 * cancelled, pushes redis update. Throws Error with `.code` on failure.
 */
export async function cancelSpotOrderById(userId: number, id: number): Promise<any> {
  if (!id) { const e: any = new Error("id required"); e.code = 400; throw e; }
  const cancelled = await db.transaction(async (tx) => {
      // SECURITY: never let a real-user request mutate a bot order, even when
      // the bot account currently runs under the same user_id (e.g. admin).
      // Bot orders must only be cancelled by the bot lifecycle / admin tools.
      const [o] = await tx.select().from(ordersTable).where(and(
        eq(ordersTable.id, id),
        eq(ordersTable.userId, userId),
        eq(ordersTable.isBot, 0),
      )).for("update").limit(1);
      if (!o) { const e: any = new Error("Order not found"); e.code = 404; throw e; }
      if (o.status !== "open" && o.status !== "partial") { const e: any = new Error(`Cannot cancel — status is ${o.status}`); e.code = 400; throw e; }
      const [pair] = await tx.select().from(pairsTable).where(eq(pairsTable.id, o.pairId)).limit(1);
      if (!pair) { const e: any = new Error("Pair missing"); e.code = 500; throw e; }
      const remainingQty = Number(o.qty) - Number(o.filledQty);
      const remainingPrice = Number(o.price);
      if (o.side === "buy") {
        // Released amount = remainingQty * price (limit orders don't pre-pay maker fee)
        const release = remainingQty * remainingPrice;
        const w = await ensureWallet(tx, userId, pair.quoteCoinId, "spot");
        await tx.update(walletsTable).set({
          balance: sql`${walletsTable.balance} + ${release}`,
          locked: sql`${walletsTable.locked} - ${release}`,
          updatedAt: new Date(),
        }).where(eq(walletsTable.id, w.id));
      } else {
        const w = await ensureWallet(tx, userId, pair.baseCoinId, "spot");
        await tx.update(walletsTable).set({
          balance: sql`${walletsTable.balance} + ${remainingQty}`,
          locked: sql`${walletsTable.locked} - ${remainingQty}`,
          updatedAt: new Date(),
        }).where(eq(walletsTable.id, w.id));
      }
      const [updated] = await tx.update(ordersTable).set({ status: "cancelled", updatedAt: new Date() }).where(eq(ordersTable.id, id)).returning();
      return { order: updated, pair };
  });
  const { order, pair } = cancelled as any;
  await pushOrderToRedis(order, pair, "cancel");
  return order;
}

router.post("/orders/:id/cancel", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const id = Number(req.params.id);
  try {
    const order = await cancelSpotOrderById(userId, id);
    res.json(order);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

// ====== Public orderbook + recent trades from Redis ======
router.get("/orderbook/:symbol", async (req, res): Promise<void> => {
  const symbol = String(req.params.symbol || "").toUpperCase();
  const levels = Math.min(100, Math.max(5, Number(req.query.levels) || 20));
  const depth = await getDepth(symbol, levels);
  res.setHeader("X-Cache", "REDIS");
  res.json({ symbol, ...depth, ts: Date.now() });
});

router.get("/trades/:symbol/recent", async (req, res): Promise<void> => {
  const symbol = String(req.params.symbol || "").toUpperCase();
  const limit = Math.min(200, Math.max(1, Number(req.query.limit) || 50));
  const trades = await getRecentTrades(symbol, limit);
  res.setHeader("X-Cache", "REDIS");
  res.json({ symbol, trades, ts: Date.now() });
});

void coinsTable;
export default router;
