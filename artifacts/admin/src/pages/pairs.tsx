import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Plus, Trash2 } from "lucide-react";
import { useState } from "react";
import { useAuth } from "@/lib/auth";

type Coin = { id: number; symbol: string };
type Pair = {
  id: number; symbol: string; baseCoinId: number; quoteCoinId: number;
  minQty: string; maxQty: string; pricePrecision: number; qtyPrecision: number;
  takerFee: string; makerFee: string; status: string;
};

export default function PairsPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data: coins = [] } = useQuery<Coin[]>({ queryKey: ["/admin/coins"], queryFn: () => get<Coin[]>("/admin/coins") });
  const { data = [] } = useQuery<Pair[]>({ queryKey: ["/admin/pairs"], queryFn: () => get<Pair[]>("/admin/pairs") });
  const [open, setOpen] = useState(false);
  const [v, setV] = useState<Partial<Pair>>({ pricePrecision: 2, qtyPrecision: 4, takerFee: "0.001", makerFee: "0.001", status: "active" });
  const create = useMutation({
    mutationFn: () => post("/admin/pairs", { ...v, symbol: `${coins.find((c) => c.id === v.baseCoinId)?.symbol || ""}${coins.find((c) => c.id === v.quoteCoinId)?.symbol || ""}` }),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/pairs"] }); setOpen(false); }
  });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Partial<Pair> }) => patch(`/admin/pairs/${id}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/pairs"] }) });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/pairs/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/pairs"] }) });

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div className="text-sm text-muted-foreground">{data.length} pairs</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Pair</Button></DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Add trading pair</DialogTitle></DialogHeader>
              <div className="space-y-3">
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
                  <div><Label>Taker Fee</Label><Input value={v.takerFee || "0.001"} onChange={(e) => setV({ ...v, takerFee: e.target.value })} /></div>
                  <div><Label>Maker Fee</Label><Input value={v.makerFee || "0.001"} onChange={(e) => setV({ ...v, makerFee: e.target.value })} /></div>
                </div>
                <Button className="w-full" onClick={() => create.mutate()}>Create</Button>
              </div>
            </DialogContent>
          </Dialog>
        )}
      </div>
      <Card>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader><TableRow>
              <TableHead>Symbol</TableHead><TableHead>Base/Quote</TableHead>
              <TableHead>Price Prec</TableHead><TableHead>Qty Prec</TableHead>
              <TableHead>Taker</TableHead><TableHead>Maker</TableHead>
              <TableHead>Status</TableHead>{isAdmin && <TableHead></TableHead>}
            </TableRow></TableHeader>
            <TableBody>
              {data.map((p) => {
                const b = coins.find((c) => c.id === p.baseCoinId)?.symbol;
                const q = coins.find((c) => c.id === p.quoteCoinId)?.symbol;
                return (
                  <TableRow key={p.id}>
                    <TableCell className="font-bold">{p.symbol}</TableCell>
                    <TableCell>{b}/{q}</TableCell>
                    <TableCell>{p.pricePrecision}</TableCell>
                    <TableCell>{p.qtyPrecision}</TableCell>
                    <TableCell>{(Number(p.takerFee) * 100).toFixed(2)}%</TableCell>
                    <TableCell>{(Number(p.makerFee) * 100).toFixed(2)}%</TableCell>
                    <TableCell>
                      {isAdmin ? (
                        <Select value={p.status} onValueChange={(s) => update.mutate({ id: p.id, body: { status: s } })}>
                          <SelectTrigger className="h-8 w-28"><SelectValue /></SelectTrigger>
                          <SelectContent>
                            <SelectItem value="active">Active</SelectItem>
                            <SelectItem value="paused">Paused</SelectItem>
                            <SelectItem value="delisted">Delisted</SelectItem>
                          </SelectContent>
                        </Select>
                      ) : <Badge>{p.status}</Badge>}
                    </TableCell>
                    {isAdmin && (
                      <TableCell><Button size="icon" variant="ghost" onClick={() => { if (confirm("Delete?")) remove.mutate(p.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button></TableCell>
                    )}
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </div>
      </Card>
    </div>
  );
}
