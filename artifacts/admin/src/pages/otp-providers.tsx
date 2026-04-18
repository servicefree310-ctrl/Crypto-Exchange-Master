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

type Provider = {
  id: number; channel: string; provider: string; apiKey: string | null;
  apiSecret: string | null; senderId: string | null; template: string | null; isActive: boolean;
};

export default function OtpProvidersPage() {
  const qc = useQueryClient();
  const { data = [] } = useQuery<Provider[]>({ queryKey: ["/admin/otp-providers"], queryFn: () => get<Provider[]>("/admin/otp-providers") });
  const [open, setOpen] = useState(false);
  const [v, setV] = useState<Partial<Provider>>({ channel: "sms", provider: "msg91", isActive: true });
  const create = useMutation({ mutationFn: () => post("/admin/otp-providers", v), onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/otp-providers"] }); setOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Partial<Provider> }) => patch(`/admin/otp-providers/${id}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/otp-providers"] }) });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/otp-providers/${id}`), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/otp-providers"] }) });

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <Dialog open={open} onOpenChange={setOpen}>
          <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Provider</Button></DialogTrigger>
          <DialogContent>
            <DialogHeader><DialogTitle>Add OTP provider</DialogTitle></DialogHeader>
            <div className="space-y-3">
              <div className="grid grid-cols-2 gap-3">
                <div><Label>Channel</Label>
                  <Select value={v.channel} onValueChange={(c) => setV({ ...v, channel: c })}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent><SelectItem value="sms">SMS</SelectItem><SelectItem value="email">Email</SelectItem><SelectItem value="whatsapp">WhatsApp</SelectItem></SelectContent>
                  </Select>
                </div>
                <div><Label>Provider</Label><Input value={v.provider || ""} onChange={(e) => setV({ ...v, provider: e.target.value })} placeholder="msg91, twilio, sendgrid" /></div>
                <div><Label>API Key</Label><Input value={v.apiKey || ""} onChange={(e) => setV({ ...v, apiKey: e.target.value })} /></div>
                <div><Label>API Secret</Label><Input value={v.apiSecret || ""} onChange={(e) => setV({ ...v, apiSecret: e.target.value })} /></div>
                <div><Label>Sender ID</Label><Input value={v.senderId || ""} onChange={(e) => setV({ ...v, senderId: e.target.value })} /></div>
                <div><Label>Template</Label><Input value={v.template || ""} onChange={(e) => setV({ ...v, template: e.target.value })} /></div>
              </div>
              <div className="flex items-center gap-2"><Switch checked={v.isActive} onCheckedChange={(c) => setV({ ...v, isActive: c })} /> <Label>Active</Label></div>
              <Button className="w-full" onClick={() => create.mutate()}>Save</Button>
            </div>
          </DialogContent>
        </Dialog>
      </div>
      <Card>
        <Table>
          <TableHeader><TableRow><TableHead>Channel</TableHead><TableHead>Provider</TableHead><TableHead>Sender</TableHead><TableHead>Active</TableHead><TableHead></TableHead></TableRow></TableHeader>
          <TableBody>
            {data.map((p) => (
              <TableRow key={p.id}>
                <TableCell><Badge>{p.channel}</Badge></TableCell>
                <TableCell className="font-medium">{p.provider}</TableCell>
                <TableCell>{p.senderId || "—"}</TableCell>
                <TableCell><Switch checked={p.isActive} onCheckedChange={(c) => update.mutate({ id: p.id, body: { isActive: c } })} /></TableCell>
                <TableCell><Button size="icon" variant="ghost" onClick={() => { if (confirm("Delete?")) remove.mutate(p.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button></TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>
    </div>
  );
}
