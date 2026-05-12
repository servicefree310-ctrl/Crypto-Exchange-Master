/**
 * Angel One SmartAPI Integration
 *
 *   POST   /smartapi/connect          — login with clientcode+password+totp+apiKey
 *   POST   /smartapi/disconnect       — clear tokens, mark disconnected
 *   POST   /smartapi/refresh          — refresh JWT using refreshToken
 *   GET    /smartapi/account          — get connected SmartAPI account(s)
 *   GET    /smartapi/profile          — Angel One user profile
 *   GET    /smartapi/funds            — available funds / margin
 *   GET    /smartapi/holdings         — equity holdings with P&L
 *   GET    /smartapi/positions        — open intraday / carryforward positions
 *   GET    /smartapi/orders           — order book (today)
 *   POST   /smartapi/orders           — place a new order
 *   DELETE /smartapi/orders/:orderId  — cancel an order
 *   GET    /smartapi/quote            — LTP / OHLC for a scrip
 *   GET    /smartapi/search           — search scrip by name/symbol
 */

import { Router } from "express";
import { eq, and, desc } from "drizzle-orm";
import { db } from "../lib/db";
import { requireAuth } from "../middleware/auth";
import { smartApiAccountsTable } from "../lib/db/schema/broker-accounts";

const router = Router();

const SMARTAPI_BASE = "https://apiconnect.angelone.in";

function uid(req: any): number { return req.user!.id; }

// ─── SmartAPI HTTP helper ──────────────────────────────────────────────────────
async function smartCall(
  path: string,
  method: "GET" | "POST" | "DELETE",
  apiKey: string,
  jwtToken: string,
  body?: object,
): Promise<{ ok: boolean; status: number; data: any }> {
  try {
    const res = await fetch(`${SMARTAPI_BASE}${path}`, {
      method,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": `Bearer ${jwtToken}`,
        "X-UserType": "USER",
        "X-SourceID": "WEB",
        "X-ClientLocalIP": "127.0.0.1",
        "X-ClientPublicIP": "106.193.147.98",
        "X-MACAddress": "fe80::216e:6507:4b90:3719",
        "X-PrivateKey": apiKey,
      },
      body: body ? JSON.stringify(body) : undefined,
    });
    const data = await res.json().catch(() => ({}));
    return { ok: res.ok, status: res.status, data };
  } catch (err: any) {
    return { ok: false, status: 503, data: { message: err.message } };
  }
}

// ─── POST /smartapi/connect ────────────────────────────────────────────────────
router.post("/smartapi/connect", requireAuth, async (req, res): Promise<void> => {
  const { clientCode, password, totp, apiKey } = req.body as {
    clientCode: string; password: string; totp: string; apiKey: string;
  };
  const userId = uid(req);

  if (!clientCode || !password || !apiKey) {
    res.status(400).json({ error: "clientCode, password and apiKey are required" });
    return;
  }

  // Call Angel One login
  const loginRes = await fetch(`${SMARTAPI_BASE}/rest/auth/angelbroking/user/v1/loginByPassword`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "X-UserType": "USER",
      "X-SourceID": "WEB",
      "X-ClientLocalIP": "127.0.0.1",
      "X-ClientPublicIP": "106.193.147.98",
      "X-MACAddress": "fe80::216e:6507:4b90:3719",
      "X-PrivateKey": apiKey,
    },
    body: JSON.stringify({ clientcode: clientCode, password, totp }),
  });

  const loginData = await loginRes.json().catch(() => ({}));

  if (!loginRes.ok || loginData.status === false || !loginData.data?.jwtToken) {
    // Upsert failed account
    await db.insert(smartApiAccountsTable).values({
      userId, clientCode, apiKey,
      status: "error",
      lastError: loginData.message ?? loginData.errorcode ?? "Login failed",
    }).onConflictDoNothing();
    res.status(401).json({ error: loginData.message ?? "SmartAPI login failed", raw: loginData });
    return;
  }

  const tokens = loginData.data;
  const jwtExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000); // ~24h

  // Fetch profile to get user name
  const profileRes = await smartCall(
    "/rest/secure/angelbroking/user/v1/getProfile",
    "GET", apiKey, tokens.jwtToken,
  );
  const profile = profileRes.data?.data ?? {};

  // Upsert account record
  const existing = await db.select({ id: smartApiAccountsTable.id })
    .from(smartApiAccountsTable)
    .where(and(eq(smartApiAccountsTable.userId, userId), eq(smartApiAccountsTable.clientCode, clientCode)))
    .limit(1);

  if (existing.length > 0) {
    await db.update(smartApiAccountsTable)
      .set({
        apiKey,
        jwtToken: tokens.jwtToken,
        refreshToken: tokens.refreshToken,
        feedToken: tokens.feedToken,
        jwtExpiresAt,
        name: profile.name ?? null,
        email: profile.email ?? null,
        mobile: profile.mobileNo ?? null,
        pan: profile.pan ?? null,
        status: "connected",
        lastError: null,
        lastConnectedAt: new Date(),
        updatedAt: new Date(),
      })
      .where(eq(smartApiAccountsTable.id, existing[0].id));
  } else {
    await db.insert(smartApiAccountsTable).values({
      userId, clientCode, apiKey,
      jwtToken: tokens.jwtToken,
      refreshToken: tokens.refreshToken,
      feedToken: tokens.feedToken,
      jwtExpiresAt,
      name: profile.name ?? null,
      email: profile.email ?? null,
      mobile: profile.mobileNo ?? null,
      pan: profile.pan ?? null,
      status: "connected",
      lastConnectedAt: new Date(),
    });
  }

  res.json({
    ok: true,
    message: `Connected as ${profile.name ?? clientCode}`,
    profile,
    feedToken: tokens.feedToken,
  });
});

// ─── POST /smartapi/disconnect ─────────────────────────────────────────────────
router.post("/smartapi/disconnect", requireAuth, async (req, res): Promise<void> => {
  const { accountId } = req.body as { accountId: number };
  const userId = uid(req);

  const [acct] = await db.select().from(smartApiAccountsTable)
    .where(and(eq(smartApiAccountsTable.id, accountId), eq(smartApiAccountsTable.userId, userId)))
    .limit(1);
  if (!acct) { res.status(404).json({ error: "Account not found" }); return; }

  // Try to call Angel One logout
  if (acct.jwtToken && acct.apiKey) {
    await smartCall(
      "/rest/secure/angelbroking/user/v1/logout",
      "POST", acct.apiKey, acct.jwtToken,
      { clientcode: acct.clientCode },
    ).catch(() => {});
  }

  await db.update(smartApiAccountsTable)
    .set({ status: "disconnected", jwtToken: null, refreshToken: null, feedToken: null, updatedAt: new Date() })
    .where(eq(smartApiAccountsTable.id, accountId));

  res.json({ ok: true });
});

// ─── POST /smartapi/refresh ────────────────────────────────────────────────────
router.post("/smartapi/refresh", requireAuth, async (req, res): Promise<void> => {
  const { accountId } = req.body as { accountId: number };
  const userId = uid(req);

  const [acct] = await db.select().from(smartApiAccountsTable)
    .where(and(eq(smartApiAccountsTable.id, accountId), eq(smartApiAccountsTable.userId, userId)))
    .limit(1);
  if (!acct?.refreshToken) { res.status(400).json({ error: "No refresh token available" }); return; }

  const r = await fetch(`${SMARTAPI_BASE}/rest/auth/angelbroking/jwt/v1/generateTokens`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${acct.jwtToken}`,
      "X-UserType": "USER",
      "X-SourceID": "WEB",
      "X-ClientLocalIP": "127.0.0.1",
      "X-ClientPublicIP": "106.193.147.98",
      "X-MACAddress": "fe80::216e:6507:4b90:3719",
      "X-PrivateKey": acct.apiKey,
    },
    body: JSON.stringify({ refreshToken: acct.refreshToken }),
  });
  const data = await r.json().catch(() => ({}));
  if (!data.data?.jwtToken) {
    res.status(401).json({ error: "Token refresh failed", raw: data });
    return;
  }

  const jwtExpiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);
  await db.update(smartApiAccountsTable)
    .set({ jwtToken: data.data.jwtToken, refreshToken: data.data.refreshToken, feedToken: data.data.feedToken, jwtExpiresAt, updatedAt: new Date() })
    .where(eq(smartApiAccountsTable.id, accountId));

  res.json({ ok: true, message: "Token refreshed" });
});

// ─── Helper: get valid account ─────────────────────────────────────────────────
async function getAccount(userId: number, accountId?: number) {
  const query = db.select().from(smartApiAccountsTable)
    .where(accountId
      ? and(eq(smartApiAccountsTable.userId, userId), eq(smartApiAccountsTable.id, accountId))
      : eq(smartApiAccountsTable.userId, userId))
    .limit(1);
  const [acct] = await query;
  return acct;
}

// ─── GET /smartapi/account ─────────────────────────────────────────────────────
router.get("/smartapi/account", requireAuth, async (req, res): Promise<void> => {
  const accounts = await db.select().from(smartApiAccountsTable)
    .where(eq(smartApiAccountsTable.userId, uid(req)))
    .orderBy(desc(smartApiAccountsTable.createdAt));
  // Don't expose raw tokens
  const safe = accounts.map(({ jwtToken, refreshToken, feedToken, apiKey, ...rest }) => ({
    ...rest,
    hasToken: !!jwtToken,
    hasFeedToken: !!feedToken,
    apiKeyHint: apiKey ? apiKey.slice(0, 4) + "****" : null,
  }));
  res.json({ accounts: safe });
});

// ─── GET /smartapi/profile ─────────────────────────────────────────────────────
router.get("/smartapi/profile", requireAuth, async (req, res): Promise<void> => {
  const accountId = req.query.accountId ? Number(req.query.accountId) : undefined;
  const acct = await getAccount(uid(req), accountId);
  if (!acct?.jwtToken) { res.status(404).json({ error: "No connected SmartAPI account" }); return; }

  const r = await smartCall("/rest/secure/angelbroking/user/v1/getProfile", "GET", acct.apiKey, acct.jwtToken);
  res.status(r.ok ? 200 : r.status).json(r.data);
});

// ─── GET /smartapi/funds ──────────────────────────────────────────────────────
router.get("/smartapi/funds", requireAuth, async (req, res): Promise<void> => {
  const accountId = req.query.accountId ? Number(req.query.accountId) : undefined;
  const acct = await getAccount(uid(req), accountId);
  if (!acct?.jwtToken) { res.status(404).json({ error: "No connected SmartAPI account" }); return; }

  const r = await smartCall("/rest/secure/angelbroking/user/v1/getRMS", "GET", acct.apiKey, acct.jwtToken);
  if (r.ok && r.data?.data?.net) {
    const net = parseFloat(r.data.data.net);
    await db.update(smartApiAccountsTable)
      .set({ availableCash: String(net), updatedAt: new Date() })
      .where(eq(smartApiAccountsTable.id, acct.id));
  }
  res.status(r.ok ? 200 : r.status).json(r.data);
});

// ─── GET /smartapi/holdings ────────────────────────────────────────────────────
router.get("/smartapi/holdings", requireAuth, async (req, res): Promise<void> => {
  const accountId = req.query.accountId ? Number(req.query.accountId) : undefined;
  const acct = await getAccount(uid(req), accountId);
  if (!acct?.jwtToken) { res.status(404).json({ error: "No connected SmartAPI account" }); return; }

  const r = await smartCall("/rest/secure/angelbroking/portfolio/v1/getAllHolding", "GET", acct.apiKey, acct.jwtToken);
  res.status(r.ok ? 200 : r.status).json(r.data);
});

// ─── GET /smartapi/positions ───────────────────────────────────────────────────
router.get("/smartapi/positions", requireAuth, async (req, res): Promise<void> => {
  const accountId = req.query.accountId ? Number(req.query.accountId) : undefined;
  const acct = await getAccount(uid(req), accountId);
  if (!acct?.jwtToken) { res.status(404).json({ error: "No connected SmartAPI account" }); return; }

  const r = await smartCall("/rest/secure/angelbroking/order/v1/getPosition", "GET", acct.apiKey, acct.jwtToken);
  res.status(r.ok ? 200 : r.status).json(r.data);
});

// ─── GET /smartapi/orders ──────────────────────────────────────────────────────
router.get("/smartapi/orders", requireAuth, async (req, res): Promise<void> => {
  const accountId = req.query.accountId ? Number(req.query.accountId) : undefined;
  const acct = await getAccount(uid(req), accountId);
  if (!acct?.jwtToken) { res.status(404).json({ error: "No connected SmartAPI account" }); return; }

  const r = await smartCall("/rest/secure/angelbroking/order/v1/getOrderBook", "GET", acct.apiKey, acct.jwtToken);
  res.status(r.ok ? 200 : r.status).json(r.data);
});

// ─── POST /smartapi/orders ─────────────────────────────────────────────────────
router.post("/smartapi/orders", requireAuth, async (req, res): Promise<void> => {
  const {
    accountId,
    variety = "NORMAL",
    tradingsymbol,
    symboltoken,
    transactiontype,
    exchange,
    ordertype,
    producttype,
    duration = "DAY",
    price = "0",
    squareoff = "0",
    stoploss = "0",
    quantity,
  } = req.body as {
    accountId: number; variety?: string; tradingsymbol: string; symboltoken: string;
    transactiontype: string; exchange: string; ordertype: string; producttype: string;
    duration?: string; price?: string; squareoff?: string; stoploss?: string; quantity: string;
  };

  const acct = await getAccount(uid(req), accountId);
  if (!acct?.jwtToken) { res.status(404).json({ error: "No connected SmartAPI account" }); return; }

  const r = await smartCall(
    "/rest/secure/angelbroking/order/v1/placeOrder",
    "POST", acct.apiKey, acct.jwtToken,
    { variety, tradingsymbol, symboltoken, transactiontype, exchange, ordertype, producttype, duration, price, squareoff, stoploss, quantity },
  );
  res.status(r.ok ? 200 : r.status).json(r.data);
});

// ─── DELETE /smartapi/orders/:orderId ─────────────────────────────────────────
router.delete("/smartapi/orders/:orderId", requireAuth, async (req, res): Promise<void> => {
  const { orderId } = req.params;
  const { accountId, variety = "NORMAL" } = req.body as { accountId: number; variety?: string };

  const acct = await getAccount(uid(req), accountId);
  if (!acct?.jwtToken) { res.status(404).json({ error: "No connected SmartAPI account" }); return; }

  const r = await smartCall(
    "/rest/secure/angelbroking/order/v1/cancelOrder",
    "POST", acct.apiKey, acct.jwtToken,
    { variety, orderid: orderId },
  );
  res.status(r.ok ? 200 : r.status).json(r.data);
});

// ─── GET /smartapi/quote ──────────────────────────────────────────────────────
// ?exchange=NSE&symboltoken=3045&tradingsymbol=SBIN-EQ
router.get("/smartapi/quote", requireAuth, async (req, res): Promise<void> => {
  const { exchange, symboltoken, tradingsymbol, mode = "FULL" } = req.query as Record<string, string>;
  const accountId = req.query.accountId ? Number(req.query.accountId) : undefined;
  const acct = await getAccount(uid(req), accountId);
  if (!acct?.jwtToken) { res.status(404).json({ error: "No connected SmartAPI account" }); return; }

  const r = await smartCall(
    "/rest/secure/angelbroking/market/v1/quote/",
    "POST", acct.apiKey, acct.jwtToken,
    { mode, exchangeTokens: { [exchange]: [symboltoken] } },
  );
  res.status(r.ok ? 200 : r.status).json(r.data);
});

// ─── GET /smartapi/search ─────────────────────────────────────────────────────
// ?query=RELIANCE&exchange=NSE
router.get("/smartapi/search", requireAuth, async (req, res): Promise<void> => {
  const { query: searchscrip, exchange = "NSE" } = req.query as Record<string, string>;
  const accountId = req.query.accountId ? Number(req.query.accountId) : undefined;
  const acct = await getAccount(uid(req), accountId);
  if (!acct?.jwtToken) { res.status(404).json({ error: "No connected SmartAPI account" }); return; }

  const r = await smartCall(
    "/rest/secure/angelbroking/order/v1/searchScrip",
    "POST", acct.apiKey, acct.jwtToken,
    { exchange, searchscrip },
  );
  res.status(r.ok ? 200 : r.status).json(r.data);
});

// ─── GET /smartapi/tradeBook ──────────────────────────────────────────────────
router.get("/smartapi/tradebook", requireAuth, async (req, res): Promise<void> => {
  const accountId = req.query.accountId ? Number(req.query.accountId) : undefined;
  const acct = await getAccount(uid(req), accountId);
  if (!acct?.jwtToken) { res.status(404).json({ error: "No connected SmartAPI account" }); return; }

  const r = await smartCall("/rest/secure/angelbroking/order/v1/getTradeBook", "GET", acct.apiKey, acct.jwtToken);
  res.status(r.ok ? 200 : r.status).json(r.data);
});

export default router;
