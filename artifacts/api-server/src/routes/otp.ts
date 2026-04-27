import { Router, type IRouter } from "express";
import { eq, and, gte, sql, desc, isNull, gt } from "drizzle-orm";
import { createHash, randomInt } from "crypto";
import { db, otpCodesTable, otpProvidersTable, usersTable } from "@workspace/db";

const router: IRouter = Router();

const OTP_TTL_MIN = 10;
const RESEND_COOLDOWN_S = 30;
const MAX_ATTEMPTS = 5;

function gen6(): string {
  return String(100000 + randomInt(0, 900000));
}

function hashCode(code: string): string {
  return createHash("sha256").update(String(code).trim()).digest("hex");
}

const VALID_CHANNELS = new Set(["sms", "email"]);
const VALID_PURPOSES = new Set(["signup", "login", "withdraw", "kyc", "2fa", "reset"]);

router.post("/otp/send", async (req, res): Promise<void> => {
  const { channel, purpose, recipient } = req.body ?? {};
  if (!VALID_CHANNELS.has(channel)) { res.status(400).json({ error: "channel must be sms|email" }); return; }
  if (!VALID_PURPOSES.has(purpose)) { res.status(400).json({ error: "invalid purpose" }); return; }
  if (!recipient || String(recipient).length < 5) { res.status(400).json({ error: "recipient required" }); return; }

  // Cooldown: don't allow re-send for same recipient/purpose within 30s
  const sinceCutoff = new Date(Date.now() - RESEND_COOLDOWN_S * 1000);
  const recent = await db
    .select({ id: otpCodesTable.id, createdAt: otpCodesTable.createdAt })
    .from(otpCodesTable)
    .where(and(eq(otpCodesTable.recipient, String(recipient)), eq(otpCodesTable.purpose, purpose), gte(otpCodesTable.createdAt, sinceCutoff)))
    .orderBy(desc(otpCodesTable.createdAt))
    .limit(1);
  if (recent.length > 0) {
    const ageS = Math.ceil((Date.now() - new Date(recent[0].createdAt).getTime()) / 1000);
    res.status(429).json({ error: `Wait ${RESEND_COOLDOWN_S - ageS}s before resending` });
    return;
  }

  // Resolve user (optional)
  let userId: number | null = null;
  if (channel === "email") {
    const [u] = await db.select({ id: usersTable.id }).from(usersTable).where(eq(usersTable.email, String(recipient))).limit(1);
    if (u) userId = u.id;
  } else {
    const [u] = await db.select({ id: usersTable.id }).from(usersTable).where(eq(usersTable.phone, String(recipient))).limit(1);
    if (u) userId = u.id;
  }

  const code = gen6();
  const expiresAt = new Date(Date.now() + OTP_TTL_MIN * 60 * 1000);
  const [row] = await db.insert(otpCodesTable).values({
    userId, channel, purpose, recipient: String(recipient), code: hashCode(code), expiresAt,
  }).returning();

  // Look up active provider for this channel — if none, treat as dev mode
  const [provider] = await db.select().from(otpProvidersTable)
    .where(and(eq(otpProvidersTable.channel, channel), eq(otpProvidersTable.isActive, true)))
    .limit(1);

  const isDev = process.env.NODE_ENV !== "production";
  const hasProvider = !!provider;

  // TODO Phase 6: integrate msg91/twilio/sendgrid via provider config; for now we just log
  if (!hasProvider) {
    // Log so dev/admin can see it; never expose in prod response unless dev mode.
    // We log at warn so it stands out — running without an OTP provider is a
    // dev-only configuration. Code is redacted in prod (info-only fields).
    req.log.warn(
      { channel, recipient, purpose, devCode: isDev ? code : undefined },
      "OTP delivered via stdout — no provider configured",
    );
  }

  res.json({
    otpId: row.id,
    expiresInSec: OTP_TTL_MIN * 60,
    delivered: hasProvider ? true : false,
    // Only expose code when there's no provider AND we're in dev — useful for testing without SMS gateway
    devCode: !hasProvider && isDev ? code : undefined,
    message: hasProvider ? `Code sent via ${provider.provider}` : "No SMS/Email provider configured — code logged on server",
  });
});

router.post("/otp/verify", async (req, res): Promise<void> => {
  const { otpId, code } = req.body ?? {};
  if (!otpId || !code) { res.status(400).json({ error: "otpId and code required" }); return; }
  const [row] = await db.select().from(otpCodesTable).where(eq(otpCodesTable.id, Number(otpId))).limit(1);
  if (!row) { res.status(404).json({ error: "OTP not found" }); return; }
  if (row.verifiedAt) { res.json({ ok: true, alreadyVerified: true }); return; }
  if (new Date(row.expiresAt).getTime() < Date.now()) {
    res.status(410).json({ error: "OTP expired, request a new one" }); return;
  }
  if (row.attempts >= MAX_ATTEMPTS) {
    res.status(429).json({ error: "Too many attempts, request a new code" }); return;
  }
  if (hashCode(String(code)) !== row.code) {
    await db.update(otpCodesTable)
      .set({ attempts: sql`${otpCodesTable.attempts} + 1` })
      .where(eq(otpCodesTable.id, row.id));
    res.status(400).json({ error: "Incorrect code", attemptsLeft: MAX_ATTEMPTS - row.attempts - 1 });
    return;
  }
  await db.update(otpCodesTable).set({ verifiedAt: new Date() }).where(eq(otpCodesTable.id, row.id));
  res.json({ ok: true, otpId: row.id, purpose: row.purpose });
});

// Helper used by other routes (withdraw etc.) — atomic single-use consumer.
// Performs a conditional UPDATE; if 0 rows affected, the OTP cannot be consumed.
// Optionally accepts a transaction so it runs inside the caller's tx.
export async function consumeVerifiedOtp(opts: {
  otpId: number; purpose: string; recipient?: string; userId?: number;
  maxAgeMin?: number;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  tx?: any;
}): Promise<{ ok: true } | { ok: false; error: string }> {
  const exec = opts.tx ?? db;
  const maxAgeSec = (opts.maxAgeMin ?? 15) * 60;
  const nowMs = Date.now();
  // Atomic conditional update: succeeds only if verified, not yet consumed
  // (expires_at still in future), and matches purpose / user / recipient.
  const conds = [
    eq(otpCodesTable.id, opts.otpId),
    eq(otpCodesTable.purpose, opts.purpose),
    sql`${otpCodesTable.verifiedAt} IS NOT NULL`,
    sql`${otpCodesTable.verifiedAt} > ${new Date(nowMs - maxAgeSec * 1000)}`,
    gt(otpCodesTable.expiresAt, new Date(nowMs)),
  ];
  if (opts.userId) conds.push(eq(otpCodesTable.userId, opts.userId));
  if (opts.recipient) conds.push(eq(otpCodesTable.recipient, opts.recipient));
  const updated = await exec.update(otpCodesTable)
    .set({ expiresAt: new Date(0) })
    .where(and(...conds))
    .returning({ id: otpCodesTable.id });
  if (!updated || updated.length === 0) {
    // Diagnose why for caller
    const [row] = await exec.select().from(otpCodesTable).where(eq(otpCodesTable.id, opts.otpId)).limit(1);
    if (!row) return { ok: false, error: "OTP not found" };
    if (!row.verifiedAt) return { ok: false, error: "OTP not verified" };
    if (row.purpose !== opts.purpose) return { ok: false, error: "OTP purpose mismatch" };
    if (new Date(row.expiresAt).getTime() <= nowMs) return { ok: false, error: "OTP already used or expired" };
    return { ok: false, error: "OTP cannot be consumed" };
  }
  return { ok: true };
}

export default router;
