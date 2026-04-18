import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, put } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { useState } from "react";

type Setting = { key: string; value: string };

export default function SettingsPage() {
  const qc = useQueryClient();
  const { data = [] } = useQuery<Setting[]>({ queryKey: ["/admin/settings"], queryFn: () => get<Setting[]>("/admin/settings") });
  const save = useMutation({ mutationFn: ({ key, value }: { key: string; value: string }) => put(`/admin/settings/${encodeURIComponent(key)}`, { value }), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/settings"] }) });
  const [newKey, setNewKey] = useState("");
  const [newVal, setNewVal] = useState("");

  return (
    <div className="space-y-4">
      <Card className="p-4 flex gap-2">
        <Input placeholder="Key" value={newKey} onChange={(e) => setNewKey(e.target.value)} />
        <Input placeholder="Value" value={newVal} onChange={(e) => setNewVal(e.target.value)} />
        <Button onClick={() => { if (newKey) { save.mutate({ key: newKey, value: newVal }); setNewKey(""); setNewVal(""); } }}>Add / Update</Button>
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
  return (
    <TableRow>
      <TableCell className="font-mono text-xs">{setting.key}</TableCell>
      <TableCell><Input value={v} onChange={(e) => setV(e.target.value)} /></TableCell>
      <TableCell><Button size="sm" onClick={() => onSave(v)}>Save</Button></TableCell>
    </TableRow>
  );
}
