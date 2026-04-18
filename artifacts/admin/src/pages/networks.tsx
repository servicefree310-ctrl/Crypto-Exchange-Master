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
import { Plus, Trash2 } from "lucide-react";
import { useState } from "react";
import { useAuth } from "@/lib/auth";

type Coin = { id: number; symbol: string };
type Network = {
  id: number; coinId: number; name: string; chain: string; contractAddress: string | null;
  minDeposit: string; minWithdraw: string; withdrawFee: string; confirmations: number;
  depositEnabled: boolean; withdrawEnabled: boolean; memoRequired: boolean; status: string;
};

export default function NetworksPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data: coins = [] } = useQuery<Coin[]>({ queryKey: ["/admin/coins"], queryFn: () => get<Coin[]>("/admin/coins") });
  const { data = [] } = useQuery<Network[]>({ queryKey: ["/admin/networks"], queryFn: () => get<Network[]>("/admin/networks") });
  const [open, setOpen] = useState(false);
  const [v, setV] = useState<Partial<Network>>({ confirmations: 12, depositEnabled: true, withdrawEnabled: true, status: "active" });
  const create = useMutation({ mutationFn: () => post("/admin/networks", v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/networks"] }); setOpen(false); setV({ confirmations: 12, depositEnabled: true, withdrawEnabled: true, status: "active" }); } });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Partial<Network> }) => patch(`/admin/networks/${id}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/networks"] }) });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/networks/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/networks"] }) });
  const sym = (id: number) => coins.find((c) => c.id === id)?.symbol || `#${id}`;

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div className="text-sm text-muted-foreground">{data.length} networks</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Network</Button></DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Add network</DialogTitle></DialogHeader>
              <div className="space-y-3">
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Coin</Label>
                    <Select value={v.coinId ? String(v.coinId) : ""} onValueChange={(c) => setV({ ...v, coinId: Number(c) })}>
                      <SelectTrigger><SelectValue placeholder="Select" /></SelectTrigger>
                      <SelectContent>{coins.map((c) => <SelectItem key={c.id} value={String(c.id)}>{c.symbol}</SelectItem>)}</SelectContent>
                    </Select>
                  </div>
                  <div><Label>Name (e.g. TRC20)</Label><Input value={v.name || ""} onChange={(e) => setV({ ...v, name: e.target.value })} /></div>
                  <div><Label>Chain</Label><Input value={v.chain || ""} onChange={(e) => setV({ ...v, chain: e.target.value })} /></div>
                  <div><Label>Contract Address</Label><Input value={v.contractAddress || ""} onChange={(e) => setV({ ...v, contractAddress: e.target.value })} /></div>
                  <div><Label>Min Deposit</Label><Input value={v.minDeposit || "0"} onChange={(e) => setV({ ...v, minDeposit: e.target.value })} /></div>
                  <div><Label>Min Withdraw</Label><Input value={v.minWithdraw || "0"} onChange={(e) => setV({ ...v, minWithdraw: e.target.value })} /></div>
                  <div><Label>Withdraw Fee</Label><Input value={v.withdrawFee || "0"} onChange={(e) => setV({ ...v, withdrawFee: e.target.value })} /></div>
                  <div><Label>Confirmations</Label><Input type="number" value={v.confirmations ?? 12} onChange={(e) => setV({ ...v, confirmations: Number(e.target.value) })} /></div>
                </div>
                <div className="flex gap-4">
                  <label className="flex items-center gap-2"><Switch checked={v.depositEnabled} onCheckedChange={(c) => setV({ ...v, depositEnabled: c })} /> Deposit</label>
                  <label className="flex items-center gap-2"><Switch checked={v.withdrawEnabled} onCheckedChange={(c) => setV({ ...v, withdrawEnabled: c })} /> Withdraw</label>
                  <label className="flex items-center gap-2"><Switch checked={v.memoRequired} onCheckedChange={(c) => setV({ ...v, memoRequired: c })} /> Memo</label>
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
            <TableHeader>
              <TableRow>
                <TableHead>Coin</TableHead><TableHead>Name</TableHead><TableHead>Chain</TableHead>
                <TableHead>Min Dep</TableHead><TableHead>Min W/d</TableHead><TableHead>Fee</TableHead>
                <TableHead>Conf</TableHead><TableHead>Dep</TableHead><TableHead>W/d</TableHead>
                {isAdmin && <TableHead></TableHead>}
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.map((n) => (
                <TableRow key={n.id}>
                  <TableCell className="font-bold">{sym(n.coinId)}</TableCell>
                  <TableCell>{n.name}</TableCell>
                  <TableCell>{n.chain}</TableCell>
                  <TableCell className="tabular-nums">{n.minDeposit}</TableCell>
                  <TableCell className="tabular-nums">{n.minWithdraw}</TableCell>
                  <TableCell className="tabular-nums">{n.withdrawFee}</TableCell>
                  <TableCell>{n.confirmations}</TableCell>
                  <TableCell>
                    {isAdmin
                      ? <Switch checked={n.depositEnabled} onCheckedChange={(c) => update.mutate({ id: n.id, body: { depositEnabled: c } })} />
                      : <Badge variant={n.depositEnabled ? "default" : "secondary"}>{n.depositEnabled ? "On" : "Off"}</Badge>}
                  </TableCell>
                  <TableCell>
                    {isAdmin
                      ? <Switch checked={n.withdrawEnabled} onCheckedChange={(c) => update.mutate({ id: n.id, body: { withdrawEnabled: c } })} />
                      : <Badge variant={n.withdrawEnabled ? "default" : "secondary"}>{n.withdrawEnabled ? "On" : "Off"}</Badge>}
                  </TableCell>
                  {isAdmin && (
                    <TableCell><Button size="icon" variant="ghost" onClick={() => { if (confirm("Delete?")) remove.mutate(n.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button></TableCell>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </Card>
    </div>
  );
}
