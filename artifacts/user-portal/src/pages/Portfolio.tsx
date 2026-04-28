import { useQuery } from "@tanstack/react-query";
import { useMemo, useState } from "react";
import { get } from "@/lib/api";
import {
  Wallet, TrendingUp, TrendingDown, Coins, PieChart, Eye, EyeOff,
  RefreshCw, Sparkles, Building2, ArrowUpRight,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { PageHeader } from "@/components/premium/PageHeader";
import { PremiumStatCard } from "@/components/premium/PremiumStatCard";
import { SectionCard } from "@/components/premium/SectionCard";
import { EmptyState } from "@/components/premium/EmptyState";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useLocation } from "wouter";

type WalletItem = {
  id: number;
  walletType: "spot" | "futures" | "earn" | "inr";
  type?: string;          // alias added server-side
  coinSymbol: string;
  coinName: string;
  currency?: string;      // alias
  balance: number | string;
  locked: number | string;
  inOrder?: number;       // alias
  usdPrice: number;
  usdValue: number;
};

// /wallets returns a flat array (kept that way to preserve back-compat with
// other consumers like Earn.tsx); we compute totals client-side.
type WalletResponse = WalletItem[];

type PnlResponse = {
  today: number;
  yesterday: number;
  pnl: number;
  pnlPct: number;
  inrRate: number;
};

// "INR" walletType is a fiat wallet — normalize to FIAT for UI grouping.
function normalizeType(t: string): string {
  const u = (t || "").toUpperCase();
  return u === "INR" ? "FIAT" : u;
}

const WALLET_TYPE_LABEL: Record<string, string> = {
  SPOT: "Spot",
  FUTURES: "Futures",
  FIAT: "Fiat",
  EARN: "Earn",
};

export default function Portfolio() {
  const [, setLocation] = useLocation();
  const [hidden, setHidden] = useState(false);
  const [groupBy, setGroupBy] = useState<"ALL" | "SPOT" | "FUTURES" | "FIAT">("ALL");

  // Live wallet — server-side valuation, polls every 7 s.
  const walletQ = useQuery<WalletResponse>({
    queryKey: ["portfolio-wallets"],
    queryFn: () => get("/wallets"),
    refetchInterval: 7_000,
    refetchOnWindowFocus: true,
  });

  // Live 24h PnL — server-side daily snapshot.
  const pnlQ = useQuery<PnlResponse>({
    queryKey: ["portfolio-pnl"],
    queryFn: () => get("/finance/wallet?pnl=true"),
    refetchInterval: 30_000,
    refetchOnWindowFocus: true,
  });

  const items: WalletItem[] = useMemo(() => walletQ.data ?? [], [walletQ.data]);
  // Live INR rate now comes from the pnl summary (which always returns it);
  // /wallets stays as the legacy flat-array contract for back-compat.
  const inrRate = pnlQ.data?.inrRate ?? 84;

  const totalUsd = useMemo(
    () => Math.round(items.reduce((acc, w) => acc + (Number(w.usdValue) || 0), 0) * 100) / 100,
    [items],
  );
  const totalInr = Math.round(totalUsd * inrRate * 100) / 100;
  const nonZeroCount = useMemo(
    () => items.filter(w => (Number(w.balance) || 0) + (Number(w.locked) || 0) > 0).length,
    [items],
  );

  // Aggregate by coin (sum across spot/futures/fiat for the "All" view).
  // Normalizes "INR" walletType -> "FIAT" so the FIAT tab actually surfaces
  // INR rows.
  const byCoin = useMemo(() => {
    const map = new Map<string, { currency: string; balance: number; usd: number; byType: Record<string, number> }>();
    for (const w of items) {
      const cur = (w.coinSymbol || w.currency || "").toUpperCase();
      if (!cur) continue;
      const t = normalizeType(w.type || w.walletType || "");
      if (groupBy !== "ALL" && t !== groupBy) continue;
      const bal = (Number(w.balance) || 0) + (Number(w.locked) || 0);
      if (!map.has(cur)) map.set(cur, { currency: cur, balance: 0, usd: 0, byType: {} });
      const row = map.get(cur)!;
      row.balance += bal;
      row.usd += Number(w.usdValue) || 0;
      row.byType[t] = (row.byType[t] || 0) + bal;
    }
    return [...map.values()].filter(r => r.balance > 0).sort((a, b) => b.usd - a.usd);
  }, [items, groupBy]);

  const filteredTotalUsd = useMemo(
    () => Math.round(byCoin.reduce((acc, r) => acc + r.usd, 0) * 100) / 100,
    [byCoin],
  );
  const displayTotalUsd = groupBy === "ALL" ? totalUsd : filteredTotalUsd;

  // Wallet-type split for the breakdown row.
  const typeSplit = useMemo(() => {
    const split: Record<string, number> = { SPOT: 0, FUTURES: 0, FIAT: 0, EARN: 0 };
    for (const w of items) {
      const key = normalizeType(w.type || w.walletType || "");
      split[key] = (split[key] ?? 0) + (Number(w.usdValue) || 0);
    }
    return split;
  }, [items]);

  const pnl = pnlQ.data?.pnl ?? 0;
  const pnlPct = pnlQ.data?.pnlPct ?? 0;
  const pnlPositive = pnl >= 0;

  const fmtUsd = (n: number) =>
    hidden ? "•••••" : "$" + (Number(n) || 0).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const fmtInr = (n: number) =>
    hidden ? "•••••" : "₹" + (Number(n) || 0).toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  const fmtCoin = (n: number, sym: string) =>
    hidden ? "•••••" : (Number(n) || 0).toLocaleString("en-US", { maximumFractionDigits: 6 }) + " " + sym;

  const refresh = () => {
    walletQ.refetch();
    pnlQ.refetch();
  };

  return (
    <div className="container mx-auto px-4 py-8 max-w-6xl">
      <PageHeader
        eyebrow="Insights"
        title="Portfolio Analysis"
        description="Aapke saare assets ka unified live view — server-side valuation, 24h PnL, aur per-asset allocation."
        actions={
          <div className="flex items-center gap-2">
            <Button
              variant="outline"
              size="sm"
              onClick={refresh}
              disabled={walletQ.isFetching}
              data-testid="portfolio-refresh"
              aria-label="Refresh"
            >
              <RefreshCw className={`w-4 h-4 mr-2 ${walletQ.isFetching ? "animate-spin" : ""}`} />
              Refresh
            </Button>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setHidden((h) => !h)}
              data-testid="portfolio-toggle-balance"
              aria-label={hidden ? "Show balances" : "Hide balances"}
            >
              {hidden ? <Eye className="w-4 h-4 mr-2" /> : <EyeOff className="w-4 h-4 mr-2" />}
              {hidden ? "Show" : "Hide"}
            </Button>
          </div>
        }
      />

      {/* ─── Top stats ────────────────────────────────────────────── */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <PremiumStatCard
          hero
          title="Total Portfolio (INR)"
          value={fmtInr(totalInr).replace("₹", "")}
          prefix="₹"
          icon={Wallet}
          loading={walletQ.isLoading}
          hint={`Live rate ₹${inrRate.toFixed(2)} / USD`}
        />
        <PremiumStatCard
          title="Total (USD)"
          value={fmtUsd(totalUsd).replace("$", "")}
          prefix="$"
          icon={TrendingUp}
          loading={walletQ.isLoading}
          hint={pnlQ.isLoading ? "Loading 24h PnL…" : (
            pnlPositive
              ? `+${fmtUsd(Math.abs(pnl)).replace("$", "$")} (+${pnlPct.toFixed(2)}%) 24h`
              : `-${fmtUsd(Math.abs(pnl)).replace("$", "$")} (${pnlPct.toFixed(2)}%) 24h`
          )}
        />
        <PremiumStatCard
          title="Active Assets"
          value={hidden ? "•••" : nonZeroCount}
          icon={Coins}
          loading={walletQ.isLoading}
          hint={`${items.length} wallets total`}
        />
      </div>

      {/* ─── Wallet-type breakdown chips ─────────────────────────── */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
        <TypeChip label="Spot" value={fmtUsd(typeSplit.SPOT || 0)} icon={<Sparkles className="h-3.5 w-3.5" />} />
        <TypeChip label="Futures" value={fmtUsd(typeSplit.FUTURES || 0)} icon={<TrendingUp className="h-3.5 w-3.5" />} />
        <TypeChip label="Fiat" value={fmtUsd(typeSplit.FIAT || 0)} icon={<Building2 className="h-3.5 w-3.5" />} />
        <TypeChip
          label="24h Change"
          value={pnlPositive ? `+${fmtUsd(Math.abs(pnl))}` : `-${fmtUsd(Math.abs(pnl))}`}
          icon={pnlPositive ? <TrendingUp className="h-3.5 w-3.5 text-emerald-400" /> : <TrendingDown className="h-3.5 w-3.5 text-rose-400" />}
          tone={pnlPositive ? "ok" : "bad"}
        />
      </div>

      {/* ─── Allocation table ────────────────────────────────────── */}
      <SectionCard
        title="Asset Allocation"
        icon={PieChart}
        description="Live per-asset breakdown by USD value"
      >
        <div className="mb-4">
          <Tabs value={groupBy} onValueChange={(v) => setGroupBy(v as any)}>
            <TabsList className="bg-muted">
              <TabsTrigger value="ALL" data-testid="portfolio-tab-all">All</TabsTrigger>
              <TabsTrigger value="SPOT" data-testid="portfolio-tab-spot">Spot</TabsTrigger>
              <TabsTrigger value="FUTURES" data-testid="portfolio-tab-futures">Futures</TabsTrigger>
              <TabsTrigger value="FIAT" data-testid="portfolio-tab-fiat">Fiat</TabsTrigger>
            </TabsList>
          </Tabs>
        </div>
        {walletQ.isLoading ? (
          <div className="space-y-3">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="h-12 bg-muted/30 rounded-md animate-pulse" />
            ))}
          </div>
        ) : walletQ.isError ? (
          <EmptyState
            icon={PieChart}
            title="Portfolio load nahi ho saka"
            description="Network ya server me dikkat hai — refresh karke try karein."
          />
        ) : byCoin.length === 0 ? (
          <EmptyState
            icon={PieChart}
            title="Abhi koi holdings nahi hain"
            description={
              groupBy === "ALL"
                ? "Wallet mein deposit karein ya trade shuru karein — yahan aapka allocation breakdown dikhega."
                : `${WALLET_TYPE_LABEL[groupBy]} wallet me kuch nahi hai. Doosri category dekhne ke liye tab change karein.`
            }
          />
        ) : (
          <div className="space-y-3">
            {byCoin.map((r) => {
              const pct = displayTotalUsd > 0 ? (r.usd / displayTotalUsd) * 100 : 0;
              return (
                <div
                  key={r.currency}
                  data-testid={`portfolio-row-${r.currency}`}
                  className="group rounded-lg p-3 hover:bg-muted/20 transition-colors border border-transparent hover:border-border/60"
                >
                  <div className="flex items-center justify-between text-sm mb-1.5 gap-3">
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="w-9 h-9 rounded-full gold-bg-soft border border-amber-500/30 flex items-center justify-center text-[11px] font-bold text-amber-300 shrink-0">
                        {r.currency.slice(0, 3)}
                      </div>
                      <div className="min-w-0">
                        <div className="font-semibold text-foreground truncate">{r.currency}</div>
                        <div className="text-[11px] text-muted-foreground tabular-nums">
                          {fmtCoin(r.balance, r.currency)}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center gap-3 shrink-0">
                      <div className="text-right">
                        <div className="font-mono tabular-nums text-foreground text-sm">
                          {fmtInr(r.usd * inrRate)}
                        </div>
                        <div className="text-[11px] text-muted-foreground tabular-nums">
                          {fmtUsd(r.usd)}
                        </div>
                      </div>
                      <div className="text-amber-300 font-semibold tabular-nums w-14 text-right text-sm">
                        {pct.toFixed(1)}%
                      </div>
                      <Button
                        size="sm"
                        variant="ghost"
                        className="opacity-0 group-hover:opacity-100 transition-opacity h-7 px-2"
                        onClick={() => setLocation(`/trade/${r.currency}_USDT`)}
                        data-testid={`portfolio-trade-${r.currency}`}
                        aria-label={`Trade ${r.currency}`}
                      >
                        Trade <ArrowUpRight className="w-3 h-3 ml-1" />
                      </Button>
                    </div>
                  </div>
                  <div className="h-1.5 bg-muted/30 rounded-full overflow-hidden">
                    <div
                      className="h-full gold-bg transition-all"
                      style={{ width: `${Math.min(100, Math.max(2, pct))}%` }}
                    />
                  </div>
                  {/* Per-wallet-type pills (only when looking at All) */}
                  {groupBy === "ALL" && Object.keys(r.byType).length > 1 && (
                    <div className="mt-2 flex flex-wrap gap-1.5">
                      {Object.entries(r.byType)
                        .filter(([, v]) => v > 0)
                        .map(([t, v]) => (
                          <Badge
                            key={t}
                            variant="secondary"
                            className="text-[10px] px-1.5 py-0 font-mono"
                          >
                            {WALLET_TYPE_LABEL[t === "INR" ? "FIAT" : t] || t}: {fmtCoin(v, r.currency)}
                          </Badge>
                        ))}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        )}
      </SectionCard>
    </div>
  );
}

function TypeChip({
  label,
  value,
  icon,
  tone,
}: {
  label: string;
  value: string;
  icon: React.ReactNode;
  tone?: "ok" | "bad";
}) {
  const valueCls =
    tone === "ok"
      ? "text-emerald-400"
      : tone === "bad"
      ? "text-rose-400"
      : "text-foreground";
  return (
    <div className="rounded-xl border border-border bg-card/50 px-4 py-3">
      <div className="flex items-center gap-1.5 text-[11px] uppercase tracking-wider text-muted-foreground mb-1">
        {icon}
        {label}
      </div>
      <div className={`text-base sm:text-lg font-semibold font-mono ${valueCls}`}>{value}</div>
    </div>
  );
}
