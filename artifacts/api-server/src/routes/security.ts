import { Router, type IRouter } from "express";
import { eq, desc } from "drizzle-orm";
import { db, usersTable, sessionsTable } from "@workspace/db";
import { requireAuth } from "../middlewares/auth";
import { consumeVerifiedOtp } from "./otp";

const router: IRouter = Router();

router.get("/security/me", requireAuth, async (req, res): Promise<void> => {
  const u = req.user!;
  const sessions = await db.select({
    id: sessionsTable.id, createdAt: sessionsTable.createdAt, expiresAt: sessionsTable.expiresAt,
    ip: sessionsTable.ip, userAgent: sessionsTable.userAgent,
  }).from(sessionsTable).where(eq(sessionsTable.userId, u.id)).orderBy(desc(sessionsTable.createdAt)).limit(20);
  res.json({
    twoFaEnabled: u.twoFaEnabled,
    activeSessions: sessions.length,
    sessions,
  });
});

router.post("/security/2fa/enable", requireAuth, async (req, res): Promise<void> => {
  const u = req.user!;
  const { otpId } = req.body ?? {};
  if (!otpId) { res.status(400).json({ error: "OTP verification required" }); return; }
  try {
    await db.transaction(async (tx) => {
      const r = await consumeVerifiedOtp({ otpId: Number(otpId), purpose: "2fa", userId: u.id, tx });
      if (!r.ok) { const e: any = new Error(r.error); e.code = 400; throw e; }
      await tx.update(usersTable).set({ twoFaEnabled: true, updatedAt: new Date() }).where(eq(usersTable.id, u.id));
    });
    res.json({ ok: true, twoFaEnabled: true });
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

router.post("/security/2fa/disable", requireAuth, async (req, res): Promise<void> => {
  const u = req.user!;
  const { otpId } = req.body ?? {};
  if (!otpId) { res.status(400).json({ error: "OTP verification required" }); return; }
  try {
    await db.transaction(async (tx) => {
      const r = await consumeVerifiedOtp({ otpId: Number(otpId), purpose: "2fa", userId: u.id, tx });
      if (!r.ok) { const e: any = new Error(r.error); e.code = 400; throw e; }
      await tx.update(usersTable).set({ twoFaEnabled: false, updatedAt: new Date() }).where(eq(usersTable.id, u.id));
    });
    res.json({ ok: true, twoFaEnabled: false });
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

router.post("/security/sessions/revoke-others", requireAuth, async (req, res): Promise<void> => {
  // Best-effort: keep current session, delete the rest
  const u = req.user!;
  const { readSessionCookie } = await import("../lib/auth");
  const currentToken = readSessionCookie(req);
  const sessions = await db.select().from(sessionsTable).where(eq(sessionsTable.userId, u.id));
  let removed = 0;
  for (const s of sessions) {
    if (s.token !== currentToken) {
      await db.delete(sessionsTable).where(eq(sessionsTable.id, s.id));
      removed++;
    }
  }
  res.json({ ok: true, removed });
});

export default router;
