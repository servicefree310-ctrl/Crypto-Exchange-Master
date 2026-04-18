import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useState } from "react";
import { useAuth } from "@/lib/auth";

type Kyc = {
  id: number; userId: number; level: number; status: string;
  fullName: string | null; panNumber: string | null; aadhaarNumber: string | null;
  rejectReason: string | null; createdAt: string;
};
type KycSetting = { level: number; depositLimit: string; withdrawLimit: string; tradeLimit: string; features: string };

export default function KycPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const [tab, setTab] = useState("pending");
  const { data: records = [] } = useQuery<Kyc[]>({ queryKey: ["/admin/kyc", tab], queryFn: () => get<Kyc[]>(`/admin/kyc?status=${tab}`) });
  const { data: settings = [] } = useQuery<KycSetting[]>({ queryKey: ["/admin/kyc-settings"], queryFn: () => get<KycSetting[]>("/admin/kyc-settings") });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Record<string, unknown> }) => patch(`/admin/kyc/${id}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/kyc"] }) });
  const updateSetting = useMutation({ mutationFn: ({ level, body }: { level: number; body: Partial<KycSetting> }) => patch(`/admin/kyc-settings/${level}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/kyc-settings"] }) });

  return (
    <Tabs defaultValue="reviews" className="space-y-4">
      <TabsList>
        <TabsTrigger value="reviews">Reviews</TabsTrigger>
        <TabsTrigger value="settings">Level Settings</TabsTrigger>
      </TabsList>
      <TabsContent value="reviews" className="space-y-4">
        <Tabs value={tab} onValueChange={setTab}>
          <TabsList>
            <TabsTrigger value="pending">Pending</TabsTrigger>
            <TabsTrigger value="approved">Approved</TabsTrigger>
            <TabsTrigger value="rejected">Rejected</TabsTrigger>
          </TabsList>
        </Tabs>
        <Card>
          <div className="overflow-x-auto">
            <Table>
              <TableHeader><TableRow>
                <TableHead>User ID</TableHead><TableHead>Level</TableHead><TableHead>Name</TableHead>
                <TableHead>PAN</TableHead><TableHead>Aadhaar</TableHead><TableHead>Status</TableHead>
                <TableHead>Submitted</TableHead><TableHead>Actions</TableHead>
              </TableRow></TableHeader>
              <TableBody>
                {records.map((r) => (
                  <TableRow key={r.id}>
                    <TableCell>#{r.userId}</TableCell>
                    <TableCell><Badge>L{r.level}</Badge></TableCell>
                    <TableCell>{r.fullName || "—"}</TableCell>
                    <TableCell className="font-mono text-xs">{r.panNumber || "—"}</TableCell>
                    <TableCell className="font-mono text-xs">{r.aadhaarNumber ? "XXXX " + r.aadhaarNumber.slice(-4) : "—"}</TableCell>
                    <TableCell><Badge variant={r.status === "approved" ? "default" : r.status === "rejected" ? "destructive" : "secondary"}>{r.status}</Badge></TableCell>
                    <TableCell className="text-xs">{new Date(r.createdAt).toLocaleDateString("en-IN")}</TableCell>
                    <TableCell className="space-x-1">
                      {isAdmin && r.status === "pending" && (
                        <>
                          <Button size="sm" onClick={() => update.mutate({ id: r.id, body: { status: "approved" } })}>Approve</Button>
                          <Button size="sm" variant="destructive" onClick={() => {
                            const reason = prompt("Reject reason?");
                            if (reason) update.mutate({ id: r.id, body: { status: "rejected", rejectReason: reason } });
                          }}>Reject</Button>
                        </>
                      )}
                      {r.rejectReason && <span className="text-xs text-destructive">{r.rejectReason}</span>}
                    </TableCell>
                  </TableRow>
                ))}
                {records.length === 0 && <TableRow><TableCell colSpan={8} className="text-center py-6 text-muted-foreground">No records</TableCell></TableRow>}
              </TableBody>
            </Table>
          </div>
        </Card>
      </TabsContent>
      <TabsContent value="settings">
        <Card>
          <div className="overflow-x-auto">
            <Table>
              <TableHeader><TableRow>
                <TableHead>Level</TableHead><TableHead>Daily Deposit (₹)</TableHead>
                <TableHead>Daily Withdraw (₹)</TableHead><TableHead>Daily Trade (₹)</TableHead>
                <TableHead>Features (JSON array)</TableHead>{isAdmin && <TableHead></TableHead>}
              </TableRow></TableHeader>
              <TableBody>
                {settings.map((s) => (
                  <KycSettingRow key={s.level} setting={s} isAdmin={isAdmin} onSave={(body) => updateSetting.mutate({ level: s.level, body })} />
                ))}
              </TableBody>
            </Table>
          </div>
        </Card>
      </TabsContent>
    </Tabs>
  );
}

function KycSettingRow({ setting, isAdmin, onSave }: { setting: KycSetting; isAdmin: boolean; onSave: (b: Partial<KycSetting>) => void }) {
  const [v, setV] = useState(setting);
  return (
    <TableRow>
      <TableCell><Badge>L{setting.level}</Badge></TableCell>
      <TableCell><Input value={v.depositLimit} onChange={(e) => setV({ ...v, depositLimit: e.target.value })} disabled={!isAdmin} /></TableCell>
      <TableCell><Input value={v.withdrawLimit} onChange={(e) => setV({ ...v, withdrawLimit: e.target.value })} disabled={!isAdmin} /></TableCell>
      <TableCell><Input value={v.tradeLimit} onChange={(e) => setV({ ...v, tradeLimit: e.target.value })} disabled={!isAdmin} /></TableCell>
      <TableCell><Input value={v.features} onChange={(e) => setV({ ...v, features: e.target.value })} disabled={!isAdmin} /></TableCell>
      {isAdmin && <TableCell><Button size="sm" onClick={() => onSave(v)}>Save</Button></TableCell>}
    </TableRow>
  );
}
void Label;
