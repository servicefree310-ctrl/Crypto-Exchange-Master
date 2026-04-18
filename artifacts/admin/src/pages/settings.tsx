import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, put } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useState, useMemo, useEffect } from "react";
import { IndianRupee } from "lucide-react";

type Setting = { key: string; value: string };

export default function SettingsPage() {
  const qc = useQueryClient();
  const { data = [] } = useQuery<Setting[]>({ queryKey: ["/admin/settings"], queryFn: () => get<Setting[]>("/admin/settings") });
  const save = useMutation({ mutationFn: ({ key, value }: { key: string; value: string }) => put(`/admin/settings/${encodeURIComponent(key)}`, { value }), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/settings"] }) });
  const inrSetting = useMemo(() => data.find(s => s.key === "inr_usdt_rate"), [data]);
  const [inrRate, setInrRate] = useState("");
  useEffect(() => { if (inrSetting && !inrRate) setInrRate(inrSetting.value); }, [inrSetting]); // eslint-disable-line
  const [newKey, setNewKey] = useState("");
  const [newVal, setNewVal] = useState("");

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
