import { useEffect, useMemo, useRef, useState } from "react";
import { Link } from "wouter";
import { useQuery } from "@tanstack/react-query";
import {
  ArrowRight,
  TrendingUp,
  TrendingDown,
  Flame,
  BarChart3,
  Wallet as WalletIcon,
  Zap,
  Shield,
  Lock,
  Banknote,
  Headphones,
  Sparkles,
  ChevronRight,
  Globe2,
  Activity,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Badge } from "@/components/ui/badge";
import { useTickers, encodeSymbol, type NormalizedTicker } from "@/lib/marketSocket";
import { useAuth } from "@/lib/auth";
import { get } from "@/lib/api";

// ──────────────────────────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────────────────────────
function isInr(sym: string) {
  return sym.endsWith("/INR") || sym.endsWith("INR");
}
function fmtPrice(n: number, sym: string): string {
  if (!isFinite(n) || n === 0) return "—";
  const inr = isInr(sym);
  const digits = inr ? 2 : n < 1 ? 6 : n < 100 ? 4 : 2;
  const prefix = inr ? "₹" : "";
  return prefix + n.toLocaleString(undefined, { minimumFractionDigits: digits, maximumFractionDigits: digits });
}
function fmtCompact(n: number, prefix = "") {
  if (!isFinite(n) || n === 0) return prefix + "0";
  const abs = Math.abs(n);
  if (abs >= 1e9) return prefix + (n / 1e9).toFixed(2) + "B";
  if (abs >= 1e6) return prefix + (n / 1e6).toFixed(2) + "M";
  if (abs >= 1e3) return prefix + (n / 1e3).toFixed(2) + "K";
  return prefix + n.toFixed(2);
}
function baseAsset(sym: string) {
  return sym.split("/")[0] || sym;
}
function quoteAsset(sym: string) {
  return sym.split("/")[1] || "";
}

// ──────────────────────────────────────────────────────────────────
// Sparkline — fetches /exchange/chart for the symbol
// ──────────────────────────────────────────────────────────────────
type Candle = [number, number, number, number, number, number]; // ts,o,h,l,c,v

function Sparkline({ symbol, positive }: { symbol: string; positive: boolean }) {
  const [bRaw, qRaw] = symbol.split("/");
  const { data } = useQuery<Candle[] | { data?: Candle[] }>({
    queryKey: ["spark", symbol],
    queryFn: () =>
      get(`/exchange/chart?currency=${encodeURIComponent(bRaw)}&pair=${encodeURIComponent(qRaw)}&interval=1h&limit=24`),
    staleTime: 60_000,
    refetchInterval: 60_000,
    retry: 1,
  });

  const points = useMemo(() => {
    const arr: Candle[] = Array.isArray(data) ? data : ((data as any)?.data ?? []);
    return arr.map((c) => Number(c[4])).filter((n) => isFinite(n));
  }, [data]);

  if (points.length < 2) {
    return <div className="h-9 w-24 opacity-30 bg-gradient-to-r from-transparent via-muted to-transparent rounded" />;
  }

  const min = Math.min(...points);
  const max = Math.max(...points);
  const range = max - min || 1;
  const W = 96;
  const H = 36;
  const stepX = W / (points.length - 1);
  const path = points
    .map((p, i) => {
      const x = i * stepX;
      const y = H - ((p - min) / range) * H;
      return `${i === 0 ? "M" : "L"}${x.toFixed(2)},${y.toFixed(2)}`;
    })
    .join(" ");
  const stroke = positive ? "hsl(var(--success))" : "hsl(var(--destructive))";
  const fillId = `sparkfill-${symbol.replace(/[^a-z0-9]/gi, "")}-${positive ? "p" : "n"}`;

  return (
    <svg width={W} height={H} viewBox={`0 0 ${W} ${H}`} className="overflow-visible">
      <defs>
        <linearGradient id={fillId} x1="0" x2="0" y1="0" y2="1">
          <stop offset="0%" stopColor={stroke} stopOpacity="0.35" />
          <stop offset="100%" stopColor={stroke} stopOpacity="0" />
        </linearGradient>
      </defs>
      <path d={`${path} L${W},${H} L0,${H} Z`} fill={`url(#${fillId})`} />
      <path d={path} stroke={stroke} strokeWidth="1.5" fill="none" />
    </svg>
  );
}

// ──────────────────────────────────────────────────────────────────
// Asset icon (text avatar)
// ──────────────────────────────────────────────────────────────────
function AssetIcon({ symbol }: { symbol: string }) {
  const b = baseAsset(symbol);
  const c = b.slice(0, 1);
  // Stable color per asset
  const palette = [
    "from-amber-500 to-orange-600",
    "from-sky-500 to-blue-600",
    "from-violet-500 to-purple-600",
    "from-emerald-500 to-teal-600",
    "from-rose-500 to-pink-600",
    "from-fuchsia-500 to-indigo-600",
    "from-yellow-500 to-amber-600",
    "from-cyan-500 to-sky-600",
  ];
  let hash = 0;
  for (let i = 0; i < b.length; i++) hash = (hash * 31 + b.charCodeAt(i)) >>> 0;
  const grad = palette[hash % palette.length];
  return (
    <div
      className={`h-8 w-8 rounded-full bg-gradient-to-br ${grad} text-white flex items-center justify-center text-xs font-bold shadow-md`}
    >
      {c}
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────
// Live Ticker Tape (marquee)
// ──────────────────────────────────────────────────────────────────
function TickerTape({ tickers }: { tickers: NormalizedTicker[] }) {
  if (tickers.length === 0) return null;
  // duplicate for seamless scroll
  const items = [...tickers, ...tickers];
  return (
    <div className="w-full overflow-hidden border-y border-border bg-card/50 backdrop-blur">
      <div className="flex gap-8 py-2 animate-[scroll_60s_linear_infinite] hover:[animation-play-state:paused]">
        {items.map((t, i) => {
          const positive = t.priceChangePercent >= 0;
          return (
            <Link
              key={`${t.symbol}-${i}`}
              href={`/trade/${encodeSymbol(t.symbol)}`}
              className="flex items-center gap-2 whitespace-nowrap text-sm hover:text-primary transition-colors"
            >
              <span className="font-bold">{t.symbol}</span>
              <span className="font-mono tabular-nums">{fmtPrice(t.lastPrice, t.symbol)}</span>
              <span className={positive ? "text-success" : "text-destructive"}>
                {positive ? "+" : ""}
                {t.priceChangePercent.toFixed(2)}%
              </span>
            </Link>
          );
        })}
      </div>
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────
// Animated counter
// ──────────────────────────────────────────────────────────────────
function AnimatedNumber({
  value,
  prefix = "",
  suffix = "",
  decimals = 0,
  compact = false,
}: {
  value: number;
  prefix?: string;
  suffix?: string;
  decimals?: number;
  compact?: boolean;
}) {
  const [shown, setShown] = useState(0);
  const fromRef = useRef(0);

  useEffect(() => {
    const from = fromRef.current;
    const to = value || 0;
    const start = performance.now();
    const dur = 900;
    let raf = 0;
    const tick = (t: number) => {
      const p = Math.min(1, (t - start) / dur);
      const eased = 1 - Math.pow(1 - p, 3);
      setShown(from + (to - from) * eased);
      if (p < 1) raf = requestAnimationFrame(tick);
      else fromRef.current = to;
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [value]);

  const formatted = compact
    ? fmtCompact(shown)
    : shown.toLocaleString(undefined, { minimumFractionDigits: decimals, maximumFractionDigits: decimals });

  return (
    <span className="font-mono tabular-nums">
      {prefix}
      {formatted}
      {suffix}
    </span>
  );
}

// ──────────────────────────────────────────────────────────────────
// Market table row
// ──────────────────────────────────────────────────────────────────
function MarketRow({ t }: { t: NormalizedTicker }) {
  const positive = t.priceChangePercent >= 0;
  return (
    <Link
      href={`/trade/${encodeSymbol(t.symbol)}`}
      className="grid grid-cols-12 gap-3 items-center px-4 py-3 hover:bg-muted/30 transition-colors border-b border-border/60 last:border-b-0"
    >
      <div className="col-span-4 sm:col-span-3 flex items-center gap-3 min-w-0">
        <AssetIcon symbol={t.symbol} />
        <div className="min-w-0">
          <div className="font-bold text-sm truncate">{baseAsset(t.symbol)}</div>
          <div className="text-[11px] text-muted-foreground truncate">/ {quoteAsset(t.symbol)}</div>
        </div>
      </div>
      <div className="col-span-3 sm:col-span-2 text-right font-mono tabular-nums text-sm">
        {fmtPrice(t.lastPrice, t.symbol)}
      </div>
      <div
        className={`col-span-3 sm:col-span-2 text-right font-mono tabular-nums text-sm ${
          positive ? "text-success" : "text-destructive"
        }`}
      >
        {positive ? "+" : ""}
        {t.priceChangePercent.toFixed(2)}%
      </div>
      <div className="hidden sm:block sm:col-span-2 text-right font-mono tabular-nums text-xs text-muted-foreground">
        {fmtCompact(t.quoteVolume, isInr(t.symbol) ? "₹" : "$")}
      </div>
      <div className="col-span-2 sm:col-span-2 flex justify-end">
        <Sparkline symbol={t.symbol} positive={positive} />
      </div>
      <div className="hidden sm:flex sm:col-span-1 justify-end">
        <ChevronRight className="h-4 w-4 text-muted-foreground" />
      </div>
    </Link>
  );
}

// ──────────────────────────────────────────────────────────────────
// Page
// ──────────────────────────────────────────────────────────────────
export default function Home() {
  const tickersMap = useTickers();
  const { user } = useAuth();
  const all = useMemo(() => Object.values(tickersMap).filter((t) => t.lastPrice > 0), [tickersMap]);

  // KPIs derived from live tickers
  const stats = useMemo(() => {
    const totalVol = all.reduce((s, t) => s + (t.quoteVolume || 0), 0);
    const gainers = all.filter((t) => t.priceChangePercent > 0).length;
    const markets = all.length;
    return { totalVol, gainers, markets };
  }, [all]);

  // Top 10 by volume for ticker tape
  const tape = useMemo(
    () => [...all].sort((a, b) => (b.quoteVolume || 0) - (a.quoteVolume || 0)).slice(0, 12),
    [all]
  );

  // Tab data sets
  const hot = useMemo(
    () =>
      [...all]
        .sort((a, b) => Math.abs(b.priceChangePercent) * (b.quoteVolume || 1) - Math.abs(a.priceChangePercent) * (a.quoteVolume || 1))
        .slice(0, 8),
    [all]
  );
  const gainers = useMemo(() => [...all].sort((a, b) => b.priceChangePercent - a.priceChangePercent).slice(0, 8), [all]);
  const losers = useMemo(() => [...all].sort((a, b) => a.priceChangePercent - b.priceChangePercent).slice(0, 8), [all]);
  const volume = useMemo(() => [...all].sort((a, b) => (b.quoteVolume || 0) - (a.quoteVolume || 0)).slice(0, 8), [all]);

  return (
    <div className="flex flex-col w-full">
      {/* Live ticker tape */}
      <TickerTape tickers={tape} />

      {/* ─── HERO ─────────────────────────────────────────────── */}
      <section className="relative w-full overflow-hidden">
        {/* Background gradient + grid */}
        <div className="absolute inset-0 bg-gradient-to-br from-background via-background to-amber-950/20" />
        <div
          className="absolute inset-0 opacity-[0.07]"
          style={{
            backgroundImage:
              "linear-gradient(hsl(var(--border)) 1px, transparent 1px), linear-gradient(90deg, hsl(var(--border)) 1px, transparent 1px)",
            backgroundSize: "48px 48px",
          }}
        />
        <div className="absolute -top-32 -right-32 h-96 w-96 rounded-full bg-amber-500/15 blur-3xl" />
        <div className="absolute -bottom-32 -left-32 h-96 w-96 rounded-full bg-orange-500/10 blur-3xl" />

        <div className="relative container mx-auto px-4 py-16 lg:py-24 grid lg:grid-cols-2 gap-10 items-center">
          <div className="space-y-6">
            <Badge variant="outline" className="border-primary/40 text-primary px-3 py-1">
              <Sparkles className="h-3 w-3 mr-1.5" />
              India's most advanced crypto terminal
            </Badge>
            <h1 className="text-5xl lg:text-6xl font-extrabold tracking-tight leading-[1.05]">
              Trade smarter on{" "}
              <span className="bg-gradient-to-r from-amber-300 via-yellow-400 to-orange-500 bg-clip-text text-transparent">
                CryptoX
              </span>
            </h1>
            <p className="text-lg text-muted-foreground max-w-xl">
              Spot &amp; perpetual futures with deep liquidity, sub-second matching, INR rails and a pro-grade desktop terminal —
              all in one place.
            </p>
            <div className="flex flex-wrap gap-3">
              {!user ? (
                <>
                  <Button size="lg" className="bg-primary text-primary-foreground hover:bg-primary/90 text-base px-7" asChild>
                    <Link href="/signup">
                      Create account <ArrowRight className="ml-2 h-4 w-4" />
                    </Link>
                  </Button>
                  <Button size="lg" variant="outline" className="text-base px-7" asChild>
                    <Link href="/markets">Explore markets</Link>
                  </Button>
                </>
              ) : (
                <>
                  <Button size="lg" className="bg-primary text-primary-foreground hover:bg-primary/90 text-base px-7" asChild>
                    <Link href="/trade">
                      Open trade terminal <ArrowRight className="ml-2 h-4 w-4" />
                    </Link>
                  </Button>
                  <Button size="lg" variant="outline" className="text-base px-7" asChild>
                    <Link href="/wallet">My wallet</Link>
                  </Button>
                </>
              )}
            </div>

            {/* Trust strip */}
            <div className="flex flex-wrap items-center gap-x-6 gap-y-2 pt-4 text-xs text-muted-foreground">
              <span className="flex items-center gap-1.5">
                <Shield className="h-3.5 w-3.5 text-success" /> 95% cold storage
              </span>
              <span className="flex items-center gap-1.5">
                <Lock className="h-3.5 w-3.5 text-success" /> 2FA &amp; biometric login
              </span>
              <span className="flex items-center gap-1.5">
                <Banknote className="h-3.5 w-3.5 text-success" /> INR deposits &amp; withdrawals
              </span>
            </div>
          </div>

          {/* KPI tiles */}
          <div className="grid grid-cols-2 gap-4">
            <Card className="p-5 bg-card/60 backdrop-blur border-border/60 hover:border-primary/40 transition-colors">
              <div className="flex items-center gap-2 text-xs text-muted-foreground uppercase tracking-wider">
                <Activity className="h-3.5 w-3.5" /> 24h volume
              </div>
              <div className="text-3xl font-bold mt-2">
                <AnimatedNumber value={stats.totalVol} prefix="$" compact />
              </div>
              <div className="text-xs text-success mt-1">Live across all markets</div>
            </Card>
            <Card className="p-5 bg-card/60 backdrop-blur border-border/60 hover:border-primary/40 transition-colors">
              <div className="flex items-center gap-2 text-xs text-muted-foreground uppercase tracking-wider">
                <Globe2 className="h-3.5 w-3.5" /> Markets
              </div>
              <div className="text-3xl font-bold mt-2">
                <AnimatedNumber value={stats.markets} />
              </div>
              <div className="text-xs text-muted-foreground mt-1">Spot &amp; perpetuals</div>
            </Card>
            <Card className="p-5 bg-card/60 backdrop-blur border-border/60 hover:border-primary/40 transition-colors">
              <div className="flex items-center gap-2 text-xs text-muted-foreground uppercase tracking-wider">
                <TrendingUp className="h-3.5 w-3.5" /> Gainers
              </div>
              <div className="text-3xl font-bold mt-2 text-success">
                <AnimatedNumber value={stats.gainers} />
              </div>
              <div className="text-xs text-muted-foreground mt-1">In the last 24h</div>
            </Card>
            <Card className="p-5 bg-card/60 backdrop-blur border-border/60 hover:border-primary/40 transition-colors">
              <div className="flex items-center gap-2 text-xs text-muted-foreground uppercase tracking-wider">
                <Zap className="h-3.5 w-3.5" /> Latency
              </div>
              <div className="text-3xl font-bold mt-2">
                {"<"}5<span className="text-base font-medium text-muted-foreground ml-1">ms</span>
              </div>
              <div className="text-xs text-muted-foreground mt-1">Match engine p99</div>
            </Card>
          </div>
        </div>
      </section>

      {/* ─── MARKETS ─────────────────────────────────────────── */}
      <section className="w-full py-14 bg-background">
        <div className="container mx-auto px-4">
          <div className="flex items-end justify-between flex-wrap gap-4 mb-6">
            <div>
              <h2 className="text-3xl font-bold tracking-tight">Live markets</h2>
              <p className="text-muted-foreground text-sm mt-1">Real-time prices straight from the exchange.</p>
            </div>
            <Button variant="outline" asChild>
              <Link href="/markets">
                View all <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
          </div>

          <Tabs defaultValue="hot" className="w-full">
            <TabsList className="bg-card border border-border h-auto p-1">
              <TabsTrigger value="hot" className="data-[state=active]:bg-primary data-[state=active]:text-primary-foreground gap-1.5">
                <Flame className="h-3.5 w-3.5" /> Hot
              </TabsTrigger>
              <TabsTrigger value="gainers" className="data-[state=active]:bg-primary data-[state=active]:text-primary-foreground gap-1.5">
                <TrendingUp className="h-3.5 w-3.5" /> Gainers
              </TabsTrigger>
              <TabsTrigger value="losers" className="data-[state=active]:bg-primary data-[state=active]:text-primary-foreground gap-1.5">
                <TrendingDown className="h-3.5 w-3.5" /> Losers
              </TabsTrigger>
              <TabsTrigger value="vol" className="data-[state=active]:bg-primary data-[state=active]:text-primary-foreground gap-1.5">
                <BarChart3 className="h-3.5 w-3.5" /> Volume
              </TabsTrigger>
            </TabsList>

            {[
              { key: "hot", data: hot },
              { key: "gainers", data: gainers },
              { key: "losers", data: losers },
              { key: "vol", data: volume },
            ].map(({ key, data }) => (
              <TabsContent key={key} value={key} className="mt-4">
                <Card className="overflow-hidden border-border/60">
                  {/* Header */}
                  <div className="hidden sm:grid grid-cols-12 gap-3 px-4 py-2.5 text-[11px] uppercase tracking-wider text-muted-foreground bg-muted/40 border-b border-border">
                    <div className="col-span-3">Pair</div>
                    <div className="col-span-2 text-right">Price</div>
                    <div className="col-span-2 text-right">24h</div>
                    <div className="col-span-2 text-right">24h vol</div>
                    <div className="col-span-2 text-right">Last 24h</div>
                    <div className="col-span-1" />
                  </div>
                  {data.length === 0 ? (
                    <div className="p-12 text-center text-muted-foreground text-sm">Loading markets…</div>
                  ) : (
                    data.map((t) => <MarketRow key={t.symbol} t={t} />)
                  )}
                </Card>
              </TabsContent>
            ))}
          </Tabs>
        </div>
      </section>

      {/* ─── PRODUCTS ─────────────────────────────────────────── */}
      <section className="w-full py-16 bg-card/30 border-y border-border">
        <div className="container mx-auto px-4">
          <div className="text-center mb-10">
            <h2 className="text-3xl font-bold tracking-tight">Trade your way</h2>
            <p className="text-muted-foreground text-sm mt-2">From simple swaps to leveraged perpetuals — built for every kind of trader.</p>
          </div>
          <div className="grid md:grid-cols-3 gap-5">
            <ProductCard
              icon={<BarChart3 className="h-6 w-6" />}
              title="Spot trading"
              desc="Buy and sell crypto on real-time order books with instant settlement and best-in-class fees."
              href="/trade"
              cta="Open spot terminal"
              accent="from-amber-500/20 to-orange-500/5"
            />
            <ProductCard
              icon={<Zap className="h-6 w-6" />}
              title="Perpetual futures"
              desc="Long or short top assets with up to 100× leverage, isolated or cross margin, and live PnL."
              href="/futures"
              cta="Open futures"
              accent="from-violet-500/20 to-fuchsia-500/5"
              badge="100×"
            />
            <ProductCard
              icon={<WalletIcon className="h-6 w-6" />}
              title="Wallet &amp; INR rails"
              desc="Deposit and withdraw INR via UPI/NEFT, manage spot &amp; futures balances from one dashboard."
              href={user ? "/wallet" : "/signup"}
              cta={user ? "Open wallet" : "Get started"}
              accent="from-emerald-500/20 to-teal-500/5"
            />
          </div>
        </div>
      </section>

      {/* ─── WHY US ─────────────────────────────────────────── */}
      <section className="w-full py-16">
        <div className="container mx-auto px-4">
          <div className="text-center mb-10">
            <h2 className="text-3xl font-bold tracking-tight">Why traders choose CryptoX</h2>
            <p className="text-muted-foreground text-sm mt-2">A serious exchange, built for the Indian market.</p>
          </div>
          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-4">
            <Feature icon={<Shield className="h-5 w-5" />} title="Bank-grade security" desc="2FA, KYC, withdrawal allow-lists and 95% of assets in cold storage." />
            <Feature icon={<Zap className="h-5 w-5" />} title="Lightning matching" desc="In-house Go matching engine clears trades in under 5ms." />
            <Feature icon={<Banknote className="h-5 w-5" />} title="INR friendly" desc="Direct INR deposits, withdrawals and pricing — no double conversion fees." />
            <Feature icon={<Headphones className="h-5 w-5" />} title="24/7 support" desc="Real humans, real fast — every day of the year." />
          </div>
        </div>
      </section>

      {/* ─── CTA ─────────────────────────────────────────── */}
      <section className="w-full py-16 bg-gradient-to-r from-amber-950/30 via-background to-orange-950/30 border-y border-border">
        <div className="container mx-auto px-4 text-center max-w-2xl">
          <h2 className="text-3xl lg:text-4xl font-bold tracking-tight">
            Ready to take your trading <span className="text-primary">to the next level?</span>
          </h2>
          <p className="text-muted-foreground mt-3">Sign up in under 60 seconds and get started with as little as ₹100.</p>
          <div className="mt-6 flex flex-wrap justify-center gap-3">
            {!user ? (
              <>
                <Button size="lg" className="bg-primary text-primary-foreground hover:bg-primary/90 px-8" asChild>
                  <Link href="/signup">
                    Create free account <ArrowRight className="ml-2 h-4 w-4" />
                  </Link>
                </Button>
                <Button size="lg" variant="outline" className="px-8" asChild>
                  <Link href="/login">I already have an account</Link>
                </Button>
              </>
            ) : (
              <Button size="lg" className="bg-primary text-primary-foreground hover:bg-primary/90 px-8" asChild>
                <Link href="/trade">
                  Start trading <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
            )}
          </div>
        </div>
      </section>
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────
// Sub components
// ──────────────────────────────────────────────────────────────────
function ProductCard({
  icon,
  title,
  desc,
  href,
  cta,
  accent,
  badge,
}: {
  icon: React.ReactNode;
  title: string;
  desc: string;
  href: string;
  cta: string;
  accent: string;
  badge?: string;
}) {
  return (
    <Link href={href} className="group block">
      <Card className={`relative overflow-hidden p-6 h-full border-border/60 hover:border-primary/40 transition-all hover:-translate-y-0.5`}>
        <div className={`absolute inset-0 bg-gradient-to-br ${accent} opacity-60 pointer-events-none`} />
        <div className="relative">
          <div className="flex items-start justify-between">
            <div className="h-11 w-11 rounded-xl bg-primary/15 text-primary flex items-center justify-center">{icon}</div>
            {badge && <Badge className="bg-primary/15 text-primary border-primary/30">{badge}</Badge>}
          </div>
          <h3 className="text-xl font-bold mt-4">{title}</h3>
          <p className="text-sm text-muted-foreground mt-2 leading-relaxed">{desc}</p>
          <div className="mt-5 inline-flex items-center text-sm font-medium text-primary group-hover:gap-2 gap-1 transition-all">
            {cta}
            <ArrowRight className="h-4 w-4" />
          </div>
        </div>
      </Card>
    </Link>
  );
}

function Feature({ icon, title, desc }: { icon: React.ReactNode; title: string; desc: string }) {
  return (
    <Card className="p-5 border-border/60 hover:border-primary/40 transition-colors">
      <div className="h-10 w-10 rounded-lg bg-primary/10 text-primary flex items-center justify-center">{icon}</div>
      <h3 className="font-bold mt-3">{title}</h3>
      <p className="text-sm text-muted-foreground mt-1.5 leading-relaxed">{desc}</p>
    </Card>
  );
}
