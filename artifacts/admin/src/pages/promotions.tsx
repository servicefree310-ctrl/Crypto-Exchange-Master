import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Plus, Pencil, Trash2, Award, Trophy } from "lucide-react";
import { useState } from "react";

type Promo = {
  id: number; type: string; tag: string; title: string; subtitle: string;
  description: string; color: string; icon: string; imageUrl: string;
  ctaLabel: string; ctaUrl: string; prizePool: string;
  position: number; isActive: boolean; showOnMobile: boolean;
  startsAt: string | null; endsAt: string | null;
};

const TYPES = [
  { v: "contest", t: "CONTEST", c: "#a06af5", i: "award" },
  { v: "event",   t: "EVENT",   c: "#5b8def", i: "calendar" },
  { v: "airdrop", t: "AIRDROP", c: "#ff8a3d", i: "gift" },
  { v: "listing", t: "NEW LISTING", c: "#0ecb81", i: "zap" },
  { v: "guide",   t: "GUIDE",   c: "#5b8def", i: "book-open" },
  { v: "trending", t: "TRENDING", c: "#F7931A", i: "trending-up" },
];

const blank = (): Partial<Promo> => ({
  type: "contest", tag: "CONTEST", title: "", subtitle: "", description: "",
  color: "#a06af5", icon: "award", imageUrl: "", ctaLabel: "Join now",
  ctaUrl: "", prizePool: "", position: 0, isActive: true, showOnMobile: true,
  startsAt: null, endsAt: null,
});

export default function PromotionsPage() {
  const qc = useQueryClient();
  const { data = [], isLoading } = useQuery<Promo[]>({
    queryKey: ["admin-promotions"],
    queryFn: () => get("/admin/promotions"),
  });

  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Partial<Promo> | null>(null);

  const save = useMutation({
    mutationFn: async (p: Partial<Promo>) => {
      if (p.id) return patch(`/admin/promotions/${p.id}`, p);
      return post("/admin/promotions", p);
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["admin-promotions"] }); setOpen(false); setEditing(null); },
  });

  const toggle = useMutation({
    mutationFn: ({ id, isActive }: { id: number; isActive: boolean }) => patch(`/admin/promotions/${id}`, { isActive }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-promotions"] }),
  });

  const remove = useMutation({
    mutationFn: (id: number) => del(`/admin/promotions/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-promotions"] }),
  });

  const onEdit = (p?: Promo) => { setEditing(p ? { ...p } : blank()); setOpen(true); };

  const applyType = (v: string) => {
    const t = TYPES.find(x => x.v === v);
    if (t && editing) setEditing({ ...editing, type: v, tag: t.t, color: t.c, icon: t.i });
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold flex items-center gap-2"><Trophy className="h-6 w-6 text-purple-500" /> Promotions & Contests</h2>
          <p className="text-sm text-muted-foreground">Trading contests, airdrops, events shown in mobile Discover section</p>
        </div>
        <Button onClick={() => onEdit()}><Plus className="h-4 w-4 mr-1" /> New Promotion</Button>
      </div>

      <Card className="p-0 overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Tag</TableHead><TableHead>Title</TableHead><TableHead>Subtitle</TableHead>
              <TableHead>Prize</TableHead><TableHead>CTA</TableHead><TableHead>Pos</TableHead>
              <TableHead>Schedule</TableHead><TableHead>Mobile</TableHead><TableHead>Active</TableHead>
              <TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading && (<TableRow><TableCell colSpan={10} className="text-center py-6 text-muted-foreground">Loading...</TableCell></TableRow>)}
            {!isLoading && data.length === 0 && (<TableRow><TableCell colSpan={10} className="text-center py-6 text-muted-foreground">No promotions yet</TableCell></TableRow>)}
            {data.map(p => (
              <TableRow key={p.id}>
                <TableCell><Badge style={{ background: p.color + "33", color: p.color, border: "none" }}>{p.tag}</Badge></TableCell>
                <TableCell className="font-medium">{p.title}</TableCell>
                <TableCell className="text-xs text-muted-foreground max-w-[180px] truncate">{p.subtitle}</TableCell>
                <TableCell className="font-mono text-xs">{p.prizePool || "—"}</TableCell>
                <TableCell className="text-xs">{p.ctaLabel}</TableCell>
                <TableCell>{p.position}</TableCell>
                <TableCell className="text-xs text-muted-foreground">{p.startsAt || p.endsAt ? `${p.startsAt?.slice(5,10) || "—"} → ${p.endsAt?.slice(5,10) || "—"}` : "Always"}</TableCell>
                <TableCell>{p.showOnMobile ? <Badge className="bg-emerald-600">ON</Badge> : <Badge variant="secondary">OFF</Badge>}</TableCell>
                <TableCell><Switch checked={p.isActive} onCheckedChange={v => toggle.mutate({ id: p.id, isActive: v })} /></TableCell>
                <TableCell className="text-right">
                  <Button size="sm" variant="ghost" onClick={() => onEdit(p)}><Pencil className="h-3.5 w-3.5" /></Button>
                  <Button size="sm" variant="ghost" onClick={() => confirm("Delete?") && remove.mutate(p.id)}><Trash2 className="h-3.5 w-3.5 text-red-500" /></Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader><DialogTitle>{editing?.id ? "Edit Promotion" : "New Promotion"}</DialogTitle></DialogHeader>
          {editing && (
            <div className="space-y-4">
              <div className="rounded-lg p-4 border" style={{ borderColor: editing.color, background: editing.color + "11" }}>
                <Badge className="mb-2" style={{ background: editing.color + "33", color: editing.color, border: "none" }}>{editing.tag}</Badge>
                <div className="font-bold text-base">{editing.title || "Title"}</div>
                <div className="text-xs text-muted-foreground mt-1">{editing.subtitle || "Subtitle"}</div>
                {editing.prizePool && <div className="text-sm font-bold mt-2" style={{ color: editing.color }}>🏆 {editing.prizePool}</div>}
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <Label>Type</Label>
                  <Select value={editing.type} onValueChange={applyType}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>{TYPES.map(t => <SelectItem key={t.v} value={t.v}>{t.t}</SelectItem>)}</SelectContent>
                  </Select>
                </div>
                <div><Label>Position</Label><Input type="number" value={editing.position ?? 0} onChange={e => setEditing({ ...editing, position: Number(e.target.value) })} /></div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div><Label>Tag (custom)</Label><Input value={editing.tag || ""} onChange={e => setEditing({ ...editing, tag: e.target.value.toUpperCase() })} /></div>
                <div><Label>Color</Label><Input value={editing.color || ""} onChange={e => setEditing({ ...editing, color: e.target.value })} /></div>
              </div>

              <div><Label>Title *</Label><Input value={editing.title || ""} onChange={e => setEditing({ ...editing, title: e.target.value })} placeholder="Trading Contest" /></div>
              <div><Label>Subtitle</Label><Input value={editing.subtitle || ""} onChange={e => setEditing({ ...editing, subtitle: e.target.value })} placeholder="Compete & win prizes" /></div>
              <div><Label>Description (long)</Label><Textarea rows={3} value={editing.description || ""} onChange={e => setEditing({ ...editing, description: e.target.value })} /></div>

              <div className="grid grid-cols-2 gap-3">
                <div><Label>Prize Pool</Label><Input value={editing.prizePool || ""} onChange={e => setEditing({ ...editing, prizePool: e.target.value })} placeholder="Win ₹10,00,000" /></div>
                <div><Label>Icon</Label><Input value={editing.icon || ""} onChange={e => setEditing({ ...editing, icon: e.target.value })} placeholder="award / gift / zap" /></div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div><Label>CTA Label</Label><Input value={editing.ctaLabel || ""} onChange={e => setEditing({ ...editing, ctaLabel: e.target.value })} /></div>
                <div><Label>CTA URL / Route</Label><Input value={editing.ctaUrl || ""} onChange={e => setEditing({ ...editing, ctaUrl: e.target.value })} placeholder="/services/refer" /></div>
              </div>

              <div><Label>Image URL (optional)</Label><Input value={editing.imageUrl || ""} onChange={e => setEditing({ ...editing, imageUrl: e.target.value })} /></div>

              <div className="grid grid-cols-2 gap-3">
                <div><Label>Starts At</Label><Input type="datetime-local" value={editing.startsAt?.slice(0,16) || ""} onChange={e => setEditing({ ...editing, startsAt: e.target.value || null })} /></div>
                <div><Label>Ends At</Label><Input type="datetime-local" value={editing.endsAt?.slice(0,16) || ""} onChange={e => setEditing({ ...editing, endsAt: e.target.value || null })} /></div>
              </div>

              <div className="flex items-center justify-between border-t pt-3">
                <div className="flex items-center gap-2"><Switch checked={!!editing.isActive} onCheckedChange={v => setEditing({ ...editing, isActive: v })} /><Label>Active</Label></div>
                <div className="flex items-center gap-2"><Switch checked={!!editing.showOnMobile} onCheckedChange={v => setEditing({ ...editing, showOnMobile: v })} /><Label>Show on Mobile</Label></div>
              </div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setOpen(false)}>Cancel</Button>
            <Button onClick={() => editing && save.mutate(editing)} disabled={!editing?.title || save.isPending}>{save.isPending ? "Saving..." : "Save"}</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
