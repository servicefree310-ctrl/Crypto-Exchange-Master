import { db, coinsTable, pairsTable, settingsTable } from "@workspace/db";
import { eq } from "drizzle-orm";
import { logger } from "./logger";

type Tick = { symbol: string; usdt: number; inr: number; change24h: number; volume24h: number; ts: number };

const cache = new Map<string, Tick>();
let inrRate = 84;
const subscribers = new Set<(ticks: Tick[]) => void>();

export function getCache(): Tick[] { return Array.from(cache.values()); }
export function getInrRate(): number { return inrRate; }
export function subscribe(fn: (ticks: Tick[]) => void): () => void {
  subscribers.add(fn);
  return () => subscribers.delete(fn);
}
function broadcast(ticks: Tick[]) {
  for (const s of subscribers) { try { s(ticks); } catch {} }
}

async function loadInrRate() {
  try {
    const [row] = await db.select().from(settingsTable).where(eq(settingsTable.key, "inr_usdt_rate")).limit(1);
    if (row) { const n = Number(row.value); if (Number.isFinite(n) && n > 0) inrRate = n; }
  } catch {}
}

// Map: source symbol (e.g. "BTCUSDT" or coin.symbol fallback) -> { price, change, volume }
async function fetchTickers(coinSymbols: string[]): Promise<Map<string, { price: number; change: number; volume: number }>> {
  const out = new Map<string, { price: number; change: number; volume: number }>();
  if (coinSymbols.length === 0) return out;

  // Primary: CoinGecko (works globally, free, no key)
  try {
    const lc = coinSymbols.map(s => s.toLowerCase()).join(",");
    const url = `https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&symbols=${encodeURIComponent(lc)}&per_page=250`;
    const r = await fetch(url, { signal: AbortSignal.timeout(10000) });
    if (r.ok) {
      const data = await r.json() as any[];
      for (const t of data) {
        const sym = String(t.symbol || "").toUpperCase();
        if (!sym) continue;
        out.set(sym, {
          price: Number(t.current_price ?? 0),
          change: Number(t.price_change_percentage_24h ?? 0),
          volume: Number(t.total_volume ?? 0),
        });
      }
      if (out.size > 0) return out;
    }
  } catch (e: any) { logger.warn({ err: e?.message }, "coingecko fetch failed"); }

  // Fallback: Binance (geo-restricted in some regions)
  try {
    const binSyms = coinSymbols.map(s => s.toUpperCase() + "USDT");
    const url = `https://api.binance.com/api/v3/ticker/24hr?symbols=${encodeURIComponent(JSON.stringify(binSyms))}`;
    const r = await fetch(url, { signal: AbortSignal.timeout(8000) });
    if (r.ok) {
      const data = await r.json() as any[];
      for (const t of data) {
        const sym = String(t.symbol).replace(/USDT$/, "");
        out.set(sym, { price: Number(t.lastPrice), change: Number(t.priceChangePercent), volume: Number(t.quoteVolume) });
      }
    }
  } catch (e: any) { logger.warn({ err: e?.message }, "binance fallback failed"); }

  return out;
}

async function tick() {
  await loadInrRate();
  const coins = await db.select().from(coinsTable);
  const liveCoins = coins.filter(c => c.priceSource !== "manual" && c.symbol !== "INR" && c.symbol !== "USDT");
  const liveSymbols = liveCoins.map(c => (c.binanceSymbol ? c.binanceSymbol.replace(/USDT$/, "") : c.symbol));
  const liveData = await fetchTickers(liveSymbols);
  const updates: Tick[] = [];

  for (const c of coins) {
    let usdt = 0, change = 0, volume = 0;
    const lookupKey = c.binanceSymbol ? c.binanceSymbol.replace(/USDT$/, "") : c.symbol;
    if (c.symbol === "USDT") { usdt = 1; }
    else if (c.symbol === "INR") { usdt = inrRate > 0 ? 1 / inrRate : 0; }
    else if (c.priceSource === "manual") { usdt = Number(c.manualPrice ?? 0); }
    else if (liveData.has(lookupKey)) {
      const d = liveData.get(lookupKey)!;
      usdt = d.price; change = d.change; volume = d.volume;
    } else { usdt = Number(c.currentPrice ?? 0); change = Number(c.change24h ?? 0); }

    const inr = usdt * inrRate;
    const t: Tick = { symbol: c.symbol, usdt, inr, change24h: change, volume24h: volume, ts: Date.now() };
    cache.set(c.symbol, t);
    updates.push(t);

    try {
      await db.update(coinsTable).set({
        currentPrice: String(usdt.toFixed(8)),
        change24h: String(change.toFixed(4)),
        updatedAt: new Date(),
      }).where(eq(coinsTable.id, c.id));
    } catch {}
  }

  // Update pairs with latest base price (in quote terms — for USDT-quoted pairs use base usdt)
  try {
    const pairs = await db.select().from(pairsTable);
    for (const p of pairs) {
      const base = coins.find(x => x.id === p.baseCoinId);
      const quote = coins.find(x => x.id === p.quoteCoinId);
      if (!base || !quote) continue;
      // Skip auto-update if base coin uses manual price — admin's manual pair edit should persist
      if (base.priceSource === "manual") continue;
      const bPx = cache.get(base.symbol)?.usdt ?? 0;
      const qPx = cache.get(quote.symbol)?.usdt ?? 1;
      if (bPx > 0 && qPx > 0) {
        const last = bPx / qPx;
        const ch = cache.get(base.symbol)?.change24h ?? 0;
        const vol = cache.get(base.symbol)?.volume24h ?? 0;
        await db.update(pairsTable).set({
          lastPrice: String(last.toFixed(8)),
          change24h: String(ch.toFixed(4)),
          volume24h: String(vol.toFixed(8)),
        }).where(eq(pairsTable.id, p.id));
      }
    }
  } catch {}

  broadcast(updates);
}

let started = false;
let ticking = false;
async function safeTick() {
  if (ticking) return;
  ticking = true;
  try { await tick(); } catch (e: any) { logger.warn({ err: e?.message }, "tick failed"); }
  finally { ticking = false; }
}
export function startPriceService(intervalMs = 1000) {
  if (started) return;
  started = true;
  void safeTick();
  setInterval(() => { void safeTick(); }, intervalMs);
  logger.info({ intervalMs }, "price service started");
}
