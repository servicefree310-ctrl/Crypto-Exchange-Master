import { Router, type IRouter } from "express";

const router: IRouter = Router();

type Kline = { ts: number; open: number; high: number; low: number; close: number; volume: number };
type CacheEntry = { data: Kline[]; expires: number };
const cache = new Map<string, CacheEntry>();
const CACHE_TTL_MS = 4000;

const VALID_INTERVALS = new Set(["1m", "3m", "5m", "15m", "30m", "1h", "2h", "4h", "6h", "12h", "1d", "1w"]);

const BYBIT_INTERVAL: Record<string, string> = {
  "1m": "1", "3m": "3", "5m": "5", "15m": "15", "30m": "30",
  "1h": "60", "2h": "120", "4h": "240", "6h": "360", "12h": "720",
  "1d": "D", "1w": "W",
};

const OKX_BAR: Record<string, string> = {
  "1m": "1m", "3m": "3m", "5m": "5m", "15m": "15m", "30m": "30m",
  "1h": "1H", "2h": "2H", "4h": "4H", "6h": "6Hutc", "12h": "12Hutc",
  "1d": "1Dutc", "1w": "1Wutc",
};

function toBaseSymbol(sym: string): string {
  const s = sym.toUpperCase().replace(/USDT$|INR$/, "");
  if (s === "USDT") return "USDC";
  return s;
}

async function fetchBybit(base: string, interval: string, limit: number): Promise<Kline[]> {
  const sym = `${base}USDT`;
  const url = `https://api.bybit.com/v5/market/kline?category=spot&symbol=${sym}&interval=${BYBIT_INTERVAL[interval]}&limit=${limit}`;
  const r = await fetch(url, { signal: AbortSignal.timeout(5000) });
  if (!r.ok) throw new Error(`bybit ${r.status}`);
  const j: any = await r.json();
  if (j?.retCode !== 0 || !j?.result?.list) throw new Error(`bybit ${j?.retMsg || "no list"}`);
  // Bybit returns most-recent first: [ts, open, high, low, close, volume, turnover]
  return (j.result.list as any[]).map((k) => ({
    ts: Number(k[0]),
    open: Number(k[1]),
    high: Number(k[2]),
    low: Number(k[3]),
    close: Number(k[4]),
    volume: Number(k[5]),
  })).reverse();
}

async function fetchOkx(base: string, interval: string, limit: number): Promise<Kline[]> {
  const sym = `${base}-USDT`;
  const url = `https://www.okx.com/api/v5/market/candles?instId=${sym}&bar=${OKX_BAR[interval]}&limit=${limit}`;
  const r = await fetch(url, { signal: AbortSignal.timeout(5000) });
  if (!r.ok) throw new Error(`okx ${r.status}`);
  const j: any = await r.json();
  if (j?.code !== "0" || !Array.isArray(j?.data)) throw new Error(`okx ${j?.msg || "no data"}`);
  // OKX: [ts, o, h, l, c, vol, volCcy, volCcyQuote, confirm], most-recent first
  return (j.data as any[]).map((k) => ({
    ts: Number(k[0]),
    open: Number(k[1]),
    high: Number(k[2]),
    low: Number(k[3]),
    close: Number(k[4]),
    volume: Number(k[5]),
  })).reverse();
}

router.get("/klines", async (req, res): Promise<void> => {
  const symbolRaw = String(req.query.symbol || "BTC").toUpperCase();
  const interval = String(req.query.interval || "1m");
  const limit = Math.max(10, Math.min(Number(req.query.limit) || 120, 500));
  if (!VALID_INTERVALS.has(interval)) { res.status(400).json({ error: "invalid interval" }); return; }

  const base = toBaseSymbol(symbolRaw);
  const key = `${base}:${interval}:${limit}`;
  const now = Date.now();
  const hit = cache.get(key);
  if (hit && hit.expires > now) { res.json({ symbol: symbolRaw, interval, candles: hit.data }); return; }

  let candles: Kline[] | null = null;
  let lastErr = "";
  for (const fn of [fetchBybit, fetchOkx]) {
    try {
      candles = await fn(base, interval, limit);
      if (candles && candles.length) break;
    } catch (e: any) { lastErr = e?.message || String(e); }
  }
  if (!candles || !candles.length) {
    if (hit) { res.json({ symbol: symbolRaw, interval, candles: hit.data, stale: true }); return; }
    res.status(502).json({ error: "klines fetch failed", detail: lastErr });
    return;
  }
  cache.set(key, { data: candles, expires: now + CACHE_TTL_MS });
  res.json({ symbol: symbolRaw, interval, candles });
});

export default router;
