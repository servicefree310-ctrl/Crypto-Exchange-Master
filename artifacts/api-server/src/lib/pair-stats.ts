import { db, pairsTable, tradesTable } from "@workspace/db";
import { sql, eq } from "drizzle-orm";
import { logger } from "./logger";

export async function recomputePairStats(): Promise<void> {
  const pairs = await db.select().from(pairsTable);
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000);

  for (const p of pairs) {
    if (p.statsOverride) continue;
    try {
      const [agg] = await db
        .select({
          high: sql<string>`COALESCE(MAX(${tradesTable.price})::text, '0')`,
          low: sql<string>`COALESCE(MIN(${tradesTable.price})::text, '0')`,
          vol: sql<string>`COALESCE(SUM(${tradesTable.qty})::text, '0')`,
          quoteVol: sql<string>`COALESCE(SUM(${tradesTable.qty} * ${tradesTable.price})::text, '0')`,
          cnt: sql<number>`COUNT(*)::int`,
          firstPrice: sql<string>`COALESCE((array_agg(${tradesTable.price} ORDER BY ${tradesTable.createdAt} ASC))[1]::text, '0')`,
          lastPrice: sql<string>`COALESCE((array_agg(${tradesTable.price} ORDER BY ${tradesTable.createdAt} DESC))[1]::text, '0')`,
        })
        .from(tradesTable)
        .where(sql`${tradesTable.pairId} = ${p.id} AND ${tradesTable.createdAt} >= ${since}`);

      const first = Number(agg?.firstPrice ?? "0");
      const last = Number(agg?.lastPrice ?? "0");
      const change = first > 0 ? ((last - first) / first) * 100 : 0;

      const cnt = Number(agg?.cnt ?? 0);
      const updates: any = { trades24h: cnt };
      if (cnt > 0) {
        updates.high24h = agg?.high ?? "0";
        updates.low24h = agg?.low ?? "0";
        updates.volume24h = agg?.vol ?? "0";
        updates.quoteVolume24h = agg?.quoteVol ?? "0";
        updates.change24h = change.toFixed(4);
        if (last > 0) updates.lastPrice = String(last);
      }
      // If no trades in 24h, leave existing high/low/volume/lastPrice untouched (don't wipe to 0)

      await db.update(pairsTable).set(updates).where(eq(pairsTable.id, p.id));
    } catch (e: any) {
      logger.warn({ err: e?.message, pairId: p.id }, "pair stats recompute failed");
    }
  }
}

let timer: NodeJS.Timeout | null = null;
export function startPairStatsService(intervalMs = 30_000): void {
  if (timer) return;
  recomputePairStats().catch((e) => logger.warn({ err: e?.message }, "initial pair stats failed"));
  timer = setInterval(() => {
    recomputePairStats().catch((e) => logger.warn({ err: e?.message }, "pair stats interval failed"));
  }, intervalMs);
  logger.info({ intervalMs }, "Pair stats service started");
}

export function stopPairStatsService(): void {
  if (timer) { clearInterval(timer); timer = null; }
}
