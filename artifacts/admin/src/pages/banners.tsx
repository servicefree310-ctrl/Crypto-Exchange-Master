import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import { Plus, Pencil, Trash2, Megaphone } from "lucide-react";
import { useState } from "react";

type Banner = {
  id: number; title: string; subtitle: string; bgColor: string; fgColor: string;
  icon: string; imageUrl: string; ctaLabel: string; ctaUrl: string;
  position: number; isActive: boolean; showOnMobile: boolean; showOnWeb: boolean;
  startsAt: string | null; endsAt: string | null;
};

const ICONS = ["shield", "gift", "trending-up", "award", "zap", "star", "bell", "bookmark"];
const PRESET_COLORS = ["#fcd535", "#a06af5", "#0ecb81", "#f6465d", "#5b8def", "#ff8a3d", "#00c2ff", "#14F195"];

const blank = (): Partial<Banner> => ({
  title: "", subtitle: "", bgColor: "#fcd535", fgColor: "#000000",
  icon: "shield", imageUrl: "", ctaLabel: "", ctaUrl: "",
  position: 0, isActive: true, showOnMobile: true, showOnWeb: true,
  startsAt: null, endsAt: null,
});

export default function BannersPage() {
  const qc = useQueryClient();
  const { data = [], isLoading } = useQuery<Banner[]>({
    queryKey: ["admin-banners"],
    queryFn: () => get("/admin/banners"),
  });

  const [open, setOpen] = useState(false);
  const [editing, setEditing] = useState<Partial<Banner> | null>(null);

  const save = useMutation({
    mutationFn: async (b: Partial<Banner>) => {
      if (b.id) return patch(`/admin/banners/${b.id}`, b);
      return post("/admin/banners", b);
    },
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["admin-banners"] }); setOpen(false); setEditing(null); },
  });

  const toggle = useMutation({
    mutationFn: ({ id, isActive }: { id: number; isActive: boolean }) => patch(`/admin/banners/${id}`, { isActive }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-banners"] }),
  });

  const remove = useMutation({
    mutationFn: (id: number) => del(`/admin/banners/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-banners"] }),
  });

  const onEdit = (b?: Banner) => { setEditing(b ? { ...b } : blank()); setOpen(true); };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold flex items-center gap-2"><Megaphone className="h-6 w-6 text-yellow-500" /> Home Banners</h2>
          <p className="text-sm text-muted-foreground">Carousel banners shown on mobile app & web home screen</p>
        </div>
        <Button onClick={() => onEdit()}><Plus className="h-4 w-4 mr-1" /> New Banner</Button>
      </div>

      <Card className="p-0 overflow-hidden">
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead>Preview</TableHead><TableHead>Title</TableHead><TableHead>Subtitle</TableHead>
              <TableHead>CTA</TableHead><TableHead>Pos</TableHead><TableHead>Mobile</TableHead><TableHead>Web</TableHead>
              <TableHead>Schedule</TableHead><TableHead>Active</TableHead><TableHead className="text-right">Actions</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {isLoading && (<TableRow><TableCell colSpan={10} className="text-center text-muted-foreground py-6">Loading...</TableCell></TableRow>)}
            {!isLoading && data.length === 0 && (<TableRow><TableCell colSpan={10} className="text-center text-muted-foreground py-6">No banners yet — click "New Banner"</TableCell></TableRow>)}
            {data.map(b => (
              <TableRow key={b.id}>
                <TableCell>
                  <div className="h-10 w-32 rounded flex items-center px-2 text-xs font-bold" style={{ background: b.bgColor, color: b.fgColor }}>
                    {b.title.slice(0, 18)}
                  </div>
                </TableCell>
                <TableCell className="font-medium">{b.title}</TableCell>
                <TableCell className="text-xs text-muted-foreground max-w-[200px] truncate">{b.subtitle}</TableCell>
                <TableCell className="text-xs">{b.ctaLabel || <span className="text-muted-foreground">—</span>}</TableCell>
                <TableCell>{b.position}</TableCell>
                <TableCell>{b.showOnMobile ? <Badge variant="default" className="bg-emerald-600">ON</Badge> : <Badge variant="secondary">OFF</Badge>}</TableCell>
                <TableCell>{b.showOnWeb ? <Badge variant="default" className="bg-emerald-600">ON</Badge> : <Badge variant="secondary">OFF</Badge>}</TableCell>
                <TableCell className="text-xs text-muted-foreground">
                  {b.startsAt || b.endsAt ? `${b.startsAt?.slice(0,10) || "—"} → ${b.endsAt?.slice(0,10) || "—"}` : "Always"}
                </TableCell>
                <TableCell><Switch checked={b.isActive} onCheckedChange={(v) => toggle.mutate({ id: b.id, isActive: v })} /></TableCell>
                <TableCell className="text-right">
                  <Button size="sm" variant="ghost" onClick={() => onEdit(b)}><Pencil className="h-3.5 w-3.5" /></Button>
                  <Button size="sm" variant="ghost" onClick={() => confirm("Delete?") && remove.mutate(b.id)}><Trash2 className="h-3.5 w-3.5 text-red-500" /></Button>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>

      <Dialog open={open} onOpenChange={setOpen}>
        <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
          <DialogHeader><DialogTitle>{editing?.id ? "Edit Banner" : "New Banner"}</DialogTitle></DialogHeader>
          {editing && (
            <div className="space-y-4">
              <div className="rounded-lg p-4 flex items-center" style={{ background: editing.bgColor }}>
                <div className="flex-1">
                  <div className="font-bold" style={{ color: editing.fgColor }}>{editing.title || "Title"}</div>
                  <div className="text-xs mt-1" style={{ color: editing.fgColor, opacity: 0.8 }}>{editing.subtitle || "Subtitle"}</div>
                </div>
                <div className="text-2xl" style={{ color: editing.fgColor }}>{editing.icon}</div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div><Label>Title *</Label><Input value={editing.title || ""} onChange={e => setEditing({ ...editing, title: e.target.value })} /></div>
                <div><Label>Position (sort)</Label><Input type="number" value={editing.position ?? 0} onChange={e => setEditing({ ...editing, position: Number(e.target.value) })} /></div>
              </div>
              <div><Label>Subtitle</Label><Input value={editing.subtitle || ""} onChange={e => setEditing({ ...editing, subtitle: e.target.value })} /></div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <Label>BG Color</Label>
                  <div className="flex gap-1 mt-1 flex-wrap">
                    {PRESET_COLORS.map(c => <button key={c} type="button" className="h-7 w-7 rounded border-2" style={{ background: c, borderColor: editing.bgColor === c ? "#000" : "transparent" }} onClick={() => setEditing({ ...editing, bgColor: c })} />)}
                  </div>
                  <Input className="mt-2" value={editing.bgColor || ""} onChange={e => setEditing({ ...editing, bgColor: e.target.value })} />
                </div>
                <div>
                  <Label>Text Color</Label>
                  <div className="flex gap-2 mt-1">
                    <button type="button" className="h-7 w-7 rounded border-2 bg-black" style={{ borderColor: editing.fgColor === "#000000" ? "#fcd535" : "transparent" }} onClick={() => setEditing({ ...editing, fgColor: "#000000" })} />
                    <button type="button" className="h-7 w-7 rounded border-2 bg-white" style={{ borderColor: editing.fgColor === "#ffffff" ? "#fcd535" : "transparent" }} onClick={() => setEditing({ ...editing, fgColor: "#ffffff" })} />
                  </div>
                  <Input className="mt-2" value={editing.fgColor || ""} onChange={e => setEditing({ ...editing, fgColor: e.target.value })} />
                </div>
              </div>

              <div>
                <Label>Icon</Label>
                <div className="flex gap-2 flex-wrap mt-1">
                  {ICONS.map(ic => <Button key={ic} type="button" size="sm" variant={editing.icon === ic ? "default" : "outline"} onClick={() => setEditing({ ...editing, icon: ic })}>{ic}</Button>)}
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div><Label>CTA Label</Label><Input value={editing.ctaLabel || ""} onChange={e => setEditing({ ...editing, ctaLabel: e.target.value })} placeholder="Trade Now" /></div>
                <div><Label>CTA URL / Route</Label><Input value={editing.ctaUrl || ""} onChange={e => setEditing({ ...editing, ctaUrl: e.target.value })} placeholder="/services/refer" /></div>
              </div>

              <div><Label>Image URL (optional)</Label><Input value={editing.imageUrl || ""} onChange={e => setEditing({ ...editing, imageUrl: e.target.value })} placeholder="https://..." /></div>

              <div className="grid grid-cols-2 gap-3">
                <div><Label>Starts At</Label><Input type="datetime-local" value={editing.startsAt?.slice(0,16) || ""} onChange={e => setEditing({ ...editing, startsAt: e.target.value || null })} /></div>
                <div><Label>Ends At</Label><Input type="datetime-local" value={editing.endsAt?.slice(0,16) || ""} onChange={e => setEditing({ ...editing, endsAt: e.target.value || null })} /></div>
              </div>

              <div className="flex items-center justify-between border-t pt-3">
                <div className="flex items-center gap-2"><Switch checked={!!editing.isActive} onCheckedChange={v => setEditing({ ...editing, isActive: v })} /><Label>Active</Label></div>
                <div className="flex items-center gap-2"><Switch checked={!!editing.showOnMobile} onCheckedChange={v => setEditing({ ...editing, showOnMobile: v })} /><Label>Show on Mobile</Label></div>
                <div className="flex items-center gap-2"><Switch checked={!!editing.showOnWeb} onCheckedChange={v => setEditing({ ...editing, showOnWeb: v })} /><Label>Show on Web</Label></div>
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
