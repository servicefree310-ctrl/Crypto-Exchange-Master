import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Plus, Trash2, Pencil, Bot as BotIcon, Activity, Search } from "lucide-react";
import { useState, useMemo } from "react";

type Pair = { id: number; symbol: string };
type Bot = {
  id: number; pairId: number; enabled: boolean;
  spreadBps: number; levels: number; priceStepBps: number;
  orderSize: string; refreshSec: number; maxOrderAgeSec: number;
  fillOnCross: boolean; spotEnabled: boolean; futuresEnabled: boolean;
  startAt: string | null; status: string; lastRunAt: string | null; lastError: string | null;
};

function toLocalDtInput(iso: string | null | undefined): string {
  if (!iso) return "";
  const d = new Date(iso);
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

function BotForm({ initial, pairs, takenPairIds, onSubmit }: { initial?: Partial<Bot>; pairs: Pair[]; takenPairIds: number[]; onSubmit: (v: Partial<Bot>) => void }) {
  const [v, setV] = useState<Partial<Bot>>(initial || {
    enabled: false, spreadBps: 20, levels: 5, priceStepBps: 10,
    orderSize: "0.01", refreshSec: 8, maxOrderAgeSec: 60, fillOnCross: true,
    spotEnabled: true, futuresEnabled: false, startAt: null,
  });
  const [pairSearch, setPairSearch] = useState("");
  const isEdit = !!initial?.id;
  const basePairs = isEdit ? pairs : pairs.filter(p => !takenPairIds.includes(p.id));
  const q = pairSearch.trim().toUpperCase();
  const availablePairs = q ? basePairs.filter(p => p.symbol.toUpperCase().includes(q)) : basePairs;
  const startAtLocal = toLocalDtInput(v.startAt as any);
  return (
    <div className="space-y-3 max-h-[70vh] overflow-y-auto pr-1">
      <div><Label>Pair</Label>
        {!isEdit && (
          <Input placeholder="Search pair (e.g. BTC, USDT)" value={pairSearch} onChange={(e) => setPairSearch(e.target.value)} className="mb-2" />
        )}
        <Select value={v.pairId ? String(v.pairId) : ""} onValueChange={(c) => setV({ ...v, pairId: Number(c) })} disabled={isEdit}>
          <SelectTrigger><SelectValue placeholder={availablePairs.length ? "Select trading pair" : "No matching pair"} /></SelectTrigger>
          <SelectContent>
            {availablePairs.length === 0
              ? <div className="px-3 py-2 text-sm text-muted-foreground">No pairs match "{pairSearch}"</div>
              : availablePairs.map((p) => <SelectItem key={p.id} value={String(p.id)}>{p.symbol}</SelectItem>)}
          </SelectContent>
        </Select>
        {!isEdit && <p className="text-xs text-muted-foreground mt-1">{availablePairs.length} of {basePairs.length} pairs without bot</p>}
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div className="flex items-center gap-2 col-span-2 p-3 border rounded">
          <Switch checked={!!v.enabled} onCheckedChange={(c) => setV({ ...v, enabled: c })} />
          <Label>Bot Enabled (master switch)</Label>
        </div>
        <div className="flex items-center gap-2 p-3 border rounded">
          <Switch checked={!!v.spotEnabled} onCheckedChange={(c) => setV({ ...v, spotEnabled: c })} />
          <Label>Spot</Label>
        </div>
        <div className="flex items-center gap-2 p-3 border rounded">
          <Switch checked={!!v.futuresEnabled} onCheckedChange={(c) => setV({ ...v, futuresEnabled: c })} />
          <Label>Futures</Label>
        </div>
        <div className="col-span-2"><Label>Start At (leave blank to start immediately)</Label>
          <div className="flex gap-2">
            <Input type="datetime-local" value={startAtLocal} onChange={(e) => setV({ ...v, startAt: e.target.value ? new Date(e.target.value).toISOString() : null })} />
            {v.startAt && <Button variant="ghost" size="sm" onClick={() => setV({ ...v, startAt: null })}>Clear</Button>}
          </div>
          <p className="text-xs text-muted-foreground mt-1">Bot will idle until this time, then auto-start.</p>
        </div>
        <div className="flex items-center gap-2 col-span-2 p-3 border rounded">
          <Switch checked={!!v.fillOnCross} onCheckedChange={(c) => setV({ ...v, fillOnCross: c })} />
          <Label>Auto-fill orders when price crosses</Label>
        </div>
        <div><Label>Spread (bps)</Label><Input type="number" value={v.spreadBps ?? 20} onChange={(e) => setV({ ...v, spreadBps: Number(e.target.value) })} />
          <p className="text-xs text-muted-foreground mt-1">20 = 0.2% from mid</p></div>
        <div><Label>Levels per side</Label><Input type="number" value={v.levels ?? 5} onChange={(e) => setV({ ...v, levels: Number(e.target.value) })} /></div>
        <div><Label>Price step (bps)</Label><Input type="number" value={v.priceStepBps ?? 10} onChange={(e) => setV({ ...v, priceStepBps: Number(e.target.value) })} /></div>
        <div><Label>Order size</Label><Input value={v.orderSize ?? "0.01"} onChange={(e) => setV({ ...v, orderSize: e.target.value })} /></div>
        <div><Label>Refresh interval (sec)</Label><Input type="number" value={v.refreshSec ?? 8} onChange={(e) => setV({ ...v, refreshSec: Number(e.target.value) })} /></div>
        <div><Label>Max order age (sec)</Label><Input type="number" value={v.maxOrderAgeSec ?? 60} onChange={(e) => setV({ ...v, maxOrderAgeSec: Number(e.target.value) })} /></div>
      </div>
      <Button onClick={() => onSubmit(v)} className="w-full">{isEdit ? "Save Bot" : "Create Bot"}</Button>
    </div>
  );
}

export default function BotsPage() {
  const qc = useQueryClient();
  const { data: bots = [] } = useQuery<Bot[]>({ queryKey: ["bots"], queryFn: () => get("/admin/bots"), refetchInterval: 5000 });
  const { data: pairs = [] } = useQuery<Pair[]>({ queryKey: ["pairs"], queryFn: () => get("/admin/pairs") });
  const [createOpen, setCreateOpen] = useState(false);
  const [editing, setEditing] = useState<Bot | null>(null);
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const inv = () => qc.invalidateQueries({ queryKey: ["bots"] });
  const create = useMutation({ mutationFn: (v: Partial<Bot>) => post("/admin/bots", v), onSuccess: () => { inv(); setCreateOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, v }: { id: number; v: Partial<Bot> }) => patch(`/admin/bots/${id}`, v), onSuccess: () => { inv(); setEditing(null); } });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/bots/${id}`), onSuccess: inv });
  const toggle = useMutation({ mutationFn: ({ id, enabled }: { id: number; enabled: boolean }) => patch(`/admin/bots/${id}`, { enabled }), onSuccess: inv });

  const pairById = useMemo(() => new Map(pairs.map(p => [p.id, p.symbol])), [pairs]);
  const takenPairIds = bots.map(b => b.pairId);

  const filteredBots = useMemo(() => {
    const q = search.trim().toUpperCase();
    return bots.filter((b) => {
      if (q) {
        const sym = (pairById.get(b.pairId) || "").toUpperCase();
        if (!sym.includes(q)) return false;
      }
      if (statusFilter === "running" && b.status !== "running") return false;
      if (statusFilter === "not_running" && b.status === "running") return false;
      if (statusFilter === "scheduled" && b.status !== "scheduled") return false;
      if (statusFilter === "error" && b.status !== "error") return false;
      if (statusFilter === "disabled" && b.enabled) return false;
      return true;
    });
  }, [bots, search, statusFilter, pairById]);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold flex items-center gap-2"><BotIcon className="size-6" /> Market-Maker Bots</h1>
          <p className="text-sm text-muted-foreground">One bot per pair. Auto-cancels stale orders, auto-fills on price cross. Configure spot/futures and start time per bot.</p>
        </div>
        <Dialog open={createOpen} onOpenChange={setCreateOpen}>
          <DialogTrigger asChild><Button><Plus className="size-4 mr-1" /> Add Bot</Button></DialogTrigger>
          <DialogContent className="max-w-xl">
            <DialogHeader><DialogTitle>New Market Bot</DialogTitle></DialogHeader>
            <BotForm pairs={pairs} takenPairIds={takenPairIds} onSubmit={(v) => create.mutate(v)} />
          </DialogContent>
        </Dialog>
      </div>

      <Card className="p-3">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
          <div className="md:col-span-2">
            <Label className="text-xs">Search pair</Label>
            <div className="relative">
              <Search className="absolute left-2 top-2.5 size-4 text-muted-foreground" />
              <Input className="pl-8" placeholder="e.g. SOL, USDT, BTC" value={search} onChange={(e) => setSearch(e.target.value)} />
            </div>
          </div>
          <div>
            <Label className="text-xs">Status</Label>
            <Select value={statusFilter} onValueChange={setStatusFilter}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All bots</SelectItem>
                <SelectItem value="running">Running</SelectItem>
                <SelectItem value="not_running">Not running</SelectItem>
                <SelectItem value="scheduled">Scheduled (waiting start)</SelectItem>
                <SelectItem value="error">Error</SelectItem>
                <SelectItem value="disabled">Disabled (switch off)</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
        <p className="text-xs text-muted-foreground mt-2">Showing {filteredBots.length} of {bots.length} bots</p>
      </Card>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Pair</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Enabled</TableHead>
              <TableHead>Mode</TableHead>
              <TableHead>Start At</TableHead>
              <TableHead>Spread</TableHead>
              <TableHead>Levels</TableHead>
              <TableHead>Order Size</TableHead>
              <TableHead>Last Run</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {filteredBots.length === 0 ? (
              <TableRow><TableCell colSpan={10} className="text-center text-muted-foreground py-8">{bots.length === 0 ? "No bots configured. Click \"Add Bot\" to enable market-making." : "No bots match the filter."}</TableCell></TableRow>
            ) : filteredBots.map((b) => {
              const ago = b.lastRunAt ? Math.floor((Date.now() - new Date(b.lastRunAt).getTime()) / 1000) : null;
              const statusColor =
                b.status === "running" ? "bg-emerald-500"
                : b.status === "scheduled" ? "bg-blue-500"
                : b.status === "error" ? "bg-red-500"
                : b.status === "no_price" ? "bg-amber-500"
                : b.status === "disabled" ? "bg-zinc-700"
                : "bg-zinc-500";
              const startMs = b.startAt ? new Date(b.startAt).getTime() : 0;
              const startsIn = startMs > Date.now() ? Math.ceil((startMs - Date.now()) / 1000) : 0;
              return (
                <TableRow key={b.id}>
                  <TableCell className="font-mono font-bold">{pairById.get(b.pairId) || `#${b.pairId}`}</TableCell>
                  <TableCell>
                    <Badge className={statusColor}><Activity className="size-3 mr-1" />{b.status}</Badge>
                    {b.lastError && <div className="text-xs text-red-500 mt-1 max-w-[200px] truncate" title={b.lastError}>{b.lastError}</div>}
                  </TableCell>
                  <TableCell><Switch checked={b.enabled} onCheckedChange={(c) => toggle.mutate({ id: b.id, enabled: c })} /></TableCell>
                  <TableCell className="space-x-1">
                    {b.spotEnabled && <Badge variant="outline" className="border-emerald-500 text-emerald-500">Spot</Badge>}
                    {b.futuresEnabled && <Badge variant="outline" className="border-purple-500 text-purple-500">Futures</Badge>}
                    {!b.spotEnabled && !b.futuresEnabled && <Badge variant="outline">—</Badge>}
                  </TableCell>
                  <TableCell className="text-xs">
                    {!b.startAt ? <span className="text-muted-foreground">Immediate</span>
                      : startsIn > 0 ? <span className="text-blue-500">in {startsIn > 3600 ? `${Math.floor(startsIn / 3600)}h ${Math.floor((startsIn % 3600) / 60)}m` : `${Math.floor(startsIn / 60)}m ${startsIn % 60}s`}</span>
                      : <span className="text-muted-foreground">{new Date(b.startAt).toLocaleString()}</span>}
                  </TableCell>
                  <TableCell className="tabular-nums">{(b.spreadBps / 100).toFixed(2)}%</TableCell>
                  <TableCell className="tabular-nums">{b.levels}/side</TableCell>
                  <TableCell className="tabular-nums">{Number(b.orderSize).toFixed(4)}</TableCell>
                  <TableCell className="text-xs text-muted-foreground">{ago == null ? "—" : `${ago}s ago`}</TableCell>
                  <TableCell className="text-right space-x-1">
                    <Button size="icon" variant="ghost" onClick={() => setEditing(b)}><Pencil className="size-4" /></Button>
                    <Button size="icon" variant="ghost" onClick={() => { if (confirm(`Delete bot for ${pairById.get(b.pairId)}?`)) remove.mutate(b.id); }}><Trash2 className="size-4" /></Button>
                  </TableCell>
                </TableRow>
              );
            })}
          </TableBody>
        </Table>
      </Card>

      <Dialog open={!!editing} onOpenChange={(o) => !o && setEditing(null)}>
        <DialogContent className="max-w-xl">
          <DialogHeader><DialogTitle>Edit Bot — {editing && pairById.get(editing.pairId)}</DialogTitle></DialogHeader>
          {editing && <BotForm initial={editing} pairs={pairs} takenPairIds={takenPairIds} onSubmit={(v) => update.mutate({ id: editing.id, v })} />}
        </DialogContent>
      </Dialog>
    </div>
  );
}
