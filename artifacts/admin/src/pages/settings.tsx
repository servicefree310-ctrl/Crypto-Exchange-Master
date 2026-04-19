import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, put } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useState, useMemo, useEffect } from "react";
import { IndianRupee, Percent, TrendingUp, Users } from "lucide-react";

type Setting = { key: string; value: string };

const FEE_KEYS = [
  { key: "spot.fee_percent",     label: "Spot Trading Fee",     hint: "Charged on both buy & sell (% of trade value)", def: "0.20", icon: Percent },
  { key: "spot.gst_percent",     label: "GST on Spot Fee",      hint: "GST applied on trading fee (India 18%)",       def: "18",   icon: Percent },
  { key: "tds.percent",          label: "TDS on Sell",          hint: "TDS deducted on sell value (India 1%)",        def: "1",    icon: Percent },
  { key: "futures.fee_percent",  label: "Futures Trading Fee",  hint: "Charged on position open + close (% of notional)", def: "0.05", icon: TrendingUp },
  { key: "futures.gst_percent",  label: "GST on Futures Fee",   hint: "GST applied on futures fee (India 18%)",       def: "18",   icon: Percent },
  { key: "referral.commission",  label: "Referral Commission",  hint: "% of referee's trading fee paid back to referrer", def: "20", icon: Users },
];

export default function SettingsPage() {
  const qc = useQueryClient();
  const { data = [] } = useQuery<Setting[]>({ queryKey: ["/admin/settings"], queryFn: () => get<Setting[]>("/admin/settings") });
  const save = useMutation({ mutationFn: ({ key, value }: { key: string; value: string }) => put(`/admin/settings/${encodeURIComponent(key)}`, { value }), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/settings"] }) });
  const inrSetting = useMemo(() => data.find(s => s.key === "inr_usdt_rate"), [data]);
  const [inrRate, setInrRate] = useState("");
  useEffect(() => { if (inrSetting && !inrRate) setInrRate(inrSetting.value); }, [inrSetting]); // eslint-disable-line
  const [newKey, setNewKey] = useState("");
  const [newVal, setNewVal] = useState("");

  const settingsMap = useMemo(() => Object.fromEntries(data.map(s => [s.key, s.value])), [data]);
  const [feeDraft, setFeeDraft] = useState<Record<string, string>>({});
  useEffect(() => {
    const init: Record<string, string> = {};
    FEE_KEYS.forEach(f => { init[f.key] = settingsMap[f.key] ?? ""; });
    setFeeDraft(init);
  }, [data]); // eslint-disable-line

  return (
    <div className="space-y-4">
      <Card className="p-4 border-primary/40 bg-primary/5">
        <div className="flex items-center gap-2 mb-2">
          <IndianRupee className="w-4 h-4 text-primary" />
          <Label className="text-base font-semibold">INR / USDT Rate (live broadcast)</Label>
        </div>
        <div className="text-xs text-muted-foreground mb-3">All app prices use this rate. Changes are pushed to mobile clients within 5s via the price feed.</div>
        <div className="flex gap-2 items-center">
          <Input value={inrRate} onChange={(e) => setInrRate(e.target.value)} placeholder="e.g. 84.50" className="max-w-xs" />
          <Button onClick={() => { if (inrRate) save.mutate({ key: "inr_usdt_rate", value: inrRate }); }} disabled={save.isPending}>Update Rate</Button>
          {inrSetting && <span className="text-xs text-muted-foreground">Current: ₹{inrSetting.value}</span>}
        </div>
      </Card>

      <Card className="p-4 border-orange-500/40 bg-orange-500/5">
        <div className="flex items-center gap-2 mb-1">
          <Percent className="w-4 h-4 text-orange-500" />
          <Label className="text-base font-semibold">Trading Fees, GST, TDS & Referral Commission</Label>
        </div>
        <div className="text-xs text-muted-foreground mb-4">
          Configure platform-wide fee rates. Mobile app pulls these every load and shows the breakdown to users at order time.
          GST applies on the trading fee (not trade value). TDS applies on sell value as per Indian crypto regulations.
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
          {FEE_KEYS.map(f => {
            const Icon = f.icon;
            const cur = settingsMap[f.key] ?? "";
            const draft = feeDraft[f.key] ?? "";
            const dirty = draft !== cur && draft !== "";
            return (
              <div key={f.key} className="rounded-lg border bg-card p-3">
                <div className="flex items-center gap-2 mb-1">
                  <Icon className="w-3.5 h-3.5 text-orange-500" />
                  <Label className="text-sm font-semibold">{f.label}</Label>
                  {cur && <span className="ml-auto text-xs text-muted-foreground">Now: {cur}%</span>}
                </div>
                <div className="text-[11px] text-muted-foreground mb-2">{f.hint}</div>
                <div className="flex gap-2 items-center">
                  <div className="relative flex-1">
                    <Input
                      type="number" step="0.01" min="0"
                      value={draft}
                      placeholder={`Default ${f.def}`}
                      onChange={(e) => setFeeDraft(d => ({ ...d, [f.key]: e.target.value }))}
                      className="pr-8"
                    />
                    <span className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">%</span>
                  </div>
                  <Button
                    size="sm"
                    disabled={!dirty || save.isPending}
                    onClick={() => save.mutate({ key: f.key, value: draft })}
                  >
                    Save
                  </Button>
                </div>
              </div>
            );
          })}
        </div>
      </Card>

      <Card className="p-4">
        <Label className="text-sm font-semibold mb-2 block">Add / Update Setting</Label>
        <div className="flex gap-2">
          <Input placeholder="Key" value={newKey} onChange={(e) => setNewKey(e.target.value)} />
          <Input placeholder="Value" value={newVal} onChange={(e) => setNewVal(e.target.value)} />
          <Button onClick={() => { if (newKey) { save.mutate({ key: newKey, value: newVal }); setNewKey(""); setNewVal(""); } }}>Save</Button>
        </div>
      </Card>

      <Card>
        <Table>
          <TableHeader><TableRow><TableHead>Key</TableHead><TableHead>Value</TableHead><TableHead></TableHead></TableRow></TableHeader>
          <TableBody>
            {data.map((s) => <Row key={s.key} setting={s} onSave={(v) => save.mutate({ key: s.key, value: v })} />)}
          </TableBody>
        </Table>
      </Card>
    </div>
  );
}

function Row({ setting, onSave }: { setting: Setting; onSave: (v: string) => void }) {
  const [v, setV] = useState(setting.value);
  useEffect(() => { setV(setting.value); }, [setting.value]);
  return (
    <TableRow>
      <TableCell className="font-mono text-xs">{setting.key}</TableCell>
      <TableCell><Input value={v} onChange={(e) => setV(e.target.value)} /></TableCell>
      <TableCell><Button size="sm" onClick={() => onSave(v)}>Save</Button></TableCell>
    </TableRow>
  );
}
