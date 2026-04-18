import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Plus, Trash2, Pencil, Zap, Clock, CheckCircle2, RefreshCw, Settings } from "lucide-react";
import { useState, useMemo, useEffect } from "react";
import { useAuth } from "@/lib/auth";

type Pair = {
  id: number; symbol: string; futuresEnabled: boolean;
  fundingIntervalHours?: number; baseFundingRate?: string; fundingAutoCreate?: string;
  maxLeverage?: number; mmRate?: string;
};
type FundingRate = {
  id: number; pairId: number; rate: string; intervalHours: number; fundingTime: string; createdAt: string;
  source?: string; settled?: string; settledAt?: string | null; positionsAffected?: number; totalPaid?: string;
};
type EngineStatus = {
  fundingCreated: number; fundingSettled: number; totalSettlementValue: number;
  positionsLiquidated: number; positionsChecked: number;
  lastRiskAt: string | null; lastFundingAt: string | null; lastSettleAt: string | null;
  intervals: { funding: number; settle: number; risk: number };
};

function FundingForm({ initial, pairs, onSubmit }: { initial?: Partial<FundingRate>; pairs: Pair[]; onSubmit: (v: Partial<FundingRate>) => void }) {
  const [v, setV] = useState<Partial<FundingRate>>(initial || { intervalHours: 8, fundingTime: new Date(Date.now() + 8 * 3600_000).toISOString() });
  return (
    <div className="space-y-3">
      <div className="grid grid-cols-2 gap-3">
        <div><Label>Pair</Label>
          <Select value={v.pairId ? String(v.pairId) : ""} onValueChange={(p) => setV({ ...v, pairId: Number(p) })}>
            <SelectTrigger><SelectValue placeholder="Select pair" /></SelectTrigger>
            <SelectContent>{pairs.filter(p => p.futuresEnabled).map(p => <SelectItem key={p.id} value={String(p.id)}>{p.symbol}</SelectItem>)}</SelectContent>
          </Select>
        </div>
        <div><Label>Rate (decimal, e.g. 0.0001 = 0.01%)</Label><Input value={v.rate || ""} onChange={(e) => setV({ ...v, rate: e.target.value })} /></div>
        <div><Label>Interval (hours)</Label><Input type="number" value={v.intervalHours ?? 8} onChange={(e) => setV({ ...v, intervalHours: Number(e.target.value) })} /></div>
        <div><Label>Funding Time</Label><Input type="datetime-local" value={v.fundingTime ? new Date(v.fundingTime).toISOString().slice(0, 16) : ""} onChange={(e) => setV({ ...v, fundingTime: e.target.value })} /></div>
      </div>
      <Button className="w-full" onClick={() => onSubmit(v)}>Save</Button>
    </div>
  );
}

function PairConfigForm({ pair, onSave }: { pair: Pair; onSave: (v: Partial<Pair>) => void }) {
  const [v, setV] = useState<Partial<Pair>>({
    fundingIntervalHours: pair.fundingIntervalHours ?? 8,
    baseFundingRate: pair.baseFundingRate ?? "0.0001",
    fundingAutoCreate: pair.fundingAutoCreate ?? "true",
    maxLeverage: pair.maxLeverage ?? 100,
    mmRate: pair.mmRate ?? "0.005",
  });
  return (
    <div className="space-y-3">
      <div className="grid grid-cols-2 gap-3">
        <div><Label>Auto-create funding rates</Label>
          <Select value={v.fundingAutoCreate ?? "true"} onValueChange={(x) => setV({ ...v, fundingAutoCreate: x })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent><SelectItem value="true">Enabled</SelectItem><SelectItem value="false">Disabled (manual only)</SelectItem></SelectContent>
          </Select>
        </div>
        <div><Label>Interval (hours)</Label><Input type="number" value={v.fundingIntervalHours ?? 8} onChange={(e) => setV({ ...v, fundingIntervalHours: Number(e.target.value) })} /></div>
        <div><Label>Base funding rate</Label><Input value={v.baseFundingRate ?? ""} onChange={(e) => setV({ ...v, baseFundingRate: e.target.value })} /></div>
        <div><Label>Max Leverage (x)</Label><Input type="number" value={v.maxLeverage ?? 100} onChange={(e) => setV({ ...v, maxLeverage: Number(e.target.value) })} /></div>
        <div className="col-span-2"><Label>Maintenance Margin Rate (e.g. 0.005 = 0.5%)</Label><Input value={v.mmRate ?? ""} onChange={(e) => setV({ ...v, mmRate: e.target.value })} /></div>
      </div>
      <Button className="w-full" onClick={() => onSave(v)}>Save Pair Config</Button>
    </div>
  );
}

function Countdown({ to }: { to: string }) {
  const [now, setNow] = useState(Date.now());
  useEffect(() => { const i = setInterval(() => setNow(Date.now()), 1000); return () => clearInterval(i); }, []);
  const diff = new Date(to).getTime() - now;
  if (diff <= 0) return <span className="text-muted-foreground">due</span>;
  const h = Math.floor(diff / 3600_000);
  const m = Math.floor((diff % 3600_000) / 60_000);
  const s = Math.floor((diff % 60_000) / 1000);
  return <span className="font-mono text-xs">{h}h {m}m {s}s</span>;
}

export default function FundingRatesPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data: pairs = [] } = useQuery<Pair[]>({ queryKey: ["/admin/pairs"], queryFn: () => get<Pair[]>("/admin/pairs") });
  const { data = [] } = useQuery<FundingRate[]>({ queryKey: ["/admin/funding-rates"], queryFn: () => get<FundingRate[]>("/admin/funding-rates"), refetchInterval: 15000 });
  const { data: engine } = useQuery<EngineStatus>({ queryKey: ["/admin/futures-engine/status"], queryFn: () => get<EngineStatus>("/admin/futures-engine/status"), refetchInterval: 10000 });
  const [open, setOpen] = useState(false);
  const [edit, setEdit] = useState<FundingRate | null>(null);
  const [editPair, setEditPair] = useState<Pair | null>(null);
  const [filterPair, setFilterPair] = useState<string>("");

  const create = useMutation({ mutationFn: (v: Partial<FundingRate>) => post("/admin/funding-rates", v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/funding-rates"] }); setOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Partial<FundingRate> }) => patch(`/admin/funding-rates/${id}`, body), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/funding-rates"] }); setEdit(null); } });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/funding-rates/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/funding-rates"] }) });
  const updatePair = useMutation({ mutationFn: ({ id, body }: { id: number; body: Partial<Pair> }) => patch(`/admin/pairs/${id}`, body), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/pairs"] }); setEditPair(null); } });
  const runFunding = useMutation({ mutationFn: () => post<{ created: number; settled: { settled: number; totalValue: number } }>("/admin/futures-engine/run-funding", {}), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/funding-rates"] }); qc.invalidateQueries({ queryKey: ["/admin/futures-engine/status"] }); } });

  const sym = (id: number) => pairs.find(p => p.id === id)?.symbol || `#${id}`;
  const filtered = useMemo(() => filterPair ? data.filter(d => d.pairId === Number(filterPair)) : data, [data, filterPair]);
  const futuresPairs = pairs.filter(p => p.futuresEnabled);

  return (
    <div className="space-y-4">
      {/* Engine status */}
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <Card className="p-3">
          <div className="flex items-center gap-2 text-xs text-muted-foreground"><Zap className="w-4 h-4" />Auto-create</div>
          <div className="text-xl font-bold">{engine?.fundingCreated ?? 0}</div>
          <div className="text-[10px] text-muted-foreground">Last: {engine?.lastFundingAt ? new Date(engine.lastFundingAt).toLocaleTimeString("en-IN") : "—"}</div>
        </Card>
        <Card className="p-3">
          <div className="flex items-center gap-2 text-xs text-muted-foreground"><CheckCircle2 className="w-4 h-4" />Settled</div>
          <div className="text-xl font-bold">{engine?.fundingSettled ?? 0}</div>
          <div className="text-[10px] text-muted-foreground">Total ${(engine?.totalSettlementValue ?? 0).toFixed(2)}</div>
        </Card>
        <Card className="p-3">
          <div className="flex items-center gap-2 text-xs text-muted-foreground"><Clock className="w-4 h-4" />Risk checks</div>
          <div className="text-xl font-bold">{engine?.positionsChecked ?? 0}</div>
          <div className="text-[10px] text-muted-foreground">{engine?.positionsLiquidated ?? 0} liquidated total</div>
        </Card>
        <Card className="p-3 flex items-center justify-between">
          <div>
            <div className="text-xs text-muted-foreground">Manual run</div>
            <div className="text-[10px] text-muted-foreground">Force engine tick now</div>
          </div>
          {isAdmin && <Button size="sm" variant="outline" onClick={() => runFunding.mutate()} disabled={runFunding.isPending} data-testid="button-run-funding"><RefreshCw className="w-3 h-3 mr-1" />{runFunding.isPending ? "…" : "Run"}</Button>}
        </Card>
      </div>

      {/* Pair config */}
      <Card className="p-3">
        <div className="text-sm font-semibold mb-2">Futures Pair Risk Config ({futuresPairs.length})</div>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader><TableRow>
              <TableHead>Pair</TableHead><TableHead>Auto</TableHead><TableHead>Interval</TableHead>
              <TableHead>Base Rate</TableHead><TableHead>Max Lev</TableHead><TableHead>MM Rate</TableHead>
              {isAdmin && <TableHead></TableHead>}
            </TableRow></TableHeader>
            <TableBody>
              {futuresPairs.map(p => (
                <TableRow key={p.id} data-testid={`pair-cfg-${p.id}`}>
                  <TableCell className="font-bold">{p.symbol}</TableCell>
                  <TableCell>{p.fundingAutoCreate === "true" ? <Badge><Zap className="w-3 h-3 mr-1" />Auto</Badge> : <Badge variant="secondary">Manual</Badge>}</TableCell>
                  <TableCell>{p.fundingIntervalHours ?? 8}h</TableCell>
                  <TableCell className="tabular-nums">{Number(p.baseFundingRate ?? 0.0001).toFixed(6)}</TableCell>
                  <TableCell>{p.maxLeverage ?? 100}x</TableCell>
                  <TableCell className="tabular-nums">{(Number(p.mmRate ?? 0.005) * 100).toFixed(2)}%</TableCell>
                  {isAdmin && <TableCell className="text-right"><Button size="icon" variant="ghost" onClick={() => setEditPair(p)} data-testid={`button-cfg-${p.id}`}><Settings className="w-4 h-4" /></Button></TableCell>}
                </TableRow>
              ))}
              {futuresPairs.length === 0 && <TableRow><TableCell colSpan={isAdmin ? 7 : 6} className="text-center py-4 text-muted-foreground">No futures pairs. Enable a pair in Pairs admin page.</TableCell></TableRow>}
            </TableBody>
          </Table>
        </div>
      </Card>

      <div className="flex justify-between items-center gap-3">
        <div className="flex items-center gap-2">
          <Label className="text-xs">Pair filter:</Label>
          <Select value={filterPair} onValueChange={(v) => setFilterPair(v === "_all" ? "" : v)}>
            <SelectTrigger className="w-48"><SelectValue placeholder="All pairs" /></SelectTrigger>
            <SelectContent>
              <SelectItem value="_all">All pairs</SelectItem>
              {futuresPairs.map(p => <SelectItem key={p.id} value={String(p.id)}>{p.symbol}</SelectItem>)}
            </SelectContent>
          </Select>
        </div>
        <div className="text-sm text-muted-foreground">{filtered.length} entries</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Manual Rate</Button></DialogTrigger>
            <DialogContent aria-describedby={undefined}><DialogHeader><DialogTitle>Add manual funding rate</DialogTitle></DialogHeader>
              <FundingForm pairs={pairs} onSubmit={(v) => create.mutate(v)} />
            </DialogContent>
          </Dialog>
        )}
      </div>

      <Card>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader><TableRow>
              <TableHead>Pair</TableHead><TableHead>Source</TableHead><TableHead>Rate %</TableHead>
              <TableHead>Funding Time</TableHead><TableHead>Countdown</TableHead>
              <TableHead>Status</TableHead><TableHead className="text-right">Total Paid</TableHead>
              {isAdmin && <TableHead></TableHead>}
            </TableRow></TableHeader>
            <TableBody>
              {filtered.length === 0 && <TableRow><TableCell colSpan={isAdmin ? 8 : 7} className="text-center text-muted-foreground py-6">No funding rates yet</TableCell></TableRow>}
              {filtered.map((f) => {
                const pct = (Number(f.rate) * 100).toFixed(4);
                const due = new Date(f.fundingTime).getTime() <= Date.now();
                return (
                  <TableRow key={f.id} data-testid={`fr-${f.id}`}>
                    <TableCell className="font-bold">{sym(f.pairId)}</TableCell>
                    <TableCell>{f.source === "auto" ? <Badge><Zap className="w-3 h-3 mr-1" />auto</Badge> : <Badge variant="secondary">manual</Badge>}</TableCell>
                    <TableCell className={Number(f.rate) >= 0 ? "text-green-500" : "text-red-500"}>{pct}%</TableCell>
                    <TableCell className="text-xs">{new Date(f.fundingTime).toLocaleString("en-IN")}</TableCell>
                    <TableCell>{f.settled === "true" ? <span className="text-xs text-muted-foreground">—</span> : <Countdown to={f.fundingTime} />}</TableCell>
                    <TableCell>{f.settled === "true" ? <Badge variant="default">settled</Badge> : due ? <Badge variant="outline" className="border-yellow-500 text-yellow-500">pending</Badge> : <Badge variant="secondary">scheduled</Badge>}</TableCell>
                    <TableCell className="text-right tabular-nums text-xs">{f.settled === "true" ? `$${Number(f.totalPaid ?? 0).toFixed(2)} (${f.positionsAffected ?? 0} pos)` : "—"}</TableCell>
                    {isAdmin && (
                      <TableCell className="text-right space-x-1">
                        <Button size="icon" variant="ghost" onClick={() => setEdit(f)}><Pencil className="w-4 h-4" /></Button>
                        <Button size="icon" variant="ghost" onClick={() => { if (confirm("Delete?")) remove.mutate(f.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button>
                      </TableCell>
                    )}
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </div>
      </Card>

      {edit && (
        <Dialog open={!!edit} onOpenChange={(o) => !o && setEdit(null)}>
          <DialogContent aria-describedby={undefined}><DialogHeader><DialogTitle>Edit funding rate</DialogTitle></DialogHeader>
            <FundingForm initial={edit} pairs={pairs} onSubmit={(v) => update.mutate({ id: edit.id, body: v })} />
          </DialogContent>
        </Dialog>
      )}
      {editPair && (
        <Dialog open={!!editPair} onOpenChange={(o) => !o && setEditPair(null)}>
          <DialogContent aria-describedby={undefined}><DialogHeader><DialogTitle>Pair config: {editPair.symbol}</DialogTitle></DialogHeader>
            <PairConfigForm pair={editPair} onSave={(v) => updatePair.mutate({ id: editPair.id, body: v })} />
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
