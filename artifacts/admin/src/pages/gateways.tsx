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
import { Plus, Trash2, Pencil, Zap, Copy, CheckCircle2 } from "lucide-react";
import { useState, useEffect } from "react";
import { useAuth } from "@/lib/auth";

type Gateway = {
  id: number; code: string; name: string; type: string; direction: string;
  provider: string; currency: string;
  minAmount: string; maxAmount: string; feeFlat: string; feePercent: string;
  processingTime: string; isAuto: boolean; status: string;
  apiKey: string | null; apiSecret: string | null; webhookSecret: string | null;
  testMode: boolean; logoUrl: string | null;
  config: string;
};

const GATEWAY_TYPES = ["upi", "imps", "neft", "rtgs", "bank", "wallet", "payment_gateway", "card"];
const PROVIDERS = [
  { value: "manual", label: "Manual (UTR-based)", auto: false },
  { value: "razorpay", label: "Razorpay (auto)", auto: true },
  { value: "payu", label: "PayU (manual config)", auto: false },
  { value: "cashfree", label: "Cashfree (manual config)", auto: false },
];

function GatewayForm({ initial, onSubmit, isEdit = false }: { initial?: Partial<Gateway>; onSubmit: (v: Partial<Gateway>) => void; isEdit?: boolean }) {
  const [v, setV] = useState<Partial<Gateway>>(initial || {
    type: "upi", direction: "deposit", provider: "manual", currency: "INR",
    processingTime: "Instant", isAuto: false, testMode: true, status: "active", config: "{}",
    minAmount: "100", maxAmount: "200000", feeFlat: "0", feePercent: "0",
  });
  const isRazorpay = v.provider === "razorpay";

  // When provider changes to razorpay, default to auto + payment_gateway type
  useEffect(() => {
    if (v.provider === "razorpay" && !isEdit) {
      setV(s => ({ ...s, isAuto: true, type: s.type === "upi" ? "payment_gateway" : s.type }));
    }
  }, [v.provider, isEdit]);

  const webhookUrl = isEdit && initial?.id
    ? `${window.location.origin.replace(/^https?:\/\/[^/]+$/, window.location.origin)}/api/webhooks/razorpay/${initial.id}`
    : null;

  return (
    <div className="space-y-4 max-h-[70vh] overflow-y-auto pr-2">
      {/* Provider banner */}
      <div className="rounded-md border bg-muted/30 p-3 space-y-2">
        <Label className="text-xs">Provider</Label>
        <Select value={v.provider} onValueChange={(p) => setV({ ...v, provider: p })}>
          <SelectTrigger data-testid="select-provider"><SelectValue /></SelectTrigger>
          <SelectContent>
            {PROVIDERS.map(p => <SelectItem key={p.value} value={p.value}>{p.label}</SelectItem>)}
          </SelectContent>
        </Select>
        {isRazorpay && <p className="text-xs text-muted-foreground">Razorpay creates orders, redirects user to checkout, and auto-credits the wallet on successful payment via webhook.</p>}
      </div>

      <div className="grid grid-cols-2 gap-3">
        <div><Label>Code (unique)</Label><Input value={v.code || ""} onChange={(e) => setV({ ...v, code: e.target.value })} disabled={isEdit} placeholder="razorpay_inr" data-testid="input-code" /></div>
        <div><Label>Display name</Label><Input value={v.name || ""} onChange={(e) => setV({ ...v, name: e.target.value })} placeholder="Razorpay" data-testid="input-name" /></div>
        <div><Label>Type</Label>
          <Select value={v.type} onValueChange={(t) => setV({ ...v, type: t })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>{GATEWAY_TYPES.map((t) => <SelectItem key={t} value={t}>{t.toUpperCase()}</SelectItem>)}</SelectContent>
          </Select>
        </div>
        <div><Label>Direction</Label>
          <Select value={v.direction} onValueChange={(t) => setV({ ...v, direction: t })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent><SelectItem value="deposit">Deposit</SelectItem><SelectItem value="withdraw">Withdraw</SelectItem></SelectContent>
          </Select>
        </div>
        <div><Label>Currency</Label>
          <Select value={v.currency || "INR"} onValueChange={(c) => setV({ ...v, currency: c })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent>{["INR","USD","EUR","AED","GBP"].map(c => <SelectItem key={c} value={c}>{c}</SelectItem>)}</SelectContent>
          </Select>
        </div>
        <div><Label>Status</Label>
          <Select value={v.status || "active"} onValueChange={(s) => setV({ ...v, status: s })}>
            <SelectTrigger><SelectValue /></SelectTrigger>
            <SelectContent><SelectItem value="active">Active</SelectItem><SelectItem value="paused">Paused</SelectItem></SelectContent>
          </Select>
        </div>
        <div><Label>Min amount</Label><Input value={v.minAmount || "0"} onChange={(e) => setV({ ...v, minAmount: e.target.value })} /></div>
        <div><Label>Max amount</Label><Input value={v.maxAmount || "0"} onChange={(e) => setV({ ...v, maxAmount: e.target.value })} /></div>
        <div><Label>Fee flat</Label><Input value={v.feeFlat || "0"} onChange={(e) => setV({ ...v, feeFlat: e.target.value })} /></div>
        <div><Label>Fee %</Label><Input value={v.feePercent || "0"} onChange={(e) => setV({ ...v, feePercent: e.target.value })} /></div>
        <div><Label>Processing time</Label><Input value={v.processingTime || ""} onChange={(e) => setV({ ...v, processingTime: e.target.value })} placeholder="Instant / 1-3 hours" /></div>
        <div><Label>Logo URL</Label><Input value={v.logoUrl || ""} onChange={(e) => setV({ ...v, logoUrl: e.target.value })} placeholder="https://…" /></div>
        <div className="flex items-center gap-2"><Switch checked={v.isAuto} onCheckedChange={(c) => setV({ ...v, isAuto: c })} /><Label>Auto-credit on success</Label></div>
        <div className="flex items-center gap-2"><Switch checked={v.testMode} onCheckedChange={(c) => setV({ ...v, testMode: c })} /><Label>Test mode</Label></div>
      </div>

      {/* Provider-specific credentials */}
      {isRazorpay && (
        <div className="rounded-md border border-primary/30 bg-primary/5 p-3 space-y-3">
          <div className="text-sm font-semibold flex items-center gap-2"><Zap className="w-4 h-4 text-primary" />Razorpay credentials</div>
          <div className="grid grid-cols-2 gap-3">
            <div><Label>Key ID (rzp_test_… / rzp_live_…)</Label><Input value={v.apiKey || ""} onChange={(e) => setV({ ...v, apiKey: e.target.value })} placeholder="rzp_test_xxxxxxxxxx" data-testid="input-rzp-key" /></div>
            <div><Label>Key Secret {isEdit && <span className="text-xs text-muted-foreground">(blank = unchanged)</span>}</Label><Input type="password" value={v.apiSecret || ""} onChange={(e) => setV({ ...v, apiSecret: e.target.value })} placeholder={isEdit ? "•••••••• stored" : "secret"} data-testid="input-rzp-secret" /></div>
            <div className="col-span-2"><Label>Webhook Secret {isEdit && <span className="text-xs text-muted-foreground">(blank = unchanged)</span>}</Label><Input type="password" value={v.webhookSecret || ""} onChange={(e) => setV({ ...v, webhookSecret: e.target.value })} placeholder="whsec_…" data-testid="input-rzp-whsec" /></div>
          </div>
          {webhookUrl && (
            <div className="text-xs space-y-1">
              <div className="flex items-center justify-between">
                <span className="text-muted-foreground">Configure this Webhook URL in Razorpay dashboard:</span>
                <Button size="sm" variant="ghost" onClick={() => navigator.clipboard.writeText(webhookUrl)}><Copy className="w-3 h-3 mr-1" />Copy</Button>
              </div>
              <code className="block bg-background border rounded p-2 break-all">{webhookUrl}</code>
              <div className="text-muted-foreground">Subscribe to events: <code>payment.captured</code>, <code>order.paid</code></div>
            </div>
          )}
        </div>
      )}

      <div>
        <Label>Config (JSON — extra fields like UPI ID / account no.)</Label>
        <Textarea rows={3} value={v.config || "{}"} onChange={(e) => setV({ ...v, config: e.target.value })} className="font-mono text-xs" />
      </div>

      <Button className="w-full" onClick={() => onSubmit(v)} data-testid="button-save">{isEdit ? "Save changes" : "Create gateway"}</Button>
    </div>
  );
}

function ProviderBadge({ p }: { p: string }) {
  if (p === "razorpay") return <Badge className="bg-blue-500/20 text-blue-500 border-blue-500/40"><Zap className="w-3 h-3 mr-1" />Razorpay</Badge>;
  if (p === "payu") return <Badge variant="outline" className="border-purple-500 text-purple-500">PayU</Badge>;
  if (p === "cashfree") return <Badge variant="outline" className="border-orange-500 text-orange-500">Cashfree</Badge>;
  return <Badge variant="secondary">Manual</Badge>;
}

export default function GatewaysPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data = [] } = useQuery<Gateway[]>({ queryKey: ["/admin/gateways"], queryFn: () => get<Gateway[]>("/admin/gateways") });
  const [open, setOpen] = useState(false);
  const [edit, setEdit] = useState<Gateway | null>(null);

  const create = useMutation({
    mutationFn: (v: Partial<Gateway>) => post("/admin/gateways", v),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/gateways"] }); setOpen(false); },
  });
  const update = useMutation({
    mutationFn: ({ id, body }: { id: number; body: Partial<Gateway> }) => patch(`/admin/gateways/${id}`, body),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["/admin/gateways"] }); setEdit(null); },
  });
  const remove = useMutation({
    mutationFn: (id: number) => del(`/admin/gateways/${id}`),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/gateways"] }),
  });

  const razorpayCount = data.filter(g => g.provider === "razorpay").length;
  const autoCount = data.filter(g => g.isAuto).length;

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <Card className="p-3"><div className="text-xs text-muted-foreground">Total Gateways</div><div className="text-xl font-bold">{data.length}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Active</div><div className="text-xl font-bold">{data.filter(g => g.status === "active").length}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Razorpay</div><div className="text-xl font-bold text-blue-500">{razorpayCount}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Auto-credit</div><div className="text-xl font-bold text-green-500">{autoCount}</div></Card>
      </div>

      <div className="flex justify-between items-center">
        <div className="text-sm text-muted-foreground">{data.length} gateways configured</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button data-testid="button-add"><Plus className="w-4 h-4 mr-1" /> Add Gateway</Button></DialogTrigger>
            <DialogContent className="max-w-2xl" aria-describedby={undefined}>
              <DialogHeader><DialogTitle>Add payment gateway</DialogTitle></DialogHeader>
              <GatewayForm onSubmit={(v) => create.mutate(v)} />
            </DialogContent>
          </Dialog>
        )}
      </div>

      <Card>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader><TableRow>
              <TableHead>Code</TableHead><TableHead>Name</TableHead><TableHead>Provider</TableHead>
              <TableHead>Type</TableHead><TableHead>Direction</TableHead>
              <TableHead>Min/Max</TableHead><TableHead>Fee</TableHead>
              <TableHead>Mode</TableHead><TableHead>Status</TableHead>
              {isAdmin && <TableHead></TableHead>}
            </TableRow></TableHeader>
            <TableBody>
              {data.length === 0 && <TableRow><TableCell colSpan={isAdmin ? 10 : 9} className="text-center py-6 text-muted-foreground">No gateways. Click "Add Gateway" to create one (Razorpay, manual UPI, etc.)</TableCell></TableRow>}
              {data.map((g) => (
                <TableRow key={g.id} data-testid={`gw-${g.id}`}>
                  <TableCell className="font-mono text-xs">{g.code}</TableCell>
                  <TableCell className="font-medium">{g.name}</TableCell>
                  <TableCell><ProviderBadge p={g.provider} /></TableCell>
                  <TableCell><Badge variant="outline">{g.type.toUpperCase()}</Badge></TableCell>
                  <TableCell><Badge>{g.direction}</Badge></TableCell>
                  <TableCell className="tabular-nums text-xs">{g.currency} {g.minAmount} – {g.maxAmount}</TableCell>
                  <TableCell className="text-xs">{g.feeFlat} + {g.feePercent}%</TableCell>
                  <TableCell>
                    <div className="flex flex-col gap-1">
                      {g.isAuto ? <Badge className="bg-green-500/20 text-green-500 border-green-500/40"><CheckCircle2 className="w-3 h-3 mr-1" />Auto</Badge> : <Badge variant="secondary">Manual</Badge>}
                      {g.testMode && <Badge variant="outline" className="text-[10px] border-yellow-500 text-yellow-500">TEST</Badge>}
                    </div>
                  </TableCell>
                  <TableCell>
                    {isAdmin ? (
                      <Switch checked={g.status === "active"} onCheckedChange={(c) => update.mutate({ id: g.id, body: { status: c ? "active" : "paused" } })} data-testid={`switch-status-${g.id}`} />
                    ) : <Badge>{g.status}</Badge>}
                  </TableCell>
                  {isAdmin && (
                    <TableCell className="text-right space-x-1">
                      <Button size="icon" variant="ghost" onClick={() => setEdit(g)} data-testid={`button-edit-${g.id}`}><Pencil className="w-4 h-4" /></Button>
                      <Button size="icon" variant="ghost" onClick={() => { if (confirm(`Delete gateway "${g.name}"?`)) remove.mutate(g.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button>
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
          <DialogContent className="max-w-2xl" aria-describedby={undefined}>
            <DialogHeader><DialogTitle>Edit: {edit.name}</DialogTitle></DialogHeader>
            <GatewayForm
              initial={{ ...edit, apiSecret: "", webhookSecret: "" }}
              isEdit
              onSubmit={(v) => update.mutate({ id: edit.id, body: v })}
            />
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
