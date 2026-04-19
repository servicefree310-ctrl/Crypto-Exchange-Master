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
import { Plus, Trash2, Pencil } from "lucide-react";
import { useState, useEffect } from "react";
import { useAuth } from "@/lib/auth";

type Coin = { id: number; symbol: string };
type Pair = {
  id: number; symbol: string; baseCoinId: number; quoteCoinId: number;
  minQty: string; maxQty: string; pricePrecision: number; qtyPrecision: number;
  takerFee: string; makerFee: string; status: string;
  tradingEnabled: boolean; futuresEnabled: boolean;
  tradingStartAt: string | null; futuresStartAt: string | null;
  lastPrice: string; volume24h: string; change24h: string; description: string | null;
  high24h?: string; low24h?: string; quoteVolume24h?: string; trades24h?: number; statsOverride?: boolean;
};

function fmtCountdown(target: string | null): string {
  if (!target) return "—";
  const ms = new Date(target).getTime() - Date.now();
  if (ms <= 0) return "Live";
  const s = Math.floor(ms / 1000);
  const d = Math.floor(s / 86400);
  const h = Math.floor((s % 86400) / 3600);
  const m = Math.floor((s % 3600) / 60);
  const sec = s % 60;
  if (d > 0) return `${d}d ${h}h ${m}m`;
  if (h > 0) return `${h}h ${m}m ${sec}s`;
  return `${m}m ${sec}s`;
}

function PairForm({ initial, coins, onSubmit }: { initial?: Partial<Pair>; coins: Coin[]; onSubmit: (v: Partial<Pair>) => void }) {
  const [v, setV] = useState<Partial<Pair>>(initial || {
    pricePrecision: 2, qtyPrecision: 4, takerFee: "0.001", makerFee: "0.001", status: "active",
    tradingEnabled: true, futuresEnabled: false,
  });
  return (
    <div className="space-y-3 max-h-[70vh] overflow-y-auto pr-1">
      <div className="grid grid-cols-2 gap-3">
        <div><Label>Base Coin</Label>
          <Select value={v.baseCoinId ? String(v.baseCoinId) : ""} onValueChange={(c) => setV({ ...v, baseCoinId: Number(c) })}>
            <SelectTrigger><SelectValue placeholder="Select" /></SelectTrigger>
            <SelectContent>{coins.map((c) => <SelectItem key={c.id} value={String(c.id)}>{c.symbol}</SelectItem>)}</SelectContent>
          </Select>
        </div>
        <div><Label>Quote Coin</Label>
          <Select value={v.quoteCoinId ? String(v.quoteCoinId) : ""} onValueChange={(c) => setV({ ...v, quoteCoinId: Number(c) })}>
            <SelectTrigger><SelectValue placeholder="Select" /></SelectTrigger>
            <SelectContent>{coins.map((c) => <SelectItem key={c.id} value={String(c.id)}>{c.symbol}</SelectItem>)}</SelectContent>
          </Select>
        </div>
        <div><Label>Min Qty</Label><Input value={v.minQty || "0"} onChange={(e) => setV({ ...v, minQty: e.target.value })} /></div>
        <div><Label>Max Qty</Label><Input value={v.maxQty || "0"} onChange={(e) => setV({ ...v, maxQty: e.target.value })} /></div>
        <div><Label>Price Precision</Label><Input type="number" value={v.pricePrecision ?? 2} onChange={(e) => setV({ ...v, pricePrecision: Number(e.target.value) })} /></div>
        <div><Label>Qty Precision</Label><Input type="number" value={v.qtyPrecision ?? 4} onChange={(e) => setV({ ...v, qtyPrecision: Number(e.target.value) })} /></div>
        <div><Label>Taker Fee (decimal)</Label><Input value={v.takerFee || "0.001"} onChange={(e) => setV({ ...v, takerFee: e.target.value })} /></div>
        <div><Label>Maker Fee (decimal)</Label><Input value={v.makerFee || "0.001"} onChange={(e) => setV({ ...v, makerFee: e.target.value })} /></div>
        <div><Label>Last Price</Label><Input value={v.lastPrice ?? ""} onChange={(e) => setV({ ...v, lastPrice: e.target.value })} placeholder="auto" /></div>
        <div><Label>24h Change %</Label><Input value={v.change24h ?? ""} onChange={(e) => setV({ ...v, change24h: e.target.value })} placeholder="auto" /></div>
        <div><Label>24h High</Label><Input value={v.high24h ?? ""} onChange={(e) => setV({ ...v, high24h: e.target.value })} placeholder="auto" /></div>
        <div><Label>24h Low</Label><Input value={v.low24h ?? ""} onChange={(e) => setV({ ...v, low24h: e.target.value })} placeholder="auto" /></div>
        <div><Label>24h Volume (Base)</Label><Input value={v.volume24h ?? ""} onChange={(e) => setV({ ...v, volume24h: e.target.value })} placeholder="auto" /></div>
        <div><Label>24h Volume (Quote)</Label><Input value={v.quoteVolume24h ?? ""} onChange={(e) => setV({ ...v, quoteVolume24h: e.target.value })} placeholder="auto" /></div>
        <div><Label>24h Trades Count</Label><Input type="number" value={v.trades24h ?? 0} onChange={(e) => setV({ ...v, trades24h: Number(e.target.value) })} placeholder="auto" /></div>
        <div><Label>Spot Trading Start</Label><Input type="datetime-local" value={v.tradingStartAt ? new Date(v.tradingStartAt).toISOString().slice(0,16) : ""} onChange={(e) => setV({ ...v, tradingStartAt: e.target.value || null })} /></div>
        <div><Label>Futures Start</Label><Input type="datetime-local" value={v.futuresStartAt ? new Date(v.futuresStartAt).toISOString().slice(0,16) : ""} onChange={(e) => setV({ ...v, futuresStartAt: e.target.value || null })} /></div>
        <div><Label>Status</Label>
          <Select value={v.status || "active"} onValueChange={(s) => setV({ ...v, status: s })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="active">Active</SelectItem>
              <SelectItem value="paused">Paused</SelectItem>
              <SelectItem value="delisted">Delisted</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div className="col-span-2"><Label>Description</Label>
          <textarea className="w-full rounded-md border bg-background px-3 py-2 text-sm min-h-[60px]" value={v.description || ""} onChange={(e) => setV({ ...v, description: e.target.value })} />
        </div>
      </div>
      <div className="flex gap-4 pt-2 flex-wrap">
        <label className="flex items-center gap-2"><Switch checked={v.tradingEnabled} onCheckedChange={(c) => setV({ ...v, tradingEnabled: c })} /> Spot Enabled</label>
        <label className="flex items-center gap-2"><Switch checked={v.futuresEnabled} onCheckedChange={(c) => setV({ ...v, futuresEnabled: c })} /> Futures Enabled</label>
        <label className="flex items-center gap-2"><Switch checked={!!v.statsOverride} onCheckedChange={(c) => setV({ ...v, statsOverride: c })} /> Manual Stats (lock auto-recompute)</label>
      </div>
      <div className="text-xs text-muted-foreground">Tip: Stats (high/low/volume/change) auto-recompute every 30s from real trades. Enable "Manual Stats" to freeze your custom values.</div>
      <Button className="w-full" onClick={() => onSubmit(v)}>Save</Button>
    </div>
  );
}

export default function PairsPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data: coins = [] } = useQuery<Coin[]>({ queryKey: ["/admin/coins"], queryFn: () => get<Coin[]>("/admin/coins") });
  const { data = [] } = useQuery<Pair[]>({ queryKey: ["/admin/pairs"], queryFn: () => get<Pair[]>("/admin/pairs") });
  const [open, setOpen] = useState(false);
  const [edit, setEdit] = useState<Pair | null>(null);
  const [, setTick] = useState(0);
  useEffect(() => { const t = setInterval(() => setTick(x => x + 1), 1000); return () => clearInterval(t); }, []);

  const create = useMutation({
    mutationFn: (v: Partial<Pair>) => {
      const b = coins.find((c) => c.id === v.baseCoinId)?.symbol || "";
      const q = coins.find((c) => c.id === v.quoteCoinId)?.symbol || "";
      return post("/admin/pairs", { ...v, symbol: b + q });
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/pairs"] }); setOpen(false); },
  });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Partial<Pair> }) => patch(`/admin/pairs/${id}`, body), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/pairs"] }); setEdit(null); } });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/pairs/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/pairs"] }) });

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div className="text-sm text-muted-foreground">{data.length} pairs</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Pair</Button></DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader><DialogTitle>Add trading pair</DialogTitle></DialogHeader>
              <PairForm coins={coins} onSubmit={(v) => create.mutate(v)} />
            </DialogContent>
          </Dialog>
        )}
      </div>
      <Card>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader><TableRow>
              <TableHead>Symbol</TableHead><TableHead>Last</TableHead><TableHead>24h%</TableHead>
              <TableHead>Vol 24h</TableHead><TableHead>Spot</TableHead><TableHead>Futures</TableHead>
              <TableHead>Spot Start</TableHead><TableHead>Futures Start</TableHead>
              <TableHead>Status</TableHead>{isAdmin && <TableHead></TableHead>}
            </TableRow></TableHeader>
            <TableBody>
              {data.map((p) => (
                <TableRow key={p.id}>
                  <TableCell className="font-bold">{p.symbol}</TableCell>
                  <TableCell className="tabular-nums">{Number(p.lastPrice).toLocaleString("en-US", { maximumFractionDigits: 6 })}</TableCell>
                  <TableCell className={Number(p.change24h) >= 0 ? "text-green-500" : "text-red-500"}>{Number(p.change24h).toFixed(2)}%</TableCell>
                  <TableCell className="tabular-nums text-xs">{Number(p.volume24h).toLocaleString("en-US", { maximumFractionDigits: 2 })}</TableCell>
                  <TableCell>
                    {isAdmin
                      ? <Switch checked={p.tradingEnabled} onCheckedChange={(c) => update.mutate({ id: p.id, body: { tradingEnabled: c } })} />
                      : <Badge variant={p.tradingEnabled ? "default" : "secondary"}>{p.tradingEnabled ? "On" : "Off"}</Badge>}
                  </TableCell>
                  <TableCell>
                    {isAdmin
                      ? <Switch checked={p.futuresEnabled} onCheckedChange={(c) => update.mutate({ id: p.id, body: { futuresEnabled: c } })} />
                      : <Badge variant={p.futuresEnabled ? "default" : "secondary"}>{p.futuresEnabled ? "On" : "Off"}</Badge>}
                  </TableCell>
                  <TableCell className="text-xs">{fmtCountdown(p.tradingStartAt)}</TableCell>
                  <TableCell className="text-xs">{fmtCountdown(p.futuresStartAt)}</TableCell>
                  <TableCell><Badge variant={p.status === "active" ? "default" : "secondary"}>{p.status}</Badge></TableCell>
                  {isAdmin && (
                    <TableCell className="text-right space-x-1">
                      <Button size="icon" variant="ghost" onClick={() => setEdit(p)}><Pencil className="w-4 h-4" /></Button>
                      <Button size="icon" variant="ghost" onClick={() => { if (confirm("Delete?")) remove.mutate(p.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button>
                    </TableCell>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </Card>
      {edit && (
        <Dialog open={!!edit} onOpenChange={(o) => !o && setEdit(null)}>
          <DialogContent className="max-w-2xl">
            <DialogHeader><DialogTitle>Edit {edit.symbol}</DialogTitle></DialogHeader>
            <PairForm initial={edit} coins={coins} onSubmit={(v) => update.mutate({ id: edit.id, body: v })} />
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
