import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Plus, Trash2 } from "lucide-react";
import { useState } from "react";
import { useAuth } from "@/lib/auth";

type Gateway = {
  id: number; code: string; name: string; type: string; direction: string;
  minAmount: string; maxAmount: string; feeFlat: string; feePercent: string;
  processingTime: string; isAuto: boolean; status: string; config: string;
};

export default function GatewaysPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data = [] } = useQuery<Gateway[]>({ queryKey: ["/admin/gateways"], queryFn: () => get<Gateway[]>("/admin/gateways") });
  const [open, setOpen] = useState(false);
  const [v, setV] = useState<Partial<Gateway>>({ type: "upi", direction: "deposit", processingTime: "Instant", isAuto: false, status: "active", config: "{}" });
  const create = useMutation({ mutationFn: () => post("/admin/gateways", v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/gateways"] }); setOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Partial<Gateway> }) => patch(`/admin/gateways/${id}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/gateways"] }) });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/gateways/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/gateways"] }) });

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div className="text-sm text-muted-foreground">{data.length} gateways</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Gateway</Button></DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Add payment gateway</DialogTitle></DialogHeader>
              <div className="space-y-3">
                <div className="grid grid-cols-2 gap-3">
                  <div><Label>Code</Label><Input value={v.code || ""} onChange={(e) => setV({ ...v, code: e.target.value })} /></div>
                  <div><Label>Name</Label><Input value={v.name || ""} onChange={(e) => setV({ ...v, name: e.target.value })} /></div>
                  <div><Label>Type</Label>
                    <Select value={v.type} onValueChange={(t) => setV({ ...v, type: t })}>
                      <SelectTrigger><SelectValue /></SelectTrigger>
                      <SelectContent>
                        {["upi","imps","neft","rtgs","bank","wallet","payment_gateway"].map((t) => <SelectItem key={t} value={t}>{t.toUpperCase()}</SelectItem>)}
                      </SelectContent>
                    </Select>
                  </div>
                  <div><Label>Direction</Label>
                    <Select value={v.direction} onValueChange={(t) => setV({ ...v, direction: t })}>
                      <SelectTrigger><SelectValue /></SelectTrigger>
                      <SelectContent>
                        <SelectItem value="deposit">Deposit</SelectItem>
                        <SelectItem value="withdraw">Withdraw</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div><Label>Min Amount</Label><Input value={v.minAmount || "0"} onChange={(e) => setV({ ...v, minAmount: e.target.value })} /></div>
                  <div><Label>Max Amount</Label><Input value={v.maxAmount || "0"} onChange={(e) => setV({ ...v, maxAmount: e.target.value })} /></div>
                  <div><Label>Fee Flat (₹)</Label><Input value={v.feeFlat || "0"} onChange={(e) => setV({ ...v, feeFlat: e.target.value })} /></div>
                  <div><Label>Fee %</Label><Input value={v.feePercent || "0"} onChange={(e) => setV({ ...v, feePercent: e.target.value })} /></div>
                  <div><Label>Processing Time</Label><Input value={v.processingTime || ""} onChange={(e) => setV({ ...v, processingTime: e.target.value })} /></div>
                  <div className="flex items-center gap-2"><Switch checked={v.isAuto} onCheckedChange={(c) => setV({ ...v, isAuto: c })} /><Label>Auto-credit</Label></div>
                </div>
                <div><Label>Config (JSON, e.g. UPI ID, account)</Label><Textarea rows={4} value={v.config || "{}"} onChange={(e) => setV({ ...v, config: e.target.value })} /></div>
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
              <TableHead>Code</TableHead><TableHead>Name</TableHead><TableHead>Type</TableHead>
              <TableHead>Direction</TableHead><TableHead>Min/Max</TableHead><TableHead>Fee</TableHead>
              <TableHead>Auto</TableHead><TableHead>Status</TableHead>{isAdmin && <TableHead></TableHead>}
            </TableRow></TableHeader>
            <TableBody>
              {data.map((g) => (
                <TableRow key={g.id}>
                  <TableCell className="font-mono text-xs">{g.code}</TableCell>
                  <TableCell className="font-medium">{g.name}</TableCell>
                  <TableCell><Badge variant="outline">{g.type.toUpperCase()}</Badge></TableCell>
                  <TableCell><Badge>{g.direction}</Badge></TableCell>
                  <TableCell className="tabular-nums text-xs">₹{g.minAmount} – ₹{g.maxAmount}</TableCell>
                  <TableCell className="text-xs">₹{g.feeFlat} + {g.feePercent}%</TableCell>
                  <TableCell>{g.isAuto ? <Badge>Auto</Badge> : <Badge variant="secondary">Manual</Badge>}</TableCell>
                  <TableCell>
                    {isAdmin ? (
                      <Switch checked={g.status === "active"} onCheckedChange={(c) => update.mutate({ id: g.id, body: { status: c ? "active" : "paused" } })} />
                    ) : <Badge>{g.status}</Badge>}
                  </TableCell>
                  {isAdmin && (
                    <TableCell><Button size="icon" variant="ghost" onClick={() => { if (confirm("Delete?")) remove.mutate(g.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button></TableCell>
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
