import { Router, type IRouter } from "express";
import { eq, and, desc } from "drizzle-orm";
import {
  db,
  coinsTable,
  networksTable,
  pairsTable,
  legalPagesTable,
  settingsTable,
  earnProductsTable,
} from "@workspace/db";

const router: IRouter = Router();

// Public coins (only active + listed)
router.get("/coins", async (_req, res): Promise<void> => {
  const rows = await db.select().from(coinsTable).where(eq(coinsTable.isListed, true)).orderBy(coinsTable.symbol);
  res.json(rows);
});

router.get("/networks", async (req, res): Promise<void> => {
  const coinId = req.query.coinId ? Number(req.query.coinId) : null;
  const rows = coinId
    ? await db.select().from(networksTable).where(and(eq(networksTable.coinId, coinId), eq(networksTable.status, "active")))
    : await db.select().from(networksTable).where(eq(networksTable.status, "active"));
  res.json(rows);
});

router.get("/pairs", async (_req, res): Promise<void> => {
  const rows = await db.select().from(pairsTable).where(eq(pairsTable.status, "active")).orderBy(pairsTable.symbol);
  res.json(rows);
});

router.get("/legal/:slug", async (req, res): Promise<void> => {
  const slug = Array.isArray(req.params.slug) ? req.params.slug[0] : req.params.slug;
  if (!slug) { res.status(400).json({ error: "slug required" }); return; }
  const [p] = await db.select().from(legalPagesTable).where(eq(legalPagesTable.slug, slug)).limit(1);
  if (!p) { res.status(404).json({ error: "Not found" }); return; }
  res.json(p);
});

router.get("/settings/:key", async (req, res): Promise<void> => {
  const key = Array.isArray(req.params.key) ? req.params.key[0] : req.params.key;
  if (!key) { res.status(400).json({ error: "key required" }); return; }
  const [s] = await db.select().from(settingsTable).where(eq(settingsTable.key, key)).limit(1);
  if (!s) { res.status(404).json({ error: "Not found" }); return; }
  res.json(s);
});

router.get("/earn-products", async (_req, res): Promise<void> => {
  const rows = await db.select().from(earnProductsTable).where(eq(earnProductsTable.status, "active")).orderBy(desc(earnProductsTable.apy));
  res.json(rows);
});

export default router;
