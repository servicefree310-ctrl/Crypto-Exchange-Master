import { Router, type IRouter } from "express";
import { sql, eq, desc, and } from "drizzle-orm";
import {
  db,
  usersTable,
  coinsTable,
  networksTable,
  pairsTable,
  gatewaysTable,
  inrDepositsTable,
  inrWithdrawalsTable,
  cryptoDepositsTable,
  cryptoWithdrawalsTable,
  kycRecordsTable,
  kycSettingsTable,
  bankAccountsTable,
  walletsTable,
  earnProductsTable,
  earnPositionsTable,
  legalPagesTable,
  settingsTable,
  ordersTable,
  loginLogsTable,
  otpProvidersTable,
  chatThreadsTable,
  chatMessagesTable,
  marketBotsTable,
  tradesTable,
} from "@workspace/db";
import { requireRole } from "../middlewares/auth";
import { sanitizeUser } from "../lib/auth";

const router: IRouter = Router();
const adminOnly = requireRole("admin", "superadmin");
const supportPlus = requireRole("admin", "superadmin", "support");

// Dashboard stats
router.get("/admin/stats", supportPlus, async (_req, res): Promise<void> => {
  const [users] = await db.select({ c: sql<number>`count(*)::int` }).from(usersTable);
  const [coins] = await db.select({ c: sql<number>`count(*)::int` }).from(coinsTable);
  const [pairs] = await db.select({ c: sql<number>`count(*)::int` }).from(pairsTable);
  const [pendingKyc] = await db
    .select({ c: sql<number>`count(*)::int` })
    .from(kycRecordsTable)
    .where(eq(kycRecordsTable.status, "pending"));
  const [pendingDeposits] = await db
    .select({ c: sql<number>`count(*)::int` })
    .from(inrDepositsTable)
    .where(eq(inrDepositsTable.status, "pending"));
  const [pendingWithdrawals] = await db
    .select({ c: sql<number>`count(*)::int` })
    .from(inrWithdrawalsTable)
    .where(eq(inrWithdrawalsTable.status, "pending"));
  const [pendingBanks] = await db
    .select({ c: sql<number>`count(*)::int` })
    .from(bankAccountsTable)
    .where(eq(bankAccountsTable.status, "under_review"));
  const [openOrders] = await db
    .select({ c: sql<number>`count(*)::int` })
    .from(ordersTable)
    .where(eq(ordersTable.status, "open"));

  res.json({
    users: users?.c ?? 0,
    coins: coins?.c ?? 0,
    pairs: pairs?.c ?? 0,
    pendingKyc: pendingKyc?.c ?? 0,
    pendingDeposits: pendingDeposits?.c ?? 0,
    pendingWithdrawals: pendingWithdrawals?.c ?? 0,
    pendingBanks: pendingBanks?.c ?? 0,
    openOrders: openOrders?.c ?? 0,
  });
});

// Users
router.get("/admin/users", supportPlus, async (_req, res): Promise<void> => {
  const rows = await db.select().from(usersTable).orderBy(desc(usersTable.createdAt)).limit(500);
  res.json(rows.map(sanitizeUser));
});

router.patch("/admin/users/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const allowed: Record<string, unknown> = {};
  for (const k of ["role", "status", "kycLevel", "vipTier", "name"]) {
    if (k in (req.body ?? {})) allowed[k] = req.body[k];
  }
  if (Object.keys(allowed).length === 0) {
    res.status(400).json({ error: "No fields to update" });
    return;
  }
  const [user] = await db.update(usersTable).set(allowed).where(eq(usersTable.id, id)).returning();
  if (!user) {
    res.status(404).json({ error: "User not found" });
    return;
  }
  res.json(sanitizeUser(user));
});

// Coins CRUD
router.get("/admin/coins", supportPlus, async (_req, res): Promise<void> => {
  const rows = await db.select().from(coinsTable).orderBy(desc(coinsTable.createdAt));
  res.json(rows);
});
router.post("/admin/coins", adminOnly, async (req, res): Promise<void> => {
  const b = req.body ?? {};
  if (!b.symbol || !b.name) {
    res.status(400).json({ error: "symbol and name required" });
    return;
  }
  const [coin] = await db.insert(coinsTable).values({
    symbol: String(b.symbol).toUpperCase(),
    name: b.name,
    type: b.type ?? "crypto",
    decimals: b.decimals ?? 8,
    logoUrl: b.logoUrl ?? null,
    description: b.description ?? null,
    status: b.status ?? "active",
    isListed: b.isListed ?? true,
    listingAt: b.listingAt ? new Date(b.listingAt) : null,
    currentPrice: b.currentPrice ?? "0",
    binanceSymbol: b.binanceSymbol ?? null,
    priceSource: b.priceSource ?? "binance",
    manualPrice: b.manualPrice !== undefined && b.manualPrice !== null ? String(b.manualPrice) : null,
    infoUrl: b.infoUrl ?? null,
  }).returning();
  res.status(201).json(coin);
});
router.patch("/admin/coins/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const b: Record<string, any> = { ...req.body };
  delete b.id; delete b.createdAt; delete b.updatedAt;
  if (b.listingAt) b.listingAt = new Date(b.listingAt);
  if (b.manualPrice !== undefined && b.manualPrice !== null) b.manualPrice = String(b.manualPrice);
  const [coin] = await db.update(coinsTable).set(b).where(eq(coinsTable.id, id)).returning();
  if (!coin) { res.status(404).json({ error: "Not found" }); return; }
  res.json(coin);
});
router.delete("/admin/coins/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  await db.delete(coinsTable).where(eq(coinsTable.id, id));
  res.sendStatus(204);
});

// Networks
router.get("/admin/networks", supportPlus, async (req, res): Promise<void> => {
  const coinId = req.query.coinId ? Number(req.query.coinId) : null;
  const rows = coinId
    ? await db.select().from(networksTable).where(eq(networksTable.coinId, coinId))
    : await db.select().from(networksTable);
  res.json(rows);
});
router.post("/admin/networks", adminOnly, async (req, res): Promise<void> => {
  const b = req.body ?? {};
  if (!b.coinId || !b.name || !b.chain) {
    res.status(400).json({ error: "coinId, name, chain required" });
    return;
  }
  const [n] = await db.insert(networksTable).values({
    coinId: Number(b.coinId),
    name: b.name,
    chain: b.chain,
    contractAddress: b.contractAddress ?? null,
    minDeposit: String(b.minDeposit ?? "0"),
    minWithdraw: String(b.minWithdraw ?? "0"),
    withdrawFee: String(b.withdrawFee ?? "0"),
    confirmations: Number(b.confirmations ?? 12),
    depositEnabled: b.depositEnabled ?? true,
    withdrawEnabled: b.withdrawEnabled ?? true,
    nodeAddress: b.nodeAddress ?? null,
    memoRequired: b.memoRequired ?? false,
  }).returning();
  res.status(201).json(n);
});
router.patch("/admin/networks/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const [n] = await db.update(networksTable).set(req.body).where(eq(networksTable.id, id)).returning();
  if (!n) { res.status(404).json({ error: "Not found" }); return; }
  res.json(n);
});
router.delete("/admin/networks/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  await db.delete(networksTable).where(eq(networksTable.id, id));
  res.sendStatus(204);
});

// Pairs
router.get("/admin/pairs", supportPlus, async (_req, res): Promise<void> => {
  const rows = await db.select().from(pairsTable).orderBy(desc(pairsTable.createdAt));
  res.json(rows);
});
router.post("/admin/pairs", adminOnly, async (req, res): Promise<void> => {
  const b = req.body ?? {};
  if (!b.symbol || !b.baseCoinId || !b.quoteCoinId) {
    res.status(400).json({ error: "symbol, baseCoinId, quoteCoinId required" });
    return;
  }
  const [p] = await db.insert(pairsTable).values({
    symbol: String(b.symbol).toUpperCase(),
    baseCoinId: Number(b.baseCoinId),
    quoteCoinId: Number(b.quoteCoinId),
    minQty: String(b.minQty ?? "0"),
    maxQty: String(b.maxQty ?? "0"),
    pricePrecision: Number(b.pricePrecision ?? 2),
    qtyPrecision: Number(b.qtyPrecision ?? 4),
    takerFee: String(b.takerFee ?? "0.001"),
    makerFee: String(b.makerFee ?? "0.001"),
    tradingEnabled: b.tradingEnabled ?? true,
    futuresEnabled: b.futuresEnabled ?? false,
    tradingStartAt: b.tradingStartAt ? new Date(b.tradingStartAt) : null,
    futuresStartAt: b.futuresStartAt ? new Date(b.futuresStartAt) : null,
    description: b.description ?? null,
    status: b.status ?? "active",
  }).returning();
  res.status(201).json(p);
});
router.patch("/admin/pairs/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const b: Record<string, any> = { ...req.body };
  delete b.id; delete b.createdAt;
  if (b.tradingStartAt) b.tradingStartAt = new Date(b.tradingStartAt);
  if (b.futuresStartAt) b.futuresStartAt = new Date(b.futuresStartAt);
  for (const k of ["minQty", "maxQty", "takerFee", "makerFee", "lastPrice", "volume24h", "change24h"]) {
    if (b[k] !== undefined && b[k] !== null) b[k] = String(b[k]);
  }
  const [p] = await db.update(pairsTable).set(b).where(eq(pairsTable.id, id)).returning();
  if (!p) { res.status(404).json({ error: "Not found" }); return; }
  res.json(p);
});
router.delete("/admin/pairs/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  await db.delete(pairsTable).where(eq(pairsTable.id, id));
  res.sendStatus(204);
});

// Market-Maker Bots
router.get("/admin/bots", adminOnly, async (_req, res): Promise<void> => {
  const rows = await db.select().from(marketBotsTable).orderBy(desc(marketBotsTable.createdAt));
  res.json(rows);
});
router.post("/admin/bots", adminOnly, async (req, res): Promise<void> => {
  const b = req.body ?? {};
  if (!b.pairId) { res.status(400).json({ error: "pairId required" }); return; }
  try {
    const [row] = await db.insert(marketBotsTable).values({
      pairId: Number(b.pairId),
      enabled: !!b.enabled,
      spreadBps: Number(b.spreadBps ?? 20),
      levels: Number(b.levels ?? 5),
      priceStepBps: Number(b.priceStepBps ?? 10),
      orderSize: String(b.orderSize ?? "0.01"),
      refreshSec: Number(b.refreshSec ?? 8),
      maxOrderAgeSec: Number(b.maxOrderAgeSec ?? 60),
      fillOnCross: b.fillOnCross !== false,
    }).returning();
    res.status(201).json(row);
  } catch (e: any) {
    res.status(400).json({ error: e?.message?.includes("unique") ? "Bot already exists for this pair" : "Failed to create bot" });
  }
});
router.patch("/admin/bots/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const allowed = ["enabled", "spreadBps", "levels", "priceStepBps", "orderSize", "refreshSec", "maxOrderAgeSec", "fillOnCross"];
  const b: Record<string, any> = {};
  for (const k of allowed) if (req.body[k] !== undefined) b[k] = req.body[k];
  if (b.orderSize !== undefined) b.orderSize = String(b.orderSize);
  for (const k of ["spreadBps", "levels", "priceStepBps", "refreshSec", "maxOrderAgeSec"]) {
    if (b[k] !== undefined) b[k] = Number(b[k]);
  }
  if (Object.keys(b).length === 0) { res.status(400).json({ error: "No updatable fields" }); return; }
  const [row] = await db.update(marketBotsTable).set(b).where(eq(marketBotsTable.id, id)).returning();
  if (!row) { res.status(404).json({ error: "Not found" }); return; }
  res.json(row);
});
router.delete("/admin/bots/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  await db.delete(marketBotsTable).where(eq(marketBotsTable.id, id));
  res.sendStatus(204);
});

// Orders & Trades (read-only for admin)
router.get("/admin/orders", supportPlus, async (req, res): Promise<void> => {
  const q = req.query as Record<string, string>;
  const conds: any[] = [];
  if (q.status) conds.push(eq(ordersTable.status, q.status));
  if (q.side) conds.push(eq(ordersTable.side, q.side));
  if (q.pairId) conds.push(eq(ordersTable.pairId, Number(q.pairId)));
  if (q.userId) conds.push(eq(ordersTable.userId, Number(q.userId)));
  if (q.isBot === "1") conds.push(sql`${ordersTable.isBot} = 1`);
  if (q.isBot === "0") conds.push(sql`${ordersTable.isBot} = 0`);
  const limit = Math.min(Number(q.limit ?? 200), 500);
  const where = conds.length ? and(...conds) : undefined;
  const rows = where
    ? await db.select().from(ordersTable).where(where).orderBy(desc(ordersTable.id)).limit(limit)
    : await db.select().from(ordersTable).orderBy(desc(ordersTable.id)).limit(limit);
  res.json(rows);
});

router.get("/admin/orders/stats", supportPlus, async (_req, res): Promise<void> => {
  const stats = await db.execute(sql`
    SELECT
      COUNT(*)::int AS total,
      COUNT(*) FILTER (WHERE status = 'open')::int AS open_count,
      COUNT(*) FILTER (WHERE status = 'filled')::int AS filled_count,
      COUNT(*) FILTER (WHERE status = 'cancelled')::int AS cancelled_count,
      COUNT(*) FILTER (WHERE side = 'buy')::int AS buy_count,
      COUNT(*) FILTER (WHERE side = 'sell')::int AS sell_count,
      COUNT(*) FILTER (WHERE is_bot = 1)::int AS bot_count,
      COUNT(*) FILTER (WHERE is_bot = 0)::int AS user_count,
      COUNT(*) FILTER (WHERE status = 'filled' AND is_bot = 1)::int AS bot_filled,
      COUNT(*) FILTER (WHERE status = 'filled' AND is_bot = 0)::int AS user_filled,
      COALESCE(SUM(filled_qty * avg_price) FILTER (WHERE status = 'filled'), 0) AS filled_value
    FROM orders
  `);
  res.json((stats as any).rows?.[0] ?? stats[0] ?? {});
});

router.get("/admin/trades", supportPlus, async (req, res): Promise<void> => {
  const q = req.query as Record<string, string>;
  const conds: any[] = [];
  if (q.pairId) conds.push(eq(tradesTable.pairId, Number(q.pairId)));
  if (q.userId) conds.push(eq(tradesTable.userId, Number(q.userId)));
  if (q.side) conds.push(eq(tradesTable.side, q.side));
  const limit = Math.min(Number(q.limit ?? 200), 500);
  const where = conds.length ? and(...conds) : undefined;
  const rows = where
    ? await db.select().from(tradesTable).where(where).orderBy(desc(tradesTable.id)).limit(limit)
    : await db.select().from(tradesTable).orderBy(desc(tradesTable.id)).limit(limit);
  res.json(rows);
});

// Gateways
router.get("/admin/gateways", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(gatewaysTable).orderBy(desc(gatewaysTable.createdAt)));
});
router.post("/admin/gateways", adminOnly, async (req, res): Promise<void> => {
  const b = req.body ?? {};
  if (!b.code || !b.name || !b.type || !b.direction) {
    res.status(400).json({ error: "code, name, type, direction required" });
    return;
  }
  const [g] = await db.insert(gatewaysTable).values({
    code: b.code,
    name: b.name,
    type: b.type,
    direction: b.direction,
    minAmount: String(b.minAmount ?? "0"),
    maxAmount: String(b.maxAmount ?? "0"),
    feeFlat: String(b.feeFlat ?? "0"),
    feePercent: String(b.feePercent ?? "0"),
    processingTime: b.processingTime ?? "Instant",
    isAuto: b.isAuto ?? false,
    status: b.status ?? "active",
    config: typeof b.config === "string" ? b.config : JSON.stringify(b.config ?? {}),
  }).returning();
  res.status(201).json(g);
});
router.patch("/admin/gateways/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const b = { ...req.body };
  if (b.config && typeof b.config !== "string") b.config = JSON.stringify(b.config);
  const [g] = await db.update(gatewaysTable).set(b).where(eq(gatewaysTable.id, id)).returning();
  if (!g) { res.status(404).json({ error: "Not found" }); return; }
  res.json(g);
});
router.delete("/admin/gateways/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  await db.delete(gatewaysTable).where(eq(gatewaysTable.id, id));
  res.sendStatus(204);
});

// KYC moderation
router.get("/admin/kyc", supportPlus, async (req, res): Promise<void> => {
  const status = (req.query.status as string) || null;
  const rows = status
    ? await db.select().from(kycRecordsTable).where(eq(kycRecordsTable.status, status)).orderBy(desc(kycRecordsTable.createdAt))
    : await db.select().from(kycRecordsTable).orderBy(desc(kycRecordsTable.createdAt));
  res.json(rows);
});
router.patch("/admin/kyc/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const { status, rejectReason } = req.body ?? {};
  if (!["approved", "rejected", "pending"].includes(status)) {
    res.status(400).json({ error: "Invalid status" }); return;
  }
  const [rec] = await db.update(kycRecordsTable).set({
    status,
    rejectReason: rejectReason ?? null,
    reviewedBy: req.user!.id,
    reviewedAt: new Date(),
  }).where(eq(kycRecordsTable.id, id)).returning();
  if (!rec) { res.status(404).json({ error: "Not found" }); return; }
  if (status === "approved") {
    // Monotonic: never lower a user's KYC level
    await db.update(usersTable)
      .set({ kycLevel: sql`GREATEST(${usersTable.kycLevel}, ${rec.level})` })
      .where(eq(usersTable.id, rec.userId));
  }
  res.json(rec);
});
router.get("/admin/kyc-settings", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(kycSettingsTable).orderBy(kycSettingsTable.level));
});
router.patch("/admin/kyc-settings/:level", adminOnly, async (req, res): Promise<void> => {
  const level = Number(Array.isArray(req.params.level) ? req.params.level[0] : req.params.level);
  const [s] = await db.update(kycSettingsTable).set(req.body).where(eq(kycSettingsTable.level, level)).returning();
  if (!s) { res.status(404).json({ error: "Not found" }); return; }
  res.json(s);
});

// Bank approvals
router.get("/admin/banks", supportPlus, async (req, res): Promise<void> => {
  const status = (req.query.status as string) || null;
  const rows = status
    ? await db.select().from(bankAccountsTable).where(eq(bankAccountsTable.status, status)).orderBy(desc(bankAccountsTable.createdAt))
    : await db.select().from(bankAccountsTable).orderBy(desc(bankAccountsTable.createdAt));
  res.json(rows);
});
router.patch("/admin/banks/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const { status, rejectReason } = req.body ?? {};
  if (!["verified", "rejected", "under_review"].includes(status)) {
    res.status(400).json({ error: "Invalid status" }); return;
  }
  const [b] = await db.update(bankAccountsTable).set({
    status,
    rejectReason: rejectReason ?? null,
    reviewedBy: req.user!.id,
    verifiedAt: status === "verified" ? new Date() : null,
  }).where(eq(bankAccountsTable.id, id)).returning();
  if (!b) { res.status(404).json({ error: "Not found" }); return; }
  res.json(b);
});

// INR deposits/withdrawals approval
router.get("/admin/inr-deposits", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(inrDepositsTable).orderBy(desc(inrDepositsTable.createdAt)).limit(500));
});
router.patch("/admin/inr-deposits/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const { status, notes } = req.body ?? {};
  if (!["completed", "rejected", "pending"].includes(status)) {
    res.status(400).json({ error: "Invalid status" }); return;
  }
  try {
    const updated = await db.transaction(async (tx) => {
      const [current] = await tx.select().from(inrDepositsTable).where(eq(inrDepositsTable.id, id)).for("update").limit(1);
      if (!current) { const e: any = new Error("Not found"); e.code = 404; throw e; }
      if (current.status === status) return current;
      // Money movement only when transitioning into 'completed'
      if (status === "completed" && current.status !== "completed") {
        const [inrCoin] = await tx.select().from(coinsTable).where(eq(coinsTable.symbol, "INR")).limit(1);
        if (!inrCoin) { const e: any = new Error("INR coin not configured"); e.code = 500; throw e; }
        const [w] = await tx.select().from(walletsTable)
          .where(and(eq(walletsTable.userId, current.userId), eq(walletsTable.coinId, inrCoin.id), eq(walletsTable.walletType, "inr")))
          .for("update").limit(1);
        if (!w) { const e: any = new Error("INR wallet not found for user"); e.code = 500; throw e; }
        const credit = Number(current.amount) - Number(current.fee || 0);
        await tx.update(walletsTable).set({
          balance: sql`${walletsTable.balance} + ${credit}`,
          updatedAt: new Date(),
        }).where(eq(walletsTable.id, w.id));
      }
      const [d] = await tx.update(inrDepositsTable).set({
        status, notes: notes ?? null, reviewedBy: req.user!.id, processedAt: new Date(),
      }).where(eq(inrDepositsTable.id, id)).returning();
      return d;
    });
    res.json(updated);
  } catch (e: any) {
    if (e?.code === 404) { res.status(404).json({ error: e.message }); return; }
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

router.get("/admin/inr-withdrawals", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(inrWithdrawalsTable).orderBy(desc(inrWithdrawalsTable.createdAt)).limit(500));
});
router.patch("/admin/inr-withdrawals/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const { status, rejectReason } = req.body ?? {};
  if (!["completed", "rejected", "pending"].includes(status)) {
    res.status(400).json({ error: "Invalid status" }); return;
  }
  try {
    const updated = await db.transaction(async (tx) => {
      const [current] = await tx.select().from(inrWithdrawalsTable).where(eq(inrWithdrawalsTable.id, id)).for("update").limit(1);
      if (!current) { const e: any = new Error("Not found"); e.code = 404; throw e; }
      if (current.status === status) return current;
      if (current.status !== "pending") {
        const e: any = new Error("Can only update pending withdrawals"); e.code = 400; throw e;
      }
      const [inrCoin] = await tx.select().from(coinsTable).where(eq(coinsTable.symbol, "INR")).limit(1);
      const [w] = await tx.select().from(walletsTable)
        .where(and(eq(walletsTable.userId, current.userId), eq(walletsTable.coinId, inrCoin!.id), eq(walletsTable.walletType, "inr")))
        .for("update").limit(1);
      if (!w) { const e: any = new Error("INR wallet not found"); e.code = 500; throw e; }
      const amt = Number(current.amount);
      if (status === "completed") {
        // money out → reduce locked
        await tx.update(walletsTable).set({
          locked: sql`${walletsTable.locked} - ${amt}`,
          updatedAt: new Date(),
        }).where(eq(walletsTable.id, w.id));
      } else if (status === "rejected") {
        // refund: locked → balance
        await tx.update(walletsTable).set({
          locked: sql`${walletsTable.locked} - ${amt}`,
          balance: sql`${walletsTable.balance} + ${amt}`,
          updatedAt: new Date(),
        }).where(eq(walletsTable.id, w.id));
      }
      const [updatedRow] = await tx.update(inrWithdrawalsTable).set({
        status, rejectReason: rejectReason ?? null, reviewedBy: req.user!.id, processedAt: new Date(),
      }).where(eq(inrWithdrawalsTable.id, id)).returning();
      return updatedRow;
    });
    res.json(updated);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

router.get("/admin/crypto-deposits", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(cryptoDepositsTable).orderBy(desc(cryptoDepositsTable.createdAt)).limit(500));
});
router.patch("/admin/crypto-deposits/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const { status, confirmations } = req.body ?? {};
  if (!["completed", "rejected", "pending"].includes(status)) {
    res.status(400).json({ error: "Invalid status" }); return;
  }
  try {
    const updated = await db.transaction(async (tx) => {
      const [current] = await tx.select().from(cryptoDepositsTable).where(eq(cryptoDepositsTable.id, id)).for("update").limit(1);
      if (!current) { const e: any = new Error("Not found"); e.code = 404; throw e; }
      if (current.status === status) return current;
      if (current.status !== "pending") {
        const e: any = new Error("Can only transition pending deposits"); e.code = 400; throw e;
      }
      // Credit on completion — atomic upsert keyed on the (userId, walletType, coinId) unique index
      if (status === "completed") {
        const amt = Number(current.amount);
        await tx.insert(walletsTable).values({
          userId: current.userId, coinId: current.coinId, walletType: "spot",
          balance: String(amt), locked: "0",
        }).onConflictDoUpdate({
          target: [walletsTable.userId, walletsTable.walletType, walletsTable.coinId],
          set: { balance: sql`${walletsTable.balance} + ${amt}`, updatedAt: new Date() },
        });
      }
      const [d] = await tx.update(cryptoDepositsTable).set({
        status,
        confirmations: typeof confirmations === "number" ? confirmations : current.confirmations,
        processedAt: new Date(),
      }).where(eq(cryptoDepositsTable.id, id)).returning();
      return d;
    });
    res.json(updated);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});
router.get("/admin/crypto-withdrawals", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(cryptoWithdrawalsTable).orderBy(desc(cryptoWithdrawalsTable.createdAt)).limit(500));
});
router.patch("/admin/crypto-withdrawals/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const { status, txHash, rejectReason } = req.body ?? {};
  if (!["completed", "rejected", "pending"].includes(status)) {
    res.status(400).json({ error: "Invalid status" }); return;
  }
  try {
    const updated = await db.transaction(async (tx) => {
      const [current] = await tx.select().from(cryptoWithdrawalsTable).where(eq(cryptoWithdrawalsTable.id, id)).for("update").limit(1);
      if (!current) { const e: any = new Error("Not found"); e.code = 404; throw e; }
      if (current.status === status) return current;
      if (current.status !== "pending") {
        const e: any = new Error("Can only update pending withdrawals"); e.code = 400; throw e;
      }
      const [w] = await tx.select().from(walletsTable)
        .where(and(eq(walletsTable.userId, current.userId), eq(walletsTable.coinId, current.coinId), eq(walletsTable.walletType, "spot")))
        .for("update").limit(1);
      if (!w) { const e: any = new Error("Spot wallet not found"); e.code = 500; throw e; }
      const amt = Number(current.amount);
      if (status === "completed") {
        await tx.update(walletsTable).set({
          locked: sql`${walletsTable.locked} - ${amt}`,
          updatedAt: new Date(),
        }).where(eq(walletsTable.id, w.id));
      } else if (status === "rejected") {
        await tx.update(walletsTable).set({
          locked: sql`${walletsTable.locked} - ${amt}`,
          balance: sql`${walletsTable.balance} + ${amt}`,
          updatedAt: new Date(),
        }).where(eq(walletsTable.id, w.id));
      }
      const [updatedRow] = await tx.update(cryptoWithdrawalsTable).set({
        status, txHash: txHash ?? null, rejectReason: rejectReason ?? null,
        reviewedBy: req.user!.id, processedAt: new Date(),
      }).where(eq(cryptoWithdrawalsTable.id, id)).returning();
      return updatedRow;
    });
    res.json(updated);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

// Earn products
router.get("/admin/earn-products", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(earnProductsTable).orderBy(desc(earnProductsTable.createdAt)));
});
router.post("/admin/earn-products", adminOnly, async (req, res): Promise<void> => {
  const b = req.body ?? {};
  if (!b.coinId || !b.type || b.apy === undefined) {
    res.status(400).json({ error: "coinId, type, apy required" }); return;
  }
  const [p] = await db.insert(earnProductsTable).values({
    coinId: Number(b.coinId),
    type: b.type,
    durationDays: Number(b.durationDays ?? 0),
    apy: String(b.apy),
    minAmount: String(b.minAmount ?? "0"),
    maxAmount: String(b.maxAmount ?? "0"),
    status: b.status ?? "active",
  }).returning();
  res.status(201).json(p);
});
router.patch("/admin/earn-products/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const [p] = await db.update(earnProductsTable).set(req.body).where(eq(earnProductsTable.id, id)).returning();
  if (!p) { res.status(404).json({ error: "Not found" }); return; }
  res.json(p);
});
router.delete("/admin/earn-products/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  await db.delete(earnProductsTable).where(eq(earnProductsTable.id, id));
  res.sendStatus(204);
});
router.get("/admin/earn-positions", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(earnPositionsTable).orderBy(desc(earnPositionsTable.startedAt)).limit(500));
});

// Legal CMS
router.get("/admin/legal", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(legalPagesTable));
});
router.put("/admin/legal/:slug", adminOnly, async (req, res): Promise<void> => {
  const slug = Array.isArray(req.params.slug) ? req.params.slug[0] : req.params.slug;
  const { title, content } = req.body ?? {};
  if (!slug || !title) { res.status(400).json({ error: "slug & title required" }); return; }
  const existing = await db.select().from(legalPagesTable).where(eq(legalPagesTable.slug, slug)).limit(1);
  if (existing.length === 0) {
    const [p] = await db.insert(legalPagesTable).values({ slug, title, content: content ?? "", updatedBy: req.user!.id }).returning();
    res.status(201).json(p); return;
  }
  const [p] = await db.update(legalPagesTable).set({ title, content: content ?? "", updatedBy: req.user!.id }).where(eq(legalPagesTable.slug, slug)).returning();
  res.json(p);
});

// Settings
router.get("/admin/settings", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(settingsTable));
});
router.put("/admin/settings/:key", adminOnly, async (req, res): Promise<void> => {
  const key = Array.isArray(req.params.key) ? req.params.key[0] : req.params.key;
  const { value } = req.body ?? {};
  if (!key) { res.status(400).json({ error: "key required" }); return; }
  const v = typeof value === "string" ? value : JSON.stringify(value ?? null);
  const existing = await db.select().from(settingsTable).where(eq(settingsTable.key, key)).limit(1);
  if (existing.length === 0) {
    const [s] = await db.insert(settingsTable).values({ key, value: v }).returning();
    res.status(201).json(s); return;
  }
  const [s] = await db.update(settingsTable).set({ value: v }).where(eq(settingsTable.key, key)).returning();
  res.json(s);
});

// OTP providers
router.get("/admin/otp-providers", adminOnly, async (_req, res): Promise<void> => {
  res.json(await db.select().from(otpProvidersTable));
});
router.post("/admin/otp-providers", adminOnly, async (req, res): Promise<void> => {
  const b = req.body ?? {};
  if (!b.channel || !b.provider) { res.status(400).json({ error: "channel & provider required" }); return; }
  const [p] = await db.insert(otpProvidersTable).values({
    channel: b.channel, provider: b.provider, apiKey: b.apiKey ?? null, apiSecret: b.apiSecret ?? null,
    senderId: b.senderId ?? null, template: b.template ?? null, isActive: b.isActive ?? false,
  }).returning();
  res.status(201).json(p);
});
router.patch("/admin/otp-providers/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const [p] = await db.update(otpProvidersTable).set(req.body).where(eq(otpProvidersTable.id, id)).returning();
  if (!p) { res.status(404).json({ error: "Not found" }); return; }
  res.json(p);
});
router.delete("/admin/otp-providers/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  await db.delete(otpProvidersTable).where(eq(otpProvidersTable.id, id));
  res.sendStatus(204);
});

// Login logs
router.get("/admin/login-logs", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(loginLogsTable).orderBy(desc(loginLogsTable.createdAt)).limit(500));
});

// Chat
router.get("/admin/chat-threads", supportPlus, async (_req, res): Promise<void> => {
  res.json(await db.select().from(chatThreadsTable).orderBy(desc(chatThreadsTable.lastMessageAt)).limit(200));
});
router.get("/admin/chat-threads/:id/messages", supportPlus, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  res.json(await db.select().from(chatMessagesTable).where(eq(chatMessagesTable.threadId, id)).orderBy(chatMessagesTable.createdAt));
});
router.post("/admin/chat-threads/:id/messages", supportPlus, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const message = String(req.body?.message ?? "").trim();
  if (!message) { res.status(400).json({ error: "message required" }); return; }
  const [m] = await db.insert(chatMessagesTable).values({
    threadId: id, senderId: req.user!.id, senderRole: "support", message,
  }).returning();
  await db.update(chatThreadsTable).set({ lastMessageAt: new Date(), assigneeId: req.user!.id }).where(eq(chatThreadsTable.id, id));
  res.status(201).json(m);
});
router.patch("/admin/chat-threads/:id", supportPlus, async (req, res): Promise<void> => {
  const id = Number(Array.isArray(req.params.id) ? req.params.id[0] : req.params.id);
  const [t] = await db.update(chatThreadsTable).set(req.body).where(eq(chatThreadsTable.id, id)).returning();
  if (!t) { res.status(404).json({ error: "Not found" }); return; }
  res.json(t);
});

void and;
export default router;
