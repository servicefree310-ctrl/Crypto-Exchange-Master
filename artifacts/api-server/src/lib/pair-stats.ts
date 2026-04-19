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
      // Use raw SQL update so we don't depend on Drizzle's column-name
      // mapping (which has previously dropped volume_24h silently when
      // routed through .set({ volume24h })). Stats include bot fills —
      // bot trades land in tradesTable identically to user trades, so
      // volume/quote-volume/24h-change naturally reflect them.
      if (cnt > 0) {
        const high = agg?.high ?? "0";
        const low = agg?.low ?? "0";
        const vol = agg?.vol ?? "0";
        const qvol = agg?.quoteVol ?? "0";
        const chg = change.toFixed(4);
        if (last > 0) {
          await db.execute(sql`
            UPDATE pairs SET trades_24h = ${cnt},
              high_24h = ${high}, low_24h = ${low},
              volume_24h = ${vol}, quote_volume_24h = ${qvol},
              change_24h = ${chg}, last_price = ${String(last)}
            WHERE id = ${p.id}`);
        } else {
          await db.execute(sql`
            UPDATE pairs SET trades_24h = ${cnt},
              high_24h = ${high}, low_24h = ${low},
              volume_24h = ${vol}, quote_volume_24h = ${qvol},
              change_24h = ${chg}
            WHERE id = ${p.id}`);
        }
      } else {
        await db.execute(sql`UPDATE pairs SET trades_24h = 0 WHERE id = ${p.id}`);
      }
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
