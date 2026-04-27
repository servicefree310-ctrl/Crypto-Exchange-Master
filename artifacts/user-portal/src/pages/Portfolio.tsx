import { useQuery } from "@tanstack/react-query";
import { useMemo, useState } from "react";
import { get } from "@/lib/api";
import { useTickers } from "@/lib/marketSocket";
import { Wallet, TrendingUp, Coins, PieChart, Eye, EyeOff } from "lucide-react";
import { Button } from "@/components/ui/button";
import { PageHeader } from "@/components/premium/PageHeader";
import { PremiumStatCard } from "@/components/premium/PremiumStatCard";
import { SectionCard } from "@/components/premium/SectionCard";
import { EmptyState } from "@/components/premium/EmptyState";

type WalletItem = {
  currency: string;
  balance: number | string;
  inOrder?: number | string;
  type?: string;
};

type WalletResponse = { wallets?: WalletItem[]; data?: WalletItem[] } | WalletItem[];

/**
 * Portfolio Analysis — premium dashboard view.
 *
 * Aggregates the user's wallet balances against live tickers (USDT-quoted)
 * to surface total portfolio value in INR-friendly formatting plus a simple
 * allocation breakdown. Stays defensive — if /wallets returns nothing or
 * the websocket has no quotes yet, we degrade gracefully to skeletons /
 * empty states rather than throwing.
 */
export default function Portfolio() {
  const [hidden, setHidden] = useState(false);

  const { data: walletData, isLoading } = useQuery<WalletResponse>({
    queryKey: ["wallets"],
    queryFn: () => get("/wallets"),
  });

  const wallets: WalletItem[] = useMemo(() => {
    if (Array.isArray(walletData)) return walletData;
    const w = walletData as { wallets?: WalletItem[]; data?: WalletItem[] };
    return w?.wallets ?? w?.data ?? [];
  }, [walletData]);

  const tickers = useTickers();

  const { rows, total, totalNonZero } = useMemo(() => {
    let total = 0;
    let totalNonZero = 0;
    const rows = wallets.map((w) => {
      const cur = (w.currency || "").toUpperCase();
      const bal = Number(w.balance) + Number(w.inOrder ?? 0);
      let usd = 0;
      if (cur === "USDT" || cur === "USDC" || cur === "USD") {
        usd = bal;
      } else if (cur === "INR") {
        usd = bal / 83;
      } else {
        const t = tickers[`${cur}USDT`];
        const px = t?.lastPrice ? Number(t.lastPrice) : 0;
        usd = bal * px;
      }
      total += usd;
      if (bal > 0) totalNonZero += 1;
      return { currency: cur, balance: bal, usd };
    });
    rows.sort((a, b) => b.usd - a.usd);
    return { rows, total, totalNonZero };
  }, [wallets, tickers]);

  const inrTotal = total * 83;
  const topAlloc = rows.filter((r) => r.usd > 0).slice(0, 5);

  const fmt = (v: string | number) =>
    hidden ? "•••••" : typeof v === "number" ? v.toLocaleString("en-IN", { maximumFractionDigits: 2 }) : v;

  return (
    <div className="container mx-auto px-4 py-8 max-w-6xl">
      <PageHeader
        eyebrow="Insights"
        title="Portfolio Analysis"
        description="Aapke saare assets ka unified view — live valuation aur allocation ke saath."
        actions={
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
        }
      />

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-6">
        <PremiumStatCard
          hero
          title="Total Portfolio (INR)"
          value={fmt(inrTotal)}
          prefix="₹"
          icon={Wallet}
          loading={isLoading}
          hint="Live USDT prices se"
        />
        <PremiumStatCard
          title="Total (USD)"
          value={fmt(total)}
          prefix="$"
          icon={TrendingUp}
          loading={isLoading}
        />
        <PremiumStatCard
          title="Active Assets"
          value={hidden ? "•••" : totalNonZero}
          icon={Coins}
          loading={isLoading}
          hint={`${wallets.length} wallets total`}
        />
      </div>

      <SectionCard title="Top Allocation" icon={PieChart} description="Top 5 holdings by value">
        {isLoading ? (
          <div className="space-y-3">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="h-10 bg-muted/30 rounded-md animate-pulse" />
            ))}
          </div>
        ) : topAlloc.length === 0 ? (
          <EmptyState
            icon={PieChart}
            title="Abhi koi holdings nahi hain"
            description="Wallet mein deposit karein ya trade shuru karein — yahan aapka allocation breakdown dikhega."
          />
        ) : (
          <div className="space-y-3">
            {topAlloc.map((r) => {
              const pct = total > 0 ? (r.usd / total) * 100 : 0;
              return (
                <div key={r.currency} data-testid={`portfolio-row-${r.currency}`}>
                  <div className="flex items-center justify-between text-sm mb-1.5">
                    <div className="flex items-center gap-2">
                      <div className="w-7 h-7 rounded-full gold-bg-soft border border-amber-500/30 flex items-center justify-center text-[10px] font-bold text-amber-300">
                        {r.currency.slice(0, 3)}
                      </div>
                      <span className="font-medium text-foreground">{r.currency}</span>
                    </div>
                    <div className="flex items-center gap-3 text-xs">
                      <span className="font-mono tabular-nums text-muted-foreground">
                        {fmt(r.balance)} {r.currency}
                      </span>
                      <span className="font-mono tabular-nums text-foreground min-w-[70px] text-right">
                        ₹{fmt(r.usd * 83)}
                      </span>
                      <span className="text-amber-300 font-semibold tabular-nums w-12 text-right">
                        {pct.toFixed(1)}%
                      </span>
                    </div>
                  </div>
                  <div className="h-1.5 bg-muted/30 rounded-full overflow-hidden">
                    <div
                      className="h-full gold-bg transition-all"
                      style={{ width: `${Math.min(100, Math.max(2, pct))}%` }}
                    />
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </SectionCard>
    </div>
  );
}
