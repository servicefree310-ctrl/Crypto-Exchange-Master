import { Router, type IRouter } from "express";
import { eq, desc, or, ilike, and, sql } from "drizzle-orm";
import {
  db, coinsTable, pairsTable, fundingRatesTable, adminApiKeysTable,
  usersTable, kycRecordsTable, walletsTable, sessionsTable,
  inrDepositsTable, cryptoDepositsTable, inrWithdrawalsTable, cryptoWithdrawalsTable,
} from "@workspace/db";
void sql;
import { requireAuth } from "../middlewares/auth";
import { getCache, getInrRate } from "../lib/price-service";

const router: IRouter = Router();

const supportPlus = (req: any, res: any, next: any) => {
  if (!req.user) return res.sendStatus(401);
  if (!["support", "admin", "superadmin"].includes(req.user.role)) return res.sendStatus(403);
  next();
};
const adminOnly = (req: any, res: any, next: any) => {
  if (!req.user) return res.sendStatus(401);
  if (!["admin", "superadmin"].includes(req.user.role)) return res.sendStatus(403);
  next();
};

// ─── Public live prices ───────────────────────────────────────────────────────
router.get("/prices", (_req, res) => {
  res.json({ inrRate: getInrRate(), ticks: getCache() });
});

// ─── Admin: search users ──────────────────────────────────────────────────────
router.get("/admin/users-search", requireAuth, supportPlus, async (req, res): Promise<void> => {
  const q = (req.query.q as string) || "";
  const role = req.query.role as string | undefined;
  const status = req.query.status as string | undefined;
  const conds: any[] = [];
  if (q) conds.push(or(ilike(usersTable.email, `%${q}%`), ilike(usersTable.uid, `%${q}%`), ilike(usersTable.phone, `%${q}%`), ilike(usersTable.name, `%${q}%`), ilike(usersTable.referralCode, `%${q}%`)));
  if (role) conds.push(eq(usersTable.role, role));
  if (status) conds.push(eq(usersTable.status, status));
  const rows = conds.length
    ? await db.select().from(usersTable).where(and(...conds)).orderBy(desc(usersTable.createdAt)).limit(200)
    : await db.select().from(usersTable).orderBy(desc(usersTable.createdAt)).limit(200);
  res.json(rows.map(({ passwordHash, ...u }) => u));
});

// ─── Admin: full user dossier ─────────────────────────────────────────────────
router.get("/admin/users/:id/full", requireAuth, supportPlus, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  const [user] = await db.select().from(usersTable).where(eq(usersTable.id, id)).limit(1);
  if (!user) { res.status(404).json({ error: "User not found" }); return; }
  const { passwordHash, ...safe } = user;
  const [kyc, wallets, sessions, inrDeps, cryDeps, inrWds, cryWds] = await Promise.all([
    db.select().from(kycRecordsTable).where(eq(kycRecordsTable.userId, id)).orderBy(desc(kycRecordsTable.createdAt)),
    db.select().from(walletsTable).where(eq(walletsTable.userId, id)),
    db.select({ id: sessionsTable.id, createdAt: sessionsTable.createdAt, expiresAt: sessionsTable.expiresAt, ip: sessionsTable.ip, userAgent: sessionsTable.userAgent }).from(sessionsTable).where(eq(sessionsTable.userId, id)).orderBy(desc(sessionsTable.createdAt)).limit(20),
    db.select().from(inrDepositsTable).where(eq(inrDepositsTable.userId, id)).orderBy(desc(inrDepositsTable.createdAt)).limit(50),
    db.select().from(cryptoDepositsTable).where(eq(cryptoDepositsTable.userId, id)).orderBy(desc(cryptoDepositsTable.createdAt)).limit(50),
    db.select().from(inrWithdrawalsTable).where(eq(inrWithdrawalsTable.userId, id)).orderBy(desc(inrWithdrawalsTable.createdAt)).limit(50),
    db.select().from(cryptoWithdrawalsTable).where(eq(cryptoWithdrawalsTable.userId, id)).orderBy(desc(cryptoWithdrawalsTable.createdAt)).limit(50),
  ]);
  res.json({
    user: safe,
    security: {
      twoFaEnabled: user.twoFaEnabled,
      activeSessions: sessions.length,
      lastSessionAt: sessions[0]?.createdAt ?? null,
    },
    kyc, wallets, sessions, inrDeposits: inrDeps, cryptoDeposits: cryDeps, inrWithdrawals: inrWds, cryptoWithdrawals: cryWds,
  });
});

// Admin: full user edit (extends the basic /admin/users/:id PATCH)
router.patch("/admin/users/:id/full", requireAuth, adminOnly, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  const allowed: Record<string, unknown> = {};
  for (const k of ["role", "status", "kycLevel", "vipTier", "name", "phone", "email", "twoFaEnabled"]) {
    if (k in (req.body ?? {})) allowed[k] = req.body[k];
  }
  if (Object.keys(allowed).length === 0) { res.status(400).json({ error: "No fields to update" }); return; }
  const [u] = await db.update(usersTable).set(allowed).where(eq(usersTable.id, id)).returning();
  if (!u) { res.status(404).json({ error: "User not found" }); return; }
  const { passwordHash, ...safe } = u;
  res.json(safe);
});

// ─── Admin: funding rates ─────────────────────────────────────────────────────
router.get("/admin/funding-rates", requireAuth, supportPlus, async (req, res): Promise<void> => {
  const pairId = req.query.pairId ? Number(req.query.pairId) : null;
  const rows = pairId
    ? await db.select().from(fundingRatesTable).where(eq(fundingRatesTable.pairId, pairId)).orderBy(desc(fundingRatesTable.fundingTime)).limit(200)
    : await db.select().from(fundingRatesTable).orderBy(desc(fundingRatesTable.fundingTime)).limit(200);
  res.json(rows);
});
router.post("/admin/funding-rates", requireAuth, adminOnly, async (req, res): Promise<void> => {
  const { pairId, rate, intervalHours, fundingTime } = req.body ?? {};
  if (!pairId || rate === undefined || !fundingTime) { res.status(400).json({ error: "pairId, rate, fundingTime required" }); return; }
  const [r] = await db.insert(fundingRatesTable).values({
    pairId: Number(pairId), rate: String(rate), intervalHours: Number(intervalHours ?? 8), fundingTime: new Date(fundingTime),
  }).returning();
  res.status(201).json(r);
});
router.patch("/admin/funding-rates/:id", requireAuth, adminOnly, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  const b: Record<string, unknown> = { ...req.body };
  if (b.fundingTime) b.fundingTime = new Date(b.fundingTime as string);
  if (b.rate !== undefined) b.rate = String(b.rate);
  const [r] = await db.update(fundingRatesTable).set(b).where(eq(fundingRatesTable.id, id)).returning();
  if (!r) { res.status(404).json({ error: "Not found" }); return; }
  res.json(r);
});
router.delete("/admin/funding-rates/:id", requireAuth, adminOnly, async (req, res): Promise<void> => {
  await db.delete(fundingRatesTable).where(eq(fundingRatesTable.id, Number(req.params.id)));
  res.sendStatus(204);
});

// ─── Admin: API keys (Binance etc) ────────────────────────────────────────────
function maskSecret(s: string | null | undefined): string {
  if (!s) return "";
  if (s.length <= 8) return "•".repeat(s.length);
  return s.slice(0, 4) + "•".repeat(Math.max(0, s.length - 8)) + s.slice(-4);
}
router.get("/admin/api-keys", requireAuth, adminOnly, async (_req, res): Promise<void> => {
  const rows = await db.select().from(adminApiKeysTable).orderBy(desc(adminApiKeysTable.createdAt));
  res.json(rows.map(r => ({ ...r, apiKey: maskSecret(r.apiKey), apiSecret: maskSecret(r.apiSecret) })));
});
router.post("/admin/api-keys", requireAuth, adminOnly, async (req, res): Promise<void> => {
  const { provider, label, apiKey, apiSecret, baseUrl, isActive } = req.body ?? {};
  if (!provider) { res.status(400).json({ error: "provider required" }); return; }
  const [r] = await db.insert(adminApiKeysTable).values({
    provider, label: label ?? "", apiKey: apiKey ?? "", apiSecret: apiSecret ?? "",
    baseUrl: baseUrl ?? null, isActive: String(isActive ?? "true"),
  }).returning();
  res.status(201).json({ ...r, apiKey: maskSecret(r.apiKey), apiSecret: maskSecret(r.apiSecret) });
});
router.patch("/admin/api-keys/:id", requireAuth, adminOnly, async (req, res): Promise<void> => {
  const id = Number(req.params.id);
  const b: Record<string, unknown> = {};
  for (const k of ["provider", "label", "baseUrl", "isActive"]) if (k in (req.body ?? {})) b[k] = (req.body as any)[k];
  // Only overwrite secrets when explicitly provided (and non-empty)
  if (typeof req.body?.apiKey === "string" && req.body.apiKey.length > 0 && !req.body.apiKey.includes("•")) b.apiKey = req.body.apiKey;
  if (typeof req.body?.apiSecret === "string" && req.body.apiSecret.length > 0 && !req.body.apiSecret.includes("•")) b.apiSecret = req.body.apiSecret;
  if (typeof b.isActive !== "undefined") b.isActive = String(b.isActive);
  const [r] = await db.update(adminApiKeysTable).set(b).where(eq(adminApiKeysTable.id, id)).returning();
  if (!r) { res.status(404).json({ error: "Not found" }); return; }
  res.json({ ...r, apiKey: maskSecret(r.apiKey), apiSecret: maskSecret(r.apiSecret) });
});
router.delete("/admin/api-keys/:id", requireAuth, adminOnly, async (req, res): Promise<void> => {
  await db.delete(adminApiKeysTable).where(eq(adminApiKeysTable.id, Number(req.params.id)));
  res.sendStatus(204);
});

// ─── Admin: coin search (extends /admin/coins) ────────────────────────────────
router.get("/admin/coins-search", requireAuth, supportPlus, async (req, res): Promise<void> => {
  const q = (req.query.q as string) || "";
  const rows = q
    ? await db.select().from(coinsTable).where(or(ilike(coinsTable.symbol, `%${q}%`), ilike(coinsTable.name, `%${q}%`))).orderBy(coinsTable.symbol).limit(200)
    : await db.select().from(coinsTable).orderBy(coinsTable.symbol).limit(200);
  res.json(rows);
});

export default router;
