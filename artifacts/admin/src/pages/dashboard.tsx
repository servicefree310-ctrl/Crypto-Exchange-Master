import { useQuery } from "@tanstack/react-query";
import { get } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Users, Coins as CoinsIcon, ArrowLeftRight, ShieldCheck, ArrowDownToLine,
  ArrowUpFromLine, Landmark, ListChecks, TrendingUp, Activity, Wallet,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";

type Stats = {
  users: number; coins: number; pairs: number;
  pendingKyc: number; pendingDeposits: number; pendingWithdrawals: number;
  pendingBanks: number; openOrders: number;
  pendingCryptoDeposits: number; pendingCryptoWithdrawals: number;
  openFuturesPositions: number; futures24hVolume: number;
};

function fmt(n: number): string {
  if (!Number.isFinite(n)) return "0";
  if (Math.abs(n) >= 1_000_000) return (n / 1_000_000).toFixed(2) + "M";
  if (Math.abs(n) >= 1_000) return (n / 1_000).toFixed(1) + "K";
  return n.toLocaleString("en-IN", { maximumFractionDigits: 2 });
}

function StatCard({ title, value, icon: Icon, accent, prefix }: { title: string; value: number | string; icon: LucideIcon; accent?: boolean; prefix?: string }) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">{title}</CardTitle>
        <Icon className={`w-4 h-4 ${accent ? "text-primary" : "text-muted-foreground"}`} />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold tabular-nums">
          {prefix ?? ""}{typeof value === "number" ? value.toLocaleString("en-IN") : value}
        </div>
      </CardContent>
    </Card>
  );
}

export default function DashboardPage() {
  const { data, isLoading } = useQuery<Stats>({
    queryKey: ["/admin/stats"],
    queryFn: () => get<Stats>("/admin/stats"),
    refetchInterval: 15000,
  });

  const s = data || {
    users: 0, coins: 0, pairs: 0, pendingKyc: 0, pendingDeposits: 0, pendingWithdrawals: 0,
    pendingBanks: 0, openOrders: 0, pendingCryptoDeposits: 0, pendingCryptoWithdrawals: 0,
    openFuturesPositions: 0, futures24hVolume: 0,
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold">Welcome back</h2>
        <p className="text-sm text-muted-foreground">Aaj ke pending tasks aur live numbers</p>
      </div>

      <div>
        <h3 className="text-lg font-semibold mb-3">Platform</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <StatCard title="Total Users" value={s.users} icon={Users} />
          <StatCard title="Listed Coins" value={s.coins} icon={CoinsIcon} />
          <StatCard title="Trading Pairs" value={s.pairs} icon={ArrowLeftRight} />
          <StatCard title="Open Orders" value={s.openOrders} icon={ListChecks} />
        </div>
      </div>

      <div>
        <h3 className="text-lg font-semibold mb-3">Futures Markets</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <StatCard title="24h Volume (USDT)" value={fmt(s.futures24hVolume)} prefix="$" icon={TrendingUp} accent />
          <StatCard title="Open Positions" value={s.openFuturesPositions} icon={Activity} accent />
        </div>
      </div>

      <div>
        <h3 className="text-lg font-semibold mb-3">Pending Approvals</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
          <StatCard title="KYC Reviews" value={s.pendingKyc} icon={ShieldCheck} accent />
          <StatCard title="Bank Verifications" value={s.pendingBanks} icon={Landmark} accent />
          <StatCard title="INR Deposits" value={s.pendingDeposits} icon={ArrowDownToLine} accent />
          <StatCard title="INR Withdrawals" value={s.pendingWithdrawals} icon={ArrowUpFromLine} accent />
          <StatCard title="Crypto Deposits" value={s.pendingCryptoDeposits} icon={Wallet} accent />
          <StatCard title="Crypto Withdrawals" value={s.pendingCryptoWithdrawals} icon={ArrowUpFromLine} accent />
        </div>
      </div>

      {isLoading && <div className="text-sm text-muted-foreground">Loading…</div>}
    </div>
  );
}
