import { Router, type IRouter } from "express";
import { eq, and, gte, sql } from "drizzle-orm";
import { db, tradesTable, pairsTable, coinsTable, usersTable, settingsTable } from "@workspace/db";
import { requireAuth } from "../middlewares/auth";

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

export default router;
