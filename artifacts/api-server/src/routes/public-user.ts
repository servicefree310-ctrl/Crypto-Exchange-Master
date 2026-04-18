import { Router, type IRouter } from "express";
import { eq, and, desc } from "drizzle-orm";
import {
  db,
  walletsTable,
  coinsTable,
  bankAccountsTable,
  inrWithdrawalsTable,
  cryptoWithdrawalsTable,
  networksTable,
} from "@workspace/db";
import { requireAuth } from "../middlewares/auth";

const router: IRouter = Router();

// ─── Wallets ──────────────────────────────────────────────────────────────────
router.get("/wallets", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const rows = await db
    .select({
      id: walletsTable.id,
      walletType: walletsTable.walletType,
      coinId: walletsTable.coinId,
      balance: walletsTable.balance,
      locked: walletsTable.locked,
      coinSymbol: coinsTable.symbol,
      coinName: coinsTable.name,
      coinPrice: coinsTable.currentPrice,
    })
    .from(walletsTable)
    .innerJoin(coinsTable, eq(walletsTable.coinId, coinsTable.id))
    .where(eq(walletsTable.userId, userId));
  res.json(rows);
});

// ─── Banks (with single-verified-bank rule) ───────────────────────────────────
router.get("/banks", requireAuth, async (req, res): Promise<void> => {
  const rows = await db
    .select()
    .from(bankAccountsTable)
    .where(eq(bankAccountsTable.userId, req.user!.id))
    .orderBy(desc(bankAccountsTable.createdAt));
  res.json(rows);
});

router.post("/banks", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const { bankName, accountNumber, ifsc, holderName } = req.body ?? {};
  if (!bankName || !accountNumber || !ifsc || !holderName) {
    res.status(400).json({ error: "bankName, accountNumber, ifsc, holderName required" }); return;
  }
  if (!/^[A-Z]{4}0[A-Z0-9]{6}$/.test(String(ifsc).toUpperCase())) {
    res.status(400).json({ error: "Invalid IFSC code" }); return;
  }

  // Single verified bank rule: a user can have many under_review/rejected banks but only one verified
  const verified = await db
    .select()
    .from(bankAccountsTable)
    .where(and(eq(bankAccountsTable.userId, userId), eq(bankAccountsTable.status, "verified")))
    .limit(1);
  if (verified.length > 0) {
    res.status(409).json({ error: "You already have a verified bank account. Remove it first to add another." });
    return;
  }

  // Block duplicate account numbers for this user
  const dup = await db
    .select()
    .from(bankAccountsTable)
    .where(and(eq(bankAccountsTable.userId, userId), eq(bankAccountsTable.accountNumber, String(accountNumber))))
    .limit(1);
  if (dup.length > 0) { res.status(409).json({ error: "This account is already added" }); return; }

  const [created] = await db.insert(bankAccountsTable).values({
    userId,
    bankName: String(bankName),
    accountNumber: String(accountNumber),
    ifsc: String(ifsc).toUpperCase(),
    holderName: String(holderName),
    status: "under_review",
    isPrimary: true,
  }).returning();
  res.status(201).json(created);
});

router.delete("/banks/:id", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const id = Number(req.params.id);
  if (!id) { res.status(400).json({ error: "id required" }); return; }
  const [bank] = await db
    .select()
    .from(bankAccountsTable)
    .where(and(eq(bankAccountsTable.id, id), eq(bankAccountsTable.userId, userId)))
    .limit(1);
  if (!bank) { res.status(404).json({ error: "Bank not found" }); return; }
  await db.delete(bankAccountsTable).where(eq(bankAccountsTable.id, id));
  res.json({ ok: true });
});

// ─── Withdrawals ──────────────────────────────────────────────────────────────
router.get("/inr-withdrawals", requireAuth, async (req, res): Promise<void> => {
  const rows = await db.select().from(inrWithdrawalsTable)
    .where(eq(inrWithdrawalsTable.userId, req.user!.id))
    .orderBy(desc(inrWithdrawalsTable.createdAt));
  res.json(rows);
});

router.post("/inr-withdrawals", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const { bankId, amount } = req.body ?? {};
  const amt = Number(amount);
  if (!bankId || !Number.isFinite(amt) || amt <= 0) {
    res.status(400).json({ error: "bankId and positive amount required" }); return;
  }
  if (amt < 100) { res.status(400).json({ error: "Minimum withdrawal is ₹100" }); return; }

  const [bank] = await db.select().from(bankAccountsTable)
    .where(and(eq(bankAccountsTable.id, Number(bankId)), eq(bankAccountsTable.userId, userId)))
    .limit(1);
  if (!bank) { res.status(404).json({ error: "Bank not found" }); return; }
  if (bank.status !== "verified") { res.status(403).json({ error: "Bank must be verified to withdraw" }); return; }

  const fee = Math.max(10, amt * 0.001);
  const refId = `WINR-${Date.now().toString(36).toUpperCase()}-${Math.random().toString(36).slice(2, 7).toUpperCase()}`;
  const [created] = await db.insert(inrWithdrawalsTable).values({
    userId, bankId: Number(bankId),
    amount: String(amt), fee: String(fee), refId, status: "pending",
  }).returning();
  res.status(201).json(created);
});

router.get("/crypto-withdrawals", requireAuth, async (req, res): Promise<void> => {
  const rows = await db.select().from(cryptoWithdrawalsTable)
    .where(eq(cryptoWithdrawalsTable.userId, req.user!.id))
    .orderBy(desc(cryptoWithdrawalsTable.createdAt));
  res.json(rows);
});

router.post("/crypto-withdrawals", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const { coinId, networkId, amount, toAddress, memo } = req.body ?? {};
  const amt = Number(amount);
  if (!coinId || !networkId || !Number.isFinite(amt) || amt <= 0 || !toAddress) {
    res.status(400).json({ error: "coinId, networkId, positive amount, toAddress required" }); return;
  }
  const [network] = await db.select().from(networksTable).where(eq(networksTable.id, Number(networkId))).limit(1);
  if (!network) { res.status(404).json({ error: "Network not found" }); return; }
  if (network.coinId !== Number(coinId)) { res.status(400).json({ error: "Network does not belong to this coin" }); return; }
  if (network.status !== "active") { res.status(400).json({ error: "Network is not active" }); return; }
  const minWd = Number(network.minWithdraw);
  if (amt < minWd) { res.status(400).json({ error: `Minimum withdrawal is ${minWd}` }); return; }

  const fee = Number(network.withdrawFee) || 0;
  const refId = `WCRY-${Date.now().toString(36).toUpperCase()}-${Math.random().toString(36).slice(2, 7).toUpperCase()}`;
  const [created] = await db.insert(cryptoWithdrawalsTable).values({
    userId, coinId: Number(coinId), networkId: Number(networkId),
    amount: String(amt), fee: String(fee), toAddress: String(toAddress), memo: memo ? String(memo) : null,
    status: "pending",
  }).returning();
  res.status(201).json(created);
});

export default router;
