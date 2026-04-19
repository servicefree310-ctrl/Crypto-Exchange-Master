import { Router, type IRouter } from "express";
import { eq, and, gte, sql } from "drizzle-orm";
import { db, tradesTable, pairsTable, coinsTable, usersTable, settingsTable } from "@workspace/db";
import { requireAuth, optionalAuth } from "../middlewares/auth";

const router: IRouter = Router();

export interface VipTier {
  level: number; name: string; minVolume: number;
  spotMaker: number; spotTaker: number;
  futuresMaker: number; futuresTaker: number;
  withdrawDiscount: number;
}

export const DEFAULT_VIP_TIERS: VipTier[] = [
  { level: 0, name: "Regular", minVolume: 0,        spotMaker: 0.20, spotTaker: 0.25, futuresMaker: 0.05, futuresTaker: 0.07, withdrawDiscount: 0 },
  { level: 1, name: "VIP 1",   minVolume: 100000,   spotMaker: 0.16, spotTaker: 0.20, futuresMaker: 0.04, futuresTaker: 0.06, withdrawDiscount: 5 },
  { level: 2, name: "VIP 2",   minVolume: 500000,   spotMaker: 0.12, spotTaker: 0.15, futuresMaker: 0.03, futuresTaker: 0.05, withdrawDiscount: 10 },
  { level: 3, name: "VIP 3",   minVolume: 2500000,  spotMaker: 0.08, spotTaker: 0.10, futuresMaker: 0.02, futuresTaker: 0.04, withdrawDiscount: 15 },
  { level: 4, name: "VIP 4",   minVolume: 10000000, spotMaker: 0.06, spotTaker: 0.08, futuresMaker: 0.015,futuresTaker: 0.03, withdrawDiscount: 20 },
  { level: 5, name: "VIP 5",   minVolume: 50000000, spotMaker: 0.04, spotTaker: 0.06, futuresMaker: 0.01, futuresTaker: 0.025,withdrawDiscount: 25 },
];

const TIERS_KEY = "fees.vip_tiers";

export async function loadVipTiers(): Promise<VipTier[]> {
  try {
    const [row] = await db.select().from(settingsTable).where(eq(settingsTable.key, TIERS_KEY)).limit(1);
    if (row?.value) {
      const arr = JSON.parse(row.value);
      if (Array.isArray(arr) && arr.length > 0 && arr.every((t: any) => typeof t.level === "number")) {
        return arr.sort((a: VipTier, b: VipTier) => a.level - b.level);
      }
    }
  } catch (e) { /* fallthrough */ }
  return DEFAULT_VIP_TIERS;
}

// Back-compat re-export (kept for any imports of VIP_TIERS — now async source)
export const VIP_TIERS = DEFAULT_VIP_TIERS;

export interface FeeSettings {
  spotFeePercent: number;       // base spot fee % override (0 = use VIP tier)
  spotGstPercent: number;       // GST applied on spot fee
  tdsPercent: number;           // TDS % on sell quote received
  futuresFeePercent: number;
  futuresGstPercent: number;
  referralCommission: number;
}
const DEFAULT_FEE_SETTINGS: FeeSettings = {
  spotFeePercent: 0, spotGstPercent: 18, tdsPercent: 1,
  futuresFeePercent: 0, futuresGstPercent: 18, referralCommission: 20,
};
export async function loadFeeSettings(): Promise<FeeSettings> {
  try {
    const keys = ["spot.fee_percent","spot.gst_percent","tds.percent","futures.fee_percent","futures.gst_percent","referral.commission"];
    const rows = await db.select().from(settingsTable);
    const map = new Map(rows.map(r => [r.key, r.value]));
    const num = (k: string, d: number) => { const v = map.get(k); const n = v ? Number(v) : NaN; return Number.isFinite(n) ? n : d; };
    return {
      spotFeePercent: num("spot.fee_percent", DEFAULT_FEE_SETTINGS.spotFeePercent),
      spotGstPercent: num("spot.gst_percent", DEFAULT_FEE_SETTINGS.spotGstPercent),
      tdsPercent: num("tds.percent", DEFAULT_FEE_SETTINGS.tdsPercent),
      futuresFeePercent: num("futures.fee_percent", DEFAULT_FEE_SETTINGS.futuresFeePercent),
      futuresGstPercent: num("futures.gst_percent", DEFAULT_FEE_SETTINGS.futuresGstPercent),
      referralCommission: num("referral.commission", DEFAULT_FEE_SETTINGS.referralCommission),
    };
  } catch { return DEFAULT_FEE_SETTINGS; }
}

/** Compute effective spot maker/taker rates (as fractions, e.g. 0.0025) including GST.
 *  feeRate = max(VIP tier rate, admin spot.fee_percent override) × (1 + gst%/100)
 *  Returned values are multiplied directly on notional. TDS is separate (sell only). */
export async function getSpotFeeRates(vipTier: number): Promise<{ maker: number; taker: number; tds: number; gstPercent: number }> {
  const tiers = await loadVipTiers();
  const settings = await loadFeeSettings();
  const t = tiers[Math.max(0, Math.min(tiers.length - 1, vipTier ?? 0))] ?? tiers[0];
  const baseMaker = Math.max(t.spotMaker, settings.spotFeePercent) / 100;
  const baseTaker = Math.max(t.spotTaker, settings.spotFeePercent) / 100;
  const gstMul = 1 + settings.spotGstPercent / 100;
  return {
    maker: baseMaker * gstMul,
    taker: baseTaker * gstMul,
    tds: settings.tdsPercent / 100,
    gstPercent: settings.spotGstPercent,
  };
}

router.get("/fees/tiers", async (_req, res) => { res.json(await loadVipTiers()); });

router.get("/fees/my", requireAuth, async (req, res): Promise<void> => {
  const userId = req.user!.id;
  const since = new Date(Date.now() - 30 * 86400_000);

  // Volume in quote currency. Sum per quote coin then convert to USDT-ish using current price of quote.
  // Simpler: sum (price*qty) grouped by quoteCoinId, multiply by quote.currentPrice (USDT).
  const rows = await db
    .select({
      quoteSymbol: coinsTable.symbol,
      quotePrice: coinsTable.currentPrice,
      vol: sql<string>`COALESCE(SUM(${tradesTable.price} * ${tradesTable.qty}), '0')`,
      feeQuote: sql<string>`COALESCE(SUM(${tradesTable.fee}), '0')`,
    })
    .from(tradesTable)
    .innerJoin(pairsTable, eq(tradesTable.pairId, pairsTable.id))
    .innerJoin(coinsTable, eq(pairsTable.quoteCoinId, coinsTable.id))
    .where(and(eq(tradesTable.userId, userId), gte(tradesTable.createdAt, since)))
    .groupBy(coinsTable.symbol, coinsTable.currentPrice);

  let volumeUsdt = 0, totalFeeUsdt = 0;
  for (const r of rows) {
    const px = r.quoteSymbol === "USDT" ? 1 : Number(r.quotePrice) || 0;
    volumeUsdt += Number(r.vol) * px;
    totalFeeUsdt += Number(r.feeQuote) * px;
  }

  // Find tier — ladder using user vipTier (admin-overridable) max with volume-based
  const tiers = await loadVipTiers();
  const [u] = await db.select({ vipTier: usersTable.vipTier }).from(usersTable).where(eq(usersTable.id, userId)).limit(1);
  const adminTier = u?.vipTier ?? 0;
  const volTier = [...tiers].reverse().find(t => volumeUsdt >= t.minVolume) ?? tiers[0];
  const finalTier = adminTier >= volTier.level ? tiers[adminTier] ?? volTier : volTier;

  res.json({
    volume30dUsdt: +volumeUsdt.toFixed(2),
    totalFeesUsdt: +totalFeeUsdt.toFixed(4),
    currentTier: finalTier,
    nextTier: tiers[finalTier.level + 1] ?? null,
    tiers,
  });
});

/**
 * Live fee/GST/TDS quote for the trading form. Public so the form can render
 * the breakdown before the user is logged in (still uses tier 0 for guests).
 *
 * Query: side=buy|sell, notional=number (qty * price in QUOTE units)
 * Returns: { feeRate, feePercent, gstPercent, tdsPercent, fee, gstAmount, tds,
 *           totalDeducted, netReceive, vipTier }
 *
 * For SELL: trader receives `notional - fee - tds`
 * For BUY:  trader pays    `notional + fee` (TDS not applied on buy side)
 */
router.get("/fees/quote", optionalAuth, async (req, res): Promise<void> => {
  const side = String(req.query.side || "sell").toLowerCase();
  const orderType = String(req.query.type || "market").toLowerCase();
  const notional = Math.max(0, Number(req.query.notional) || 0);
  let vipTier = 0;
  try {
    const userId = (req as any).user?.id;
    if (userId) {
      const [u] = await db.select({ vipTier: usersTable.vipTier }).from(usersTable).where(eq(usersTable.id, userId)).limit(1);
      vipTier = u?.vipTier ?? 0;
    }
  } catch { /* tier 0 */ }

  const rates = await getSpotFeeRates(vipTier);
  // Limit orders rest in the book → maker rate; market/stop orders cross →
  // taker rate. Both already include GST multiplier from getSpotFeeRates.
  const feeRate = orderType === "limit" ? rates.maker : rates.taker;
  const fee = notional * feeRate;
  const gstMul = 1 + rates.gstPercent / 100;
  const baseFeeRate = feeRate / gstMul; // GST-exclusive trading fee rate
  const baseFee = fee / gstMul;
  const gstAmount = fee - baseFee;
  const tds = side === "sell" ? notional * rates.tds : 0;
  const totalDeducted = fee + tds;
  const netReceive = side === "sell" ? notional - totalDeducted : notional + fee;

  res.json({
    side,
    type: orderType,
    notional: +notional.toFixed(8),
    vipTier,
    feeRate,
    feePercent: +(feeRate * 100).toFixed(4),       // GST-inclusive (matches `fee`)
    baseFeePercent: +(baseFeeRate * 100).toFixed(4), // GST-exclusive (matches `baseFee`)
    gstPercent: rates.gstPercent,
    tdsPercent: +(rates.tds * 100).toFixed(4),
    baseFee: +baseFee.toFixed(8),
    gstAmount: +gstAmount.toFixed(8),
    fee: +fee.toFixed(8),
    tds: +tds.toFixed(8),
    totalDeducted: +totalDeducted.toFixed(8),
    netReceive: +netReceive.toFixed(8),
  });
});

export default router;
