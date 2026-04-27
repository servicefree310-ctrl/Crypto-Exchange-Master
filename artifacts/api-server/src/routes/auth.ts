import { Router, type IRouter } from "express";
import { eq, or } from "drizzle-orm";
import { db, usersTable, loginLogsTable, walletsTable, coinsTable } from "@workspace/db";
import {
  hashPassword,
  verifyPassword,
  createSession,
  destroySession,
  readSessionCookie,
  generateReferralCode,
  generateUid,
  sanitizeUser,
  SESSION_COOKIE,
} from "../lib/auth";
import { requireAuth } from "../middlewares/auth";

const router: IRouter = Router();

const COOKIE_OPTS = {
  httpOnly: true,
  // strict: cookie is never sent on cross-site requests — the strongest
  // built-in CSRF defense. Combined with the originGuard middleware in
  // app.ts this gives belt-and-braces protection. All our web clients
  // (admin, user-portal, flutter web) are same-site to the API, so this
  // is safe. Mobile Expo uses Bearer tokens via the bicrypto adapter and
  // is unaffected by cookie SameSite.
  sameSite: "strict" as const,
  path: "/",
  maxAge: 14 * 24 * 60 * 60 * 1000,
  secure: process.env.NODE_ENV === "production",
};

router.post("/auth/register", async (req, res): Promise<void> => {
  const { email, phone, password, name, referralCode } = req.body ?? {};
  if (!email || !password || password.length < 6) {
    res.status(400).json({ error: "Email and a 6+ char password are required" });
    return;
  }
  const existing = await db
    .select()
    .from(usersTable)
    .where(or(eq(usersTable.email, email), phone ? eq(usersTable.phone, phone) : eq(usersTable.email, email)))
    .limit(1);
  if (existing.length > 0) {
    res.status(409).json({ error: "User already exists" });
    return;
  }
  let referredBy: number | null = null;
  if (referralCode) {
    const [r] = await db.select().from(usersTable).where(eq(usersTable.referralCode, referralCode)).limit(1);
    if (r) referredBy = r.id;
  }
  const passwordHash = await hashPassword(password);
  const [user] = await db
    .insert(usersTable)
    .values({
      email,
      phone: phone || null,
      passwordHash,
      name: name || "",
      referralCode: generateReferralCode(),
      uid: generateUid(),
      referredBy,
      role: "user",
    })
    .returning();
  if (!user) {
    res.status(500).json({ error: "Failed to create user" });
    return;
  }

  // Initialize INR + USDT spot wallets at zero
  const inrCoin = await db.select().from(coinsTable).where(eq(coinsTable.symbol, "INR")).limit(1);
  const usdtCoin = await db.select().from(coinsTable).where(eq(coinsTable.symbol, "USDT")).limit(1);
  const inits = [];
  if (inrCoin[0]) {
    inits.push({ userId: user.id, walletType: "inr", coinId: inrCoin[0].id, balance: "0" });
    inits.push({ userId: user.id, walletType: "spot", coinId: inrCoin[0].id, balance: "0" });
  }
  if (usdtCoin[0]) {
    inits.push({ userId: user.id, walletType: "spot", coinId: usdtCoin[0].id, balance: "0" });
  }
  if (inits.length) await db.insert(walletsTable).values(inits);

  const token = await createSession(user.id, req);
  res.cookie(SESSION_COOKIE, token, COOKIE_OPTS);
  res.status(201).json({ user: sanitizeUser(user) });
});

router.post("/auth/login", async (req, res): Promise<void> => {
  const { email, password } = req.body ?? {};
  if (!email || !password) {
    res.status(400).json({ error: "Email and password required" });
    return;
  }
  const ip = (req.headers["x-forwarded-for"] as string) || req.socket.remoteAddress || null;
  const ua = req.headers["user-agent"] || null;

  const [user] = await db
    .select()
    .from(usersTable)
    .where(or(eq(usersTable.email, email), eq(usersTable.phone, email)))
    .limit(1);

  if (!user) {
    await db.insert(loginLogsTable).values({ email, ip, userAgent: ua, success: "false", reason: "no_user" });
    res.status(401).json({ error: "Invalid credentials" });
    return;
  }
  const ok = await verifyPassword(password, user.passwordHash);
  if (!ok) {
    await db.insert(loginLogsTable).values({ userId: user.id, email, ip, userAgent: ua, success: "false", reason: "bad_password" });
    res.status(401).json({ error: "Invalid credentials" });
    return;
  }
  if (user.status !== "active") {
    res.status(403).json({ error: "Account suspended" });
    return;
  }
  await db.insert(loginLogsTable).values({ userId: user.id, email, ip, userAgent: ua, success: "true" });
  await db.update(usersTable).set({ lastLoginAt: new Date() }).where(eq(usersTable.id, user.id));
  const token = await createSession(user.id, req);
  res.cookie(SESSION_COOKIE, token, COOKIE_OPTS);
  res.json({ user: sanitizeUser(user) });
});

router.post("/auth/logout", async (req, res): Promise<void> => {
  const token = readSessionCookie(req);
  await destroySession(token);
  res.clearCookie(SESSION_COOKIE, { path: "/" });
  res.json({ ok: true });
});

router.get("/auth/me", requireAuth, async (req, res): Promise<void> => {
  res.json({ user: sanitizeUser(req.user!) });
});

export default router;
