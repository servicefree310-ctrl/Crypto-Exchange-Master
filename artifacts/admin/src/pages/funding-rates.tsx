import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Plus, Trash2, Pencil } from "lucide-react";
import { useState, useMemo } from "react";
import { useAuth } from "@/lib/auth";

type Pair = { id: number; symbol: string; futuresEnabled: boolean };
type FundingRate = { id: number; pairId: number; rate: string; intervalHours: number; fundingTime: string; createdAt: string };

function FundingForm({ initial, pairs, onSubmit }: { initial?: Partial<FundingRate>; pairs: Pair[]; onSubmit: (v: Partial<FundingRate>) => void }) {
  const [v, setV] = useState<Partial<FundingRate>>(initial || { intervalHours: 8, fundingTime: new Date(Date.now() + 8 * 3600_000).toISOString() });
  return (
    <div className="space-y-3">
      <div className="grid grid-cols-2 gap-3">
        <div><Label>Pair</Label>
          <Select value={v.pairId ? String(v.pairId) : ""} onValueChange={(p) => setV({ ...v, pairId: Number(p) })}>
            <SelectTrigger><SelectValue placeholder="Select pair" /></SelectTrigger>
            <SelectContent>{pairs.filter(p => p.futuresEnabled).map(p => <SelectItem key={p.id} value={String(p.id)}>{p.symbol}</SelectItem>)}</SelectContent>
          </Select>
        </div>
        <div><Label>Rate (decimal, e.g. 0.0001 = 0.01%)</Label><Input value={v.rate || ""} onChange={(e) => setV({ ...v, rate: e.target.value })} /></div>
        <div><Label>Interval (hours)</Label><Input type="number" value={v.intervalHours ?? 8} onChange={(e) => setV({ ...v, intervalHours: Number(e.target.value) })} /></div>
        <div><Label>Funding Time</Label><Input type="datetime-local" value={v.fundingTime ? new Date(v.fundingTime).toISOString().slice(0,16) : ""} onChange={(e) => setV({ ...v, fundingTime: e.target.value })} /></div>
      </div>
      <Button className="w-full" onClick={() => onSubmit(v)}>Save</Button>
    </div>
  );
}

export default function FundingRatesPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data: pairs = [] } = useQuery<Pair[]>({ queryKey: ["/admin/pairs"], queryFn: () => get<Pair[]>("/admin/pairs") });
  const { data = [] } = useQuery<FundingRate[]>({ queryKey: ["/admin/funding-rates"], queryFn: () => get<FundingRate[]>("/admin/funding-rates") });
  const [open, setOpen] = useState(false);
  const [edit, setEdit] = useState<FundingRate | null>(null);
  const [filterPair, setFilterPair] = useState<string>("");

  const create = useMutation({ mutationFn: (v: Partial<FundingRate>) => post("/admin/funding-rates", v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/funding-rates"] }); setOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Partial<FundingRate> }) => patch(`/admin/funding-rates/${id}`, body), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/funding-rates"] }); setEdit(null); } });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/funding-rates/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/funding-rates"] }) });

  const sym = (id: number) => pairs.find(p => p.id === id)?.symbol || `#${id}`;
  const filtered = useMemo(() => filterPair ? data.filter(d => d.pairId === Number(filterPair)) : data, [data, filterPair]);

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center gap-3">
        <div className="flex items-center gap-2">
          <Label className="text-xs">Pair filter:</Label>
          <Select value={filterPair} onValueChange={(v) => setFilterPair(v === "_all" ? "" : v)}>
            <SelectTrigger className="w-48"><SelectValue placeholder="All pairs" /></SelectTrigger>
            <SelectContent>
              <SelectItem value="_all">All pairs</SelectItem>
              {pairs.filter(p => p.futuresEnabled).map(p => <SelectItem key={p.id} value={String(p.id)}>{p.symbol}</SelectItem>)}
            </SelectContent>
          </Select>
        </div>
        <div className="text-sm text-muted-foreground">{filtered.length} entries</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Funding Rate</Button></DialogTrigger>
            <DialogContent>
              <DialogHeader><DialogTitle>Add funding rate</DialogTitle></DialogHeader>
              <FundingForm pairs={pairs} onSubmit={(v) => create.mutate(v)} />
            </DialogContent>
          </Dialog>
        )}
      </div>
      <Card>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader><TableRow>
              <TableHead>Pair</TableHead><TableHead>Rate</TableHead><TableHead>%</TableHead>
              <TableHead>Interval (h)</TableHead><TableHead>Funding Time</TableHead>
              <TableHead>Created</TableHead>{isAdmin && <TableHead></TableHead>}
            </TableRow></TableHeader>
            <TableBody>
              {filtered.length === 0 && <TableRow><TableCell colSpan={7} className="text-center text-muted-foreground py-6">No funding rates yet</TableCell></TableRow>}
              {filtered.map((f) => (
                <TableRow key={f.id}>
                  <TableCell className="font-bold">{sym(f.pairId)}</TableCell>
                  <TableCell className="tabular-nums">{f.rate}</TableCell>
                  <TableCell className={Number(f.rate) >= 0 ? "text-green-500" : "text-red-500"}>{(Number(f.rate) * 100).toFixed(4)}%</TableCell>
                  <TableCell>{f.intervalHours}h</TableCell>
                  <TableCell className="text-xs">{new Date(f.fundingTime).toLocaleString("en-IN")}</TableCell>
                  <TableCell className="text-xs text-muted-foreground">{new Date(f.createdAt).toLocaleString("en-IN")}</TableCell>
                  {isAdmin && (
                    <TableCell className="text-right space-x-1">
                      <Button size="icon" variant="ghost" onClick={() => setEdit(f)}><Pencil className="w-4 h-4" /></Button>
                      <Button size="icon" variant="ghost" onClick={() => { if (confirm("Delete?")) remove.mutate(f.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button>
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
            <DialogHeader><DialogTitle>Edit funding rate</DialogTitle></DialogHeader>
            <FundingForm initial={edit} pairs={pairs} onSubmit={(v) => update.mutate({ id: edit.id, body: v })} />
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
