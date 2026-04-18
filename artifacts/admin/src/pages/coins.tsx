import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogFooter, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Plus, Trash2, Pencil } from "lucide-react";
import { useState } from "react";
import { useAuth } from "@/lib/auth";

type Coin = {
  id: number; symbol: string; name: string; type: string; decimals: number;
  logoUrl: string | null; status: string; isListed: boolean;
  listingAt: string | null; currentPrice: string; change24h: string;
};

function CoinForm({ initial, onSubmit }: { initial?: Partial<Coin>; onSubmit: (v: Partial<Coin>) => void }) {
  const [v, setV] = useState<Partial<Coin>>(initial || { type: "crypto", decimals: 8, status: "active", isListed: true, currentPrice: "0" });
  return (
    <div className="space-y-3">
      <div className="grid grid-cols-2 gap-3">
        <div><Label>Symbol</Label><Input value={v.symbol || ""} onChange={(e) => setV({ ...v, symbol: e.target.value.toUpperCase() })} /></div>
        <div><Label>Name</Label><Input value={v.name || ""} onChange={(e) => setV({ ...v, name: e.target.value })} /></div>
        <div><Label>Type</Label>
          <Select value={v.type || "crypto"} onValueChange={(t) => setV({ ...v, type: t })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="crypto">Crypto</SelectItem>
              <SelectItem value="fiat">Fiat</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div><Label>Decimals</Label><Input type="number" value={v.decimals ?? 8} onChange={(e) => setV({ ...v, decimals: Number(e.target.value) })} /></div>
        <div><Label>Current Price (INR)</Label><Input value={v.currentPrice || "0"} onChange={(e) => setV({ ...v, currentPrice: e.target.value })} /></div>
        <div><Label>24h Change %</Label><Input value={v.change24h || "0"} onChange={(e) => setV({ ...v, change24h: e.target.value })} /></div>
        <div className="col-span-2"><Label>Logo URL</Label><Input value={v.logoUrl || ""} onChange={(e) => setV({ ...v, logoUrl: e.target.value })} /></div>
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
        <div><Label>Listing At (countdown)</Label><Input type="datetime-local" value={v.listingAt ? new Date(v.listingAt).toISOString().slice(0,16) : ""} onChange={(e) => setV({ ...v, listingAt: e.target.value || null })} /></div>
        <div className="col-span-2 flex items-center gap-2">
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
  const { data = [], isLoading } = useQuery<Coin[]>({ queryKey: ["/admin/coins"], queryFn: () => get<Coin[]>("/admin/coins") });
  const create = useMutation({ mutationFn: (v: Partial<Coin>) => post("/admin/coins", v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/coins"] }); setOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, v }: { id: number; v: Partial<Coin> }) => patch(`/admin/coins/${id}`, v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/coins"] }); setEdit(null); } });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/coins/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/coins"] }) });
  const [open, setOpen] = useState(false);
  const [edit, setEdit] = useState<Coin | null>(null);

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div className="text-sm text-muted-foreground">{data.length} coins</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Coin</Button></DialogTrigger>
            <DialogContent>
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
                <TableHead>Symbol</TableHead><TableHead>Name</TableHead><TableHead>Type</TableHead>
                <TableHead>Price (INR)</TableHead><TableHead>24h%</TableHead><TableHead>Listed</TableHead>
                <TableHead>Status</TableHead><TableHead>Listing</TableHead>{isAdmin && <TableHead></TableHead>}
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading && <TableRow><TableCell colSpan={9} className="text-center py-6">Loading…</TableCell></TableRow>}
              {data.map((c) => (
                <TableRow key={c.id}>
                  <TableCell className="font-bold">{c.symbol}</TableCell>
                  <TableCell>{c.name}</TableCell>
                  <TableCell><Badge variant="outline">{c.type}</Badge></TableCell>
                  <TableCell className="tabular-nums">₹{Number(c.currentPrice).toLocaleString("en-IN")}</TableCell>
                  <TableCell className={Number(c.change24h) >= 0 ? "text-green-500" : "text-red-500"}>{c.change24h}%</TableCell>
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
          <DialogContent>
            <DialogHeader><DialogTitle>Edit {edit.symbol}</DialogTitle></DialogHeader>
            <CoinForm initial={edit} onSubmit={(v) => update.mutate({ id: edit.id, v })} />
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
