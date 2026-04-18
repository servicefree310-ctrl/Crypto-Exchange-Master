import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { useAuth } from "@/lib/auth";
import { useState } from "react";
import { Input } from "@/components/ui/input";
import { Search, ShieldCheck, ShieldAlert, Eye } from "lucide-react";

type User = {
  id: number; email: string; name: string; phone: string | null;
  role: string; status: string; kycLevel: number; vipTier: number;
  uid: string; referralCode: string; createdAt: string; twoFaEnabled: boolean;
};

type Dossier = {
  user: User;
  security: { twoFaEnabled: boolean; activeSessions: number; lastSessionAt: string | null };
  kyc: any[]; wallets: any[]; sessions: any[];
  inrDeposits: any[]; cryptoDeposits: any[]; inrWithdrawals: any[]; cryptoWithdrawals: any[];
};

const ROLES = ["user", "support", "admin", "superadmin"];
const STATUSES = ["active", "suspended", "banned"];

export default function UsersPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const [search, setSearch] = useState("");
  const [view, setView] = useState<number | null>(null);
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";

  const { data = [], isLoading } = useQuery<User[]>({
    queryKey: ["/admin/users-search", search],
    queryFn: () => get<User[]>(`/admin/users-search?q=${encodeURIComponent(search)}&limit=200`),
  });

  const update = useMutation({
    mutationFn: ({ id, body }: { id: number; body: Partial<User> }) => patch(`/admin/users/${id}`, body),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/users-search"] }),
  });

  const dossier = useQuery<Dossier>({
    queryKey: ["/admin/users", view, "full"],
    queryFn: () => get<Dossier>(`/admin/users/${view}/full`),
    enabled: view !== null,
  });

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-3">
        <div className="relative max-w-sm flex-1">
          <Search className="w-4 h-4 absolute left-2.5 top-2.5 text-muted-foreground" />
          <Input placeholder="Search by email, UID, phone, name, referral…" value={search} onChange={(e) => setSearch(e.target.value)} className="pl-8" />
        </div>
        <div className="text-sm text-muted-foreground">{data.length} users</div>
      </div>

      <Card className="overflow-hidden">
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>UID</TableHead>
                <TableHead>Email / Name</TableHead>
                <TableHead>Phone</TableHead>
                <TableHead>2FA</TableHead>
                <TableHead>Role</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>KYC</TableHead>
                <TableHead>VIP</TableHead>
                <TableHead>Created</TableHead>
                <TableHead></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading && <TableRow><TableCell colSpan={10} className="text-center text-muted-foreground py-6">Loading…</TableCell></TableRow>}
              {data.map((u) => (
                <TableRow key={u.id}>
                  <TableCell className="font-mono text-xs">{u.uid}</TableCell>
                  <TableCell>
                    <div className="font-medium">{u.email}</div>
                    {u.name && <div className="text-xs text-muted-foreground">{u.name}</div>}
                  </TableCell>
                  <TableCell>{u.phone || "—"}</TableCell>
                  <TableCell>
                    {u.twoFaEnabled
                      ? <span className="inline-flex items-center gap-1 text-xs text-green-600"><ShieldCheck className="w-3 h-3" />ON</span>
                      : <span className="inline-flex items-center gap-1 text-xs text-muted-foreground"><ShieldAlert className="w-3 h-3" />OFF</span>}
                  </TableCell>
                  <TableCell>
                    {isAdmin ? (
                      <Select value={u.role} onValueChange={(v) => update.mutate({ id: u.id, body: { role: v } })}>
                        <SelectTrigger className="h-8 w-32"><SelectValue /></SelectTrigger>
                        <SelectContent>{ROLES.map((r) => <SelectItem key={r} value={r}>{r}</SelectItem>)}</SelectContent>
                      </Select>
                    ) : <Badge variant="outline">{u.role}</Badge>}
                  </TableCell>
                  <TableCell>
                    {isAdmin ? (
                      <Select value={u.status} onValueChange={(v) => update.mutate({ id: u.id, body: { status: v } })}>
                        <SelectTrigger className="h-8 w-32"><SelectValue /></SelectTrigger>
                        <SelectContent>{STATUSES.map((r) => <SelectItem key={r} value={r}>{r}</SelectItem>)}</SelectContent>
                      </Select>
                    ) : <Badge variant={u.status === "active" ? "default" : "destructive"}>{u.status}</Badge>}
                  </TableCell>
                  <TableCell>
                    {isAdmin ? (
                      <Select value={String(u.kycLevel)} onValueChange={(v) => update.mutate({ id: u.id, body: { kycLevel: Number(v) } })}>
                        <SelectTrigger className="h-8 w-20"><SelectValue /></SelectTrigger>
                        <SelectContent>{[0,1,2,3].map((r) => <SelectItem key={r} value={String(r)}>L{r}</SelectItem>)}</SelectContent>
                      </Select>
                    ) : <Badge>L{u.kycLevel}</Badge>}
                  </TableCell>
                  <TableCell>
                    {isAdmin ? (
                      <Select value={String(u.vipTier)} onValueChange={(v) => update.mutate({ id: u.id, body: { vipTier: Number(v) } })}>
                        <SelectTrigger className="h-8 w-20"><SelectValue /></SelectTrigger>
                        <SelectContent>{[0,1,2,3,4,5].map((r) => <SelectItem key={r} value={String(r)}>V{r}</SelectItem>)}</SelectContent>
                      </Select>
                    ) : <Badge variant="outline">V{u.vipTier}</Badge>}
                  </TableCell>
                  <TableCell className="text-xs text-muted-foreground">{new Date(u.createdAt).toLocaleDateString("en-IN")}</TableCell>
                  <TableCell><Button size="icon" variant="ghost" onClick={() => setView(u.id)}><Eye className="w-4 h-4" /></Button></TableCell>
                </TableRow>
              ))}
              {!isLoading && data.length === 0 && (
                <TableRow><TableCell colSpan={10} className="text-center text-muted-foreground py-6">No users</TableCell></TableRow>
              )}
            </TableBody>
          </Table>
        </div>
      </Card>

      <Dialog open={view !== null} onOpenChange={(o) => !o && setView(null)}>
        <DialogContent className="max-w-3xl max-h-[85vh] overflow-y-auto">
          <DialogHeader><DialogTitle>User Dossier</DialogTitle></DialogHeader>
          {dossier.isLoading && <div className="text-center text-muted-foreground py-6">Loading…</div>}
          {dossier.data && (
            <div className="space-y-4 text-sm">
              <Card className="p-3 grid grid-cols-2 gap-x-6 gap-y-2">
                <div><span className="text-muted-foreground">UID:</span> <span className="font-mono">{dossier.data.user.uid}</span></div>
                <div><span className="text-muted-foreground">Email:</span> {dossier.data.user.email}</div>
                <div><span className="text-muted-foreground">Phone:</span> {dossier.data.user.phone || "—"}</div>
                <div><span className="text-muted-foreground">Name:</span> {dossier.data.user.name || "—"}</div>
                <div><span className="text-muted-foreground">Role:</span> {dossier.data.user.role}</div>
                <div><span className="text-muted-foreground">Status:</span> {dossier.data.user.status}</div>
                <div><span className="text-muted-foreground">KYC:</span> L{dossier.data.user.kycLevel}</div>
                <div><span className="text-muted-foreground">VIP:</span> V{dossier.data.user.vipTier}</div>
                <div><span className="text-muted-foreground">2FA:</span> {dossier.data.security.twoFaEnabled ? <Badge variant="default">Enabled</Badge> : <Badge variant="secondary">Off</Badge>}</div>
                <div><span className="text-muted-foreground">Active sessions:</span> {dossier.data.security.activeSessions}</div>
              </Card>

              <Section title={`KYC Records (${dossier.data.kyc.length})`}>
                {dossier.data.kyc.length === 0 ? <Empty /> : dossier.data.kyc.map((k: any) => (
                  <div key={k.id} className="border-b last:border-0 py-1.5 grid grid-cols-4 gap-2 text-xs">
                    <span>L{k.level}</span><span><Badge variant="outline">{k.status}</Badge></span>
                    <span className="font-mono truncate">{k.fullName || k.panNumber || k.documentNumber || "—"}</span>
                    <span className="text-muted-foreground">{new Date(k.createdAt).toLocaleString("en-IN")}</span>
                  </div>
                ))}
              </Section>

              <Section title={`Wallets (${dossier.data.wallets.length})`}>
                {dossier.data.wallets.length === 0 ? <Empty /> : dossier.data.wallets.map((w: any) => (
                  <div key={w.id} className="border-b last:border-0 py-1.5 grid grid-cols-4 gap-2 text-xs">
                    <span><Badge variant="outline">{w.walletType}</Badge></span>
                    <span>Coin #{w.coinId}</span>
                    <span className="tabular-nums">{w.balance}</span>
                    <span className="text-muted-foreground tabular-nums">locked: {w.locked}</span>
                  </div>
                ))}
              </Section>

              <Section title={`Recent Sessions (${dossier.data.sessions.length})`}>
                {dossier.data.sessions.length === 0 ? <Empty /> : dossier.data.sessions.map((s: any) => (
                  <div key={s.id} className="border-b last:border-0 py-1.5 grid grid-cols-3 gap-2 text-xs">
                    <span className="font-mono">{s.ip || "—"}</span>
                    <span className="truncate">{s.userAgent || "—"}</span>
                    <span className="text-muted-foreground">{new Date(s.createdAt).toLocaleString("en-IN")}</span>
                  </div>
                ))}
              </Section>

              <div className="grid grid-cols-2 gap-3">
                <Section title={`INR Deposits (${dossier.data.inrDeposits.length})`}>
                  {dossier.data.inrDeposits.length === 0 ? <Empty /> : dossier.data.inrDeposits.slice(0, 10).map((d: any) => (
                    <div key={d.id} className="border-b last:border-0 py-1 grid grid-cols-3 gap-2 text-xs">
                      <span className="tabular-nums">₹{d.amount}</span><Badge variant="outline">{d.status}</Badge><span className="text-muted-foreground">{new Date(d.createdAt).toLocaleDateString("en-IN")}</span>
                    </div>
                  ))}
                </Section>
                <Section title={`Crypto Deposits (${dossier.data.cryptoDeposits.length})`}>
                  {dossier.data.cryptoDeposits.length === 0 ? <Empty /> : dossier.data.cryptoDeposits.slice(0, 10).map((d: any) => (
                    <div key={d.id} className="border-b last:border-0 py-1 grid grid-cols-3 gap-2 text-xs">
                      <span className="tabular-nums">{d.amount}</span><Badge variant="outline">{d.status}</Badge><span className="text-muted-foreground">{new Date(d.createdAt).toLocaleDateString("en-IN")}</span>
                    </div>
                  ))}
                </Section>
                <Section title={`INR Withdrawals (${dossier.data.inrWithdrawals.length})`}>
                  {dossier.data.inrWithdrawals.length === 0 ? <Empty /> : dossier.data.inrWithdrawals.slice(0, 10).map((d: any) => (
                    <div key={d.id} className="border-b last:border-0 py-1 grid grid-cols-3 gap-2 text-xs">
                      <span className="tabular-nums">₹{d.amount}</span><Badge variant="outline">{d.status}</Badge><span className="text-muted-foreground">{new Date(d.createdAt).toLocaleDateString("en-IN")}</span>
                    </div>
                  ))}
                </Section>
                <Section title={`Crypto Withdrawals (${dossier.data.cryptoWithdrawals.length})`}>
                  {dossier.data.cryptoWithdrawals.length === 0 ? <Empty /> : dossier.data.cryptoWithdrawals.slice(0, 10).map((d: any) => (
                    <div key={d.id} className="border-b last:border-0 py-1 grid grid-cols-3 gap-2 text-xs">
                      <span className="tabular-nums">{d.amount}</span><Badge variant="outline">{d.status}</Badge><span className="text-muted-foreground">{new Date(d.createdAt).toLocaleDateString("en-IN")}</span>
                    </div>
                  ))}
                </Section>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <Card className="p-3">
      <div className="font-semibold text-xs uppercase tracking-wider text-muted-foreground mb-2">{title}</div>
      {children}
    </Card>
  );
}
function Empty() { return <div className="text-xs text-muted-foreground italic">No records</div>; }
