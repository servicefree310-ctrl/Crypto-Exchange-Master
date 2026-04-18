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
import { useState } from "react";
import { useAuth } from "@/lib/auth";

type Coin = { id: number; symbol: string };
type Network = {
  id: number; coinId: number; name: string; chain: string; contractAddress: string | null;
  minDeposit: string; minWithdraw: string; withdrawFee: string; confirmations: number;
  depositEnabled: boolean; withdrawEnabled: boolean; memoRequired: boolean; status: string;
  nodeAddress: string | null; nodeStatus: string; lastNodeCheckAt: string | null;
};

const STATUS_COLOR: Record<string, string> = {
  online: "bg-green-500/15 text-green-600 border-green-500/30",
  offline: "bg-red-500/15 text-red-600 border-red-500/30",
  syncing: "bg-amber-500/15 text-amber-600 border-amber-500/30",
  unknown: "bg-muted text-muted-foreground",
};

function NetworkForm({ initial, coins, onSubmit }: { initial?: Partial<Network>; coins: Coin[]; onSubmit: (v: Partial<Network>) => void }) {
  const [v, setV] = useState<Partial<Network>>(initial || {
    confirmations: 12, depositEnabled: true, withdrawEnabled: true, memoRequired: false, status: "active", nodeStatus: "unknown",
  });
  return (
    <div className="space-y-3 max-h-[70vh] overflow-y-auto pr-1">
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
        <div className="col-span-2"><Label>Node Address (RPC URL or hot wallet)</Label><Input value={v.nodeAddress || ""} onChange={(e) => setV({ ...v, nodeAddress: e.target.value })} /></div>
        <div><Label>Node Status</Label>
          <Select value={v.nodeStatus || "unknown"} onValueChange={(s) => setV({ ...v, nodeStatus: s })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="online">Online</SelectItem>
              <SelectItem value="offline">Offline</SelectItem>
              <SelectItem value="syncing">Syncing</SelectItem>
              <SelectItem value="unknown">Unknown</SelectItem>
            </SelectContent>
          </Select>
        </div>
        <div><Label>Status</Label>
          <Select value={v.status || "active"} onValueChange={(s) => setV({ ...v, status: s })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="active">Active</SelectItem>
              <SelectItem value="paused">Paused</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>
      <div className="flex gap-4 flex-wrap pt-2">
        <label className="flex items-center gap-2"><Switch checked={v.depositEnabled} onCheckedChange={(c) => setV({ ...v, depositEnabled: c })} /> Deposit</label>
        <label className="flex items-center gap-2"><Switch checked={v.withdrawEnabled} onCheckedChange={(c) => setV({ ...v, withdrawEnabled: c })} /> Withdraw</label>
        <label className="flex items-center gap-2"><Switch checked={v.memoRequired} onCheckedChange={(c) => setV({ ...v, memoRequired: c })} /> Memo Required</label>
      </div>
      <Button className="w-full" onClick={() => onSubmit(v)}>Save</Button>
    </div>
  );
}

export default function NetworksPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data: coins = [] } = useQuery<Coin[]>({ queryKey: ["/admin/coins"], queryFn: () => get<Coin[]>("/admin/coins") });
  const { data = [] } = useQuery<Network[]>({ queryKey: ["/admin/networks"], queryFn: () => get<Network[]>("/admin/networks") });
  const [open, setOpen] = useState(false);
  const [edit, setEdit] = useState<Network | null>(null);
  const create = useMutation({ mutationFn: (v: Partial<Network>) => post("/admin/networks", v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/networks"] }); setOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Partial<Network> }) => patch(`/admin/networks/${id}`, body), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/networks"] }); setEdit(null); } });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/networks/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/networks"] }) });
  const sym = (id: number) => coins.find((c) => c.id === id)?.symbol || `#${id}`;

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div className="text-sm text-muted-foreground">{data.length} networks</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Network</Button></DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader><DialogTitle>Add network</DialogTitle></DialogHeader>
              <NetworkForm coins={coins} onSubmit={(v) => create.mutate(v)} />
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
                <TableHead>Conf</TableHead><TableHead>Node</TableHead><TableHead>Dep</TableHead><TableHead>W/d</TableHead>
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
                    <span className={`px-2 py-0.5 text-xs rounded-md border ${STATUS_COLOR[n.nodeStatus] || STATUS_COLOR.unknown}`}>{n.nodeStatus}</span>
                  </TableCell>
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
                    <TableCell className="text-right space-x-1">
                      <Button size="icon" variant="ghost" onClick={() => setEdit(n)}><Pencil className="w-4 h-4" /></Button>
                      <Button size="icon" variant="ghost" onClick={() => { if (confirm("Delete?")) remove.mutate(n.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button>
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
            <DialogHeader><DialogTitle>Edit {sym(edit.coinId)} / {edit.name}</DialogTitle></DialogHeader>
            <NetworkForm initial={edit} coins={coins} onSubmit={(v) => update.mutate({ id: edit.id, body: v })} />
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
