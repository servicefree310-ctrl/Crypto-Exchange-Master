import { useQuery } from "@tanstack/react-query";
import { get } from "@/lib/api";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Users, Coins as CoinsIcon, ArrowLeftRight, ShieldCheck, ArrowDownToLine, ArrowUpFromLine, Landmark, ListChecks } from "lucide-react";
import type { LucideIcon } from "lucide-react";

type Stats = {
  users: number; coins: number; pairs: number;
  pendingKyc: number; pendingDeposits: number; pendingWithdrawals: number;
  pendingBanks: number; openOrders: number;
};

function StatCard({ title, value, icon: Icon, accent }: { title: string; value: number; icon: LucideIcon; accent?: boolean }) {
  return (
    <Card>
      <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
        <CardTitle className="text-sm font-medium text-muted-foreground">{title}</CardTitle>
        <Icon className={`w-4 h-4 ${accent ? "text-primary" : "text-muted-foreground"}`} />
      </CardHeader>
      <CardContent>
        <div className="text-2xl font-bold tabular-nums">{value.toLocaleString("en-IN")}</div>
      </CardContent>
    </Card>
  );
}

export default function DashboardPage() {
  const { data, isLoading } = useQuery<Stats>({
    queryKey: ["/admin/stats"],
    queryFn: () => get<Stats>("/admin/stats"),
  });

  const s = data || { users: 0, coins: 0, pairs: 0, pendingKyc: 0, pendingDeposits: 0, pendingWithdrawals: 0, pendingBanks: 0, openOrders: 0 };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold">Welcome back</h2>
        <p className="text-sm text-muted-foreground">Aaj ke pending tasks aur live numbers</p>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
        <StatCard title="Total Users" value={s.users} icon={Users} />
        <StatCard title="Listed Coins" value={s.coins} icon={CoinsIcon} />
        <StatCard title="Trading Pairs" value={s.pairs} icon={ArrowLeftRight} />
        <StatCard title="Open Orders" value={s.openOrders} icon={ListChecks} />
      </div>

      <div>
        <h3 className="text-lg font-semibold mb-3">Pending Approvals</h3>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          <StatCard title="KYC Reviews" value={s.pendingKyc} icon={ShieldCheck} accent />
          <StatCard title="Bank Verifications" value={s.pendingBanks} icon={Landmark} accent />
          <StatCard title="INR Deposits" value={s.pendingDeposits} icon={ArrowDownToLine} accent />
          <StatCard title="INR Withdrawals" value={s.pendingWithdrawals} icon={ArrowUpFromLine} accent />
        </div>
      </div>

      {isLoading && <div className="text-sm text-muted-foreground">Loading…</div>}
    </div>
  );
}
