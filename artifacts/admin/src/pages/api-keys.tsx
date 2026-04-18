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
import { Plus, Trash2, Pencil, KeyRound } from "lucide-react";
import { useState } from "react";
import { useAuth } from "@/lib/auth";

type ApiKey = {
  id: number; provider: string; label: string;
  apiKey: string; apiSecret: string; baseUrl: string | null;
  isActive: string; createdAt: string;
};

function ApiKeyForm({ initial, onSubmit }: { initial?: Partial<ApiKey>; onSubmit: (v: Partial<ApiKey>) => void }) {
  const [v, setV] = useState<Partial<ApiKey>>(initial || { provider: "binance", isActive: "true" });
  return (
    <div className="space-y-3">
      <div className="grid grid-cols-2 gap-3">
        <div><Label>Provider</Label><Input value={v.provider || ""} onChange={(e) => setV({ ...v, provider: e.target.value })} /></div>
        <div><Label>Label</Label><Input value={v.label || ""} onChange={(e) => setV({ ...v, label: e.target.value })} /></div>
        <div className="col-span-2"><Label>API Key {initial && <span className="text-xs text-muted-foreground">(leave blank to keep existing)</span>}</Label><Input value={v.apiKey || ""} onChange={(e) => setV({ ...v, apiKey: e.target.value })} /></div>
        <div className="col-span-2"><Label>API Secret {initial && <span className="text-xs text-muted-foreground">(leave blank to keep existing)</span>}</Label><Input type="password" value={v.apiSecret || ""} onChange={(e) => setV({ ...v, apiSecret: e.target.value })} /></div>
        <div className="col-span-2"><Label>Base URL (optional)</Label><Input value={v.baseUrl || ""} onChange={(e) => setV({ ...v, baseUrl: e.target.value })} /></div>
      </div>
      <label className="flex items-center gap-2 pt-1"><Switch checked={v.isActive === "true"} onCheckedChange={(c) => setV({ ...v, isActive: c ? "true" : "false" })} /> Active</label>
      <Button className="w-full" onClick={() => onSubmit(v)}>Save</Button>
    </div>
  );
}

export default function ApiKeysPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data = [] } = useQuery<ApiKey[]>({ queryKey: ["/admin/api-keys"], queryFn: () => get<ApiKey[]>("/admin/api-keys"), enabled: isAdmin });
  const [open, setOpen] = useState(false);
  const [edit, setEdit] = useState<ApiKey | null>(null);
  const create = useMutation({ mutationFn: (v: Partial<ApiKey>) => post("/admin/api-keys", v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/api-keys"] }); setOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Partial<ApiKey> }) => patch(`/admin/api-keys/${id}`, body), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/api-keys"] }); setEdit(null); } });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/api-keys/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/api-keys"] }) });

  if (!isAdmin) return <Card className="p-6 text-center text-muted-foreground">Admin only</Card>;

  return (
    <div className="space-y-4">
      <div className="flex justify-between items-center">
        <div className="text-sm text-muted-foreground flex items-center gap-2"><KeyRound className="w-4 h-4" /> {data.length} API keys</div>
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add API Key</Button></DialogTrigger>
          <DialogContent>
            <DialogHeader><DialogTitle>Add API key</DialogTitle></DialogHeader>
            <ApiKeyForm onSubmit={(v) => create.mutate(v)} />
          </DialogContent>
        </Dialog>
      </div>
      <Card>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader><TableRow>
              <TableHead>Provider</TableHead><TableHead>Label</TableHead>
              <TableHead>API Key</TableHead><TableHead>Secret</TableHead>
              <TableHead>Base URL</TableHead><TableHead>Active</TableHead>
              <TableHead>Created</TableHead><TableHead></TableHead>
            </TableRow></TableHeader>
            <TableBody>
              {data.length === 0 && <TableRow><TableCell colSpan={8} className="text-center text-muted-foreground py-6">No API keys yet</TableCell></TableRow>}
              {data.map((k) => (
                <TableRow key={k.id}>
                  <TableCell><Badge>{k.provider}</Badge></TableCell>
                  <TableCell>{k.label}</TableCell>
                  <TableCell className="font-mono text-xs">{k.apiKey || "—"}</TableCell>
                  <TableCell className="font-mono text-xs">{k.apiSecret || "—"}</TableCell>
                  <TableCell className="text-xs">{k.baseUrl || "—"}</TableCell>
                  <TableCell><Switch checked={k.isActive === "true"} onCheckedChange={(c) => update.mutate({ id: k.id, body: { isActive: c ? "true" : "false" } })} /></TableCell>
                  <TableCell className="text-xs text-muted-foreground">{new Date(k.createdAt).toLocaleDateString("en-IN")}</TableCell>
                  <TableCell className="text-right space-x-1">
                    <Button size="icon" variant="ghost" onClick={() => setEdit(k)}><Pencil className="w-4 h-4" /></Button>
                    <Button size="icon" variant="ghost" onClick={() => { if (confirm(`Delete ${k.provider}/${k.label}?`)) remove.mutate(k.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </Card>
      {edit && (
        <Dialog open={!!edit} onOpenChange={(o) => !o && setEdit(null)}>
          <DialogContent>
            <DialogHeader><DialogTitle>Edit {edit.provider}/{edit.label}</DialogTitle></DialogHeader>
            <ApiKeyForm initial={{ ...edit, apiKey: "", apiSecret: "" }} onSubmit={(v) => update.mutate({ id: edit.id, body: v })} />
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
