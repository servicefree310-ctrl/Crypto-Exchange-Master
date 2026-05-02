import { Router, type IRouter } from "express";
import { eq, and, or, desc, asc, sql, ne, gt, gte, inArray } from "drizzle-orm";
import { z } from "zod";
import {
  db,
  p2pOffersTable,
  p2pOrdersTable,
  p2pMessagesTable,
  p2pPaymentMethodsTable,
  walletsTable,
  coinsTable,
  usersTable,
} from "@workspace/db";
import { requireAuth, requireRole } from "../middlewares/auth";

const router: IRouter = Router();
const adminOnly = requireRole("admin", "superadmin");
const supportPlus = requireRole("admin", "superadmin", "support");

// ─── Constants ──────────────────────────────────────────────────────────
const PAYMENT_METHOD_TYPES = ["upi", "imps", "neft", "bank", "paytm", "phonepe", "gpay"] as const;
const OFFER_SIDES = ["buy", "sell"] as const;
const ORDER_STATUSES = ["pending", "paid", "released", "cancelled", "disputed", "expired"] as const;

// ─── Helpers ────────────────────────────────────────────────────────────

/** Resolve a coin row by symbol (e.g. "BTC"); throws 404 with .code on miss. */
async function getCoinBySymbol(sym: string) {
  const [coin] = await db.select().from(coinsTable).where(eq(coinsTable.symbol, sym.toUpperCase())).limit(1);
  if (!coin) { const e: any = new Error(`Coin ${sym} not found`); e.code = 404; throw e; }
  return coin;
}

/** Locate-or-create a user's spot wallet for a coin, taking row lock. */
async function ensureSpotWallet(tx: any, userId: number, coinId: number) {
  const [w] = await tx.select().from(walletsTable)
    .where(and(eq(walletsTable.userId, userId), eq(walletsTable.coinId, coinId), eq(walletsTable.walletType, "spot")))
    .for("update").limit(1);
  if (w) return w;
  const [created] = await tx.insert(walletsTable).values({
    userId, coinId, walletType: "spot", balance: "0", locked: "0",
  }).returning();
  const [locked] = await tx.select().from(walletsTable).where(eq(walletsTable.id, created.id)).for("update").limit(1);
  return locked;
}

/** Hide PII (phone/email) from non-counterparty users in marketplace browsing. */
function publicMerchantView(u: any) {
  const name = u?.name?.trim() || (u?.email ? u.email.split("@")[0] : "Trader");
  return {
    id: u?.id,
    name,
    // Reveal only first letter + masked
    handle: name.length > 1 ? `${name[0]}${"*".repeat(Math.max(2, name.length - 2))}${name[name.length - 1]}` : name,
    kycLevel: u?.kycLevel ?? 0,
    vipTier: u?.vipTier ?? 0,
    createdAt: u?.createdAt,
  };
}

/** Offer view for marketplace listing (joins coin + merchant). */
async function hydrateOffers(rows: any[]) {
  if (!rows.length) return [];
  const coinIds = Array.from(new Set(rows.map(r => r.coinId)));
  const userIds = Array.from(new Set(rows.map(r => r.userId)));
  const [coins, users] = await Promise.all([
    db.select().from(coinsTable).where(inArray(coinsTable.id, coinIds)),
    db.select().from(usersTable).where(inArray(usersTable.id, userIds)),
  ]);
  const coinById = new Map(coins.map(c => [c.id, c]));
  const userById = new Map(users.map(u => [u.id, u]));
  return rows.map(r => ({
    ...r,
    price: Number(r.price),
    totalQty: Number(r.totalQty),
    availableQty: Number(r.availableQty),
    minFiat: Number(r.minFiat),
    maxFiat: Number(r.maxFiat),
    paymentMethods: String(r.paymentMethods || "").split(",").filter(Boolean),
    coin: coinById.get(r.coinId) ? {
      id: coinById.get(r.coinId)!.id,
      symbol: coinById.get(r.coinId)!.symbol,
      name: coinById.get(r.coinId)!.name,
    } : null,
    merchant: publicMerchantView(userById.get(r.userId)),
  }));
}

// ═══════════════════════════════════════════════════════════════════════
// Payment methods (per-user)
// ═══════════════════════════════════════════════════════════════════════

router.get("/p2p/payment-methods", requireAuth, async (req, res): Promise<void> => {
  const rows = await db.select().from(p2pPaymentMethodsTable)
    .where(and(eq(p2pPaymentMethodsTable.userId, req.user!.id), eq(p2pPaymentMethodsTable.active, true)))
    .orderBy(desc(p2pPaymentMethodsTable.createdAt));
  res.json(rows);
});

const PaymentMethodBody = z.object({
  method: z.enum(PAYMENT_METHOD_TYPES),
  label: z.string().min(2).max(60),
  account: z.string().min(3).max(120),
  ifsc: z.string().min(4).max(20).optional(),
  holderName: z.string().min(2).max(80).optional(),
}).strict();

router.post("/p2p/payment-methods", requireAuth, async (req, res): Promise<void> => {
  const parsed = PaymentMethodBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.issues[0]?.message ?? "Invalid input" }); return; }
  // Bank-rail methods need IFSC + holder name; UPI/wallet methods don't.
  const needsBank = parsed.data.method === "imps" || parsed.data.method === "neft" || parsed.data.method === "bank";
  if (needsBank && (!parsed.data.ifsc || !parsed.data.holderName)) {
    res.status(400).json({ error: "ifsc and holderName required for bank methods" }); return;
  }
  const [created] = await db.insert(p2pPaymentMethodsTable).values({
    userId: req.user!.id,
    method: parsed.data.method,
    label: parsed.data.label,
    account: parsed.data.account,
    ifsc: parsed.data.ifsc ?? null,
    holderName: parsed.data.holderName ?? null,
  }).returning();
  res.status(201).json(created);
});

router.delete("/p2p/payment-methods/:id", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  // Soft-delete: keep row so historical orders can still display the
  // payment label that was used at deal time.
  const [updated] = await db.update(p2pPaymentMethodsTable)
    .set({ active: false })
    .where(and(eq(p2pPaymentMethodsTable.id, id), eq(p2pPaymentMethodsTable.userId, req.user!.id)))
    .returning();
  if (!updated) { res.status(404).json({ error: "Payment method not found" }); return; }
  res.json({ ok: true });
});

// ═══════════════════════════════════════════════════════════════════════
// Offers (Ads)
// ═══════════════════════════════════════════════════════════════════════

// Public marketplace browse — anyone (auth required for detail/order, but
// browse is gated to logged-in users so we can hide PII consistently).
router.get("/p2p/offers", requireAuth, async (req, res): Promise<void> => {
  const side = String(req.query.side || "sell").toLowerCase();
  const coin = String(req.query.coin || "").toUpperCase();
  const fiat = String(req.query.fiat || "INR").toUpperCase();
  const method = String(req.query.method || "").toLowerCase();
  const limit = Math.min(100, Math.max(1, Number(req.query.limit) || 50));

  if (!OFFER_SIDES.includes(side as any)) { res.status(400).json({ error: "side must be buy/sell" }); return; }

  const conds: any[] = [
    eq(p2pOffersTable.side, side),
    eq(p2pOffersTable.fiat, fiat),
    eq(p2pOffersTable.status, "online"),
    gt(p2pOffersTable.availableQty, "0"),
    // Hide own offers from browsing — merchants shouldn't see/match their own ads.
    ne(p2pOffersTable.userId, req.user!.id),
  ];
  if (coin) {
    const c = await db.select({ id: coinsTable.id }).from(coinsTable).where(eq(coinsTable.symbol, coin)).limit(1);
    if (!c.length) { res.json([]); return; }
    conds.push(eq(p2pOffersTable.coinId, c[0].id));
  }
  if (method) {
    if (!PAYMENT_METHOD_TYPES.includes(method as any)) { res.status(400).json({ error: "Invalid method" }); return; }
    // payment_methods stored as comma-list — match via ILIKE on the joined string.
    conds.push(sql`${p2pOffersTable.paymentMethods} ILIKE ${'%' + method + '%'}`);
  }

  // SELL ads (merchant selling crypto) → buyer wants LOWEST price first.
  // BUY  ads (merchant buying crypto)  → seller wants HIGHEST price first.
  const orderBy = side === "sell" ? asc(p2pOffersTable.price) : desc(p2pOffersTable.price);
  const rows = await db.select().from(p2pOffersTable).where(and(...conds)).orderBy(orderBy).limit(limit);
  res.json(await hydrateOffers(rows));
});

// My ads (online + offline + closed)
router.get("/p2p/offers/mine", requireAuth, async (req, res): Promise<void> => {
  const rows = await db.select().from(p2pOffersTable)
    .where(eq(p2pOffersTable.userId, req.user!.id))
    .orderBy(desc(p2pOffersTable.createdAt))
    .limit(200);
  res.json(await hydrateOffers(rows));
});

router.get("/p2p/offers/:id", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  const [offer] = await db.select().from(p2pOffersTable).where(eq(p2pOffersTable.id, id)).limit(1);
  if (!offer) { res.status(404).json({ error: "Offer not found" }); return; }
  const [hydrated] = await hydrateOffers([offer]);
  res.json(hydrated);
});

/**
 * For SELL offers, the buyer (counterparty) needs to pick which of the
 * MERCHANT's saved payment methods to use. To preserve some privacy we
 * only return id/method/label — not the account number — until the
 * order is opened, at which point the order row carries the snapshot.
 */
router.get("/p2p/offers/:id/seller-methods", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  const [offer] = await db.select().from(p2pOffersTable).where(eq(p2pOffersTable.id, id)).limit(1);
  if (!offer) { res.status(404).json({ error: "Offer not found" }); return; }
  if (offer.userId === req.user!.id) {
    res.status(400).json({ error: "Cannot trade your own offer" }); return;
  }
  // Only relevant for SELL offers (where the counterparty is the buyer).
  // For BUY offers the counterparty (seller) supplies their OWN method.
  if (offer.side !== "sell") { res.json([]); return; }
  const accepted = String(offer.paymentMethods || "").split(",").filter(Boolean);
  const rows = await db.select({
    id: p2pPaymentMethodsTable.id,
    method: p2pPaymentMethodsTable.method,
    label: p2pPaymentMethodsTable.label,
  }).from(p2pPaymentMethodsTable)
    .where(and(eq(p2pPaymentMethodsTable.userId, offer.userId), eq(p2pPaymentMethodsTable.active, true)))
    .limit(20);
  // Filter only methods compatible with the offer's accepted list.
  res.json(rows.filter(r => accepted.includes(r.method)));
});

const OfferBody = z.object({
  side: z.enum(OFFER_SIDES),
  coinSymbol: z.string().min(1).max(20),
  fiat: z.string().min(2).max(8).default("INR"),
  price: z.coerce.number().finite().positive(),
  totalQty: z.coerce.number().finite().positive(),
  minFiat: z.coerce.number().finite().positive(),
  maxFiat: z.coerce.number().finite().positive(),
  paymentMethods: z.array(z.enum(PAYMENT_METHOD_TYPES)).min(1).max(7),
  payWindowMins: z.coerce.number().int().min(5).max(120).default(15),
  terms: z.string().max(500).optional(),
  minKycLevel: z.coerce.number().int().min(0).max(3).default(1),
  minTrades: z.coerce.number().int().min(0).max(10000).default(0),
}).strict().superRefine((d, ctx) => {
  if (d.maxFiat < d.minFiat) ctx.addIssue({ code: "custom", path: ["maxFiat"], message: "maxFiat must be >= minFiat" });
  // Sanity: order amount must be reachable within total liquidity.
  if (d.minFiat > d.totalQty * d.price) ctx.addIssue({ code: "custom", path: ["minFiat"], message: "minFiat exceeds total liquidity (totalQty*price)" });
});

router.post("/p2p/offers", requireAuth, async (req, res): Promise<void> => {
  const parsed = OfferBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.issues[0]?.message ?? "Invalid input" }); return; }
  const d = parsed.data;
  const u = req.user!;
  if (u.kycLevel < 1) { res.status(403).json({ error: "KYC Level 1 required to post P2P ads" }); return; }
  try {
    const coin = await getCoinBySymbol(d.coinSymbol);
    // For SELL ads we don't pre-lock balance — escrow only locks at the
    // moment a buyer opens an order. But we DO check the merchant has at
    // least totalQty available right now so we don't list an undeliverable ad.
    if (d.side === "sell") {
      const [w] = await db.select().from(walletsTable)
        .where(and(eq(walletsTable.userId, u.id), eq(walletsTable.coinId, coin.id), eq(walletsTable.walletType, "spot")))
        .limit(1);
      if (!w || Number(w.balance) < d.totalQty) {
        res.status(400).json({ error: `Insufficient ${coin.symbol} spot balance (need ${d.totalQty})` });
        return;
      }
    }
    const [created] = await db.insert(p2pOffersTable).values({
      userId: u.id,
      side: d.side,
      coinId: coin.id,
      fiat: d.fiat.toUpperCase(),
      price: String(d.price),
      totalQty: String(d.totalQty),
      availableQty: String(d.totalQty),
      minFiat: String(d.minFiat),
      maxFiat: String(d.maxFiat),
      paymentMethods: d.paymentMethods.join(","),
      payWindowMins: d.payWindowMins,
      terms: d.terms ?? null,
      minKycLevel: d.minKycLevel,
      minTrades: d.minTrades,
      status: "online",
    }).returning();
    const [hydrated] = await hydrateOffers([created]);
    res.status(201).json(hydrated);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

const OfferPatchBody = z.object({
  status: z.enum(["online", "offline", "closed"]).optional(),
  price: z.coerce.number().finite().positive().optional(),
  minFiat: z.coerce.number().finite().positive().optional(),
  maxFiat: z.coerce.number().finite().positive().optional(),
  terms: z.string().max(500).optional(),
}).strict();

router.patch("/p2p/offers/:id", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  const parsed = OfferPatchBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.issues[0]?.message ?? "Invalid input" }); return; }

  const [existing] = await db.select().from(p2pOffersTable)
    .where(and(eq(p2pOffersTable.id, id), eq(p2pOffersTable.userId, req.user!.id)))
    .limit(1);
  if (!existing) { res.status(404).json({ error: "Offer not found" }); return; }
  if (existing.status === "suspended") { res.status(403).json({ error: "Suspended by admin — cannot edit" }); return; }

  const upd: Record<string, any> = { updatedAt: new Date() };
  if (parsed.data.status) upd.status = parsed.data.status;
  if (parsed.data.price != null) upd.price = String(parsed.data.price);
  if (parsed.data.minFiat != null) upd.minFiat = String(parsed.data.minFiat);
  if (parsed.data.maxFiat != null) upd.maxFiat = String(parsed.data.maxFiat);
  if (parsed.data.terms !== undefined) upd.terms = parsed.data.terms || null;
  const [updated] = await db.update(p2pOffersTable).set(upd).where(eq(p2pOffersTable.id, id)).returning();
  const [hydrated] = await hydrateOffers([updated]);
  res.json(hydrated);
});

router.delete("/p2p/offers/:id", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  // Block delete if the offer still has active orders against it — admins
  // resolve those via the dispute panel before the merchant can clean up.
  const [openOrder] = await db.select({ id: p2pOrdersTable.id }).from(p2pOrdersTable)
    .where(and(eq(p2pOrdersTable.offerId, id), inArray(p2pOrdersTable.status, ["pending", "paid", "disputed"])))
    .limit(1);
  if (openOrder) { res.status(400).json({ error: "Cannot delete — offer has active orders. Set offline instead." }); return; }
  const [updated] = await db.update(p2pOffersTable)
    .set({ status: "closed", updatedAt: new Date() })
    .where(and(eq(p2pOffersTable.id, id), eq(p2pOffersTable.userId, req.user!.id)))
    .returning();
  if (!updated) { res.status(404).json({ error: "Offer not found" }); return; }
  res.json({ ok: true });
});

// ═══════════════════════════════════════════════════════════════════════
// Orders (Deals) — escrow-backed P2P trades
// ═══════════════════════════════════════════════════════════════════════

const OpenOrderBody = z.object({
  offerId: z.coerce.number().int().positive(),
  // Counterparty specifies amount in EITHER fiat or crypto — we resolve
  // the other side from the offer's frozen price. Exactly one required.
  fiatAmount: z.coerce.number().finite().positive().optional(),
  qty: z.coerce.number().finite().positive().optional(),
  paymentMethodId: z.coerce.number().int().positive(),
}).strict().superRefine((d, ctx) => {
  if (d.fiatAmount == null && d.qty == null) ctx.addIssue({ code: "custom", path: ["fiatAmount"], message: "Provide fiatAmount or qty" });
  if (d.fiatAmount != null && d.qty != null) ctx.addIssue({ code: "custom", path: ["qty"], message: "Provide only ONE of fiatAmount/qty" });
});

router.post("/p2p/orders", requireAuth, async (req, res): Promise<void> => {
  const parsed = OpenOrderBody.safeParse(req.body);
  if (!parsed.success) { res.status(400).json({ error: parsed.error.issues[0]?.message ?? "Invalid input" }); return; }
  const d = parsed.data;
  const me = req.user!;
  if (me.kycLevel < 1) { res.status(403).json({ error: "KYC Level 1 required for P2P trading" }); return; }

  try {
    const created = await db.transaction(async (tx) => {
      const [offer] = await tx.select().from(p2pOffersTable)
        .where(eq(p2pOffersTable.id, d.offerId))
        .for("update").limit(1);
      if (!offer) { const e: any = new Error("Offer not found"); e.code = 404; throw e; }
      if (offer.status !== "online") { const e: any = new Error(`Offer is ${offer.status}`); e.code = 400; throw e; }
      if (offer.userId === me.id) { const e: any = new Error("Cannot trade your own offer"); e.code = 400; throw e; }
      if (me.kycLevel < offer.minKycLevel) {
        const e: any = new Error(`KYC Level ${offer.minKycLevel} required by this merchant`); e.code = 403; throw e;
      }

      // Resolve qty + fiat amount, snapshot price.
      const price = Number(offer.price);
      const qty = d.qty != null ? Number(d.qty) : (d.fiatAmount! / price);
      const fiatAmount = d.fiatAmount != null ? Number(d.fiatAmount) : (qty * price);
      const minF = Number(offer.minFiat), maxF = Number(offer.maxFiat);
      if (fiatAmount < minF) { const e: any = new Error(`Below min order amount (₹${minF})`); e.code = 400; throw e; }
      if (fiatAmount > maxF) { const e: any = new Error(`Above max order amount (₹${maxF})`); e.code = 400; throw e; }
      if (qty > Number(offer.availableQty)) { const e: any = new Error("Not enough liquidity remaining"); e.code = 400; throw e; }

      // Resolve buyer / seller from offer side. Offer side is the
      // MERCHANT's intent; the order opener is the counterparty.
      // - offer.side = "sell" → merchant sells, opener BUYS
      // - offer.side = "buy"  → merchant buys, opener SELLS
      const buyerId = offer.side === "sell" ? me.id : offer.userId;
      const sellerId = offer.side === "sell" ? offer.userId : me.id;

      // The seller's payment method is irrelevant — we use the BUYER's
      // payment method as the destination the buyer will send fiat from
      // (and the seller will look at to confirm). For symmetry we let
      // the merchant's offer dictate the channel (matching by type), but
      // we always resolve the actual payee account from the SELLER side
      // because that's who the fiat goes TO.
      // The seller's payment method is what matters — that's the account
      // the buyer pays TO. The `paymentMethodId` posted by the client
      // must reference an active method belonging to the seller.
      // For SELL offers: seller is the merchant who already saved methods
      // on the offer creation flow. For BUY offers: seller is the opener
      // (they're selling crypto for fiat) — they posted their OWN method
      // when opening the order, so the merchant knows where to pay.
      const [pm] = await tx.select().from(p2pPaymentMethodsTable)
        .where(and(eq(p2pPaymentMethodsTable.id, d.paymentMethodId), eq(p2pPaymentMethodsTable.userId, sellerId), eq(p2pPaymentMethodsTable.active, true)))
        .limit(1);
      if (!pm) { const e: any = new Error("Payment method not found or not owned by the seller"); e.code = 404; throw e; }
      const acceptedMethods = String(offer.paymentMethods || "").split(",").filter(Boolean);
      if (!acceptedMethods.includes(pm.method)) {
        const e: any = new Error(`This offer doesn't accept ${pm.method}`); e.code = 400; throw e;
      }

      // ─── Escrow lock — reduce seller's spot.balance, add to spot.locked
      const sellerWallet = await ensureSpotWallet(tx, sellerId, offer.coinId);
      if (Number(sellerWallet.balance) < qty) {
        const e: any = new Error("Seller has insufficient balance — try a smaller order"); e.code = 400; throw e;
      }
      await tx.update(walletsTable).set({
        balance: sql`${walletsTable.balance} - ${qty}`,
        locked: sql`${walletsTable.locked} + ${qty}`,
        updatedAt: new Date(),
      }).where(eq(walletsTable.id, sellerWallet.id));

      // Decrement available liquidity on the offer.
      await tx.update(p2pOffersTable).set({
        availableQty: sql`${p2pOffersTable.availableQty} - ${qty}`,
        updatedAt: new Date(),
      }).where(eq(p2pOffersTable.id, offer.id));

      const expiresAt = new Date(Date.now() + offer.payWindowMins * 60 * 1000);
      const [order] = await tx.insert(p2pOrdersTable).values({
        offerId: offer.id,
        buyerId, sellerId,
        coinId: offer.coinId,
        fiat: offer.fiat,
        price: String(price),
        qty: String(qty),
        fiatAmount: String(fiatAmount),
        paymentMethod: (pm as any).method,
        paymentAccount: (pm as any).account,
        paymentLabel: (pm as any).label,
        paymentIfsc: (pm as any).ifsc,
        paymentHolderName: (pm as any).holderName,
        status: "pending",
        expiresAt,
      }).returning();

      // Seed a system message so the chat shows the deal opening as
      // its first event (great for audit + onboarding context).
      await tx.insert(p2pMessagesTable).values({
        orderId: order.id,
        senderId: me.id,
        senderRole: "system",
        body: `Order opened — buyer must pay ₹${fiatAmount.toFixed(2)} within ${offer.payWindowMins} minutes.`,
      });
      return order;
    });
    res.status(201).json(created);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    req.log?.error?.({ err: e }, "p2p order create failed");
    throw e;
  }
});

router.get("/p2p/orders", requireAuth, async (req, res): Promise<void> => {
  const role = String(req.query.role || "all"); // buyer | seller | all
  const status = String(req.query.status || "all");
  const me = req.user!.id;

  const conds: any[] = [];
  if (role === "buyer") conds.push(eq(p2pOrdersTable.buyerId, me));
  else if (role === "seller") conds.push(eq(p2pOrdersTable.sellerId, me));
  else conds.push(or(eq(p2pOrdersTable.buyerId, me), eq(p2pOrdersTable.sellerId, me)));
  if (status !== "all" && ORDER_STATUSES.includes(status as any)) {
    conds.push(eq(p2pOrdersTable.status, status));
  }

  const rows = await db.select().from(p2pOrdersTable).where(and(...conds))
    .orderBy(desc(p2pOrdersTable.createdAt)).limit(200);
  res.json(await hydrateOrders(rows, me));
});

router.get("/p2p/orders/:id", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  const me = req.user!.id;
  const [order] = await db.select().from(p2pOrdersTable).where(eq(p2pOrdersTable.id, id)).limit(1);
  if (!order || (order.buyerId !== me && order.sellerId !== me && req.user!.role === "user")) {
    res.status(404).json({ error: "Order not found" }); return;
  }
  const [hydrated] = await hydrateOrders([order], me);
  res.json(hydrated);
});

async function hydrateOrders(rows: any[], myId: number) {
  if (!rows.length) return [];
  const userIds = Array.from(new Set(rows.flatMap(r => [r.buyerId, r.sellerId])));
  const coinIds = Array.from(new Set(rows.map(r => r.coinId)));
  const [users, coins] = await Promise.all([
    db.select({ id: usersTable.id, name: usersTable.name, email: usersTable.email, kycLevel: usersTable.kycLevel, vipTier: usersTable.vipTier, createdAt: usersTable.createdAt }).from(usersTable).where(inArray(usersTable.id, userIds)),
    db.select().from(coinsTable).where(inArray(coinsTable.id, coinIds)),
  ]);
  const userById = new Map(users.map(u => [u.id, u]));
  const coinById = new Map(coins.map(c => [c.id, c]));
  return rows.map(r => ({
    ...r,
    price: Number(r.price),
    qty: Number(r.qty),
    fiatAmount: Number(r.fiatAmount),
    role: r.buyerId === myId ? "buyer" : (r.sellerId === myId ? "seller" : "admin"),
    coin: coinById.get(r.coinId) ? { id: r.coinId, symbol: coinById.get(r.coinId)!.symbol, name: coinById.get(r.coinId)!.name } : null,
    buyer: publicMerchantView(userById.get(r.buyerId)),
    seller: publicMerchantView(userById.get(r.sellerId)),
  }));
}

// Buyer: I have sent fiat — flip status to "paid"
router.post("/p2p/orders/:id/mark-paid", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  const utr = (req.body?.utr ? String(req.body.utr).slice(0, 60) : null);

  try {
    const result = await db.transaction(async (tx) => {
      const [o] = await tx.select().from(p2pOrdersTable).where(eq(p2pOrdersTable.id, id)).for("update").limit(1);
      if (!o) { const e: any = new Error("Order not found"); e.code = 404; throw e; }
      if (o.buyerId !== req.user!.id) { const e: any = new Error("Only the buyer can mark paid"); e.code = 403; throw e; }
      if (o.status !== "pending") { const e: any = new Error(`Cannot mark paid — order is ${o.status}`); e.code = 400; throw e; }
      // Window check — if the window has elapsed we don't accept the
      // paid claim; the buyer must talk to the seller via dispute.
      if (o.expiresAt && o.expiresAt.getTime() < Date.now()) {
        const e: any = new Error("Pay window expired — open a dispute if you've already paid"); e.code = 400; throw e;
      }
      const [updated] = await tx.update(p2pOrdersTable).set({
        status: "paid",
        paidAt: new Date(),
        paymentUtr: utr,
        updatedAt: new Date(),
      }).where(eq(p2pOrdersTable.id, id)).returning();
      await tx.insert(p2pMessagesTable).values({
        orderId: id, senderId: req.user!.id, senderRole: "system",
        body: utr ? `Buyer marked as paid (UTR: ${utr}). Seller please verify and release.`
                  : `Buyer marked as paid. Seller please verify and release.`,
      });
      return updated;
    });
    res.json(result);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

// Seller (or admin): I confirm receipt — release escrow to buyer.
router.post("/p2p/orders/:id/release", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  try {
    const result = await releaseOrder(id, req.user!.id, req.user!.role);
    res.json(result);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

/**
 * Move escrowed crypto from seller.locked → buyer.balance, mark order
 * "released". Callable by:
 *   - the seller (only if status === "paid")
 *   - admin/superadmin (any status, used by dispute resolution)
 */
async function releaseOrder(orderId: number, actorId: number, actorRole: string) {
  return await db.transaction(async (tx) => {
    const [o] = await tx.select().from(p2pOrdersTable).where(eq(p2pOrdersTable.id, orderId)).for("update").limit(1);
    if (!o) { const e: any = new Error("Order not found"); e.code = 404; throw e; }
    const isAdmin = actorRole === "admin" || actorRole === "superadmin";
    if (!isAdmin && o.sellerId !== actorId) { const e: any = new Error("Only the seller or admin can release"); e.code = 403; throw e; }
    if (o.status === "released") { const e: any = new Error("Already released"); e.code = 400; throw e; }
    if (!isAdmin && o.status !== "paid") { const e: any = new Error("Buyer hasn't marked as paid yet"); e.code = 400; throw e; }
    if (o.status === "cancelled" || o.status === "expired") { const e: any = new Error("Cannot release a cancelled/expired order"); e.code = 400; throw e; }

    // Move crypto: seller.locked -= qty ; buyer.balance += qty.
    const sellerWallet = await ensureSpotWallet(tx, o.sellerId, o.coinId);
    const buyerWallet = await ensureSpotWallet(tx, o.buyerId, o.coinId);
    const qty = Number(o.qty);
    if (Number(sellerWallet.locked) < qty - 1e-12) {
      const e: any = new Error("Escrow accounting error — locked < qty"); e.code = 500; throw e;
    }
    await tx.update(walletsTable).set({
      locked: sql`${walletsTable.locked} - ${qty}`,
      updatedAt: new Date(),
    }).where(eq(walletsTable.id, sellerWallet.id));
    await tx.update(walletsTable).set({
      balance: sql`${walletsTable.balance} + ${qty}`,
      updatedAt: new Date(),
    }).where(eq(walletsTable.id, buyerWallet.id));

    const [updated] = await tx.update(p2pOrdersTable).set({
      status: "released",
      releasedAt: new Date(),
      ...(isAdmin ? { disputeResolution: "release", disputeResolvedBy: actorId, disputeResolvedAt: new Date() } : {}),
      updatedAt: new Date(),
    }).where(eq(p2pOrdersTable.id, orderId)).returning();

    await tx.insert(p2pMessagesTable).values({
      orderId, senderId: actorId, senderRole: isAdmin ? "admin" : "system",
      body: isAdmin ? "Admin released funds to buyer." : "Seller released funds — order completed.",
    });
    return updated;
  });
}

// Cancel: refund escrow back to seller. Allowed when status=pending
// (either side can cancel). Once buyer has marked paid, only admin can
// cancel — buyer/seller must use dispute.
router.post("/p2p/orders/:id/cancel", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  try {
    const result = await cancelOrder(id, req.user!.id, req.user!.role);
    res.json(result);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

async function cancelOrder(orderId: number, actorId: number, actorRole: string) {
  return await db.transaction(async (tx) => {
    const [o] = await tx.select().from(p2pOrdersTable).where(eq(p2pOrdersTable.id, orderId)).for("update").limit(1);
    if (!o) { const e: any = new Error("Order not found"); e.code = 404; throw e; }
    const isAdmin = actorRole === "admin" || actorRole === "superadmin";
    const isParty = o.buyerId === actorId || o.sellerId === actorId;
    if (!isAdmin && !isParty) { const e: any = new Error("Forbidden"); e.code = 403; throw e; }
    if (o.status === "cancelled" || o.status === "released" || o.status === "expired") {
      const e: any = new Error(`Cannot cancel — order is ${o.status}`); e.code = 400; throw e;
    }
    // Non-admins can ONLY cancel a still-pending order. Once buyer marks
    // paid OR a dispute has been opened, only admin moderation can resolve
    // it — otherwise a malicious seller could escape via paid→disputed→cancel
    // and refund themselves AFTER the buyer has paid fiat.
    if (o.status !== "pending" && !isAdmin) {
      const msg = o.status === "paid"
        ? "Buyer already marked as paid — open a dispute instead"
        : "Order is under dispute — only an admin can cancel";
      const e: any = new Error(msg); e.code = 400; throw e;
    }

    // Refund seller's escrow.
    const sellerWallet = await ensureSpotWallet(tx, o.sellerId, o.coinId);
    const qty = Number(o.qty);
    await tx.update(walletsTable).set({
      balance: sql`${walletsTable.balance} + ${qty}`,
      locked: sql`${walletsTable.locked} - ${qty}`,
      updatedAt: new Date(),
    }).where(eq(walletsTable.id, sellerWallet.id));

    // Restore offer's available liquidity.
    await tx.update(p2pOffersTable).set({
      availableQty: sql`${p2pOffersTable.availableQty} + ${qty}`,
      updatedAt: new Date(),
    }).where(eq(p2pOffersTable.id, o.offerId));

    const [updated] = await tx.update(p2pOrdersTable).set({
      status: "cancelled",
      cancelledAt: new Date(),
      ...(isAdmin && o.status === "disputed" ? {
        disputeResolution: "refund",
        disputeResolvedBy: actorId,
        disputeResolvedAt: new Date(),
      } : {}),
      updatedAt: new Date(),
    }).where(eq(p2pOrdersTable.id, orderId)).returning();

    await tx.insert(p2pMessagesTable).values({
      orderId, senderId: actorId, senderRole: isAdmin ? "admin" : "system",
      body: isAdmin ? "Admin cancelled and refunded escrow to seller." : "Order cancelled — escrow refunded to seller.",
    });
    return updated;
  });
}

// Open a dispute — flip status, capture reason, notify admin queue.
router.post("/p2p/orders/:id/dispute", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  const reason = String(req.body?.reason || "").trim().slice(0, 500);
  if (reason.length < 10) { res.status(400).json({ error: "Please describe the issue (min 10 chars)" }); return; }

  try {
    const result = await db.transaction(async (tx) => {
      const [o] = await tx.select().from(p2pOrdersTable).where(eq(p2pOrdersTable.id, id)).for("update").limit(1);
      if (!o) { const e: any = new Error("Order not found"); e.code = 404; throw e; }
      const isParty = o.buyerId === req.user!.id || o.sellerId === req.user!.id;
      if (!isParty) { const e: any = new Error("Forbidden"); e.code = 403; throw e; }
      if (o.status !== "pending" && o.status !== "paid") {
        const e: any = new Error(`Cannot dispute — order is ${o.status}`); e.code = 400; throw e;
      }
      const [updated] = await tx.update(p2pOrdersTable).set({
        status: "disputed",
        disputeOpenedBy: req.user!.id,
        disputeReason: reason,
        disputeOpenedAt: new Date(),
        updatedAt: new Date(),
      }).where(eq(p2pOrdersTable.id, id)).returning();
      await tx.insert(p2pMessagesTable).values({
        orderId: id, senderId: req.user!.id, senderRole: "system",
        body: `Dispute opened: ${reason.slice(0, 200)}`,
      });
      return updated;
    });
    res.json(result);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

// ═══════════════════════════════════════════════════════════════════════
// Chat
// ═══════════════════════════════════════════════════════════════════════

router.get("/p2p/orders/:id/messages", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  const me = req.user!.id;
  const isAdmin = req.user!.role === "admin" || req.user!.role === "superadmin" || req.user!.role === "support";
  const [o] = await db.select().from(p2pOrdersTable).where(eq(p2pOrdersTable.id, id)).limit(1);
  if (!o || (!isAdmin && o.buyerId !== me && o.sellerId !== me)) {
    res.status(404).json({ error: "Order not found" }); return;
  }
  const rows = await db.select().from(p2pMessagesTable)
    .where(eq(p2pMessagesTable.orderId, id))
    .orderBy(asc(p2pMessagesTable.createdAt))
    .limit(500);
  res.json(rows);
});

router.post("/p2p/orders/:id/messages", requireAuth, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  const body = String(req.body?.body || "").trim();
  if (body.length < 1) { res.status(400).json({ error: "Message body required" }); return; }
  if (body.length > 1000) { res.status(400).json({ error: "Message too long (max 1000 chars)" }); return; }

  const me = req.user!.id;
  const isAdmin = req.user!.role === "admin" || req.user!.role === "superadmin" || req.user!.role === "support";
  const [o] = await db.select().from(p2pOrdersTable).where(eq(p2pOrdersTable.id, id)).limit(1);
  if (!o) { res.status(404).json({ error: "Order not found" }); return; }
  if (!isAdmin && o.buyerId !== me && o.sellerId !== me) { res.status(403).json({ error: "Forbidden" }); return; }

  const role = isAdmin && o.buyerId !== me && o.sellerId !== me
    ? "admin"
    : (o.buyerId === me ? "buyer" : "seller");
  const [created] = await db.insert(p2pMessagesTable).values({
    orderId: id, senderId: me, senderRole: role, body,
  }).returning();
  res.status(201).json(created);
});

// ═══════════════════════════════════════════════════════════════════════
// Admin / moderation
// ═══════════════════════════════════════════════════════════════════════

router.get("/admin/p2p/stats", supportPlus, async (_req, res): Promise<void> => {
  const [open] = await db.select({ c: sql<number>`count(*)::int` }).from(p2pOffersTable).where(eq(p2pOffersTable.status, "online"));
  const [orders] = await db.select({ c: sql<number>`count(*)::int` }).from(p2pOrdersTable).where(inArray(p2pOrdersTable.status, ["pending", "paid"]));
  const [disputes] = await db.select({ c: sql<number>`count(*)::int` }).from(p2pOrdersTable).where(eq(p2pOrdersTable.status, "disputed"));
  const [released] = await db.select({ c: sql<number>`count(*)::int` }).from(p2pOrdersTable).where(eq(p2pOrdersTable.status, "released"));
  res.json({
    onlineOffers: open?.c ?? 0,
    activeOrders: orders?.c ?? 0,
    openDisputes: disputes?.c ?? 0,
    completedOrders: released?.c ?? 0,
  });
});

router.get("/admin/p2p/offers", supportPlus, async (req, res): Promise<void> => {
  const status = String(req.query.status || "all");
  const conds: any[] = [];
  if (status !== "all") conds.push(eq(p2pOffersTable.status, status));
  const rows = await db.select().from(p2pOffersTable)
    .where(conds.length ? and(...conds) : undefined)
    .orderBy(desc(p2pOffersTable.createdAt))
    .limit(200);
  res.json(await hydrateOffers(rows));
});

router.patch("/admin/p2p/offers/:id", adminOnly, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  const status = String(req.body?.status || "");
  if (!["online", "offline", "suspended", "closed"].includes(status)) {
    res.status(400).json({ error: "status must be online/offline/suspended/closed" }); return;
  }
  const [updated] = await db.update(p2pOffersTable)
    .set({ status, updatedAt: new Date() })
    .where(eq(p2pOffersTable.id, id))
    .returning();
  if (!updated) { res.status(404).json({ error: "Offer not found" }); return; }
  const [hydrated] = await hydrateOffers([updated]);
  res.json(hydrated);
});

router.get("/admin/p2p/orders", supportPlus, async (req, res): Promise<void> => {
  const status = String(req.query.status || "all");
  const conds: any[] = [];
  if (status !== "all" && ORDER_STATUSES.includes(status as any)) {
    conds.push(eq(p2pOrdersTable.status, status));
  }
  const rows = await db.select().from(p2pOrdersTable)
    .where(conds.length ? and(...conds) : undefined)
    .orderBy(desc(p2pOrdersTable.createdAt))
    .limit(200);
  res.json(await hydrateOrders(rows, -1));
});

router.get("/admin/p2p/disputes", supportPlus, async (_req, res): Promise<void> => {
  const rows = await db.select().from(p2pOrdersTable)
    .where(eq(p2pOrdersTable.status, "disputed"))
    .orderBy(asc(p2pOrdersTable.disputeOpenedAt))
    .limit(200);
  res.json(await hydrateOrders(rows, -1));
});

// Resolve dispute: "release" → push escrow to buyer. "refund" → return to seller.
router.post("/admin/p2p/disputes/:id/resolve", adminOnly, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  if (!Number.isFinite(id)) { res.status(400).json({ error: "Invalid id" }); return; }
  const action = String(req.body?.action || "");
  const notes = String(req.body?.notes || "").slice(0, 500);
  if (!["release", "refund"].includes(action)) { res.status(400).json({ error: "action must be release/refund" }); return; }

  try {
    const [o] = await db.select().from(p2pOrdersTable).where(eq(p2pOrdersTable.id, id)).limit(1);
    if (!o) { res.status(404).json({ error: "Order not found" }); return; }
    if (o.status !== "disputed") { res.status(400).json({ error: "Order is not in dispute state" }); return; }

    const result = action === "release"
      ? await releaseOrder(id, req.user!.id, req.user!.role)
      : await cancelOrder(id, req.user!.id, req.user!.role);

    if (notes) {
      await db.update(p2pOrdersTable)
        .set({ disputeNotes: notes, updatedAt: new Date() })
        .where(eq(p2pOrdersTable.id, id));
      await db.insert(p2pMessagesTable).values({
        orderId: id, senderId: req.user!.id, senderRole: "admin",
        body: `Admin notes: ${notes.slice(0, 300)}`,
      });
    }
    res.json(result);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

export default router;
