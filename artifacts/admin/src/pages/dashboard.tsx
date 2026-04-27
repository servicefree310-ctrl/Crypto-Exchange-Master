import { useQuery } from "@tanstack/react-query";
import { Link } from "wouter";
import { get } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { PageHeader } from "@/components/premium/PageHeader";
import { PremiumStatCard } from "@/components/premium/PremiumStatCard";
import { SectionCard } from "@/components/premium/SectionCard";
import { StatusPill } from "@/components/premium/StatusPill";
import { EmptyState } from "@/components/premium/EmptyState";
import {
  Users, Coins as CoinsIcon, ArrowLeftRight, ShieldCheck, ArrowDownToLine,
  ArrowUpFromLine, Landmark, ListChecks, TrendingUp, Activity, Wallet,
  Bitcoin, Banknote, CheckCircle2, AlertCircle, ServerCog, Database,
  KeyRound, Inbox, ArrowUpRight, Sparkles, Gauge,
} from "lucide-react";

type Stats = {
  users: number; coins: number; pairs: number;
  pendingKyc: number; pendingDeposits: number; pendingWithdrawals: number;
  pendingBanks: number; openOrders: number;
  pendingCryptoDeposits: number; pendingCryptoWithdrawals: number;
  openFuturesPositions: number; futures24hVolume: number;
};

type SystemHealth = {
  futuresEngine?: { running?: boolean; status?: string; last?: string };
  sweeper?: { running?: boolean; status?: string };
  vault?: { passwordSet?: boolean; mnemonicConfigured?: boolean };
  matching?: { enabled?: boolean; running?: boolean; ordersMatched?: number };
};

type RecentUser = {
  id: number; uid?: string; email: string; name?: string | null;
  role: string; status: string; kycLevel?: number; createdAt?: string;
};

type RecentWithdrawal = {
  id: number; userId?: number; userEmail?: string;
  amount?: number | string; status: string;
  coin?: string; currency?: string; createdAt?: string;
};

function fmt(n: number, opts?: { compact?: boolean }): string {
  if (!Number.isFinite(n)) return "0";
  if (opts?.compact) {
    if (Math.abs(n) >= 1_000_000) return (n / 1_000_000).toFixed(2) + "M";
    if (Math.abs(n) >= 1_000) return (n / 1_000).toFixed(1) + "K";
  }
  return n.toLocaleString("en-IN", { maximumFractionDigits: 2 });
}

function timeAgo(iso?: string): string {
  if (!iso) return "—";
  const d = new Date(iso).getTime();
  if (!d) return "—";
  const diff = Date.now() - d;
  const m = Math.floor(diff / 60000);
  if (m < 1) return "just now";
  if (m < 60) return `${m}m ago`;
  const h = Math.floor(m / 60);
  if (h < 24) return `${h}h ago`;
  const days = Math.floor(h / 24);
  return `${days}d ago`;
}

export default function DashboardPage() {
  const { user } = useAuth();

  const { data, isLoading } = useQuery<Stats>({
    queryKey: ["/admin/stats"],
    queryFn: () => get<Stats>("/admin/stats"),
    refetchInterval: 15000,
  });

  const futuresEngine = useQuery({
    queryKey: ["/admin/futures-engine/status"],
    queryFn: () => get<any>("/admin/futures-engine/status").catch(() => null),
    refetchInterval: 30000,
  });

  const sweeper = useQuery({
    queryKey: ["/admin/sweeper/status"],
    queryFn: () => get<any>("/admin/sweeper/status").catch(() => null),
    refetchInterval: 30000,
  });

  const vault = useQuery({
    queryKey: ["/admin/vault/status"],
    queryFn: () => get<any>("/admin/vault/status").catch(() => null),
    refetchInterval: 60000,
  });


  const recentUsers = useQuery<RecentUser[]>({
    queryKey: ["/admin/users", "recent"],
    queryFn: async () => {
      const r = await get<RecentUser[] | { rows?: RecentUser[] }>("/admin/users").catch(() => []);
      const arr = Array.isArray(r) ? r : (r as any)?.rows ?? [];
      return arr.slice(0, 5);
    },
    refetchInterval: 30000,
  });

  const recentInrW = useQuery<RecentWithdrawal[]>({
    queryKey: ["/admin/inr-withdrawals", "recent"],
    queryFn: async () => {
      const r = await get<RecentWithdrawal[] | { rows?: RecentWithdrawal[] }>(
        "/admin/inr-withdrawals?status=pending"
      ).catch(() => []);
      const arr = Array.isArray(r) ? r : (r as any)?.rows ?? [];
      return arr.slice(0, 5);
    },
    refetchInterval: 30000,
  });

  const s = data || {
    users: 0, coins: 0, pairs: 0, pendingKyc: 0, pendingDeposits: 0, pendingWithdrawals: 0,
    pendingBanks: 0, openOrders: 0, pendingCryptoDeposits: 0, pendingCryptoWithdrawals: 0,
    openFuturesPositions: 0, futures24hVolume: 0,
  };

  const totalPending =
    s.pendingKyc + s.pendingDeposits + s.pendingWithdrawals + s.pendingBanks +
    s.pendingCryptoDeposits + s.pendingCryptoWithdrawals;

  const sysHealthy =
    (futuresEngine.data?.running ?? true) &&
    (sweeper.data?.running ?? true) &&
    (vault.data?.passwordSet ?? false);

  const greet = (() => {
    const h = new Date().getHours();
    if (h < 5) return "Working late";
    if (h < 12) return "Good morning";
    if (h < 17) return "Good afternoon";
    if (h < 21) return "Good evening";
    return "Good night";
  })();

  const today = new Date().toLocaleDateString("en-IN", {
    weekday: "long", day: "numeric", month: "long", year: "numeric",
  });

  return (
    <div className="space-y-6 max-w-[1400px]">
      <PageHeader
        eyebrow="Console · Overview"
        title={`${greet}, ${user?.name || (user?.email || "Admin").split("@")[0]}`}
        description={today + " · Aaj ke pending tasks aur live numbers"}
        actions={
          <StatusPill
            variant={sysHealthy ? "success" : "warning"}
            dot
          >
            {sysHealthy ? "All systems operational" : "Attention required"}
          </StatusPill>
        }
      />

      {/* Hero KPI row */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3 md:gap-4">
        <PremiumStatCard
          title="Total Users"
          value={s.users}
          icon={Users}
          hero
          loading={isLoading}
          hint="Registered accounts"
        />
        <PremiumStatCard
          title="24h Futures Volume"
          value={fmt(s.futures24hVolume, { compact: true })}
          prefix="$"
          icon={TrendingUp}
          hero
          loading={isLoading}
          hint="USDT-margined"
        />
        <PremiumStatCard
          title="Open Positions"
          value={s.openFuturesPositions}
          icon={Activity}
          hero
          loading={isLoading}
          hint="Futures · live"
        />
        <PremiumStatCard
          title="Pending Approvals"
          value={totalPending}
          icon={Inbox}
          hero
          loading={isLoading}
          hint="Across all queues"
        />
      </div>

      {/* Pending approvals breakdown */}
      <SectionCard
        title="Pending Approvals"
        description="Quick access to queues that need attention"
        icon={Sparkles}
        actions={
          <span className="text-xs text-muted-foreground tabular-nums">
            {totalPending} item{totalPending === 1 ? "" : "s"}
          </span>
        }
      >
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3">
          <ApprovalCard href="/kyc" label="KYC Reviews" count={s.pendingKyc} icon={ShieldCheck} />
          <ApprovalCard href="/banks" label="Bank Verifications" count={s.pendingBanks} icon={Landmark} />
          <ApprovalCard href="/inr-deposits" label="INR Deposits" count={s.pendingDeposits} icon={ArrowDownToLine} />
          <ApprovalCard href="/inr-withdrawals" label="INR Withdrawals" count={s.pendingWithdrawals} icon={ArrowUpFromLine} />
          <ApprovalCard href="/crypto-deposits" label="Crypto Deposits" count={s.pendingCryptoDeposits} icon={Bitcoin} />
          <ApprovalCard href="/crypto-withdrawals" label="Crypto Withdrawals" count={s.pendingCryptoWithdrawals} icon={Banknote} />
        </div>
      </SectionCard>

      {/* System health */}
      <SectionCard
        title="System Health"
        description="Engines, treasury vault and matching status"
        icon={Gauge}
      >
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          <HealthRow
            icon={ServerCog}
            label="Futures Engine"
            healthy={!!futuresEngine.data?.running}
            valueLabel={futuresEngine.data?.running ? "Running" : "Stopped"}
            href="/funding-rates"
            loading={futuresEngine.isLoading}
          />
          <HealthRow
            icon={Database}
            label="Deposit Sweeper"
            healthy={!!sweeper.data?.running}
            valueLabel={sweeper.data?.running ? "Running" : "Idle"}
            href="/user-addresses"
            loading={sweeper.isLoading}
          />
          <HealthRow
            icon={KeyRound}
            label="HD Vault"
            healthy={!!vault.data?.passwordSet && !!vault.data?.mnemonicConfigured}
            valueLabel={
              vault.data?.passwordSet
                ? vault.data?.mnemonicConfigured ? "Configured" : "Mnemonic missing"
                : "Password not set"
            }
            href="/user-addresses"
            loading={vault.isLoading}
          />
          <HealthRow
            icon={Activity}
            label="API Server"
            healthy={!isLoading && !!data}
            valueLabel={!isLoading && !!data ? "Healthy · live data" : "Reconnecting…"}
            href="/backend-status"
            loading={isLoading && !data}
          />
        </div>
      </SectionCard>

      {/* Platform stats */}
      <div>
        <div className="flex items-center justify-between mb-3 px-1">
          <h2 className="text-sm font-semibold text-foreground tracking-wide">Platform Overview</h2>
          <span className="text-[11px] text-muted-foreground">Live · auto-refresh 15s</span>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4">
          <PremiumStatCard title="Listed Coins" value={s.coins} icon={CoinsIcon} loading={isLoading} />
          <PremiumStatCard title="Trading Pairs" value={s.pairs} icon={ArrowLeftRight} loading={isLoading} />
          <PremiumStatCard title="Open Spot Orders" value={s.openOrders} icon={ListChecks} loading={isLoading} />
          <PremiumStatCard title="Crypto Pending" value={s.pendingCryptoDeposits + s.pendingCryptoWithdrawals} icon={Wallet} loading={isLoading} />
        </div>
      </div>

      {/* Recent activity */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        <SectionCard
          title="Recent Users"
          description="Latest signups"
          icon={Users}
          actions={
            <Link href="/users">
              <a className="text-xs text-amber-300 hover:underline inline-flex items-center gap-0.5">
                View all <ArrowUpRight className="w-3 h-3" />
              </a>
            </Link>
          }
          padded={false}
        >
          {recentUsers.isLoading ? (
            <div className="p-6 text-center text-muted-foreground text-sm">Loading…</div>
          ) : !recentUsers.data || recentUsers.data.length === 0 ? (
            <EmptyState icon={Users} title="No users yet" description="New signups will appear here." />
          ) : (
            <ul className="divide-y divide-border/60">
              {recentUsers.data.map((u) => (
                <li key={u.id} className="flex items-center gap-3 px-4 md:px-5 py-3">
                  <div className="w-9 h-9 rounded-full gold-bg-soft border border-amber-500/25 flex items-center justify-center text-xs font-semibold text-amber-300 shrink-0">
                    {(u.name || u.email).slice(0, 2).toUpperCase()}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-sm font-medium truncate">{u.name || u.email}</div>
                    <div className="text-[11px] text-muted-foreground truncate font-mono">
                      {u.uid || u.email}
                    </div>
                  </div>
                  <div className="hidden sm:flex items-center gap-2">
                    <StatusPill status={u.status} />
                    <span className="text-[10px] text-muted-foreground tabular-nums w-14 text-right">
                      {timeAgo(u.createdAt)}
                    </span>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </SectionCard>

        <SectionCard
          title="Pending INR Withdrawals"
          description="Waiting for processing"
          icon={ArrowUpFromLine}
          actions={
            <Link href="/inr-withdrawals">
              <a className="text-xs text-amber-300 hover:underline inline-flex items-center gap-0.5">
                View all <ArrowUpRight className="w-3 h-3" />
              </a>
            </Link>
          }
          padded={false}
        >
          {recentInrW.isLoading ? (
            <div className="p-6 text-center text-muted-foreground text-sm">Loading…</div>
          ) : !recentInrW.data || recentInrW.data.length === 0 ? (
            <EmptyState
              icon={CheckCircle2}
              title="All caught up"
              description="No pending INR withdrawals right now."
            />
          ) : (
            <ul className="divide-y divide-border/60">
              {recentInrW.data.map((w) => (
                <li key={w.id} className="flex items-center gap-3 px-4 md:px-5 py-3">
                  <div className="w-9 h-9 rounded-full bg-amber-500/12 border border-amber-500/25 flex items-center justify-center shrink-0">
                    <ArrowUpFromLine className="w-4 h-4 text-amber-300" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-sm font-medium truncate">
                      {w.userEmail || `User #${w.userId ?? "?"}`}
                    </div>
                    <div className="text-[11px] text-muted-foreground tabular-nums">
                      ₹{fmt(Number(w.amount || 0))}
                    </div>
                  </div>
                  <div className="hidden sm:flex items-center gap-2">
                    <StatusPill status={w.status} />
                    <span className="text-[10px] text-muted-foreground tabular-nums w-14 text-right">
                      {timeAgo(w.createdAt)}
                    </span>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </SectionCard>
      </div>
    </div>
  );
}

function ApprovalCard({
  href, label, count, icon: Icon,
}: {
  href: string; label: string; count: number;
  icon: typeof ShieldCheck;
}) {
  const hot = count > 0;
  return (
    <Link href={href}>
      <a
        className={`group relative rounded-lg p-3 border transition-all hover-elevate flex flex-col gap-1.5 ${
          hot
            ? "border-amber-500/30 bg-amber-500/[0.04]"
            : "border-border bg-[hsl(222_16%_11%)]"
        }`}
      >
        <div className="flex items-center justify-between">
          <Icon className={`w-4 h-4 ${hot ? "text-amber-300" : "text-muted-foreground"}`} />
          {hot && (
            <span className="w-1.5 h-1.5 rounded-full bg-amber-400 shadow-[0_0_6px_rgba(251,191,36,0.7)] animate-pulse" />
          )}
        </div>
        <div className="text-[11px] text-muted-foreground">{label}</div>
        <div
          className={`text-xl font-bold tabular-nums leading-none ${
            hot ? "gold-text" : "text-foreground"
          }`}
        >
          {count}
        </div>
      </a>
    </Link>
  );
}

function HealthRow({
  icon: Icon,
  label,
  healthy,
  valueLabel,
  href,
  loading,
}: {
  icon: typeof ServerCog;
  label: string;
  healthy: boolean;
  valueLabel: string;
  href: string;
  loading?: boolean;
}) {
  return (
    <Link href={href}>
      <a className="flex items-center gap-3 p-3 rounded-lg border border-border bg-[hsl(222_16%_11%)] hover-elevate transition-all">
        <div
          className={`w-9 h-9 rounded-md flex items-center justify-center shrink-0 ${
            healthy
              ? "bg-emerald-500/12 border border-emerald-500/30"
              : "bg-amber-500/12 border border-amber-500/30"
          }`}
        >
          <Icon className={`w-4 h-4 ${healthy ? "text-emerald-300" : "text-amber-300"}`} />
        </div>
        <div className="flex-1 min-w-0">
          <div className="text-[11px] text-muted-foreground">{label}</div>
          <div className="text-sm font-semibold truncate">
            {loading ? <span className="inline-block h-4 w-16 bg-muted/50 rounded animate-pulse" /> : valueLabel}
          </div>
        </div>
        <StatusPill variant={healthy ? "success" : "warning"} dot={false}>
          {healthy ? <CheckCircle2 className="w-3 h-3" /> : <AlertCircle className="w-3 h-3" />}
        </StatusPill>
      </a>
    </Link>
  );
}
