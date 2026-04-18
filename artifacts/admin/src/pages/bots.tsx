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
import { Plus, Trash2, Pencil, Bot as BotIcon, Activity } from "lucide-react";
import { useState } from "react";

type Pair = { id: number; symbol: string };
type Bot = {
  id: number; pairId: number; enabled: boolean;
  spreadBps: number; levels: number; priceStepBps: number;
  orderSize: string; refreshSec: number; maxOrderAgeSec: number;
  fillOnCross: boolean; status: string; lastRunAt: string | null; lastError: string | null;
};

function BotForm({ initial, pairs, takenPairIds, onSubmit }: { initial?: Partial<Bot>; pairs: Pair[]; takenPairIds: number[]; onSubmit: (v: Partial<Bot>) => void }) {
  const [v, setV] = useState<Partial<Bot>>(initial || {
    enabled: false, spreadBps: 20, levels: 5, priceStepBps: 10,
    orderSize: "0.01", refreshSec: 8, maxOrderAgeSec: 60, fillOnCross: true,
  });
  const [pairSearch, setPairSearch] = useState("");
  const isEdit = !!initial?.id;
  const basePairs = isEdit ? pairs : pairs.filter(p => !takenPairIds.includes(p.id));
  const q = pairSearch.trim().toUpperCase();
  const availablePairs = q ? basePairs.filter(p => p.symbol.toUpperCase().includes(q)) : basePairs;
  return (
    <div className="space-y-3">
      <div><Label>Pair</Label>
        {!isEdit && (
          <Input
            placeholder="Search pair (e.g. BTC, USDT)"
            value={pairSearch}
            onChange={(e) => setPairSearch(e.target.value)}
            className="mb-2"
          />
        )}
        <Select value={v.pairId ? String(v.pairId) : ""} onValueChange={(c) => setV({ ...v, pairId: Number(c) })} disabled={isEdit}>
          <SelectTrigger><SelectValue placeholder={availablePairs.length ? "Select trading pair" : "No matching pair"} /></SelectTrigger>
          <SelectContent>
            {availablePairs.length === 0
              ? <div className="px-3 py-2 text-sm text-muted-foreground">No pairs match "{pairSearch}"</div>
              : availablePairs.map((p) => <SelectItem key={p.id} value={String(p.id)}>{p.symbol}</SelectItem>)}
          </SelectContent>
        </Select>
        {!isEdit && <p className="text-xs text-muted-foreground mt-1">{availablePairs.length} of {basePairs.length} available pairs</p>}
      </div>
      <div className="grid grid-cols-2 gap-3">
        <div className="flex items-center gap-2 col-span-2 p-3 border rounded">
          <Switch checked={!!v.enabled} onCheckedChange={(c) => setV({ ...v, enabled: c })} />
          <Label>Bot Enabled (auto-create orders)</Label>
        </div>
        <div className="flex items-center gap-2 col-span-2 p-3 border rounded">
          <Switch checked={!!v.fillOnCross} onCheckedChange={(c) => setV({ ...v, fillOnCross: c })} />
          <Label>Auto-fill orders when price crosses</Label>
        </div>
        <div><Label>Spread (bps)</Label><Input type="number" value={v.spreadBps ?? 20} onChange={(e) => setV({ ...v, spreadBps: Number(e.target.value) })} />
          <p className="text-xs text-muted-foreground mt-1">Distance between best bid & ask. 20 = 0.2%</p></div>
        <div><Label>Levels per side</Label><Input type="number" value={v.levels ?? 5} onChange={(e) => setV({ ...v, levels: Number(e.target.value) })} />
          <p className="text-xs text-muted-foreground mt-1">Number of buy & sell orders</p></div>
        <div><Label>Price step (bps)</Label><Input type="number" value={v.priceStepBps ?? 10} onChange={(e) => setV({ ...v, priceStepBps: Number(e.target.value) })} />
          <p className="text-xs text-muted-foreground mt-1">Gap between levels. 10 = 0.1%</p></div>
        <div><Label>Order size</Label><Input value={v.orderSize ?? "0.01"} onChange={(e) => setV({ ...v, orderSize: e.target.value })} />
          <p className="text-xs text-muted-foreground mt-1">Qty per order in base coin</p></div>
        <div><Label>Refresh interval (sec)</Label><Input type="number" value={v.refreshSec ?? 8} onChange={(e) => setV({ ...v, refreshSec: Number(e.target.value) })} /></div>
        <div><Label>Max order age (sec)</Label><Input type="number" value={v.maxOrderAgeSec ?? 60} onChange={(e) => setV({ ...v, maxOrderAgeSec: Number(e.target.value) })} />
          <p className="text-xs text-muted-foreground mt-1">Cancel orders older than this</p></div>
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
  const inv = () => qc.invalidateQueries({ queryKey: ["bots"] });
  const create = useMutation({ mutationFn: (v: Partial<Bot>) => post("/admin/bots", v), onSuccess: () => { inv(); setCreateOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, v }: { id: number; v: Partial<Bot> }) => patch(`/admin/bots/${id}`, v), onSuccess: () => { inv(); setEditing(null); } });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/bots/${id}`), onSuccess: inv });
  const toggle = useMutation({ mutationFn: ({ id, enabled }: { id: number; enabled: boolean }) => patch(`/admin/bots/${id}`, { enabled }), onSuccess: inv });

  const pairById = new Map(pairs.map(p => [p.id, p.symbol]));
  const takenPairIds = bots.map(b => b.pairId);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold flex items-center gap-2"><BotIcon className="size-6" /> Market-Maker Bots</h1>
          <p className="text-sm text-muted-foreground">Automated order placement around live mid price. Bot orders auto-cancel when stale and auto-fill when price crosses.</p>
        </div>
        <Dialog open={createOpen} onOpenChange={setCreateOpen}>
          <DialogTrigger asChild><Button><Plus className="size-4 mr-1" /> Add Bot</Button></DialogTrigger>
          <DialogContent className="max-w-xl">
            <DialogHeader><DialogTitle>New Market Bot</DialogTitle></DialogHeader>
            <BotForm pairs={pairs} takenPairIds={takenPairIds} onSubmit={(v) => create.mutate(v)} />
          </DialogContent>
        </Dialog>
      </div>

      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Pair</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>Enabled</TableHead>
              <TableHead>Spread</TableHead>
              <TableHead>Levels</TableHead>
              <TableHead>Order Size</TableHead>
              <TableHead>Refresh</TableHead>
              <TableHead>Last Run</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {bots.length === 0 ? (
              <TableRow><TableCell colSpan={9} className="text-center text-muted-foreground py-8">No bots configured. Click "Add Bot" to enable market-making on a pair.</TableCell></TableRow>
            ) : bots.map((b) => {
              const ago = b.lastRunAt ? Math.floor((Date.now() - new Date(b.lastRunAt).getTime()) / 1000) : null;
              const statusColor = b.status === "running" ? "bg-emerald-500" : b.status === "error" ? "bg-red-500" : b.status === "no_price" ? "bg-amber-500" : "bg-zinc-500";
              return (
                <TableRow key={b.id}>
                  <TableCell className="font-mono font-bold">{pairById.get(b.pairId) || `#${b.pairId}`}</TableCell>
                  <TableCell><Badge className={statusColor}><Activity className="size-3 mr-1" />{b.status}</Badge>{b.lastError && <div className="text-xs text-red-500 mt-1 max-w-[200px] truncate" title={b.lastError}>{b.lastError}</div>}</TableCell>
                  <TableCell><Switch checked={b.enabled} onCheckedChange={(c) => toggle.mutate({ id: b.id, enabled: c })} /></TableCell>
                  <TableCell className="tabular-nums">{(b.spreadBps / 100).toFixed(2)}%</TableCell>
                  <TableCell className="tabular-nums">{b.levels}/side</TableCell>
                  <TableCell className="tabular-nums">{Number(b.orderSize).toFixed(4)}</TableCell>
                  <TableCell className="tabular-nums">{b.refreshSec}s</TableCell>
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
