import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, del, patch } from "@/lib/api";
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
type Product = {
  id: number; coinId: number; type: string; durationDays: number;
  apy: string; minAmount: string; maxAmount: string; status: string;
};

export default function EarnPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data: coins = [] } = useQuery<Coin[]>({ queryKey: ["/admin/coins"], queryFn: () => get<Coin[]>("/admin/coins") });
  const { data = [] } = useQuery<Product[]>({ queryKey: ["/admin/earn-products"], queryFn: () => get<Product[]>("/admin/earn-products") });
  const [open, setOpen] = useState(false);
  const [v, setV] = useState<Partial<Product>>({ type: "simple", durationDays: 0, apy: "5", minAmount: "0", maxAmount: "0", status: "active" });
  const create = useMutation({ mutationFn: () => post("/admin/earn-products", v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/earn-products"] }); setOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Partial<Product> }) => patch(`/admin/earn-products/${id}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/earn-products"] }) });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/earn-products/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/earn-products"] }) });

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div className="text-sm text-muted-foreground">{data.length} products</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Product</Button></DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Add earn product</DialogTitle></DialogHeader>
              <div className="space-y-3">
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Coin</Label>
                    <Select value={v.coinId ? String(v.coinId) : ""} onValueChange={(c) => setV({ ...v, coinId: Number(c) })}>
                      <SelectTrigger><SelectValue placeholder="Select" /></SelectTrigger>
                      <SelectContent>{coins.map((c) => <SelectItem key={c.id} value={String(c.id)}>{c.symbol}</SelectItem>)}</SelectContent>
                    </Select>
                  </div>
                  <div><Label>Type</Label>
                    <Select value={v.type} onValueChange={(t) => setV({ ...v, type: t })}>
                      <SelectTrigger><SelectValue /></SelectTrigger>
                      <SelectContent>
                        <SelectItem value="simple">Simple (Flexible)</SelectItem>
                        <SelectItem value="advanced">Advanced (Locked)</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div><Label>Duration (days, 0 for flexible)</Label><Input type="number" value={v.durationDays ?? 0} onChange={(e) => setV({ ...v, durationDays: Number(e.target.value) })} /></div>
                  <div><Label>APY %</Label><Input value={v.apy || "5"} onChange={(e) => setV({ ...v, apy: e.target.value })} /></div>
                  <div><Label>Min Amount</Label><Input value={v.minAmount || "0"} onChange={(e) => setV({ ...v, minAmount: e.target.value })} /></div>
                  <div><Label>Max Amount</Label><Input value={v.maxAmount || "0"} onChange={(e) => setV({ ...v, maxAmount: e.target.value })} /></div>
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
              <TableHead>Coin</TableHead><TableHead>Type</TableHead><TableHead>Duration</TableHead>
              <TableHead>APY</TableHead><TableHead>Min/Max</TableHead><TableHead>Status</TableHead>
              {isAdmin && <TableHead></TableHead>}
            </TableRow></TableHeader>
            <TableBody>
              {data.map((p) => {
                const sym = coins.find((c) => c.id === p.coinId)?.symbol || `#${p.coinId}`;
                return (
                  <TableRow key={p.id}>
                    <TableCell className="font-bold">{sym}</TableCell>
                    <TableCell><Badge variant="outline">{p.type}</Badge></TableCell>
                    <TableCell>{p.durationDays === 0 ? "Flexible" : `${p.durationDays} days`}</TableCell>
                    <TableCell className="font-bold text-primary">{p.apy}%</TableCell>
                    <TableCell className="text-xs">{p.minAmount} – {p.maxAmount}</TableCell>
                    <TableCell>
                      {isAdmin ? (
                        <Select value={p.status} onValueChange={(s) => update.mutate({ id: p.id, body: { status: s } })}>
                          <SelectTrigger className="h-8 w-28"><SelectValue /></SelectTrigger>
                          <SelectContent>
                            <SelectItem value="active">Active</SelectItem>
                            <SelectItem value="paused">Paused</SelectItem>
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
