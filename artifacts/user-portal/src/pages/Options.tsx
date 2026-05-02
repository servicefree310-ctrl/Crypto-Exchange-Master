import { useEffect, useMemo, useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { useToast } from "@/hooks/use-toast";
import { PageHeader } from "@/components/premium/PageHeader";
import { SectionCard } from "@/components/premium/SectionCard";
import { PremiumStatCard } from "@/components/premium/PremiumStatCard";
import { StatusPill } from "@/components/premium/StatusPill";
import { EmptyState } from "@/components/premium/EmptyState";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription,
} from "@/components/ui/dialog";
import { Layers, TrendingUp, Activity, X, ArrowDownToLine, ArrowUpToLine, Calendar, Sparkles, Sigma } from "lucide-react";
import { cn } from "@/lib/utils";

type Contract = {
  id: number; symbol: string; underlyingSymbol: string; optionType: "call" | "put";
  strike: number; expiryAt: string; iv: number; contractSize: number; minQty: number;
  mark: number; delta: number; gamma: number; theta: number; vega: number;
  spot: number; intrinsic: number; timeValue: number;
};
type Position = {
  id: number; contractId: number; symbol: string; optionType: "call" | "put";
  strike: number; expiryAt: string; side: "long" | "short"; qty: number;
  avgEntryPremium: number; marginLocked: number; mark: number; spot: number;
  delta: number; gamma: number; theta: number; vega: number; unrealizedPnl: number;
  openedAt: string;
};
type OrderRow = {
  id: number; contractSymbol: string; optionType: string; strike: string;
  side: string; qty: string; premium: string; markPriceAtFill: string;
  fee: string; status: string; createdAt: string;
};

const fmtUsd = (n: number, dp = 2) => Number(n ?? 0).toLocaleString("en-US", { maximumFractionDigits: dp, minimumFractionDigits: dp });
const fmtSmall = (n: number) => Number(n ?? 0).toFixed(4);
function timeUntil(iso: string): string {
  const ms = new Date(iso).getTime() - Date.now();
  if (ms <= 0) return "expired";
  const d = Math.floor(ms / 86_400_000);
  const h = Math.floor((ms % 86_400_000) / 3_600_000);
  if (d > 0) return `${d}d ${h}h`;
  const m = Math.floor((ms % 3_600_000) / 60_000);
  return `${h}h ${m}m`;
}

export default function OptionsPage() {
  const { user } = useAuth();
  const { toast } = useToast();
  const qc = useQueryClient();

  const [underlying, setUnderlying] = useState<string>("BTC");
  const [tab, setTab] = useState<"chain" | "positions" | "history">("chain");

  const contractsQ = useQuery<{ contracts: Contract[] }>({
    queryKey: ["options-contracts", underlying],
    queryFn: () => get(`/api/options/contracts?underlying=${encodeURIComponent(underlying)}`),
    refetchInterval: 5_000,
  });
  const positionsQ = useQuery<{ positions: Position[] }>({
    queryKey: ["options-positions"],
    queryFn: () => get(`/api/options/positions`),
    enabled: !!user,
    refetchInterval: 5_000,
  });
  const historyQ = useQuery<{ orders: OrderRow[] }>({
    queryKey: ["options-history"],
    queryFn: () => get(`/api/options/orders/history?limit=50`),
    enabled: !!user && tab === "history",
  });

  // Group contracts by expiry → unique sorted expiries; pick first by default
  const expiries = useMemo(() => {
    const set = new Set<string>();
    (contractsQ.data?.contracts ?? []).forEach((c) => set.add(c.expiryAt));
    return [...set].sort();
  }, [contractsQ.data]);
  const [activeExpiry, setActiveExpiry] = useState<string>("");
  useEffect(() => { if (expiries.length && !expiries.includes(activeExpiry)) setActiveExpiry(expiries[0]); }, [expiries, activeExpiry]);

  // Build option chain rows (one per strike with call+put side-by-side)
  const chainRows = useMemo(() => {
    const list = (contractsQ.data?.contracts ?? []).filter((c) => c.expiryAt === activeExpiry);
    const byStrike = new Map<number, { strike: number; call?: Contract; put?: Contract }>();
    for (const c of list) {
      const r = byStrike.get(c.strike) ?? { strike: c.strike };
      if (c.optionType === "call") r.call = c; else r.put = c;
      byStrike.set(c.strike, r);
    }
    return [...byStrike.values()].sort((a, b) => a.strike - b.strike);
  }, [contractsQ.data, activeExpiry]);

  const spot = chainRows[0]?.call?.spot ?? chainRows[0]?.put?.spot ?? 0;

  // Order ticket modal
  const [ticket, setTicket] = useState<{ contract: Contract; side: "buy" | "sell" } | null>(null);
  const [qty, setQty] = useState<string>("0.1");

  const placeOrder = useMutation({
    mutationFn: (vars: { contractId: number; side: "buy" | "sell"; qty: number }) =>
      post(`/api/options/orders`, vars),
    onSuccess: () => {
      toast({ title: "Order filled", description: "Position update ho gayi hai" });
      setTicket(null); setQty("0.1");
      qc.invalidateQueries({ queryKey: ["options-positions"] });
      qc.invalidateQueries({ queryKey: ["options-history"] });
    },
    onError: (e: any) => toast({ title: "Order fail", description: e?.message ?? "Try again", variant: "destructive" }),
  });

  const closePosition = useMutation({
    mutationFn: (id: number) => post(`/api/options/positions/${id}/close`, {}),
    onSuccess: (r: any) => {
      toast({
        title: "Position closed",
        description: `Realized PnL: ${r.pnl >= 0 ? "+" : ""}${fmtUsd(r.pnl)} USDT`,
      });
      qc.invalidateQueries({ queryKey: ["options-positions"] });
      qc.invalidateQueries({ queryKey: ["options-history"] });
    },
    onError: (e: any) => toast({ title: "Close fail", description: e?.message ?? "Try again", variant: "destructive" }),
  });

  const positions = positionsQ.data?.positions ?? [];
  const totalUnreal = positions.reduce((s, p) => s + p.unrealizedPnl, 0);
  const totalDelta = positions.reduce((s, p) => s + p.delta * p.qty, 0);

  return (
    <div className="container mx-auto px-3 md:px-6 py-5">
      <PageHeader
        eyebrow="Derivatives"
        title="Options Trading"
        description="Calls aur puts kharidiye ya sell kariye. Premium upfront pay karein, expiry par auto-settle ho jayega."
        actions={
          <div className="flex items-center gap-2">
            <select
              value={underlying}
              onChange={(e) => setUnderlying(e.target.value)}
              className="bg-muted/40 border border-border rounded-md px-3 py-1.5 text-sm"
              data-testid="select-underlying"
            >
              <option value="BTC">BTC</option>
              <option value="ETH">ETH</option>
            </select>
          </div>
        }
      />

      <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-5">
        <PremiumStatCard title={`${underlying} Spot`} value={fmtUsd(spot, 2)} prefix="$" icon={TrendingUp} hero />
        <PremiumStatCard title="Open Positions" value={positions.length} icon={Layers} accent />
        <PremiumStatCard
          title="Unrealized PnL"
          value={fmtUsd(totalUnreal, 2)}
          prefix={totalUnreal >= 0 ? "+$" : "-$"}
          icon={Sigma}
          delta={totalUnreal >= 0 ? 1 : -1}
          loading={positionsQ.isLoading}
        />
        <PremiumStatCard title="Net Delta" value={fmtSmall(totalDelta)} icon={Activity} hint={`Net exposure ≈ ${fmtUsd(totalDelta * spot, 0)} ${underlying}`} />
      </div>

      <Tabs value={tab} onValueChange={(v) => setTab(v as any)}>
        <TabsList>
          <TabsTrigger value="chain" data-testid="tab-chain">Option Chain</TabsTrigger>
          <TabsTrigger value="positions" data-testid="tab-positions">Positions ({positions.length})</TabsTrigger>
          <TabsTrigger value="history" data-testid="tab-history">History</TabsTrigger>
        </TabsList>

        {/* ─── Option Chain Tab ──────────────────────────────────────────── */}
        <TabsContent value="chain" className="mt-4">
          {expiries.length > 1 && (
            <div className="flex items-center gap-2 mb-3 overflow-x-auto pb-1">
              <Calendar className="w-4 h-4 text-muted-foreground shrink-0" />
              {expiries.map((e) => (
                <button
                  key={e}
                  onClick={() => setActiveExpiry(e)}
                  className={cn(
                    "px-3 py-1.5 rounded-md text-xs font-medium border whitespace-nowrap",
                    activeExpiry === e
                      ? "gold-bg-soft border-amber-500/40 text-amber-300"
                      : "bg-muted/30 border-border text-muted-foreground hover:text-foreground",
                  )}
                  data-testid={`expiry-${e}`}
                >
                  {new Date(e).toLocaleDateString("en-IN", { day: "2-digit", month: "short" })}
                  <span className="ml-2 text-[10px] opacity-70">{timeUntil(e)}</span>
                </button>
              ))}
            </div>
          )}

          <SectionCard
            title={`${underlying} Option Chain`}
            description={activeExpiry ? `Expiry: ${new Date(activeExpiry).toLocaleString("en-IN")}` : "Loading…"}
            icon={Sparkles}
            padded={false}
          >
            {contractsQ.isLoading ? (
              <div className="p-6 text-center text-sm text-muted-foreground">Loading chain…</div>
            ) : chainRows.length === 0 ? (
              <EmptyState title="No active contracts" description="Admin ne abhi koi contract list nahi kiya" icon={Layers} />
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-xs md:text-sm">
                  <thead className="bg-muted/20 text-muted-foreground border-y border-border/50">
                    <tr>
                      <th colSpan={4} className="text-center py-2 font-semibold text-emerald-400">CALLS</th>
                      <th className="py-2 text-center font-semibold border-x border-border/50">Strike</th>
                      <th colSpan={4} className="text-center py-2 font-semibold text-rose-400">PUTS</th>
                    </tr>
                    <tr className="text-[10px] uppercase tracking-wide">
                      <th className="px-2 py-1.5 text-right">IV</th>
                      <th className="px-2 py-1.5 text-right">Δ</th>
                      <th className="px-2 py-1.5 text-right">Mark</th>
                      <th className="px-2 py-1.5 text-center">Action</th>
                      <th className="px-2 py-1.5 text-center border-x border-border/50">USD</th>
                      <th className="px-2 py-1.5 text-center">Action</th>
                      <th className="px-2 py-1.5 text-right">Mark</th>
                      <th className="px-2 py-1.5 text-right">Δ</th>
                      <th className="px-2 py-1.5 text-right">IV</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border/40">
                    {chainRows.map((r) => {
                      const atm = Math.abs(r.strike - spot) / Math.max(spot, 1) < 0.005;
                      return (
                        <tr key={r.strike} className={cn("hover:bg-muted/10", atm && "bg-amber-500/5")}>
                          <td className="px-2 py-2 text-right tabular-nums text-muted-foreground">{r.call ? `${(r.call.iv * 100).toFixed(0)}%` : "—"}</td>
                          <td className="px-2 py-2 text-right tabular-nums text-muted-foreground">{r.call ? r.call.delta.toFixed(2) : "—"}</td>
                          <td className="px-2 py-2 text-right tabular-nums font-medium text-emerald-300">{r.call ? `$${fmtUsd(r.call.mark)}` : "—"}</td>
                          <td className="px-1 py-2 text-center">
                            {r.call && (
                              <div className="inline-flex gap-1">
                                <button onClick={() => { setTicket({ contract: r.call!, side: "buy" }); }} className="px-2 py-0.5 rounded text-[10px] bg-emerald-500/15 text-emerald-300 hover:bg-emerald-500/25" data-testid={`btn-buy-call-${r.strike}`}>BUY</button>
                                <button onClick={() => { setTicket({ contract: r.call!, side: "sell" }); }} className="px-2 py-0.5 rounded text-[10px] bg-rose-500/15 text-rose-300 hover:bg-rose-500/25" data-testid={`btn-sell-call-${r.strike}`}>SELL</button>
                              </div>
                            )}
                          </td>
                          <td className={cn("px-2 py-2 text-center font-bold tabular-nums border-x border-border/50", atm ? "gold-text" : "text-foreground")}>
                            ${fmtUsd(r.strike, 0)}
                          </td>
                          <td className="px-1 py-2 text-center">
                            {r.put && (
                              <div className="inline-flex gap-1">
                                <button onClick={() => { setTicket({ contract: r.put!, side: "buy" }); }} className="px-2 py-0.5 rounded text-[10px] bg-emerald-500/15 text-emerald-300 hover:bg-emerald-500/25" data-testid={`btn-buy-put-${r.strike}`}>BUY</button>
                                <button onClick={() => { setTicket({ contract: r.put!, side: "sell" }); }} className="px-2 py-0.5 rounded text-[10px] bg-rose-500/15 text-rose-300 hover:bg-rose-500/25" data-testid={`btn-sell-put-${r.strike}`}>SELL</button>
                              </div>
                            )}
                          </td>
                          <td className="px-2 py-2 text-right tabular-nums font-medium text-rose-300">{r.put ? `$${fmtUsd(r.put.mark)}` : "—"}</td>
                          <td className="px-2 py-2 text-right tabular-nums text-muted-foreground">{r.put ? r.put.delta.toFixed(2) : "—"}</td>
                          <td className="px-2 py-2 text-right tabular-nums text-muted-foreground">{r.put ? `${(r.put.iv * 100).toFixed(0)}%` : "—"}</td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            )}
          </SectionCard>
        </TabsContent>

        {/* ─── Positions Tab ─────────────────────────────────────────────── */}
        <TabsContent value="positions" className="mt-4">
          <SectionCard title="Open Positions" icon={Layers} padded={false}>
            {!user ? (
              <EmptyState title="Login karein" description="Positions dekhne ke liye login zaruri hai" icon={Layers} />
            ) : positions.length === 0 ? (
              <EmptyState title="Koi position nahi" description="Chain se BUY/SELL dabakar position banaiye" icon={Layers} />
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-xs md:text-sm">
                  <thead className="bg-muted/20 text-muted-foreground text-[10px] uppercase tracking-wide">
                    <tr>
                      <th className="px-3 py-2 text-left">Contract</th>
                      <th className="px-3 py-2 text-left">Side</th>
                      <th className="px-3 py-2 text-right">Qty</th>
                      <th className="px-3 py-2 text-right">Entry</th>
                      <th className="px-3 py-2 text-right">Mark</th>
                      <th className="px-3 py-2 text-right">Δ / Θ</th>
                      <th className="px-3 py-2 text-right">PnL</th>
                      <th className="px-3 py-2 text-right">Expiry</th>
                      <th className="px-3 py-2"></th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border/40">
                    {positions.map((p) => (
                      <tr key={p.id} className="hover:bg-muted/10" data-testid={`row-position-${p.id}`}>
                        <td className="px-3 py-2.5 font-medium">{p.symbol}</td>
                        <td className="px-3 py-2.5">
                          <StatusPill variant={p.side === "long" ? "success" : "danger"}>
                            {p.side === "long" ? "LONG" : "SHORT"} {p.optionType.toUpperCase()}
                          </StatusPill>
                        </td>
                        <td className="px-3 py-2.5 text-right tabular-nums">{p.qty}</td>
                        <td className="px-3 py-2.5 text-right tabular-nums">${fmtUsd(p.avgEntryPremium)}</td>
                        <td className="px-3 py-2.5 text-right tabular-nums font-medium">${fmtUsd(p.mark)}</td>
                        <td className="px-3 py-2.5 text-right tabular-nums text-muted-foreground">
                          {p.delta.toFixed(2)} / {p.theta.toFixed(2)}
                        </td>
                        <td className={cn("px-3 py-2.5 text-right tabular-nums font-semibold", p.unrealizedPnl >= 0 ? "text-emerald-400" : "text-rose-400")}>
                          {p.unrealizedPnl >= 0 ? "+" : ""}${fmtUsd(p.unrealizedPnl)}
                        </td>
                        <td className="px-3 py-2.5 text-right text-xs text-muted-foreground">{timeUntil(p.expiryAt)}</td>
                        <td className="px-3 py-2.5 text-right">
                          <Button size="sm" variant="outline" disabled={closePosition.isPending} onClick={() => closePosition.mutate(p.id)} data-testid={`btn-close-${p.id}`}>
                            <X className="w-3.5 h-3.5 mr-1" /> Close
                          </Button>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </SectionCard>
        </TabsContent>

        {/* ─── History Tab ───────────────────────────────────────────────── */}
        <TabsContent value="history" className="mt-4">
          <SectionCard title="Order History" icon={Activity} padded={false}>
            {!user ? (
              <EmptyState title="Login karein" description="History dekhne ke liye login zaruri hai" icon={Activity} />
            ) : (historyQ.data?.orders ?? []).length === 0 ? (
              <EmptyState title="Koi order nahi" description="Pehla order place karke shuru kariye" icon={Activity} />
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full text-xs md:text-sm">
                  <thead className="bg-muted/20 text-muted-foreground text-[10px] uppercase tracking-wide">
                    <tr>
                      <th className="px-3 py-2 text-left">Time</th>
                      <th className="px-3 py-2 text-left">Contract</th>
                      <th className="px-3 py-2 text-left">Side</th>
                      <th className="px-3 py-2 text-right">Qty</th>
                      <th className="px-3 py-2 text-right">Mark</th>
                      <th className="px-3 py-2 text-right">Premium</th>
                      <th className="px-3 py-2 text-right">Fee</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-border/40">
                    {(historyQ.data?.orders ?? []).map((o) => (
                      <tr key={o.id} className="hover:bg-muted/10">
                        <td className="px-3 py-2 text-muted-foreground whitespace-nowrap">{new Date(o.createdAt).toLocaleString("en-IN")}</td>
                        <td className="px-3 py-2 font-medium">{o.contractSymbol}</td>
                        <td className="px-3 py-2">
                          <span className={cn("text-xs font-semibold", o.side === "buy" ? "text-emerald-400" : "text-rose-400")}>{o.side.toUpperCase()}</span>
                        </td>
                        <td className="px-3 py-2 text-right tabular-nums">{Number(o.qty).toFixed(2)}</td>
                        <td className="px-3 py-2 text-right tabular-nums">${fmtUsd(Number(o.markPriceAtFill))}</td>
                        <td className="px-3 py-2 text-right tabular-nums">${fmtUsd(Number(o.premium))}</td>
                        <td className="px-3 py-2 text-right tabular-nums text-muted-foreground">${fmtUsd(Number(o.fee), 4)}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </SectionCard>
        </TabsContent>
      </Tabs>

      {/* ─── Order Ticket Modal ───────────────────────────────────────────── */}
      <Dialog open={!!ticket} onOpenChange={(o) => { if (!o) setTicket(null); }}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2">
              {ticket?.side === "buy" ? <ArrowDownToLine className="w-4 h-4 text-emerald-400" /> : <ArrowUpToLine className="w-4 h-4 text-rose-400" />}
              {ticket?.side === "buy" ? "Buy" : "Sell"} {ticket?.contract.symbol}
            </DialogTitle>
            <DialogDescription>
              {ticket?.side === "buy"
                ? "Premium turant USDT wallet se kat jayega. Expiry par profit credit hoga."
                : "Margin lock hoga. Expiry par mark price ke hisab se settle hoga."}
            </DialogDescription>
          </DialogHeader>

          {ticket && (
            <div className="space-y-3">
              <div className="grid grid-cols-3 gap-3 text-xs">
                <div className="p-2 bg-muted/30 rounded">
                  <div className="text-[10px] text-muted-foreground uppercase">Mark</div>
                  <div className="font-bold tabular-nums">${fmtUsd(ticket.contract.mark)}</div>
                </div>
                <div className="p-2 bg-muted/30 rounded">
                  <div className="text-[10px] text-muted-foreground uppercase">IV</div>
                  <div className="font-bold tabular-nums">{(ticket.contract.iv * 100).toFixed(0)}%</div>
                </div>
                <div className="p-2 bg-muted/30 rounded">
                  <div className="text-[10px] text-muted-foreground uppercase">Δ</div>
                  <div className="font-bold tabular-nums">{ticket.contract.delta.toFixed(2)}</div>
                </div>
              </div>

              <div>
                <Label className="text-xs">Quantity (min {ticket.contract.minQty})</Label>
                <Input type="number" step="0.01" value={qty} onChange={(e) => setQty(e.target.value)} data-testid="input-qty" />
              </div>

              <div className="bg-muted/20 rounded-lg p-3 text-xs space-y-1.5">
                <div className="flex justify-between">
                  <span className="text-muted-foreground">{ticket.side === "buy" ? "You pay" : "You receive"}</span>
                  <span className="font-bold tabular-nums">${fmtUsd(ticket.contract.mark * (Number(qty) || 0))} USDT</span>
                </div>
                {ticket.side === "sell" && (
                  <div className="flex justify-between">
                    <span className="text-muted-foreground">Margin lock</span>
                    <span className="tabular-nums">~${fmtUsd((ticket.contract.optionType === "call" ? Math.max(ticket.contract.spot, ticket.contract.strike) : ticket.contract.strike) * (Number(qty) || 0))}</span>
                  </div>
                )}
                <div className="flex justify-between text-muted-foreground">
                  <span>Expiry</span>
                  <span>{timeUntil(ticket.contract.expiryAt)}</span>
                </div>
              </div>
            </div>
          )}

          <DialogFooter>
            <Button variant="outline" onClick={() => setTicket(null)}>Cancel</Button>
            <Button
              disabled={!ticket || !Number(qty) || placeOrder.isPending}
              onClick={() => ticket && placeOrder.mutate({ contractId: ticket.contract.id, side: ticket.side, qty: Number(qty) })}
              data-testid="btn-confirm-order"
              className={ticket?.side === "buy" ? "bg-emerald-600 hover:bg-emerald-700 text-white" : "bg-rose-600 hover:bg-rose-700 text-white"}
            >
              {placeOrder.isPending ? "Placing…" : `Confirm ${ticket?.side === "buy" ? "Buy" : "Sell"}`}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
