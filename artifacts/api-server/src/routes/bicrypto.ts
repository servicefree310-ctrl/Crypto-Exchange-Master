// Bicrypto v5 API contract adapter for Flutter mobile app.
// Maps the Bicrypto-shaped endpoints onto the existing Node API server,
// returning real data where we have it and safe empty stubs elsewhere
// so the Flutter UI can mount every screen without crashing.

import { Router, type IRouter, type Request, type Response, type NextFunction } from "express";
import { eq, or, and, desc } from "drizzle-orm";
import {
  db, usersTable, loginLogsTable, walletsTable, coinsTable, pairsTable, sessionsTable,
} from "@workspace/db";
import {
  hashPassword, verifyPassword, generateReferralCode, generateUid,
} from "../lib/auth";
import { signJwt, verifyJwt, newCsrfToken, newSessionId, powHash } from "../lib/jwt";
import { getCache } from "../lib/price-service";
import { randomBytes, createHash } from "node:crypto";

const r: IRouter = Router();

// ──────────────────────────────────────────────────────────────────────────
// Bicrypto-style auth: JWT in cookie + Authorization: Bearer header.
// ──────────────────────────────────────────────────────────────────────────

const ACCESS_COOKIE = "accessToken";
const SESSION_COOKIE = "sessionId";
const CSRF_COOKIE = "csrfToken";

function cookieOpts() {
  return {
    httpOnly: true as const,
    sameSite: "lax" as const,
    path: "/",
    maxAge: 14 * 24 * 60 * 60 * 1000,
    secure: process.env.NODE_ENV === "production",
  };
}

function setAuthCookies(res: Response, accessToken: string, sessionId: string, csrfToken: string) {
  res.cookie(ACCESS_COOKIE, accessToken, cookieOpts());
  res.cookie(SESSION_COOKIE, sessionId, cookieOpts());
  res.cookie(CSRF_COOKIE, csrfToken, { ...cookieOpts(), httpOnly: false });
}
function clearAuthCookies(res: Response) {
  for (const c of [ACCESS_COOKIE, SESSION_COOKIE, CSRF_COOKIE]) res.clearCookie(c, { path: "/" });
}

function readBearer(req: Request): string | undefined {
  const h = req.headers.authorization;
  if (h && h.startsWith("Bearer ")) return h.slice(7);
  const cookies = (req as any).cookies as Record<string, string> | undefined;
  return cookies?.[ACCESS_COOKIE];
}

async function bicryptoAuth(req: Request, res: Response, next: NextFunction) {
  const tok = readBearer(req);
  if (!tok) { res.status(401).json({ message: "Unauthorized" }); return; }
  const decoded = verifyJwt(tok);
  if (!decoded?.sub?.id) { res.status(401).json({ message: "Invalid token" }); return; }
  const id = Number(decoded.sub.id);
  if (!Number.isFinite(id)) { res.status(401).json({ message: "Invalid token" }); return; }
  const [u] = await db.select().from(usersTable).where(eq(usersTable.id, id)).limit(1);
  if (!u) { res.status(401).json({ message: "User not found" }); return; }
  if (u.status !== "active") { res.status(403).json({ message: "Account suspended" }); return; }
  (req as any).bcUser = u;
  next();
}

const optionalAuth = async (req: Request, _res: Response, next: NextFunction) => {
  const tok = readBearer(req);
  if (tok) {
    const decoded = verifyJwt(tok);
    if (decoded?.sub?.id) {
      const id = Number(decoded.sub.id);
      const [u] = await db.select().from(usersTable).where(eq(usersTable.id, id)).limit(1);
      if (u) (req as any).bcUser = u;
    }
  }
  next();
};

function userToBicrypto(u: any) {
  const [first, ...rest] = String(u.name || "").split(" ");
  return {
    id: String(u.id),
    firstName: first || "User",
    lastName: rest.join(" ") || "",
    email: u.email,
    phone: u.phone || null,
    avatar: u.avatarUrl || null,
    emailVerified: true,
    status: u.status === "active" ? "ACTIVE" : "SUSPENDED",
    role: String(u.role === "admin" || u.role === "superadmin" ? 2 : u.role === "support" ? 1 : 0),
    emailVerifiedAt: u.createdAt,
    createdAt: u.createdAt,
    updatedAt: u.updatedAt ?? u.createdAt,
    twoFactor: u.twoFaEnabled
      ? { id: String(u.id), userId: String(u.id), type: "EMAIL", enabled: true }
      : null,
    author: null,
  };
}

function makeAuthBundle(user: any) {
  const accessToken = signJwt({ id: String(user.id), role: user.role === "admin" || user.role === "superadmin" ? 2 : 0, email: user.email });
  const sessionId = newSessionId();
  const csrfToken = newCsrfToken();
  return { accessToken, sessionId, csrfToken };
}

// ──────────────────────────────────────────────────────────────────────────
// PoW captcha — trivial difficulty so client solves instantly
// ──────────────────────────────────────────────────────────────────────────

const POW_DIFFICULTY = 1; // leading zeros required in hex hash
const powIssued = new Map<string, number>(); // challenge -> issuedAt
function purgePow() {
  const cutoff = Date.now() - 10 * 60_000;
  for (const [k, v] of powIssued) if (v < cutoff) powIssued.delete(k);
}

r.get("/auth/pow/challenge", (_req, res) => {
  purgePow();
  const challenge = randomBytes(16).toString("hex");
  powIssued.set(challenge, Date.now());
  res.json({ challenge, difficulty: POW_DIFFICULTY });
});

function verifyPow(solution: any): boolean {
  if (!solution?.challenge || solution.nonce === undefined) return false;
  if (!powIssued.has(solution.challenge)) return false;
  const hash = powHash(solution.challenge, solution.nonce);
  const need = "0".repeat(POW_DIFFICULTY);
  if (!hash.startsWith(need)) return false;
  powIssued.delete(solution.challenge);
  return true;
}

// ──────────────────────────────────────────────────────────────────────────
// Auth: login (Flutter), register, logout, refresh, 2FA, password reset
// ──────────────────────────────────────────────────────────────────────────

r.post("/auth/login/flutter", async (req, res): Promise<void> => {
  const { email, password } = req.body ?? {};
  if (!email || !password) { res.status(400).json({ message: "Email and password required" }); return; }
  const ip = (req.headers["x-forwarded-for"] as string) || req.socket.remoteAddress || null;
  const ua = req.headers["user-agent"] || null;

  const [user] = await db.select().from(usersTable)
    .where(or(eq(usersTable.email, String(email).toLowerCase()), eq(usersTable.phone, String(email))))
    .limit(1);

  if (!user) {
    await db.insert(loginLogsTable).values({ email, ip, userAgent: ua, success: "false", reason: "no_user" });
    res.status(401).json({ message: "Invalid credentials" }); return;
  }
  if (!(await verifyPassword(password, user.passwordHash))) {
    await db.insert(loginLogsTable).values({ userId: user.id, email, ip, userAgent: ua, success: "false", reason: "bad_password" });
    res.status(401).json({ message: "Invalid credentials" }); return;
  }
  if (user.status !== "active") { res.status(403).json({ message: "Account suspended" }); return; }

  // 2FA gate
  if (user.twoFaEnabled) {
    res.json({
      id: String(user.id),
      message: "Two-factor verification required",
      twoFactor: { enabled: true, type: "EMAIL" },
    });
    return;
  }

  await db.insert(loginLogsTable).values({ userId: user.id, email, ip, userAgent: ua, success: "true" });
  const bundle = makeAuthBundle(user);
  setAuthCookies(res, bundle.accessToken, bundle.sessionId, bundle.csrfToken);
  res.json({ message: "Login successful", cookies: bundle, user: userToBicrypto(user) });
});

r.post("/auth/register", async (req, res): Promise<void> => {
  const { firstName, lastName, email, password, ref, powSolution } = req.body ?? {};
  if (!email || !password || password.length < 6) {
    res.status(400).json({ message: "Email and a 6+ char password are required" }); return;
  }
  if (!verifyPow(powSolution)) {
    res.status(400).json({ message: "Invalid PoW solution" }); return;
  }
  const lower = String(email).toLowerCase();
  const [existing] = await db.select().from(usersTable).where(eq(usersTable.email, lower)).limit(1);
  if (existing) { res.status(409).json({ message: "User already exists" }); return; }

  let referredBy: number | null = null;
  if (ref) {
    const [refUser] = await db.select().from(usersTable).where(eq(usersTable.referralCode, ref)).limit(1);
    if (refUser) referredBy = refUser.id;
  }
  const fullName = [firstName, lastName].filter(Boolean).join(" ").trim();
  const passwordHash = await hashPassword(password);
  const [user] = await db.insert(usersTable).values({
    email: lower,
    passwordHash,
    name: fullName || lower.split("@")[0],
    referralCode: generateReferralCode(),
    uid: generateUid(),
    referredBy,
    role: "user",
  }).returning();
  if (!user) { res.status(500).json({ message: "Failed to create user" }); return; }

  // Initialize default wallets at zero
  const inrCoin = await db.select().from(coinsTable).where(eq(coinsTable.symbol, "INR")).limit(1);
  const usdtCoin = await db.select().from(coinsTable).where(eq(coinsTable.symbol, "USDT")).limit(1);
  const btcCoin = await db.select().from(coinsTable).where(eq(coinsTable.symbol, "BTC")).limit(1);
  const inits: any[] = [];
  if (inrCoin[0]) {
    inits.push({ userId: user.id, walletType: "inr", coinId: inrCoin[0].id, balance: "0" });
  }
  if (usdtCoin[0]) {
    inits.push({ userId: user.id, walletType: "spot", coinId: usdtCoin[0].id, balance: "0" });
    inits.push({ userId: user.id, walletType: "futures", coinId: usdtCoin[0].id, balance: "0" });
  }
  if (btcCoin[0]) {
    inits.push({ userId: user.id, walletType: "spot", coinId: btcCoin[0].id, balance: "0" });
  }
  if (inits.length) await db.insert(walletsTable).values(inits);

  const bundle = makeAuthBundle(user);
  setAuthCookies(res, bundle.accessToken, bundle.sessionId, bundle.csrfToken);
  res.json({ message: "Registration successful", cookies: bundle, user: userToBicrypto(user) });
});

r.post("/auth/logout", (_req, res) => {
  clearAuthCookies(res);
  // Also clear the legacy admin SESSION cookie for compatibility.
  res.clearCookie("session", { path: "/" });
  res.json({ message: "Logged out" });
});

r.post("/auth/refresh", async (req, res): Promise<void> => {
  const tok = readBearer(req);
  if (!tok) { res.status(401).json({ message: "Unauthorized" }); return; }
  const decoded = verifyJwt(tok);
  if (!decoded?.sub?.id) { res.status(401).json({ message: "Invalid token" }); return; }
  const id = Number(decoded.sub.id);
  const [u] = await db.select().from(usersTable).where(eq(usersTable.id, id)).limit(1);
  if (!u) { res.status(401).json({ message: "User not found" }); return; }
  const bundle = makeAuthBundle(u);
  setAuthCookies(res, bundle.accessToken, bundle.sessionId, bundle.csrfToken);
  res.json({ message: "Token refreshed", cookies: bundle });
});

// 2FA verification — NOT IMPLEMENTED.
// Returning 501 here is intentional: a previous draft of this stub minted
// auth cookies for any submitted OTP, which would let an attacker bypass
// 2FA entirely. Until the OTP delivery channel + verification storage is
// wired up properly, this endpoint MUST refuse to issue credentials.
r.post("/auth/otp/login", async (_req, res): Promise<void> => {
  res.status(501).json({ message: "2FA login not implemented" });
});

// 2FA verification — NOT IMPLEMENTED.
// Previous draft accepted only userId (no OTP, no auth guard) and replied
// "verified", which both violates the security contract and lets unauth'd
// callers probe user existence by ID. Refuse until the OTP delivery +
// verification path is wired up.
r.post("/auth/2fa", async (_req, res): Promise<void> => {
  res.status(501).json({ message: "2FA verification not implemented" });
});

r.post("/auth/otp/resend", (_req, res) => res.json({ message: "OTP sent" }));
r.post("/auth/reset", (_req, res) => res.json({ message: "Reset email sent" }));
r.post("/auth/reset/confirm", (_req, res) => res.json({ message: "Password reset" }));
r.post("/auth/change-password", bicryptoAuth, async (req: any, res): Promise<void> => {
  const { currentPassword, newPassword } = req.body ?? {};
  if (!currentPassword || !newPassword || newPassword.length < 6) {
    res.status(400).json({ message: "Both passwords required (newPassword 6+ chars)" }); return;
  }
  const u = req.bcUser;
  if (!(await verifyPassword(currentPassword, u.passwordHash))) {
    res.status(400).json({ message: "Current password wrong" }); return;
  }
  await db.update(usersTable).set({ passwordHash: await hashPassword(newPassword), updatedAt: new Date() }).where(eq(usersTable.id, u.id));
  res.json({ message: "Password changed" });
});
r.post("/auth/verify", (_req, res) => res.json({ message: "Email verified" }));
r.post("/auth/login/google", (_req, res) => res.status(501).json({ message: "Google login not configured" }));
r.post("/auth/register/google", (_req, res) => res.status(501).json({ message: "Google register not configured" }));

// ──────────────────────────────────────────────────────────────────────────
// User: profile, settings, notifications, watchlist, support
// ──────────────────────────────────────────────────────────────────────────

r.get("/user/profile", bicryptoAuth, (req: any, res) => res.json(userToBicrypto(req.bcUser)));
r.put("/user/profile", bicryptoAuth, async (req: any, res): Promise<void> => {
  const { firstName, lastName, phone, avatar } = req.body ?? {};
  const name = [firstName, lastName].filter(Boolean).join(" ").trim();
  const fields: any = {};
  if (name) fields.name = name;
  if (phone !== undefined) fields.phone = phone;
  if (avatar !== undefined) fields.avatarUrl = avatar;
  if (Object.keys(fields).length === 0) { res.json(userToBicrypto(req.bcUser)); return; }
  fields.updatedAt = new Date();
  const [u] = await db.update(usersTable).set(fields).where(eq(usersTable.id, req.bcUser.id)).returning();
  res.json(userToBicrypto(u));
});

r.get("/user/settings", bicryptoAuth, (_req, res) =>
  res.json({ theme: "dark", language: "en", notifications: { email: true, push: true } }));
r.put("/user/settings", bicryptoAuth, (req, res) => res.json(req.body ?? {}));

r.get("/user/notification", bicryptoAuth, (_req, res) =>
  res.json({ items: [], pagination: emptyPg() }));
r.delete("/user/notification/:id", bicryptoAuth, (_req, res) => res.json({ message: "Deleted" }));

r.get("/user/watchlist", bicryptoAuth, (_req, res) => res.json({ items: [], pagination: emptyPg() }));
r.post("/user/watchlist", bicryptoAuth, (_req, res) => res.json({ message: "Added" }));

// KYC
r.get("/user/kyc/status", bicryptoAuth, (req: any, res) => res.json({
  status: req.bcUser.kycLevel ? "APPROVED" : "NOT_STARTED",
  level: req.bcUser.kycLevel ?? 0,
  applications: [],
}));
r.get("/user/kyc/level", (_req, res) => res.json({ items: [], pagination: emptyPg() }));
r.get("/user/kyc/level/:id", (_req, res) => res.status(404).json({ message: "Not found" }));
r.get("/user/kyc/application", bicryptoAuth, (_req, res) => res.json({ items: [], pagination: emptyPg() }));
r.post("/user/kyc/application", bicryptoAuth, (_req, res) => res.json({ message: "Submitted", id: "stub" }));

// Support tickets
r.get("/user/support/ticket", bicryptoAuth, (_req, res) => res.json({ items: [], pagination: emptyPg() }));
r.post("/user/support/ticket", bicryptoAuth, (_req, res) => res.status(501).json({ message: "Support ticketing coming soon" }));

// ──────────────────────────────────────────────────────────────────────────
// Settings (public)
// ──────────────────────────────────────────────────────────────────────────

r.get("/settings", (_req, res) => {
  res.json({
    settings: [
      { key: "siteName", value: "BiCrypto" },
      { key: "siteDescription", value: "Crypto Exchange" },
      { key: "logo", value: "/flutter/icons/Icon-192.png" },
      { key: "defaultCurrency", value: "USDT" },
      { key: "kycEnabled", value: "false" },
      { key: "p2pEnabled", value: "false" },
      { key: "stakingEnabled", value: "false" },
      { key: "icoEnabled", value: "false" },
      { key: "ecommerceEnabled", value: "false" },
      { key: "blogEnabled", value: "false" },
      { key: "mlmEnabled", value: "false" },
      { key: "futuresEnabled", value: "true" },
      { key: "spotEnabled", value: "true" },
      { key: "depositsEnabled", value: "true" },
      { key: "withdrawalsEnabled", value: "true" },
      { key: "googleAuthStatus", value: "false" },
      { key: "registrationEnabled", value: "true" },
      { key: "twoFactorEnabled", value: "true" },
    ],
    extensions: [],
  });
});
// Flutter posts to /settings; admin clients PUT. Accept both.
const upsertSettings = (req: Request, res: Response) =>
  res.json(req.body ?? { settings: [], extensions: [] });
r.put("/settings", bicryptoAuth, upsertSettings);
r.post("/settings", bicryptoAuth, upsertSettings);

// ──────────────────────────────────────────────────────────────────────────
// Wallets — paginated grouped by type
// ──────────────────────────────────────────────────────────────────────────

function emptyPg(perPage = 10) {
  return { total: 0, page: 1, perPage, totalPages: 0 };
}

function walletTypeOut(t: string): "FIAT" | "SPOT" | "FUTURES" | "ECO" {
  switch (t) {
    case "inr": return "FIAT";
    case "futures": return "FUTURES";
    case "earn": return "ECO";
    default: return "SPOT";
  }
}
function walletTypeIn(t: string): "spot" | "futures" | "earn" | "inr" {
  switch ((t || "").toUpperCase()) {
    case "FIAT": return "inr";
    case "FUTURES": return "futures";
    case "ECO": return "earn";
    default: return "spot";
  }
}

function walletToBicrypto(w: any, coin: any) {
  return {
    id: String(w.id),
    userId: String(w.userId),
    type: walletTypeOut(w.walletType),
    currency: coin?.symbol || "UNKNOWN",
    balance: Number(w.balance ?? 0),
    inOrder: Number(w.locked ?? 0),
    address: null,
    icon: coin?.logoUrl || null,
    status: true,
    createdAt: (w.updatedAt ?? new Date()).toISOString?.() ?? String(w.updatedAt),
    updatedAt: (w.updatedAt ?? new Date()).toISOString?.() ?? String(w.updatedAt),
  };
}

r.get("/finance/wallet", bicryptoAuth, async (req: any, res): Promise<void> => {
  // PnL summary mode
  if (req.query.pnl === "true") {
    const today = await sumUsd(req.bcUser.id);
    res.json({ today, yesterday: today, pnl: 0, chart: Array.from({ length: 28 }, (_, i) => ({ t: Date.now() - (27 - i) * 86400000, v: today })) });
    return;
  }
  const page = Math.max(1, Number(req.query.page) || 1);
  const perPage = Math.min(200, Math.max(1, Number(req.query.perPage) || 100));
  const userId = req.bcUser.id;

  const wallets = await db.select().from(walletsTable).where(eq(walletsTable.userId, userId));
  const coinIds = Array.from(new Set(wallets.map(w => w.coinId)));
  const coins = coinIds.length
    ? await db.select().from(coinsTable).where(or(...coinIds.map(id => eq(coinsTable.id, id)))!)
    : [];
  const coinById = new Map(coins.map(c => [c.id, c]));

  const items = wallets.map(w => walletToBicrypto(w, coinById.get(w.coinId)));
  const start = (page - 1) * perPage;
  const slice = items.slice(start, start + perPage);
  res.json({
    items: slice,
    pagination: { total: items.length, page, perPage, totalPages: Math.ceil(items.length / perPage) },
  });
});

async function sumUsd(userId: number): Promise<number> {
  const wallets = await db.select().from(walletsTable).where(eq(walletsTable.userId, userId));
  if (!wallets.length) return 0;
  const coinIds = Array.from(new Set(wallets.map(w => w.coinId)));
  const coins = await db.select().from(coinsTable).where(or(...coinIds.map(id => eq(coinsTable.id, id)))!);
  const ticks = getCache();
  let total = 0;
  for (const w of wallets) {
    const c = coins.find(x => x.id === w.coinId);
    if (!c) continue;
    const bal = Number(w.balance) + Number(w.locked);
    if (c.symbol === "USDT" || c.symbol === "USD") { total += bal; continue; }
    if (c.symbol === "INR") { total += bal / 83; continue; }
    const t = ticks.find((tk: any) => tk.symbol === c.symbol);
    if (t?.usdt) total += bal * Number(t.usdt);
  }
  return Math.round(total * 100) / 100;
}

r.get("/finance/wallet/:type/:currency", bicryptoAuth, async (req: any, res): Promise<void> => {
  const wt = walletTypeIn(req.params.type);
  const sym = String(req.params.currency).toUpperCase();
  const [coin] = await db.select().from(coinsTable).where(eq(coinsTable.symbol, sym)).limit(1);
  if (!coin) { res.status(404).json({ message: "Currency not found" }); return; }
  const [w] = await db.select().from(walletsTable).where(and(
    eq(walletsTable.userId, req.bcUser.id), eq(walletsTable.coinId, coin.id), eq(walletsTable.walletType, wt),
  )).limit(1);
  if (!w) {
    // Auto-create
    const [created] = await db.insert(walletsTable).values({
      userId: req.bcUser.id, coinId: coin.id, walletType: wt, balance: "0", locked: "0",
    }).returning();
    res.json(walletToBicrypto(created, coin)); return;
  }
  res.json(walletToBicrypto(w, coin));
});

r.get("/finance/wallet/symbol", bicryptoAuth, async (req: any, res): Promise<void> => {
  const wt = walletTypeIn(String(req.query.type || "SPOT"));
  const cur = String(req.query.currency || "").toUpperCase();
  const pair = String(req.query.pair || "").toUpperCase();
  const [c1] = await db.select().from(coinsTable).where(eq(coinsTable.symbol, cur)).limit(1);
  const [c2] = await db.select().from(coinsTable).where(eq(coinsTable.symbol, pair)).limit(1);
  let CURRENCY = 0, PAIR = 0;
  if (c1) {
    const [w] = await db.select().from(walletsTable).where(and(
      eq(walletsTable.userId, req.bcUser.id), eq(walletsTable.coinId, c1.id), eq(walletsTable.walletType, wt),
    )).limit(1);
    if (w) CURRENCY = Number(w.balance);
  }
  if (c2) {
    const [w] = await db.select().from(walletsTable).where(and(
      eq(walletsTable.userId, req.bcUser.id), eq(walletsTable.coinId, c2.id), eq(walletsTable.walletType, wt),
    )).limit(1);
    if (w) PAIR = Number(w.balance);
  }
  res.json({ CURRENCY, PAIR });
});

r.get("/finance/wallet/transfer-options", bicryptoAuth, (_req, res) =>
  res.json({ from: ["FIAT", "SPOT", "FUTURES", "ECO"], to: ["FIAT", "SPOT", "FUTURES", "ECO"] }));

r.get("/finance/transaction", bicryptoAuth, (_req, res) => res.json({ items: [], pagination: emptyPg() }));

// Currency listings
r.get("/finance/currency", async (req, res): Promise<void> => {
  const action = String(req.query.action || "deposit");
  const walletType = walletTypeIn(String(req.query.walletType || "SPOT"));
  const coins = await db.select().from(coinsTable);
  const items = coins
    .filter(c => walletType === "inr" ? c.symbol === "INR" : c.symbol !== "INR")
    .map(c => ({
      id: String(c.id), currency: c.symbol, name: c.name, icon: c.logoUrl,
      precision: c.decimals ?? 8, status: c.status === "active",
      action,
    }));
  res.json(items);
});
r.get("/finance/currency/:type", async (req, res): Promise<void> => {
  const walletType = walletTypeIn(req.params.type);
  const coins = await db.select().from(coinsTable);
  const items = coins
    .filter(c => walletType === "inr" ? c.symbol === "INR" : c.symbol !== "INR")
    .map(c => ({ currency: c.symbol, name: c.name, icon: c.logoUrl, networks: ["TRC20", "ERC20", "BEP20"], status: true }));
  res.json(items);
});
r.get("/finance/currency/:type/:currency", async (req, res): Promise<void> => {
  const sym = String(req.params.currency).toUpperCase();
  const [c] = await db.select().from(coinsTable).where(eq(coinsTable.symbol, sym)).limit(1);
  if (!c) { res.status(404).json({ message: "Not found" }); return; }
  res.json({
    currency: c.symbol, name: c.name, icon: c.logoUrl,
    networks: [
      { chain: "TRC20", fee: 1, minWithdraw: 10, address: "T" + randomBytes(16).toString("hex") },
      { chain: "ERC20", fee: 5, minWithdraw: 30, address: "0x" + randomBytes(20).toString("hex") },
    ],
    status: true,
  });
});

r.post("/finance/deposit/spot", bicryptoAuth, (_req, res) => res.json({ message: "Use one of the listed deposit addresses" }));
r.post("/finance/withdraw", bicryptoAuth, (_req, res) => res.status(501).json({ message: "Withdrawals are admin-managed" }));
r.post("/finance/withdraw/spot", bicryptoAuth, (_req, res) => res.status(501).json({ message: "Withdrawals coming soon" }));
r.post("/finance/withdraw/fiat", bicryptoAuth, (_req, res) => res.status(501).json({ message: "Fiat withdrawals coming soon" }));
r.post("/finance/transfer", bicryptoAuth, (_req, res) => res.status(501).json({ message: "Use the existing /api/transfer endpoint" }));
r.post("/finance/transfer/validate", bicryptoAuth, (_req, res) => res.json({ valid: true }));

// ──────────────────────────────────────────────────────────────────────────
// Exchange: market, ticker, orderbook, trades, chart
// ──────────────────────────────────────────────────────────────────────────

function pairToMarket(p: any, coinById: Map<number, any>) {
  const base = coinById.get(p.baseCoinId)?.symbol || "BTC";
  const quote = coinById.get(p.quoteCoinId)?.symbol || "USDT";
  return {
    id: String(p.id),
    symbol: `${base}/${quote}`,
    currency: base,
    pair: quote,
    isTrending: false,
    isHot: false,
    status: p.status === "active",
    isEco: false,
    icon: null,
    metadata: {
      taker: 0.001, maker: 0.001,
      precision: { price: Number(p.pricePrecision ?? 2), amount: Number(p.qtyPrecision ?? 4) },
      limits: {
        amount: { min: Number(p.minQty ?? 0), max: null },
        price: { min: 0, max: null },
        cost: { min: 0, max: null },
        leverage: p.futuresEnabled ? { min: 1, max: Number(p.maxLeverage ?? 100) } : null,
      },
    },
  };
}

async function loadCoinMap(): Promise<Map<number, any>> {
  const coins = await db.select().from(coinsTable);
  return new Map(coins.map(c => [c.id, c]));
}

r.get("/exchange/market", async (_req, res): Promise<void> => {
  const pairs = await db.select().from(pairsTable).where(eq(pairsTable.status, "active"));
  const coinMap = await loadCoinMap();
  res.json(pairs.map(p => pairToMarket(p, coinMap)));
});

// Build a ticker entry from a Tick + the quote symbol (USDT or INR).
// `change` is exposed as a percentage to match the Bicrypto/Flutter contract
// (TickerModel reads it as a percent-style value). `change24h <= -100` is
// guarded to avoid divide-by-zero / inverted prices in synthetic OHLC.
function tickerEntry(t: any, quote: string) {
  const px = quote === "INR" ? Number(t.inr ?? 0) : Number(t.usdt ?? 0);
  const pctRaw = Number(t.change24h ?? 0);
  const pct = pctRaw <= -100 ? -99.99 : pctRaw;
  const openSafe = px / (1 + pct / 100);
  return {
    last: px, bid: px * 0.999, ask: px * 1.001,
    high: px * (1 + Math.max(pct, 0) / 100),
    low: px * (1 + Math.min(pct, 0) / 100),
    open: openSafe, close: px,
    change: pct,
    percentage: pct,
    baseVolume: Number(t.volume24h ?? 0),
    quoteVolume: Number(t.volume24h ?? 0) * px,
    timestamp: Number(t.ts ?? Date.now()),
  };
}

r.get("/exchange/ticker", async (_req, res): Promise<void> => {
  const ticks = getCache() as any[];
  const map: Record<string, any> = {};
  for (const t of ticks) {
    if (t.symbol === "USDT" || t.symbol === "INR") continue;
    map[`${t.symbol}/USDT`] = tickerEntry(t, "USDT");
    if (Number(t.inr) > 0) map[`${t.symbol}/INR`] = tickerEntry(t, "INR");
  }
  res.json(map);
});

r.get("/exchange/ticker/:currency/:pair", async (req, res): Promise<void> => {
  const cur = req.params.currency.toUpperCase();
  const quote = req.params.pair.toUpperCase();
  const ticks = getCache() as any[];
  const t = ticks.find(x => x.symbol === cur);
  if (!t) { res.json({ symbol: `${cur}/${quote}`, last: 0, bid: 0, ask: 0 }); return; }
  res.json({ symbol: `${cur}/${quote}`, ...tickerEntry(t, quote) });
});

r.get("/exchange/orderbook/:currency/:pair", async (req, res): Promise<void> => {
  const sym = `${req.params.currency.toUpperCase()}/${req.params.pair.toUpperCase()}`;
  const { getDepth } = await import("../lib/matching-engine");
  const depth = await getDepth(sym, 50);
  res.json({ symbol: sym, ...depth, timestamp: Date.now() });
});

r.get("/exchange/trades/:currency/:pair", async (req, res): Promise<void> => {
  const sym = `${req.params.currency.toUpperCase()}/${req.params.pair.toUpperCase()}`;
  const { getRecentTrades } = await import("../lib/matching-engine");
  const trades = await getRecentTrades(sym, 50);
  res.json(trades);
});

function buildChart(symbol: string, interval: string, limit: number) {
  const ticks = getCache() as any[];
  const base = symbol.split("/")[0];
  const quote = symbol.split("/")[1] || "USDT";
  const t = ticks.find(x => x.symbol === base);
  const last = t ? (quote === "INR" ? Number(t.inr) : Number(t.usdt)) || 50000 : 50000;
  const num = parseInt(interval, 10) || 1;
  const stepMs = interval.endsWith("m") ? num * 60000 : interval.endsWith("h") ? num * 3600000 : 86400000;
  const now = Date.now();
  return Array.from({ length: limit }, (_, i) => {
    const ts = now - (limit - i) * stepMs;
    const drift = Math.sin(i / 6) * last * 0.005;
    const open = last + drift;
    const close = last + Math.cos(i / 5) * last * 0.005;
    const high = Math.max(open, close) * 1.002;
    const low = Math.min(open, close) * 0.998;
    return [ts, open, high, low, close, last * 0.01];
  });
}

r.get("/exchange/chart", (req, res) => {
  const symbol = String(req.query.symbol || "BTC/USDT");
  const interval = String(req.query.interval || "1h");
  const limit = Math.min(500, Number(req.query.limit) || 100);
  res.json(buildChart(symbol, interval, limit));
});

r.get("/exchange/order", bicryptoAuth, (_req, res) => res.json({ items: [], pagination: emptyPg() }));
r.post("/exchange/order", bicryptoAuth, (_req, res) => res.status(501).json({ message: "Use /api/orders" }));
r.delete("/exchange/order/:id", bicryptoAuth, (_req, res) => res.json({ message: "Use /api/orders/:id/cancel" }));

// ──────────────────────────────────────────────────────────────────────────
// Futures (real impl in Task #2 — for now empty)
// ──────────────────────────────────────────────────────────────────────────

r.get("/futures/market", async (_req, res): Promise<void> => {
  const pairs = await db.select().from(pairsTable).where(eq(pairsTable.futuresEnabled, true));
  const coinMap = await loadCoinMap();
  res.json(pairs.map(p => pairToMarket(p, coinMap)));
});
// Flutter futures data sources expect either a raw list or `{data:[...]}` for
// list endpoints, and either an object or `{data:{}}` for write endpoints.
// Real implementations land in Task #2 (matching engine + futures service).
r.get("/futures/position", bicryptoAuth, (_req, res) => res.json({ data: [] }));
r.get("/futures/order", bicryptoAuth, (_req, res) => res.json({ data: [] }));

r.put("/futures/leverage", bicryptoAuth, (req, res) => {
  const { currency = "BTC", pair = "USDT", leverage = 10 } = req.body ?? {};
  res.json({
    data: {
      id: "stub",
      symbol: `${currency}/${pair}`,
      currency, pair,
      side: "LONG",
      leverage: Number(leverage),
      entryPrice: 0, markPrice: 0, liquidationPrice: 0,
      amount: 0, margin: 0, unrealizedPnl: 0,
      status: "OPEN",
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    },
  });
});

r.post("/futures/order", bicryptoAuth, (req, res) => {
  const b = req.body ?? {};
  res.json({
    data: {
      id: `stub-${Date.now()}`,
      symbol: `${b.currency}/${b.pair}`,
      currency: b.currency, pair: b.pair,
      type: b.type, side: b.side,
      amount: Number(b.amount ?? 0),
      price: Number(b.price ?? 0),
      leverage: Number(b.leverage ?? 1),
      stopLossPrice: b.stopLossPrice ?? null,
      takeProfitPrice: b.takeProfitPrice ?? null,
      status: "PENDING",
      filled: 0,
      createdAt: new Date().toISOString(),
    },
  });
});

r.delete("/futures/order/:id", bicryptoAuth, (req, res) => {
  res.json({ data: { id: req.params.id, status: "CANCELLED", createdAt: new Date().toISOString() } });
});

r.delete("/futures/position", bicryptoAuth, (req, res) => {
  const { currency = "BTC", pair = "USDT", side = "LONG" } = req.body ?? {};
  res.json({
    data: {
      id: "stub",
      symbol: `${currency}/${pair}`,
      currency, pair, side,
      status: "CLOSED",
      closedAt: new Date().toISOString(),
    },
  });
});
r.get("/futures/chart", (req, res) => {
  const symbol = String(req.query.symbol || "BTC/USDT");
  const interval = String(req.query.interval || "1h");
  const limit = Math.min(500, Number(req.query.limit) || 100);
  res.json(buildChart(symbol, interval, limit));
});

// ──────────────────────────────────────────────────────────────────────────
// Content + payment + every other Bicrypto-only domain → empty stubs
// ──────────────────────────────────────────────────────────────────────────

const okEmptyPg = (_req: Request, res: Response) => res.json({ items: [], pagination: emptyPg() });
const okEmptyArr = (_req: Request, res: Response) => res.json([]);
const okEmptyObj = (_req: Request, res: Response) => res.json({});

// Content
r.get("/content/announcements", okEmptyArr);
r.get("/content/faqs", okEmptyArr);
r.get("/faq", okEmptyArr);
r.get("/faq/category", okEmptyArr);

// Notifications, support extras
r.get("/support", okEmptyPg);
r.get("/support/ticket", bicryptoAuth, okEmptyPg);

// Payment
r.get("/payment/gateway", okEmptyArr);
r.get("/payment/method", okEmptyArr);

// Blog
r.get("/blog/post", okEmptyPg);
r.get("/blog/category", okEmptyArr);
r.get("/blog/tag", okEmptyArr);
r.get("/blog/author", okEmptyPg);
r.get("/blog/author/top", okEmptyArr);
r.get("/blog/comment", okEmptyPg);

// Ecommerce
r.get("/ecommerce/product", okEmptyPg);
r.get("/ecommerce/category", okEmptyArr);
r.get("/ecommerce/order", bicryptoAuth, okEmptyPg);
r.get("/ecommerce/wishlist", bicryptoAuth, okEmptyArr);
r.get("/ecommerce/landing", okEmptyObj);
r.get("/ecommerce/stats", okEmptyObj);
r.get("/ecommerce/shipping", okEmptyArr);

// P2P
r.get("/p2p/offer", okEmptyPg);
r.get("/p2p/offer/popularity", okEmptyArr);
r.get("/p2p/trade", bicryptoAuth, okEmptyPg);
r.get("/p2p/payment-method", okEmptyArr);
r.get("/p2p/market/stats", okEmptyObj);
r.get("/p2p/market/top", okEmptyArr);
r.get("/p2p/market/highlight", okEmptyArr);
r.get("/p2p/location", okEmptyArr);
r.get("/p2p/dashboard", optionalAuth, okEmptyObj);
r.get("/p2p/dashboard/stats", optionalAuth, okEmptyObj);
r.get("/p2p/dashboard/activity", optionalAuth, okEmptyArr);
r.get("/p2p/dashboard/portfolio", optionalAuth, okEmptyObj);
r.get("/p2p/dispute", optionalAuth, okEmptyPg);
r.get("/p2p/user/profile", bicryptoAuth, okEmptyObj);
r.get("/p2p/user/reviews", bicryptoAuth, okEmptyArr);
r.get("/p2p/review", okEmptyPg);

// ICO
r.get("/ico/offer", okEmptyPg);
r.get("/ico/offer/featured", okEmptyArr);
r.get("/ico/blockchain", okEmptyArr);
r.get("/ico/token/type", okEmptyArr);
r.get("/ico/plan", okEmptyArr);
r.get("/ico/stats", okEmptyObj);
r.get("/ico/portfolio", bicryptoAuth, okEmptyObj);
r.get("/ico/transaction", bicryptoAuth, okEmptyPg);
r.get("/ico/creator/token", bicryptoAuth, okEmptyPg);
r.get("/ico/creator/launch/plan", bicryptoAuth, okEmptyArr);
r.get("/ico/creator/investor", bicryptoAuth, okEmptyPg);
r.get("/ico/creator/stat", bicryptoAuth, okEmptyObj);
r.get("/ico/creator/performance", bicryptoAuth, okEmptyObj);

// Affiliate / MLM
r.get("/affiliate", optionalAuth, okEmptyObj);
r.get("/affiliate/landing", okEmptyObj);
r.get("/affiliate/referral", bicryptoAuth, okEmptyPg);
r.get("/affiliate/reward", bicryptoAuth, okEmptyPg);
r.get("/affiliate/network", bicryptoAuth, okEmptyObj);
r.get("/affiliate/condition", okEmptyArr);
r.get("/affiliate/analytics", bicryptoAuth, okEmptyObj);
r.get("/affiliate/performance", bicryptoAuth, okEmptyObj);
r.get("/affiliate/stats", bicryptoAuth, okEmptyObj);
r.get("/affiliate/commission", bicryptoAuth, okEmptyPg);

// Staking
r.get("/staking/pool", okEmptyPg);
r.get("/staking/stats", okEmptyObj);
r.get("/staking/position", bicryptoAuth, okEmptyPg);
r.get("/staking/user/summary", bicryptoAuth, okEmptyObj);
r.get("/staking/user/earnings", bicryptoAuth, okEmptyArr);

// Forex
r.get("/forex/currency", okEmptyArr);
r.get("/forex/plan", okEmptyArr);
r.get("/forex/investment", bicryptoAuth, okEmptyPg);
r.get("/forex/signal", okEmptyArr);

// AI
r.get("/ai/plan", okEmptyArr);
r.get("/ai/investment", bicryptoAuth, okEmptyPg);
r.get("/ai/investment/plan", okEmptyArr);
r.get("/ai/investment/log", bicryptoAuth, okEmptyPg);
r.get("/ai/trade", bicryptoAuth, okEmptyArr);

// Ecosystem
r.get("/ecosystem/token", okEmptyArr);
r.get("/ecosystem/master-wallet", bicryptoAuth, okEmptyArr);
r.get("/ecosystem/pool", okEmptyArr);
r.get("/ecosystem/staking", bicryptoAuth, okEmptyPg);
r.get("/ecosystem/wallet", bicryptoAuth, okEmptyArr);

// Upload (KYC etc)
r.post("/upload/kyc-document", bicryptoAuth, (_req, res) => res.json({ url: "https://placeholder.local/doc.png" }));

// Used by injectable.config (sanity check)
r.get("/healthz", (_req, res) => res.json({ ok: true, layer: "bicrypto" }));

export default r;
