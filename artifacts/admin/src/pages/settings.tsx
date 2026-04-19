import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, put } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useState, useMemo, useEffect } from "react";
import { IndianRupee, Percent, TrendingUp, Users, Crown, Plus, Trash2, RotateCcw } from "lucide-react";

type Setting = { key: string; value: string };

interface VipTier {
  level: number; name: string; minVolume: number;
  spotMaker: number; spotTaker: number;
  futuresMaker: number; futuresTaker: number;
  withdrawDiscount: number;
}

const DEFAULT_TIERS: VipTier[] = [
  { level: 0, name: "Regular", minVolume: 0,        spotMaker: 0.20, spotTaker: 0.25, futuresMaker: 0.05, futuresTaker: 0.07, withdrawDiscount: 0 },
  { level: 1, name: "VIP 1",   minVolume: 100000,   spotMaker: 0.16, spotTaker: 0.20, futuresMaker: 0.04, futuresTaker: 0.06, withdrawDiscount: 5 },
  { level: 2, name: "VIP 2",   minVolume: 500000,   spotMaker: 0.12, spotTaker: 0.15, futuresMaker: 0.03, futuresTaker: 0.05, withdrawDiscount: 10 },
  { level: 3, name: "VIP 3",   minVolume: 2500000,  spotMaker: 0.08, spotTaker: 0.10, futuresMaker: 0.02, futuresTaker: 0.04, withdrawDiscount: 15 },
  { level: 4, name: "VIP 4",   minVolume: 10000000, spotMaker: 0.06, spotTaker: 0.08, futuresMaker: 0.015,futuresTaker: 0.03, withdrawDiscount: 20 },
  { level: 5, name: "VIP 5",   minVolume: 50000000, spotMaker: 0.04, spotTaker: 0.06, futuresMaker: 0.01, futuresTaker: 0.025,withdrawDiscount: 25 },
];

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

      <VipTierEditor data={data} save={save} />

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

function VipTierEditor({ data, save }: { data: Setting[]; save: any }) {
  const stored = useMemo(() => data.find(s => s.key === "fees.vip_tiers")?.value, [data]);
  const [tiers, setTiers] = useState<VipTier[]>(DEFAULT_TIERS);
  const [dirty, setDirty] = useState(false);

  useEffect(() => {
    if (stored) {
      try {
        const parsed = JSON.parse(stored);
        if (Array.isArray(parsed) && parsed.length > 0) { setTiers(parsed); setDirty(false); return; }
      } catch {}
    }
    setTiers(DEFAULT_TIERS);
  }, [stored]);

  const updateField = (idx: number, field: keyof VipTier, raw: string) => {
    setTiers(prev => prev.map((t, i) => {
      if (i !== idx) return t;
      const v = field === "name" ? raw : (raw === "" ? 0 : Number(raw));
      return { ...t, [field]: v };
    }));
    setDirty(true);
  };

  const addTier = () => {
    const last = tiers[tiers.length - 1];
    setTiers(prev => [...prev, {
      level: (last?.level ?? -1) + 1,
      name: `VIP ${(last?.level ?? -1) + 1}`,
      minVolume: (last?.minVolume ?? 0) * 5 || 100000,
      spotMaker: (last?.spotMaker ?? 0.20) * 0.8,
      spotTaker: (last?.spotTaker ?? 0.25) * 0.8,
      futuresMaker: (last?.futuresMaker ?? 0.05) * 0.8,
      futuresTaker: (last?.futuresTaker ?? 0.07) * 0.8,
      withdrawDiscount: Math.min(50, (last?.withdrawDiscount ?? 0) + 5),
    }]);
    setDirty(true);
  };

  const removeTier = (idx: number) => {
    setTiers(prev => prev.filter((_, i) => i !== idx));
    setDirty(true);
  };

  const reset = () => { setTiers(DEFAULT_TIERS); setDirty(true); };

  const persist = () => {
    const sorted = [...tiers].sort((a, b) => a.level - b.level).map((t, i) => ({ ...t, level: i }));
    save.mutate({ key: "fees.vip_tiers", value: JSON.stringify(sorted) }, {
      onSuccess: () => setDirty(false),
    });
  };

  const fmtVol = (v: number) => v >= 1e6 ? `${(v/1e6).toFixed(v % 1e6 ? 2 : 0)}M` : v >= 1e3 ? `${(v/1e3).toFixed(0)}K` : String(v);

  return (
    <Card className="p-4 border-yellow-500/40 bg-yellow-500/5">
      <div className="flex items-center gap-2 mb-1">
        <Crown className="w-4 h-4 text-yellow-500" />
        <Label className="text-base font-semibold">Volume-Based VIP Fee Schedule</Label>
        <span className="ml-auto flex gap-2">
          <Button size="sm" variant="outline" onClick={reset} title="Reset to defaults">
            <RotateCcw className="w-3 h-3 mr-1" /> Reset
          </Button>
          <Button size="sm" onClick={persist} disabled={!dirty || save.isPending}>
            Save Schedule
          </Button>
        </span>
      </div>
      <div className="text-xs text-muted-foreground mb-3">
        Users automatically promoted to higher tier based on 30-day trading volume (USDT). Lower fees + bigger withdraw discount at higher VIP.
        Fee values are in <span className="font-semibold text-yellow-500">percent</span> (e.g. 0.20 = 0.20%).
      </div>

      <div className="overflow-x-auto rounded-lg border bg-card">
        <Table>
          <TableHeader>
            <TableRow className="bg-muted/40">
              <TableHead className="w-14 text-xs">Lvl</TableHead>
              <TableHead className="w-28 text-xs">Name</TableHead>
              <TableHead className="text-xs">30d Vol ≥ (USDT)</TableHead>
              <TableHead className="text-xs text-blue-500">Spot Maker %</TableHead>
              <TableHead className="text-xs text-blue-600">Spot Taker %</TableHead>
              <TableHead className="text-xs text-orange-500">Fut Maker %</TableHead>
              <TableHead className="text-xs text-orange-600">Fut Taker %</TableHead>
              <TableHead className="text-xs text-green-600">Withdraw −%</TableHead>
              <TableHead className="w-10"></TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {tiers.map((t, idx) => (
              <TableRow key={idx} className="hover:bg-muted/20">
                <TableCell className="text-center font-mono text-sm font-bold text-yellow-500">{idx}</TableCell>
                <TableCell><Input className="h-8" value={t.name} onChange={e => updateField(idx, "name", e.target.value)} /></TableCell>
                <TableCell>
                  <div className="flex items-center gap-1">
                    <Input className="h-8 w-32 font-mono text-xs" type="number" min="0" step="1000"
                      value={t.minVolume} onChange={e => updateField(idx, "minVolume", e.target.value)} />
                    <span className="text-[10px] text-muted-foreground w-10">{fmtVol(t.minVolume)}</span>
                  </div>
                </TableCell>
                <TableCell><Input className="h-8 w-20" type="number" step="0.001" min="0"
                  value={t.spotMaker} onChange={e => updateField(idx, "spotMaker", e.target.value)} /></TableCell>
                <TableCell><Input className="h-8 w-20" type="number" step="0.001" min="0"
                  value={t.spotTaker} onChange={e => updateField(idx, "spotTaker", e.target.value)} /></TableCell>
                <TableCell><Input className="h-8 w-20" type="number" step="0.001" min="0"
                  value={t.futuresMaker} onChange={e => updateField(idx, "futuresMaker", e.target.value)} /></TableCell>
                <TableCell><Input className="h-8 w-20" type="number" step="0.001" min="0"
                  value={t.futuresTaker} onChange={e => updateField(idx, "futuresTaker", e.target.value)} /></TableCell>
                <TableCell><Input className="h-8 w-20" type="number" step="1" min="0" max="100"
                  value={t.withdrawDiscount} onChange={e => updateField(idx, "withdrawDiscount", e.target.value)} /></TableCell>
                <TableCell>
                  {tiers.length > 1 && (
                    <Button size="icon" variant="ghost" className="h-7 w-7 text-destructive hover:bg-destructive/10"
                      onClick={() => removeTier(idx)}>
                      <Trash2 className="w-3.5 h-3.5" />
                    </Button>
                  )}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      <div className="flex items-center justify-between mt-3">
        <Button size="sm" variant="outline" onClick={addTier}>
          <Plus className="w-3.5 h-3.5 mr-1" /> Add Tier
        </Button>
        {dirty && <span className="text-xs text-yellow-600 font-semibold">⚠ Unsaved changes — click "Save Schedule" to apply</span>}
      </div>
    </Card>
  );
}
