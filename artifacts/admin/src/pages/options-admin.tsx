import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { useToast } from "@/hooks/use-toast";
import { PageHeader } from "@/components/premium/PageHeader";
import { PremiumStatCard } from "@/components/premium/PremiumStatCard";
import { StatusPill } from "@/components/premium/StatusPill";
import { EmptyState } from "@/components/premium/EmptyState";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription } from "@/components/ui/dialog";
import { Sigma, Plus, Trash2, Zap, Layers, TrendingUp } from "lucide-react";
import { cn } from "@/lib/utils";

type Contract = {
  id: number; symbol: string; underlyingCoinId: number; underlyingSymbol: string;
  quoteCoinSymbol: string; optionType: "call" | "put";
  strikePrice: string; expiryAt: string;
  ivBps: number; riskFreeRateBps: number; contractSize: string; minQty: string;
  status: string; settlementPrice: string | null; settledAt: string | null; createdAt: string;
};

const fmt = (n: number, dp = 2) => Number(n ?? 0).toLocaleString("en-US", { maximumFractionDigits: dp, minimumFractionDigits: dp });

export default function OptionsAdminPage() {
  const { toast } = useToast();
  const qc = useQueryClient();

  const contractsQ = useQuery<{ contracts: Contract[] }>({
    queryKey: ["admin-options"],
    queryFn: () => get(`/api/admin/options/contracts`),
    refetchInterval: 10_000,
  });

  const [createOpen, setCreateOpen] = useState(false);
  const [form, setForm] = useState({
    underlyingSymbol: "BTC",
    quoteCoinSymbol: "USDT",
    optionType: "call" as "call" | "put",
    strikePrice: "",
    expiryAt: "",
    ivBps: 8000,
    riskFreeRateBps: 500,
    contractSize: 1,
    minQty: 0.01,
  });

  const createMut = useMutation({
    mutationFn: () => post(`/api/admin/options/contracts`, form),
    onSuccess: () => {
      toast({ title: "Contract created", description: "New option live ho gaya" });
      setCreateOpen(false);
      qc.invalidateQueries({ queryKey: ["admin-options"] });
    },
    onError: (e: any) => toast({ title: "Create failed", description: e?.message ?? "Try again", variant: "destructive" }),
  });

  const settleMut = useMutation({
    mutationFn: (id: number) => post(`/api/admin/options/contracts/${id}/settle`, {}),
    onSuccess: () => {
      toast({ title: "Force settle queued", description: "Engine ~1 minute mein settle karega" });
      qc.invalidateQueries({ queryKey: ["admin-options"] });
    },
  });

  const deleteMut = useMutation({
    mutationFn: (id: number) => del(`/api/admin/options/contracts/${id}`),
    onSuccess: () => {
      toast({ title: "Contract deleted" });
      qc.invalidateQueries({ queryKey: ["admin-options"] });
    },
    onError: (e: any) => toast({ title: "Delete failed", description: e?.message ?? "Try again", variant: "destructive" }),
  });

  const ivPatch = useMutation({
    mutationFn: ({ id, ivBps }: { id: number; ivBps: number }) => patch(`/api/admin/options/contracts/${id}`, { ivBps }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-options"] }),
  });

  const contracts = contractsQ.data?.contracts ?? [];
  const active = contracts.filter((c) => c.status === "active");
  const expired = contracts.filter((c) => c.status === "expired");
  const settled = contracts.filter((c) => c.status === "settled");

  return (
    <div className="space-y-5">
      <PageHeader
        eyebrow="Derivatives"
        title="Options Admin"
        description="Option contracts list kariye, IV update kariye, force-settle kariye."
        actions={
          <Button onClick={() => setCreateOpen(true)} data-testid="btn-create-contract">
            <Plus className="w-4 h-4 mr-1.5" /> New Contract
          </Button>
        }
      />

      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <PremiumStatCard title="Active" value={active.length} icon={Sigma} hero />
        <PremiumStatCard title="Expired" value={expired.length} icon={Layers} accent />
        <PremiumStatCard title="Settled" value={settled.length} icon={TrendingUp} />
        <PremiumStatCard title="Total" value={contracts.length} icon={Sigma} />
      </div>

      <div className="premium-card rounded-xl">
        <div className="p-4 border-b border-border/50">
          <h3 className="font-semibold">All Contracts</h3>
        </div>
        {contracts.length === 0 ? (
          <EmptyState title="Koi contract nahi" description="Naya contract create karke shuru kariye" icon={Sigma} />
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-muted/20 text-muted-foreground text-[10px] uppercase tracking-wide">
                <tr>
                  <th className="px-3 py-2 text-left">Symbol</th>
                  <th className="px-3 py-2 text-left">Underlying</th>
                  <th className="px-3 py-2 text-left">Type</th>
                  <th className="px-3 py-2 text-right">Strike</th>
                  <th className="px-3 py-2 text-left">Expiry</th>
                  <th className="px-3 py-2 text-right">IV %</th>
                  <th className="px-3 py-2">Status</th>
                  <th className="px-3 py-2 text-right">Settlement</th>
                  <th className="px-3 py-2"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-border/40">
                {contracts.map((c) => (
                  <tr key={c.id} className="hover:bg-muted/10" data-testid={`row-contract-${c.id}`}>
                    <td className="px-3 py-2 font-mono text-xs">{c.symbol}</td>
                    <td className="px-3 py-2">{c.underlyingSymbol}</td>
                    <td className="px-3 py-2">
                      <span className={cn("text-xs font-semibold", c.optionType === "call" ? "text-emerald-400" : "text-rose-400")}>
                        {c.optionType.toUpperCase()}
                      </span>
                    </td>
                    <td className="px-3 py-2 text-right tabular-nums">${fmt(Number(c.strikePrice), 0)}</td>
                    <td className="px-3 py-2 text-xs text-muted-foreground">{new Date(c.expiryAt).toLocaleString("en-IN")}</td>
                    <td className="px-3 py-2 text-right">
                      <input
                        type="number"
                        defaultValue={c.ivBps / 100}
                        className="w-16 bg-muted/30 border border-border rounded px-2 py-0.5 text-xs text-right tabular-nums"
                        onBlur={(e) => {
                          const v = Number(e.target.value) * 100;
                          if (v !== c.ivBps && v > 0) ivPatch.mutate({ id: c.id, ivBps: Math.round(v) });
                        }}
                        data-testid={`input-iv-${c.id}`}
                      />
                    </td>
                    <td className="px-3 py-2"><StatusPill status={c.status} /></td>
                    <td className="px-3 py-2 text-right tabular-nums text-xs">
                      {c.settlementPrice ? `$${fmt(Number(c.settlementPrice))}` : "—"}
                    </td>
                    <td className="px-3 py-2 text-right">
                      <div className="flex items-center justify-end gap-1">
                        {c.status !== "settled" && (
                          <Button size="sm" variant="outline" onClick={() => settleMut.mutate(c.id)} disabled={settleMut.isPending} data-testid={`btn-settle-${c.id}`}>
                            <Zap className="w-3.5 h-3.5 mr-1" /> Settle
                          </Button>
                        )}
                        <Button size="sm" variant="ghost" className="text-red-400" onClick={() => { if (confirm(`Delete ${c.symbol}?`)) deleteMut.mutate(c.id); }} data-testid={`btn-delete-${c.id}`}>
                          <Trash2 className="w-3.5 h-3.5" />
                        </Button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Create dialog */}
      <Dialog open={createOpen} onOpenChange={setCreateOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Create Option Contract</DialogTitle>
            <DialogDescription>Symbol auto-generate hoga: e.g. BTC-30MAY26-50000-C</DialogDescription>
          </DialogHeader>
          <div className="grid grid-cols-2 gap-3">
            <div>
              <Label className="text-xs">Underlying</Label>
              <select value={form.underlyingSymbol} onChange={(e) => setForm({ ...form, underlyingSymbol: e.target.value })} className="w-full bg-muted/40 border border-border rounded-md px-3 py-2 text-sm">
                <option>BTC</option><option>ETH</option><option>SOL</option><option>BNB</option>
              </select>
            </div>
            <div>
              <Label className="text-xs">Type</Label>
              <select value={form.optionType} onChange={(e) => setForm({ ...form, optionType: e.target.value as any })} className="w-full bg-muted/40 border border-border rounded-md px-3 py-2 text-sm">
                <option value="call">Call</option><option value="put">Put</option>
              </select>
            </div>
            <div>
              <Label className="text-xs">Strike (USD)</Label>
              <Input type="number" value={form.strikePrice} onChange={(e) => setForm({ ...form, strikePrice: e.target.value })} placeholder="65000" />
            </div>
            <div>
              <Label className="text-xs">Expiry (UTC)</Label>
              <Input type="datetime-local" value={form.expiryAt} onChange={(e) => setForm({ ...form, expiryAt: e.target.value })} />
            </div>
            <div>
              <Label className="text-xs">IV %</Label>
              <Input type="number" value={form.ivBps / 100} onChange={(e) => setForm({ ...form, ivBps: Math.round(Number(e.target.value) * 100) })} />
            </div>
            <div>
              <Label className="text-xs">Risk-free rate %</Label>
              <Input type="number" value={form.riskFreeRateBps / 100} onChange={(e) => setForm({ ...form, riskFreeRateBps: Math.round(Number(e.target.value) * 100) })} />
            </div>
            <div>
              <Label className="text-xs">Contract size</Label>
              <Input type="number" step="0.01" value={form.contractSize} onChange={(e) => setForm({ ...form, contractSize: Number(e.target.value) })} />
            </div>
            <div>
              <Label className="text-xs">Min qty</Label>
              <Input type="number" step="0.01" value={form.minQty} onChange={(e) => setForm({ ...form, minQty: Number(e.target.value) })} />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setCreateOpen(false)}>Cancel</Button>
            <Button disabled={createMut.isPending || !form.strikePrice || !form.expiryAt} onClick={() => createMut.mutate()} data-testid="btn-create-confirm">
              {createMut.isPending ? "Creating…" : "Create"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
