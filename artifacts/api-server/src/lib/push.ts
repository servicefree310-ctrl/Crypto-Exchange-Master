/**
 * Push notification service via FCM (Firebase Cloud Messaging).
 * Uses FCM Legacy HTTP API — configure server key in Admin → Settings → push.fcmKey
 * Also manages device_tokens table (registered via /api/push/register-token).
 */
import { db } from "@workspace/db";
import { sql } from "drizzle-orm";
import { logger } from "./logger";

const FCM_ENDPOINT = "https://fcm.googleapis.com/fcm/send";

export type PushPayload = {
  title: string;
  body: string;
  data?: Record<string, string>;
  imageUrl?: string;
  clickAction?: string;
};

async function getFcmKey(): Promise<string | null> {
  try {
    const rows = await db.execute(sql`SELECT value FROM settings WHERE key = 'push.fcmKey' LIMIT 1`);
    const row = (rows as any).rows?.[0] ?? (rows as any)[0];
    return row?.value ?? null;
  } catch {
    return null;
  }
}

/** Send push to a single FCM token */
export async function sendPushToToken(token: string, payload: PushPayload): Promise<{ ok: boolean; error?: string }> {
  const fcmKey = await getFcmKey();
  if (!fcmKey) return { ok: false, error: "FCM server key not configured. Set push.fcmKey in Admin → Settings." };
  try {
    const body: Record<string, any> = {
      to: token,
      notification: {
        title: payload.title,
        body: payload.body,
        ...(payload.imageUrl ? { image: payload.imageUrl } : {}),
        ...(payload.clickAction ? { click_action: payload.clickAction } : {}),
        sound: "default",
        badge: 1,
      },
    };
    if (payload.data) body.data = payload.data;
    const r = await fetch(FCM_ENDPOINT, {
      method: "POST",
      headers: { "Authorization": `key=${fcmKey}`, "Content-Type": "application/json" },
      body: JSON.stringify(body),
      signal: AbortSignal.timeout(10000),
    });
    const json: any = await r.json();
    if (json.failure > 0) {
      const err = json.results?.[0]?.error;
      // Remove invalid/unregistered tokens
      if (err === "NotRegistered" || err === "InvalidRegistration") {
        await db.execute(sql`UPDATE device_tokens SET is_active = false WHERE token = ${token}`);
      }
      return { ok: false, error: err };
    }
    return { ok: true };
  } catch (e: any) {
    return { ok: false, error: e.message };
  }
}

/** Send push to all active tokens for a user */
export async function sendPushToUser(userId: number, payload: PushPayload): Promise<{ sent: number; failed: number }> {
  const tokens = await db.execute(sql`SELECT token FROM device_tokens WHERE user_id = ${userId} AND is_active = true LIMIT 10`);
  const rows = (tokens as any).rows ?? (tokens as any);
  let sent = 0, failed = 0;
  for (const row of rows) {
    const r = await sendPushToToken(row.token, payload);
    if (r.ok) sent++; else failed++;
  }
  return { sent, failed };
}

/** Broadcast push to all registered active devices (or by platform) */
export async function broadcastPush(payload: PushPayload, opts?: { platform?: string; audienceUserIds?: number[] }): Promise<{ sent: number; failed: number; total: number }> {
  const fcmKey = await getFcmKey();
  if (!fcmKey) return { sent: 0, failed: 0, total: 0 };

  let whereClause = "is_active = true";
  if (opts?.platform) whereClause += ` AND platform = '${opts.platform.replace(/'/g, "''")}'`;

  const tokens = await db.execute(sql.raw(`SELECT token FROM device_tokens WHERE ${whereClause} LIMIT 1000`));
  const rows = (tokens as any).rows ?? (tokens as any);
  const total = rows.length;

  // FCM supports up to 1000 tokens per multicast request
  const chunks: string[][] = [];
  for (let i = 0; i < rows.length; i += 1000) {
    chunks.push(rows.slice(i, i + 1000).map((r: any) => r.token));
  }

  let sent = 0, failed = 0;
  for (const chunk of chunks) {
    try {
      const body: Record<string, any> = {
        registration_ids: chunk,
        notification: {
          title: payload.title,
          body: payload.body,
          ...(payload.imageUrl ? { image: payload.imageUrl } : {}),
          sound: "default",
          badge: 1,
        },
      };
      if (payload.data) body.data = payload.data;
      const r = await fetch(FCM_ENDPOINT, {
        method: "POST",
        headers: { "Authorization": `key=${fcmKey}`, "Content-Type": "application/json" },
        body: JSON.stringify(body),
        signal: AbortSignal.timeout(15000),
      });
      const json: any = await r.json();
      sent += json.success ?? 0;
      failed += json.failure ?? 0;
      // Invalidate bad tokens
      if (json.results && Array.isArray(json.results)) {
        for (let i = 0; i < json.results.length; i++) {
          const e = json.results[i]?.error;
          if (e === "NotRegistered" || e === "InvalidRegistration") {
            await db.execute(sql`UPDATE device_tokens SET is_active = false WHERE token = ${chunk[i]}`);
          }
        }
      }
    } catch (e: any) {
      failed += chunk.length;
      logger.error({ err: e.message }, "FCM broadcast chunk failed");
    }
  }
  logger.info({ sent, failed, total }, "FCM broadcast completed");
  return { sent, failed, total };
}

/** Register or refresh a device token */
export async function registerDeviceToken(userId: number, token: string, platform: "web" | "android" | "ios"): Promise<void> {
  await db.execute(sql`
    INSERT INTO device_tokens (user_id, token, platform, is_active, created_at, last_seen_at)
    VALUES (${userId}, ${token}, ${platform}, true, NOW(), NOW())
    ON CONFLICT (user_id, token) DO UPDATE SET is_active = true, last_seen_at = NOW(), platform = ${platform}
  `);
}

/** Deregister a device token (logout) */
export async function deregisterDeviceToken(userId: number, token: string): Promise<void> {
  await db.execute(sql`UPDATE device_tokens SET is_active = false WHERE user_id = ${userId} AND token = ${token}`);
}
