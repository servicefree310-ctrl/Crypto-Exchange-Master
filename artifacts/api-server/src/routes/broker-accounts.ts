/**
 * Angel One Sub-broker Account System
 *
 *   GET    /broker/account               — get my broker account status
 *   POST   /broker/account               — create / update application (draft)
 *   POST   /broker/account/submit        — submit for review
 *   GET    /broker/account/kyc           — list my KYC docs
 *   POST   /broker/account/kyc           — upload a KYC doc (base64)
 *   GET    /broker/portfolio             — my holdings
 *   GET    /broker/orders                — my broker orders
 *   POST   /broker/orders               — place order via AP
 *
 *   Admin:
 *   GET    /admin/broker-applications    — all applications
 *   PATCH  /admin/broker-applications/:id/approve
 *   PATCH  /admin/broker-applications/:id/reject
 *   PATCH  /admin/broker-applications/:id/kyc/:docId
 *   GET    /admin/broker-applications/:id
 */
import { Router, type IRouter } from "express";
import { eq, desc, and } from "drizzle-orm";
import {
  db,
  brokerAccountsTable,
  brokerKycDocsTable,
  brokerOrdersTable,
  brokerPortfolioTable,
  instrumentsTable,
} from "@workspace/db";
import { requireAuth, requireRole } from "../middlewares/auth";
import { logAdminAction } from "../lib/audit";
import { getQuote } from "../lib/angel-one-adapter";

const router: IRouter = Router();
const ADMIN_GUARD = [requireAuth, requireRole("admin", "superadmin")];

// ─── Helpers ──────────────────────────────────────────────────────────────────
function uid(req: any): number { return req.user!.id as number; }

async function getOrCreateAccount(userId: number) {
  const [existing] = await db.select().from(brokerAccountsTable)
    .where(eq(brokerAccountsTable.userId, userId)).limit(1);
  if (existing) return existing;
  const [created] = await db.insert(brokerAccountsTable)
    .values({ userId, status: "draft" }).returning();
  return created;
}

// ─── GET /broker/account ──────────────────────────────────────────────────────
router.get("/broker/account", requireAuth, async (req, res): Promise<void> => {
  const account = await getOrCreateAccount(uid(req));
  const kyc = await db.select().from(brokerKycDocsTable)
    .where(eq(brokerKycDocsTable.brokerAccountId, account.id))
    .orderBy(desc(brokerKycDocsTable.uploadedAt));
  res.json({ account, kyc });
});

// ─── POST /broker/account (save draft) ───────────────────────────────────────
router.post("/broker/account", requireAuth, async (req, res): Promise<void> => {
  const account = await getOrCreateAccount(uid(req));
  if (account.status !== "draft" && account.status !== "rejected") {
    res.status(400).json({ error: "Cannot edit account in current status" }); return;
  }
  const allowed = [
    "fullName","dob","gender","fatherName","motherName","maritalStatus",
    "annualIncome","occupation","mobile","email","address","city","state","pincode",
    "panNumber","aadharNumber","bankAccountNo","bankIfsc","bankName","bankAccountType",
    "segmentEquity","segmentFno","segmentCommodity","segmentCurrency",
    "nomineeName","nomineeRelation","nomineeDob",
  ];
  const update: Record<string, unknown> = { updatedAt: new Date() };
  for (const key of allowed) {
    if (req.body[key] !== undefined) update[key as keyof typeof update] = req.body[key];
  }
  const [updated] = await db.update(brokerAccountsTable).set(update as any)
    .where(eq(brokerAccountsTable.id, account.id)).returning();
  res.json({ account: updated });
});

// ─── POST /broker/account/submit ─────────────────────────────────────────────
router.post("/broker/account/submit", requireAuth, async (req, res): Promise<void> => {
  const account = await getOrCreateAccount(uid(req));
  if (account.status !== "draft" && account.status !== "rejected") {
    res.status(400).json({ error: "Already submitted" }); return;
  }
  // Basic validation
  const required = ["fullName","dob","panNumber","mobile","email","bankAccountNo","bankIfsc","address","city","state","pincode"];
  const missing = required.filter(k => !account[k as keyof typeof account]);
  if (missing.length > 0) {
    res.status(400).json({ error: "Missing required fields", missing }); return;
  }
  const [updated] = await db.update(brokerAccountsTable)
    .set({ status: "submitted", submittedAt: new Date(), updatedAt: new Date(), rejectionReason: null })
    .where(eq(brokerAccountsTable.id, account.id)).returning();
  res.json({ account: updated, message: "Application submitted for review" });
});

// ─── GET /broker/account/kyc ─────────────────────────────────────────────────
router.get("/broker/account/kyc", requireAuth, async (req, res): Promise<void> => {
  const account = await getOrCreateAccount(uid(req));
  const docs = await db.select().from(brokerKycDocsTable)
    .where(eq(brokerKycDocsTable.brokerAccountId, account.id))
    .orderBy(desc(brokerKycDocsTable.uploadedAt));
  res.json({ docs });
});

// ─── POST /broker/account/kyc (upload doc) ───────────────────────────────────
router.post("/broker/account/kyc", requireAuth, async (req, res): Promise<void> => {
  const account = await getOrCreateAccount(uid(req));
  const { docType, fileUrl, fileKey } = req.body as { docType: string; fileUrl?: string; fileKey?: string };
  if (!docType) { res.status(400).json({ error: "docType required" }); return; }

  // Upsert: replace existing doc of same type
  const [existing] = await db.select().from(brokerKycDocsTable)
    .where(and(eq(brokerKycDocsTable.brokerAccountId, account.id), eq(brokerKycDocsTable.docType, docType))).limit(1);

  let doc;
  if (existing) {
    [doc] = await db.update(brokerKycDocsTable)
      .set({ fileUrl: fileUrl ?? existing.fileUrl, fileKey: fileKey ?? existing.fileKey, status: "pending", rejectionNote: null, uploadedAt: new Date() })
      .where(eq(brokerKycDocsTable.id, existing.id)).returning();
  } else {
    [doc] = await db.insert(brokerKycDocsTable)
      .values({ brokerAccountId: account.id, docType, fileUrl, fileKey, status: "pending" }).returning();
  }
  res.json({ doc });
});

// ─── GET /broker/portfolio ────────────────────────────────────────────────────
router.get("/broker/portfolio", requireAuth, async (req, res): Promise<void> => {
  const rows = await db.select().from(brokerPortfolioTable)
    .where(eq(brokerPortfolioTable.userId, uid(req)))
    .orderBy(desc(brokerPortfolioTable.updatedAt));
  res.json({ portfolio: rows });
});

// ─── GET /broker/orders ───────────────────────────────────────────────────────
router.get("/broker/orders", requireAuth, async (req, res): Promise<void> => {
  const orders = await db.select().from(brokerOrdersTable)
    .where(eq(brokerOrdersTable.userId, uid(req)))
    .orderBy(desc(brokerOrdersTable.createdAt))
    .limit(100);
  res.json({ orders });
});

// ─── POST /broker/orders (place order) ───────────────────────────────────────
router.post("/broker/orders", requireAuth, async (req, res): Promise<void> => {
  const userId = uid(req);
  const account = await getOrCreateAccount(userId);

  const { symbol, exchange, assetClass, orderType = "market", side, qty, price, triggerPrice } = req.body as {
    symbol: string; exchange: string; assetClass: string;
    orderType?: string; side: string; qty: number; price?: number; triggerPrice?: number;
  };

  if (!symbol || !side || !qty) {
    res.status(400).json({ error: "symbol, side, qty required" }); return;
  }

  // Get instrument
  const [inst] = await db.select().from(instrumentsTable)
    .where(eq(instrumentsTable.symbol, symbol.toUpperCase())).limit(1);
  if (!inst) { res.status(404).json({ error: "Instrument not found" }); return; }

  const isSimulated = account.status !== "active";
  const quote = await getQuote(symbol.toUpperCase());
  const execPrice = price ?? quote?.ltp ?? Number(inst.currentPrice);

  const [order] = await db.insert(brokerOrdersTable).values({
    userId,
    brokerAccountId: account.id,
    symbol: symbol.toUpperCase(),
    exchange: exchange ?? inst.exchange,
    assetClass: assetClass ?? inst.assetClass,
    orderType,
    side,
    qty: String(qty),
    price: price ? String(price) : null,
    triggerPrice: triggerPrice ? String(triggerPrice) : null,
    status: isSimulated ? "complete" : "pending",
    executedQty: isSimulated ? String(qty) : "0",
    executedPrice: isSimulated ? String(execPrice) : null,
    brokerage: String(Number(qty) * execPrice * Number(inst.takerFee)),
    simulated: isSimulated,
    placedAt: new Date(),
    executedAt: isSimulated ? new Date() : null,
  }).returning();

  // Update portfolio for simulated orders
  if (isSimulated) {
    const [existing] = await db.select().from(brokerPortfolioTable)
      .where(and(eq(brokerPortfolioTable.userId, userId), eq(brokerPortfolioTable.symbol, symbol.toUpperCase()), eq(brokerPortfolioTable.exchange, exchange ?? inst.exchange))).limit(1);

    const newQty = side === "buy"
      ? Number(existing?.holdingQty ?? 0) + Number(qty)
      : Math.max(0, Number(existing?.holdingQty ?? 0) - Number(qty));
    const newAvg = side === "buy" && existing
      ? (Number(existing.holdingQty) * Number(existing.avgBuyPrice) + Number(qty) * execPrice) / (Number(existing.holdingQty) + Number(qty))
      : existing?.avgBuyPrice ?? execPrice;

    if (existing) {
      await db.update(brokerPortfolioTable).set({
        holdingQty: String(newQty), avgBuyPrice: String(newAvg),
        currentPrice: String(execPrice), updatedAt: new Date(),
      }).where(eq(brokerPortfolioTable.id, existing.id));
    } else if (side === "buy") {
      await db.insert(brokerPortfolioTable).values({
        userId, brokerAccountId: account.id, symbol: symbol.toUpperCase(),
        exchange: exchange ?? inst.exchange, assetClass: assetClass ?? inst.assetClass,
        holdingQty: String(qty), avgBuyPrice: String(execPrice),
        currentPrice: String(execPrice),
      });
    }
  }

  res.json({ order, simulated: isSimulated });
});

// ─── ADMIN: List all applications ─────────────────────────────────────────────
router.get("/admin/broker-applications", ...ADMIN_GUARD, async (_req, res): Promise<void> => {
  const apps = await db.select().from(brokerAccountsTable).orderBy(desc(brokerAccountsTable.createdAt));
  res.json({ applications: apps });
});

// ─── ADMIN: Get single application ───────────────────────────────────────────
router.get("/admin/broker-applications/:id", ...ADMIN_GUARD, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  const [app] = await db.select().from(brokerAccountsTable).where(eq(brokerAccountsTable.id, id)).limit(1);
  if (!app) { res.status(404).json({ error: "Not found" }); return; }
  const docs = await db.select().from(brokerKycDocsTable).where(eq(brokerKycDocsTable.brokerAccountId, id));
  const orders = await db.select().from(brokerOrdersTable).where(eq(brokerOrdersTable.brokerAccountId, id)).limit(50);
  res.json({ application: app, docs, orders });
});

// ─── ADMIN: Approve application ───────────────────────────────────────────────
router.patch("/admin/broker-applications/:id/approve", ...ADMIN_GUARD, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  const { angelClientId, angelDemat, angelTradingId } = req.body as { angelClientId?: string; angelDemat?: string; angelTradingId?: string };
  const [app] = await db.update(brokerAccountsTable).set({
    status: "active", approvedAt: new Date(), updatedAt: new Date(),
    angelClientId: angelClientId ?? `ANG${id.toString().padStart(6,"0")}`,
    angelDemat: angelDemat ?? `IN${id.toString().padStart(8,"0")}`,
    angelTradingId: angelTradingId ?? `TR${id.toString().padStart(8,"0")}`,
    rejectionReason: null,
  }).where(eq(brokerAccountsTable.id, id)).returning();
  await logAdminAction(req as any, "broker_account_approved", "broker_accounts", id, {});
  res.json({ application: app });
});

// ─── ADMIN: Reject application ────────────────────────────────────────────────
router.patch("/admin/broker-applications/:id/reject", ...ADMIN_GUARD, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  const { reason } = req.body as { reason?: string };
  const [app] = await db.update(brokerAccountsTable).set({
    status: "rejected", updatedAt: new Date(),
    rejectionReason: reason ?? "Application rejected by admin",
  }).where(eq(brokerAccountsTable.id, id)).returning();
  await logAdminAction(req as any, "broker_account_rejected", "broker_accounts", id, { reason });
  res.json({ application: app });
});

// ─── ADMIN: Update KYC doc status ─────────────────────────────────────────────
router.patch("/admin/broker-applications/:id/kyc/:docId", ...ADMIN_GUARD, async (req, res): Promise<void> => {
  const docId = Number(req.params.docId);
  const { status, rejectionNote } = req.body as { status: string; rejectionNote?: string };
  const [doc] = await db.update(brokerKycDocsTable).set({
    status, rejectionNote: rejectionNote ?? null,
    verifiedAt: status === "verified" ? new Date() : null,
  }).where(eq(brokerKycDocsTable.id, docId)).returning();
  res.json({ doc });
});

export default router;
