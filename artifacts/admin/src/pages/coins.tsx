import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Plus, Trash2, Pencil, Search } from "lucide-react";
import { useState, useMemo } from "react";
import { useAuth } from "@/lib/auth";

type Coin = {
  id: number; symbol: string; name: string; type: string; decimals: number;
  logoUrl: string | null; description: string | null; status: string; isListed: boolean;
  listingAt: string | null; currentPrice: string; change24h: string;
  binanceSymbol: string | null; priceSource: string; manualPrice: string | null; infoUrl: string | null;
};

function CoinForm({ initial, onSubmit }: { initial?: Partial<Coin>; onSubmit: (v: Partial<Coin>) => void }) {
  const [v, setV] = useState<Partial<Coin>>(initial || { type: "crypto", decimals: 8, status: "active", isListed: true, currentPrice: "0", priceSource: "binance" });
  return (
    <div className="space-y-3 max-h-[70vh] overflow-y-auto pr-1">
      <div className="grid grid-cols-2 gap-3">
        <div><Label>Symbol</Label><Input value={v.symbol || ""} onChange={(e) => setV({ ...v, symbol: e.target.value.toUpperCase() })} /></div>
        <div><Label>Name</Label><Input value={v.name || ""} onChange={(e) => setV({ ...v, name: e.target.value })} /></div>
        <div><Label>Type</Label>
          <Select value={v.type || "crypto"} onValueChange={(t) => setV({ ...v, type: t })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent><SelectItem value="crypto">Crypto</SelectItem><SelectItem value="fiat">Fiat</SelectItem></SelectContent>
          </Select>
        </div>
        <div><Label>Decimals</Label><Input type="number" value={v.decimals ?? 8} onChange={(e) => setV({ ...v, decimals: Number(e.target.value) })} /></div>
        <div><Label>Price Source</Label>
          <Select value={v.priceSource || "binance"} onValueChange={(t) => setV({ ...v, priceSource: t })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="binance">Live (CoinGecko/Binance)</SelectItem>
              <SelectItem value="manual">Manual</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div><Label>Binance Symbol (override)</Label><Input placeholder="e.g. BTCUSDT" value={v.binanceSymbol || ""} onChange={(e) => setV({ ...v, binanceSymbol: e.target.value.toUpperCase() })} /></div>
        <div><Label>Manual Price (USDT)</Label><Input value={v.manualPrice || ""} placeholder="only when source = manual" onChange={(e) => setV({ ...v, manualPrice: e.target.value })} /></div>
        <div><Label>Current Price (USDT)</Label><Input value={v.currentPrice || "0"} onChange={(e) => setV({ ...v, currentPrice: e.target.value })} /></div>
        <div><Label>24h Change %</Label><Input value={v.change24h || "0"} onChange={(e) => setV({ ...v, change24h: e.target.value })} /></div>
        <div><Label>Status</Label>
          <Select value={v.status || "active"} onValueChange={(t) => setV({ ...v, status: t })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="active">Active</SelectItem>
              <SelectItem value="paused">Paused</SelectItem>
              <SelectItem value="delisted">Delisted</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div className="col-span-2"><Label>Logo URL</Label><Input value={v.logoUrl || ""} onChange={(e) => setV({ ...v, logoUrl: e.target.value })} /></div>
        <div className="col-span-2"><Label>Info URL</Label><Input value={v.infoUrl || ""} onChange={(e) => setV({ ...v, infoUrl: e.target.value })} /></div>
        <div className="col-span-2"><Label>Description</Label>
          <textarea className="w-full rounded-md border bg-background px-3 py-2 text-sm min-h-[80px]" value={v.description || ""} onChange={(e) => setV({ ...v, description: e.target.value })} />
        </div>
        <div><Label>Listing At (countdown)</Label><Input type="datetime-local" value={v.listingAt ? new Date(v.listingAt).toISOString().slice(0,16) : ""} onChange={(e) => setV({ ...v, listingAt: e.target.value || null })} /></div>
        <div className="flex items-center gap-2 mt-6">
          <Switch checked={v.isListed ?? true} onCheckedChange={(c) => setV({ ...v, isListed: c })} />
          <Label>Listed (visible to users)</Label>
        </div>
      </div>
      <Button className="w-full" onClick={() => onSubmit(v)}>Save</Button>
    </div>
  );
}

export default function CoinsPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const [search, setSearch] = useState("");
  const { data = [], isLoading } = useQuery<Coin[]>({ queryKey: ["/admin/coins"], queryFn: () => get<Coin[]>("/admin/coins") });
  const create = useMutation({ mutationFn: (v: Partial<Coin>) => post("/admin/coins", v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/coins"] }); setOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, v }: { id: number; v: Partial<Coin> }) => patch(`/admin/coins/${id}`, v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/coins"] }); setEdit(null); } });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/coins/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/coins"] }) });
  const [open, setOpen] = useState(false);
  const [edit, setEdit] = useState<Coin | null>(null);

  const filtered = useMemo(() => {
    const q = search.toLowerCase().trim();
    if (!q) return data;
    return data.filter(c => c.symbol.toLowerCase().includes(q) || c.name.toLowerCase().includes(q));
  }, [data, search]);

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center gap-3">
        <div className="relative max-w-sm flex-1">
          <Search className="w-4 h-4 absolute left-2.5 top-2.5 text-muted-foreground" />
          <Input placeholder="Search symbol or name…" value={search} onChange={(e) => setSearch(e.target.value)} className="pl-8" />
        </div>
        <div className="text-sm text-muted-foreground">{filtered.length}/{data.length} coins</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Coin</Button></DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader><DialogTitle>Add coin</DialogTitle></DialogHeader>
              <CoinForm onSubmit={(v) => create.mutate(v)} />
            </DialogContent>
          </Dialog>
        )}
      </div>
      <Card>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Symbol</TableHead><TableHead>Name</TableHead><TableHead>Source</TableHead>
                <TableHead>Price (USDT)</TableHead><TableHead>24h%</TableHead><TableHead>Listed</TableHead>
                <TableHead>Status</TableHead><TableHead>Listing</TableHead>{isAdmin && <TableHead></TableHead>}
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading && <TableRow><TableCell colSpan={9} className="text-center py-6">Loading…</TableCell></TableRow>}
              {filtered.map((c) => (
                <TableRow key={c.id}>
                  <TableCell className="font-bold">{c.symbol}</TableCell>
                  <TableCell>{c.name}</TableCell>
                  <TableCell><Badge variant={c.priceSource === "manual" ? "secondary" : "outline"}>{c.priceSource}</Badge></TableCell>
                  <TableCell className="tabular-nums">${Number(c.currentPrice).toLocaleString("en-US", { maximumFractionDigits: 6 })}</TableCell>
                  <TableCell className={Number(c.change24h) >= 0 ? "text-green-500" : "text-red-500"}>{Number(c.change24h).toFixed(2)}%</TableCell>
                  <TableCell>{c.isListed ? <Badge>Yes</Badge> : <Badge variant="secondary">No</Badge>}</TableCell>
                  <TableCell><Badge variant={c.status === "active" ? "default" : "secondary"}>{c.status}</Badge></TableCell>
                  <TableCell className="text-xs">{c.listingAt ? new Date(c.listingAt).toLocaleString("en-IN") : "—"}</TableCell>
                  {isAdmin && (
                    <TableCell className="text-right space-x-1">
                      <Button size="icon" variant="ghost" onClick={() => setEdit(c)}><Pencil className="w-4 h-4" /></Button>
                      <Button size="icon" variant="ghost" onClick={() => { if (confirm(`Delete ${c.symbol}?`)) remove.mutate(c.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button>
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
            <CoinForm initial={edit} onSubmit={(v) => update.mutate({ id: edit.id, v })} />
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
