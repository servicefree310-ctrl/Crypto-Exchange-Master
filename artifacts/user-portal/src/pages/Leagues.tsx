import { Trophy, Crown, Medal, Award, Zap, Target, Users, Calendar, Sparkles, ArrowRight, DollarSign, Clock, Gift, UserCheck } from "lucide-react";
import { PageHeader } from "@/components/premium/PageHeader";
import { SectionCard } from "@/components/premium/SectionCard";
import { PremiumStatCard } from "@/components/premium/PremiumStatCard";
import { StatusPill } from "@/components/premium/StatusPill";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Link } from "wouter";

type LeaderRow = { rank: number; name: string; volume: string; pnl: string; prize: string };

const SAMPLE_LEADERBOARD: LeaderRow[] = [
  { rank: 1, name: "Crypto*****Raj",    volume: "$2.4M", pnl: "+184.2%", prize: "5,000 USDT" },
  { rank: 2, name: "Whale*****22",      volume: "$1.8M", pnl: "+142.7%", prize: "2,500 USDT" },
  { rank: 3, name: "Moon*****Bull",     volume: "$1.5M", pnl: "+128.3%", prize: "1,500 USDT" },
  { rank: 4, name: "Trader*****X",      volume: "$1.2M", pnl: "+98.4%",  prize: "500 USDT" },
  { rank: 5, name: "Diamond*****Hands", volume: "$980K", pnl: "+76.9%",  prize: "500 USDT" },
  { rank: 6, name: "Pro*****Maxi",      volume: "$820K", pnl: "+64.1%",  prize: "200 USDT" },
  { rank: 7, name: "Smart*****Money",   volume: "$770K", pnl: "+58.2%",  prize: "200 USDT" },
  { rank: 8, name: "Hodl*****Forever",  volume: "$640K", pnl: "+52.7%",  prize: "100 USDT" },
];

export default function LeaguesPage() {
  return (
    <div className="container mx-auto px-4 py-8 max-w-6xl">
      <PageHeader
        eyebrow="Explore"
        title="Trading Leagues"
        description="Compete karo top traders ke saath, climb karo leaderboard, aur jeeto crypto rewards."
        actions={
          <StatusPill status="pending" variant="gold">
            Season 1 starting soon
          </StatusPill>
        }
      />

      {/* Hero CTA */}
      <SectionCard className="p-6 sm:p-8 mb-6 relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-amber-500/10 via-orange-500/5 to-transparent pointer-events-none" />
        <div className="relative grid grid-cols-1 md:grid-cols-[1fr_auto] gap-6 items-center">
          <div>
            <Badge className="mb-3 bg-amber-500/15 text-amber-400 border-amber-500/30">
              <Sparkles className="h-3 w-3 mr-1" /> Season 1 — May 2026
            </Badge>
            <h2 className="text-2xl sm:text-3xl font-bold tracking-tight text-foreground">
              Zebvix Trading Champions
            </h2>
            <p className="text-sm text-muted-foreground mt-2 max-w-xl leading-relaxed">
              30 din ka contest. Highest ROI aur volume wale traders win karenge prize pool ka share. Spot, Futures, Convert — sab counts.
            </p>
            <div className="mt-4 flex flex-wrap gap-2">
              <Button className="bg-gradient-to-r from-amber-500 to-orange-500 text-black hover:from-amber-400 hover:to-orange-400 font-semibold">
                <Trophy className="h-4 w-4 mr-1.5" /> Join Waitlist
              </Button>
              <Button variant="outline" asChild>
                <Link href="/markets">Start Trading <ArrowRight className="h-4 w-4 ml-1.5" /></Link>
              </Button>
            </div>
          </div>
          <div className="hidden md:flex items-center justify-center">
            <div className="relative h-32 w-32 rounded-full bg-gradient-to-br from-amber-400 via-amber-500 to-orange-600 flex items-center justify-center shadow-2xl shadow-amber-500/30">
              <Trophy className="h-16 w-16 text-black" strokeWidth={2} />
              <span className="absolute -top-1 -right-1 inline-flex h-7 w-7 rounded-full bg-rose-500 text-white text-[10px] font-bold items-center justify-center ring-2 ring-card">
                NEW
              </span>
            </div>
          </div>
        </div>
      </SectionCard>

      {/* Stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3 mb-6">
        <PremiumStatCard title="Total Prize Pool" value="$25,000" icon={DollarSign} hint="USDT + ZBX rewards" accent />
        <PremiumStatCard title="Duration" value="30 Days" icon={Clock} hint="May 1 → May 30" />
        <PremiumStatCard title="Top Prize" value="5,000 USDT" icon={Gift} hint="Rank #1 winner" accent />
        <PremiumStatCard title="Spots" value="Unlimited" icon={UserCheck} hint="Open to all KYC users" />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {/* Leaderboard preview */}
        <SectionCard className="lg:col-span-2 p-5">
          <div className="flex items-center justify-between mb-4">
            <h3 className="font-semibold flex items-center gap-2">
              <Crown className="h-5 w-5 text-amber-400" /> Sample Leaderboard
            </h3>
            <Badge variant="outline" className="text-[10px] uppercase">Demo Data</Badge>
          </div>
          <div className="overflow-x-auto -mx-2">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-xs uppercase tracking-wider text-muted-foreground">
                  <th className="text-left py-2 px-2 font-medium w-12">#</th>
                  <th className="text-left py-2 px-2 font-medium">Trader</th>
                  <th className="text-right py-2 px-2 font-medium hidden sm:table-cell">Volume</th>
                  <th className="text-right py-2 px-2 font-medium">PnL %</th>
                  <th className="text-right py-2 px-2 font-medium">Prize</th>
                </tr>
              </thead>
              <tbody>
                {SAMPLE_LEADERBOARD.map((r) => (
                  <tr key={r.rank} className="border-t border-border hover:bg-muted/30">
                    <td className="py-2.5 px-2">
                      <RankBadge rank={r.rank} />
                    </td>
                    <td className="py-2.5 px-2 font-medium">{r.name}</td>
                    <td className="py-2.5 px-2 text-right font-mono text-muted-foreground hidden sm:table-cell">{r.volume}</td>
                    <td className="py-2.5 px-2 text-right font-mono text-emerald-400 font-semibold">{r.pnl}</td>
                    <td className="py-2.5 px-2 text-right font-mono text-amber-400 font-semibold">{r.prize}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <p className="text-[11px] text-muted-foreground mt-3">
            ⓘ Yeh demo leaderboard hai. Real contest start hone par actual rankings update hongi.
          </p>
        </SectionCard>

        {/* How it works */}
        <SectionCard className="p-5 space-y-4">
          <h3 className="font-semibold flex items-center gap-2">
            <Target className="h-5 w-5 text-amber-400" /> How it Works
          </h3>
          <Step icon={Users} title="Join Waitlist" desc="KYC complete karo aur free mein register ho jao." />
          <Step icon={Zap} title="Trade Anywhere" desc="Spot, Futures, Convert — saari activity count hoti hai." />
          <Step icon={Calendar} title="30-day Window" desc="Pure season ka volume aur ROI track hota hai live." />
          <Step icon={Award} title="Win Rewards" desc="Top 100 traders ko USDT + ZBX prize milta hai monthly." />
        </SectionCard>
      </div>

      {/* Reward tiers */}
      <SectionCard className="p-5 mt-6">
        <h3 className="font-semibold flex items-center gap-2 mb-4">
          <Trophy className="h-5 w-5 text-amber-400" /> Reward Tiers
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          <RewardTier rank="🥇 Rank 1" prize="5,000 USDT" extra="+ Diamond Badge" tone="amber" />
          <RewardTier rank="🥈 Rank 2-3" prize="1,500-2,500 USDT" extra="+ Gold Badge" tone="zinc" />
          <RewardTier rank="🥉 Rank 4-10" prize="200-500 USDT" extra="+ Silver Badge" tone="orange" />
          <RewardTier rank="🏅 Rank 11-100" prize="50-100 USDT" extra="+ Participant NFT" tone="emerald" />
        </div>
      </SectionCard>
    </div>
  );
}

function RankBadge({ rank }: { rank: number }) {
  if (rank === 1) {
    return <span className="inline-flex h-7 w-7 rounded-full bg-amber-500/20 text-amber-400 font-bold text-xs items-center justify-center">🥇</span>;
  }
  if (rank === 2) {
    return <span className="inline-flex h-7 w-7 rounded-full bg-zinc-400/20 text-zinc-300 font-bold text-xs items-center justify-center">🥈</span>;
  }
  if (rank === 3) {
    return <span className="inline-flex h-7 w-7 rounded-full bg-orange-500/20 text-orange-400 font-bold text-xs items-center justify-center">🥉</span>;
  }
  return <span className="inline-flex h-7 w-7 rounded-full bg-muted text-muted-foreground font-bold text-xs items-center justify-center">{rank}</span>;
}

function Step({ icon: Icon, title, desc }: { icon: typeof Target; title: string; desc: string }) {
  return (
    <div className="flex items-start gap-3">
      <div className="h-8 w-8 rounded-lg bg-amber-500/10 border border-amber-500/30 flex items-center justify-center flex-shrink-0">
        <Icon className="h-4 w-4 text-amber-400" />
      </div>
      <div className="min-w-0">
        <div className="text-sm font-semibold">{title}</div>
        <div className="text-xs text-muted-foreground leading-relaxed">{desc}</div>
      </div>
    </div>
  );
}

function RewardTier({ rank, prize, extra, tone }: { rank: string; prize: string; extra: string; tone: string }) {
  const bg = tone === "amber"
    ? "from-amber-500/15 to-amber-500/5 border-amber-500/30"
    : tone === "zinc"
    ? "from-zinc-400/15 to-zinc-400/5 border-zinc-400/30"
    : tone === "orange"
    ? "from-orange-500/15 to-orange-500/5 border-orange-500/30"
    : "from-emerald-500/15 to-emerald-500/5 border-emerald-500/30";
  return (
    <div className={`rounded-lg border bg-gradient-to-br ${bg} p-4`}>
      <div className="text-xs text-muted-foreground">{rank}</div>
      <div className="text-lg font-bold font-mono mt-1">{prize}</div>
      <div className="text-[11px] text-muted-foreground mt-1 inline-flex items-center gap-1">
        <Medal className="h-3 w-3" /> {extra}
      </div>
    </div>
  );
}
