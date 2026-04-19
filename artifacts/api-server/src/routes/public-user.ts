import { Router, type IRouter } from "express";
import { eq, and, desc, sql } from "drizzle-orm";
import {
  db,
  walletsTable,
  coinsTable,
  bankAccountsTable,
  inrWithdrawalsTable,
  cryptoWithdrawalsTable,
  inrDepositsTable,
  cryptoDepositsTable,
  networksTable,
  kycRecordsTable,
  kycSettingsTable,
  usersTable,
  gatewaysTable,
  depositAddressesTable,
} from "@workspace/db";
import { requireAuth } from "../middlewares/auth";
import { consumeVerifiedOtp } from "./otp";

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
  const ifscNorm = String(ifsc).toUpperCase();
  if (!/^[A-Z]{4}0[A-Z0-9]{6}$/.test(ifscNorm)) {
    res.status(400).json({ error: "Invalid IFSC code" }); return;
  }
  const acctNorm = String(accountNumber).replace(/\s+/g, "");

  try {
    const created = await db.transaction(async (tx) => {
      // 1. Block if there's already a verified bank for this user
      const verified = await tx
        .select({ id: bankAccountsTable.id })
        .from(bankAccountsTable)
        .where(and(eq(bankAccountsTable.userId, userId), eq(bankAccountsTable.status, "verified")))
        .limit(1);
      if (verified.length > 0) {
        const e: any = new Error("You already have a verified bank account. Remove it first to add another.");
        e.code = 409; throw e;
      }
      // 2. Block duplicate account number for same user
      const dup = await tx
        .select({ id: bankAccountsTable.id })
        .from(bankAccountsTable)
        .where(and(eq(bankAccountsTable.userId, userId), eq(bankAccountsTable.accountNumber, acctNorm)))
        .limit(1);
      if (dup.length > 0) {
        const e: any = new Error("This account is already added"); e.code = 409; throw e;
      }
      const [row] = await tx.insert(bankAccountsTable).values({
        userId, bankName: String(bankName), accountNumber: acctNorm, ifsc: ifscNorm,
        holderName: String(holderName), status: "under_review", isPrimary: true,
      }).returning();
      return row;
    });
    res.status(201).json(created);
  } catch (e: any) {
    // unique partial index `bank_accounts_one_verified_per_user` will fire if race condition occurs
    if (e?.code === 409) { res.status(409).json({ error: e.message }); return; }
    if (typeof e?.message === "string" && e.message.includes("bank_accounts_one_verified_per_user")) {
      res.status(409).json({ error: "You already have a verified bank account." }); return;
    }
    throw e;
  }
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

// ─── Withdrawals (transactional balance lock + debit) ─────────────────────────
router.get("/inr-withdrawals", requireAuth, async (req, res): Promise<void> => {
  const rows = await db.select().from(inrWithdrawalsTable)
    .where(eq(inrWithdrawalsTable.userId, req.user!.id))
    .orderBy(desc(inrWithdrawalsTable.createdAt));
  res.json(rows);
});

router.post("/inr-withdrawals", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const { bankId, amount, otpId } = req.body ?? {};
  const amt = Number(amount);
  if (!bankId || !Number.isFinite(amt) || amt <= 0) {
    res.status(400).json({ error: "bankId and positive amount required" }); return;
  }
  if (amt < 100) { res.status(400).json({ error: "Minimum withdrawal is ₹100" }); return; }
  if (!otpId) { res.status(400).json({ error: "OTP verification required (otpId missing)" }); return; }

  const fee = Math.max(10, +(amt * 0.001).toFixed(2));

  try {
    const created = await db.transaction(async (tx) => {
      // Atomic OTP consume (single-use, verified, fresh)
      const otpRes = await consumeVerifiedOtp({ otpId: Number(otpId), purpose: "withdraw", userId, tx });
      if (!otpRes.ok) { const e: any = new Error(otpRes.error); e.code = 400; throw e; }
      // Lock bank
      const [bank] = await tx.select().from(bankAccountsTable)
        .where(and(eq(bankAccountsTable.id, Number(bankId)), eq(bankAccountsTable.userId, userId)))
        .limit(1);
      if (!bank) { const e: any = new Error("Bank not found"); e.code = 404; throw e; }
      if (bank.status !== "verified") { const e: any = new Error("Bank must be verified to withdraw"); e.code = 403; throw e; }

      // Lock & debit INR wallet (any wallet of type INR for this user)
      const [inrCoin] = await tx.select().from(coinsTable).where(eq(coinsTable.symbol, "INR")).limit(1);
      if (!inrCoin) { const e: any = new Error("INR coin not configured"); e.code = 500; throw e; }
      const [wallet] = await tx.select().from(walletsTable)
        .where(and(eq(walletsTable.userId, userId), eq(walletsTable.coinId, inrCoin.id), eq(walletsTable.walletType, "inr")))
        .for("update")
        .limit(1);
      if (!wallet) { const e: any = new Error("INR wallet not found"); e.code = 404; throw e; }
      const balance = Number(wallet.balance);
      if (balance < amt) { const e: any = new Error(`Insufficient balance (₹${balance.toFixed(2)})`); e.code = 400; throw e; }

      await tx.update(walletsTable)
        .set({
          balance: sql`${walletsTable.balance} - ${amt}`,
          locked: sql`${walletsTable.locked} + ${amt}`,
          updatedAt: new Date(),
        })
        .where(eq(walletsTable.id, wallet.id));

      const refId = `WINR-${Date.now().toString(36).toUpperCase()}-${Math.random().toString(36).slice(2, 7).toUpperCase()}`;
      const [wd] = await tx.insert(inrWithdrawalsTable).values({
        userId, bankId: Number(bankId),
        amount: String(amt), fee: String(fee), refId, status: "pending",
      }).returning();
      return wd;
    });
    res.status(201).json(created);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

router.get("/crypto-withdrawals", requireAuth, async (req, res): Promise<void> => {
  const rows = await db.select().from(cryptoWithdrawalsTable)
    .where(eq(cryptoWithdrawalsTable.userId, req.user!.id))
    .orderBy(desc(cryptoWithdrawalsTable.createdAt));
  res.json(rows);
});

router.post("/crypto-withdrawals", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const { coinId, networkId, amount, toAddress, memo, otpId } = req.body ?? {};
  const amt = Number(amount);
  if (!coinId || !networkId || !Number.isFinite(amt) || amt <= 0 || !toAddress) {
    res.status(400).json({ error: "coinId, networkId, positive amount, toAddress required" }); return;
  }
  if (String(toAddress).trim().length < 20) {
    res.status(400).json({ error: "Recipient address looks invalid" }); return;
  }
  if (!otpId) { res.status(400).json({ error: "OTP verification required (otpId missing)" }); return; }

  try {
    const created = await db.transaction(async (tx) => {
      const otpRes = await consumeVerifiedOtp({ otpId: Number(otpId), purpose: "withdraw", userId, tx });
      if (!otpRes.ok) { const e: any = new Error(otpRes.error); e.code = 400; throw e; }
      const [network] = await tx.select().from(networksTable).where(eq(networksTable.id, Number(networkId))).limit(1);
      if (!network) { const e: any = new Error("Network not found"); e.code = 404; throw e; }
      if (network.coinId !== Number(coinId)) { const e: any = new Error("Network does not belong to this coin"); e.code = 400; throw e; }
      if (network.status !== "active") { const e: any = new Error("Network is not active"); e.code = 400; throw e; }
      const minWd = Number(network.minWithdraw);
      if (amt < minWd) { const e: any = new Error(`Minimum withdrawal is ${minWd}`); e.code = 400; throw e; }
      if (network.memoRequired && (!memo || String(memo).trim().length === 0)) {
        const e: any = new Error("This network requires a memo/destination tag"); e.code = 400; throw e;
      }

      // Withdraw fee = max( fixed + (amt × percent%), feeMin )
      const feeFixed = Number(network.withdrawFee) || 0;
      const feePct = Number(network.withdrawFeePercent) || 0;
      const feeMin = Number(network.withdrawFeeMin) || 0;
      const calcFee = feeFixed + (amt * feePct / 100);
      const fee = +Math.max(calcFee, feeMin).toFixed(8);
      const tds = +(amt * 0.01).toFixed(8); // 1% TDS on crypto withdraw

      const [wallet] = await tx.select().from(walletsTable)
        .where(and(eq(walletsTable.userId, userId), eq(walletsTable.coinId, Number(coinId)), eq(walletsTable.walletType, "spot")))
        .for("update")
        .limit(1);
      if (!wallet) { const e: any = new Error("Spot wallet for this coin not found"); e.code = 404; throw e; }

      const totalDebit = amt; // user requested gross; fee + tds taken from this on processing
      const balance = Number(wallet.balance);
      if (balance < totalDebit) { const e: any = new Error(`Insufficient balance (${balance})`); e.code = 400; throw e; }

      await tx.update(walletsTable)
        .set({
          balance: sql`${walletsTable.balance} - ${totalDebit}`,
          locked: sql`${walletsTable.locked} + ${totalDebit}`,
          updatedAt: new Date(),
        })
        .where(eq(walletsTable.id, wallet.id));

      const refId = `WCRY-${Date.now().toString(36).toUpperCase()}-${Math.random().toString(36).slice(2, 7).toUpperCase()}`;
      const [wd] = await tx.insert(cryptoWithdrawalsTable).values({
        userId, coinId: Number(coinId), networkId: Number(networkId),
        amount: String(amt), fee: String(fee + tds),
        toAddress: String(toAddress).trim(), memo: memo ? String(memo) : null,
        status: "pending",
      }).returning();
      return wd;
    });
    res.status(201).json(created);
  } catch (e: any) {
    if (e?.code) { res.status(e.code).json({ error: e.message }); return; }
    throw e;
  }
});

// ─── KYC ──────────────────────────────────────────────────────────────────────
router.get("/kyc/settings", async (_req, res): Promise<void> => {
  const rows = await db.select().from(kycSettingsTable).orderBy(kycSettingsTable.level);
  res.json(rows);
});

router.get("/kyc/my", requireAuth, async (req, res): Promise<void> => {
  const rows = await db.select().from(kycRecordsTable)
    .where(eq(kycRecordsTable.userId, req.user!.id))
    .orderBy(desc(kycRecordsTable.createdAt));
  res.json(rows);
});

router.post("/kyc/submit", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const { level, fullName, dob, address, panNumber, aadhaarNumber, panDocUrl, aadhaarDocUrl, selfieUrl } = req.body ?? {};
  const lvl = Number(level);
  if (![1, 2, 3].includes(lvl)) { res.status(400).json({ error: "level must be 1, 2 or 3" }); return; }

  // Per-level required fields
  if (lvl >= 1) {
    if (!fullName || !dob) { res.status(400).json({ error: "fullName and dob required" }); return; }
    if (!panNumber || !/^[A-Z]{5}[0-9]{4}[A-Z]$/.test(String(panNumber).toUpperCase())) {
      res.status(400).json({ error: "Valid PAN required (format: AAAAA1111A)" }); return;
    }
  }
  if (lvl >= 2) {
    if (!aadhaarNumber || !/^\d{12}$/.test(String(aadhaarNumber).replace(/\s+/g, ""))) {
      res.status(400).json({ error: "Valid 12-digit Aadhaar required" }); return;
    }
    if (!panDocUrl || !aadhaarDocUrl) { res.status(400).json({ error: "PAN and Aadhaar document URLs required" }); return; }
  }
  if (lvl >= 3) {
    if (!selfieUrl || !address) { res.status(400).json({ error: "Selfie and address required for L3" }); return; }
  }

  // Block duplicate pending submission for same level
  const existing = await db.select().from(kycRecordsTable)
    .where(and(eq(kycRecordsTable.userId, userId), eq(kycRecordsTable.level, lvl), eq(kycRecordsTable.status, "pending")))
    .limit(1);
  if (existing.length > 0) { res.status(409).json({ error: "You already have a pending submission for this level" }); return; }

  const [rec] = await db.insert(kycRecordsTable).values({
    userId, level: lvl, status: "pending",
    fullName: fullName ?? null, dob: dob ?? null, address: address ?? null,
    panNumber: panNumber ? String(panNumber).toUpperCase() : null,
    aadhaarNumber: aadhaarNumber ? String(aadhaarNumber).replace(/\s+/g, "") : null,
    panDocUrl: panDocUrl ?? null, aadhaarDocUrl: aadhaarDocUrl ?? null, selfieUrl: selfieUrl ?? null,
  }).returning();
  res.status(201).json(rec);
});

// ─── Referral stats ───────────────────────────────────────────────────────────
router.get("/refer/stats", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const me = await db.select({ code: usersTable.referralCode }).from(usersTable).where(eq(usersTable.id, userId)).limit(1);
  const referredCount = await db
    .select({ c: sql<number>`count(*)::int` })
    .from(usersTable)
    .where(eq(usersTable.referredBy, userId));
  const referredUsers = await db
    .select({ id: usersTable.id, name: usersTable.name, kycLevel: usersTable.kycLevel, createdAt: usersTable.createdAt })
    .from(usersTable).where(eq(usersTable.referredBy, userId)).orderBy(desc(usersTable.createdAt)).limit(50);

  res.json({
    referralCode: me[0]?.code ?? null,
    referredCount: referredCount[0]?.c ?? 0,
    referredKycCount: referredUsers.filter(u => (u.kycLevel ?? 0) >= 1).length,
    estimatedEarnings: 0, // placeholder until commissions ledger exists
    recent: referredUsers,
  });
});

// ─── OTP-protected withdraw confirm (optional convenience) ────────────────────
// Real OTP wiring lives inside the withdraw POSTs above when an `otpId` is supplied.

// ─── Payment gateways (public list — only active deposit gateways) ────────────
router.get("/gateways", async (req, res): Promise<void> => {
  const direction = typeof req.query.direction === "string" ? req.query.direction : "deposit";
  const rows = await db
    .select({
      id: gatewaysTable.id, code: gatewaysTable.code, name: gatewaysTable.name,
      type: gatewaysTable.type, direction: gatewaysTable.direction,
      minAmount: gatewaysTable.minAmount, maxAmount: gatewaysTable.maxAmount,
      feeFlat: gatewaysTable.feeFlat, feePercent: gatewaysTable.feePercent,
      processingTime: gatewaysTable.processingTime, isAuto: gatewaysTable.isAuto,
      config: gatewaysTable.config,
    })
    .from(gatewaysTable)
    .where(and(eq(gatewaysTable.status, "active"), eq(gatewaysTable.direction, direction)))
    .orderBy(gatewaysTable.id);
  res.json(rows);
});

// ─── INR Deposits ─────────────────────────────────────────────────────────────
router.get("/inr-deposits", requireAuth, async (req, res): Promise<void> => {
  const rows = await db.select().from(inrDepositsTable)
    .where(eq(inrDepositsTable.userId, req.user!.id))
    .orderBy(desc(inrDepositsTable.createdAt));
  res.json(rows);
});

router.post("/inr-deposits", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const { gatewayId, amount, utr, notes } = req.body ?? {};
  const amt = Number(amount);
  if (!gatewayId || !Number.isFinite(amt) || amt <= 0) {
    res.status(400).json({ error: "gatewayId and positive amount required" }); return;
  }
  const [g] = await db.select().from(gatewaysTable).where(eq(gatewaysTable.id, Number(gatewayId))).limit(1);
  if (!g) { res.status(404).json({ error: "Gateway not found" }); return; }
  if (g.status !== "active" || g.direction !== "deposit") {
    res.status(400).json({ error: "Gateway not available for deposits" }); return;
  }
  const min = Number(g.minAmount), max = Number(g.maxAmount);
  if (min > 0 && amt < min) { res.status(400).json({ error: `Minimum deposit is ₹${min}` }); return; }
  if (max > 0 && amt > max) { res.status(400).json({ error: `Maximum deposit is ₹${max}` }); return; }

  // Manual gateways (UPI/IMPS/NEFT/RTGS) need a UTR claim. Auto gateways may not.
  if (!g.isAuto && (!utr || String(utr).trim().length < 6)) {
    res.status(400).json({ error: "UTR / Transaction reference required (min 6 chars)" }); return;
  }

  const fee = +(Number(g.feeFlat) + (amt * Number(g.feePercent) / 100)).toFixed(2);
  const refId = `DINR-${Date.now().toString(36).toUpperCase()}-${Math.random().toString(36).slice(2, 7).toUpperCase()}`;

  try {
    const [row] = await db.insert(inrDepositsTable).values({
      userId, gatewayId: Number(gatewayId), amount: String(amt), fee: String(fee),
      refId, utr: utr ? String(utr).trim() : null, status: "pending",
      notes: notes ? String(notes).slice(0, 500) : null,
    }).returning();
    res.status(201).json(row);
  } catch (e: any) {
    if (typeof e?.message === "string" && e.message.includes("ref_id")) {
      res.status(409).json({ error: "Duplicate reference, please retry" }); return;
    }
    throw e;
  }
});

// ─── Crypto Deposits ──────────────────────────────────────────────────────────
router.get("/crypto-deposits", requireAuth, async (req, res): Promise<void> => {
  const rows = await db.select().from(cryptoDepositsTable)
    .where(eq(cryptoDepositsTable.userId, req.user!.id))
    .orderBy(desc(cryptoDepositsTable.createdAt));
  res.json(rows);
});

router.post("/crypto-deposits/notify", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const { coinId, networkId, amount, txHash } = req.body ?? {};
  const amt = Number(amount);
  if (!coinId || !networkId || !Number.isFinite(amt) || amt <= 0 || !txHash) {
    res.status(400).json({ error: "coinId, networkId, positive amount, txHash required" }); return;
  }
  const tx = String(txHash).trim();
  if (tx.length < 10) { res.status(400).json({ error: "Invalid txHash" }); return; }

  const [network] = await db.select().from(networksTable).where(eq(networksTable.id, Number(networkId))).limit(1);
  if (!network) { res.status(404).json({ error: "Network not found" }); return; }
  if (network.coinId !== Number(coinId)) { res.status(400).json({ error: "Network does not belong to this coin" }); return; }
  if (network.status !== "active") { res.status(400).json({ error: "Network is not active" }); return; }
  const minDep = Number(network.minDeposit ?? 0);
  if (minDep > 0 && amt < minDep) { res.status(400).json({ error: `Minimum deposit is ${minDep}` }); return; }

  // Reuse user's deterministic address (must already exist via /deposit-address)
  const [addr] = await db.select().from(depositAddressesTable).where(and(
    eq(depositAddressesTable.userId, userId),
    eq(depositAddressesTable.coinId, Number(coinId)),
    eq(depositAddressesTable.networkId, Number(networkId)),
  )).limit(1);
  if (!addr) { res.status(400).json({ error: "Generate a deposit address first" }); return; }

  // Idempotency: reject if a deposit with this txHash on this network already exists
  const [dup] = await db.select({ id: cryptoDepositsTable.id }).from(cryptoDepositsTable).where(and(
    eq(cryptoDepositsTable.networkId, Number(networkId)),
    eq(cryptoDepositsTable.txHash, tx),
  )).limit(1);
  if (dup) { res.status(409).json({ error: "This transaction hash has already been submitted" }); return; }

  const [row] = await db.insert(cryptoDepositsTable).values({
    userId, coinId: Number(coinId), networkId: Number(networkId),
    amount: String(amt), address: addr.address, txHash: tx,
    confirmations: 0, status: "pending",
  }).returning();
  res.status(201).json(row);
});

export default router;
