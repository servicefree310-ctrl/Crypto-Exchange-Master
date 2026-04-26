import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch, post } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { useAuth } from "@/lib/auth";
import { useState, useEffect } from "react";
import { Input } from "@/components/ui/input";
import { Search, ShieldCheck, ShieldAlert, Eye, Wallet, ShieldOff, LogOut, TrendingUp, TrendingDown } from "lucide-react";

type Coin = { id: number; symbol: string; name: string; type: string; status: string };

type User = {
  id: number; email: string; name: string; phone: string | null;
  role: string; status: string; kycLevel: number; vipTier: number;
  uid: string; referralCode: string; createdAt: string; twoFaEnabled: boolean;
};

type FuturesPos = {
  id: number; pairId: number; symbol: string | null; side: string; leverage: number;
  qty: string; entryPrice: string; markPrice: string; marginAmount: string;
  unrealizedPnl: string; liquidationPrice: string; status: string; openedAt: string;
};

type Dossier = {
  user: User;
  security: { twoFaEnabled: boolean; activeSessions: number; lastSessionAt: string | null };
  kyc: any[]; wallets: any[]; sessions: any[];
  inrDeposits: any[]; cryptoDeposits: any[]; inrWithdrawals: any[]; cryptoWithdrawals: any[];
  futuresPositions: FuturesPos[];
};

const ROLES = ["user", "support", "admin", "superadmin"];
const STATUSES = ["active", "suspended", "banned"];

export default function UsersPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const [search, setSearch] = useState("");
  const [view, setView] = useState<number | null>(null);
  const [fundUser, setFundUser] = useState<User | null>(null);
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

  const disable2fa = useMutation({
    mutationFn: (id: number) => post<{ ok: boolean }>(`/admin/users/${id}/disable-2fa`, {}),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["/admin/users", view, "full"] });
      qc.invalidateQueries({ queryKey: ["/admin/users-search"] });
    },
  });
  const forceLogout = useMutation({
    mutationFn: (id: number) => post<{ ok: boolean; revoked: number }>(`/admin/users/${id}/force-logout`, {}),
    onSuccess: (r) => {
      qc.invalidateQueries({ queryKey: ["/admin/users", view, "full"] });
      alert(`Revoked ${r.revoked} session(s)`);
    },
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
                  <TableCell className="flex gap-1">
                    <Button size="icon" variant="ghost" onClick={() => setView(u.id)} title="View dossier"><Eye className="w-4 h-4" /></Button>
                    {isAdmin && <Button size="icon" variant="ghost" onClick={() => setFundUser(u)} title="Fund wallet"><Wallet className="w-4 h-4" /></Button>}
                  </TableCell>
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
              <Card className="p-3 space-y-3">
                <div className="grid grid-cols-2 gap-x-6 gap-y-2">
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
                </div>
                {isAdmin && (
                  <div className="flex flex-wrap gap-2 pt-2 border-t">
                    <Button
                      size="sm"
                      variant="outline"
                      disabled={!dossier.data.security.twoFaEnabled || disable2fa.isPending}
                      onClick={() => {
                        if (confirm(`Disable 2FA for ${dossier.data!.user.email}?`)) disable2fa.mutate(dossier.data!.user.id);
                      }}
                      data-testid="button-disable-2fa"
                    >
                      <ShieldOff className="w-3 h-3 mr-1" />
                      {disable2fa.isPending ? "Disabling…" : "Reset 2FA"}
                    </Button>
                    <Button
                      size="sm"
                      variant="outline"
                      disabled={dossier.data.security.activeSessions === 0 || forceLogout.isPending}
                      onClick={() => {
                        if (confirm(`Revoke all ${dossier.data!.security.activeSessions} session(s) for ${dossier.data!.user.email}?`)) forceLogout.mutate(dossier.data!.user.id);
                      }}
                      data-testid="button-force-logout"
                    >
                      <LogOut className="w-3 h-3 mr-1" />
                      {forceLogout.isPending ? "Revoking…" : "Force Logout"}
                    </Button>
                  </div>
                )}
              </Card>

              <Section title={`Open Futures Positions (${dossier.data.futuresPositions?.length ?? 0})`}>
                {!dossier.data.futuresPositions || dossier.data.futuresPositions.length === 0 ? <Empty /> : (
                  <div className="space-y-1">
                    {dossier.data.futuresPositions.map((p) => {
                      const pnl = Number(p.unrealizedPnl);
                      return (
                        <div key={p.id} className="border-b last:border-0 py-1.5 grid grid-cols-7 gap-2 text-xs items-center">
                          <span className="font-bold">{p.symbol ?? `#${p.pairId}`}</span>
                          <span>
                            {p.side === "long"
                              ? <Badge className="bg-green-500/20 text-green-500"><TrendingUp className="w-3 h-3 mr-1" />long</Badge>
                              : <Badge className="bg-red-500/20 text-red-500"><TrendingDown className="w-3 h-3 mr-1" />short</Badge>}
                          </span>
                          <span>{p.leverage}x</span>
                          <span className="tabular-nums">qty {Number(p.qty).toLocaleString("en-IN", { maximumFractionDigits: 6 })}</span>
                          <span className="tabular-nums">@ {Number(p.entryPrice).toLocaleString("en-IN", { maximumFractionDigits: 4 })}</span>
                          <span className="tabular-nums text-muted-foreground">mk {Number(p.markPrice).toLocaleString("en-IN", { maximumFractionDigits: 4 })}</span>
                          <span className={`tabular-nums font-semibold ${pnl >= 0 ? "text-green-500" : "text-red-500"}`}>
                            {pnl >= 0 ? "+" : ""}{pnl.toFixed(2)}
                          </span>
                        </div>
                      );
                    })}
                  </div>
                )}
              </Section>

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

      <FundDialog user={fundUser} onClose={() => setFundUser(null)} onSuccess={() => qc.invalidateQueries({ queryKey: ["/admin/users", fundUser?.id, "full"] })} />
    </div>
  );
}

function FundDialog({ user, onClose, onSuccess }: { user: User | null; onClose: () => void; onSuccess: () => void }) {
  const [coinId, setCoinId] = useState<string>("");
  const [amount, setAmount] = useState<string>("");
  const [walletType, setWalletType] = useState<"spot" | "inr">("spot");
  const [note, setNote] = useState<string>("");
  const [error, setError] = useState<string>("");

  const { data: coins = [] } = useQuery<Coin[]>({
    queryKey: ["/admin/coins"],
    queryFn: () => get<Coin[]>("/admin/coins"),
    enabled: user !== null,
  });

  const fund = useMutation({
    mutationFn: () => post(`/admin/users/${user!.id}/fund`, {
      coinId: Number(coinId), amount: Number(amount), walletType, note: note || undefined,
    }),
    onSuccess: () => { onSuccess(); reset(); onClose(); },
    onError: (e: any) => setError(e?.message || "Failed to fund wallet"),
  });

  const reset = () => { setCoinId(""); setAmount(""); setWalletType("spot"); setNote(""); setError(""); };

  // Auto-pick wallet type based on coin (INR -> inr wallet, others -> spot)
  const selectedCoin = coins.find((c) => String(c.id) === coinId);
  useEffect(() => {
    if (selectedCoin) setWalletType(selectedCoin.symbol === "INR" ? "inr" : "spot");
  }, [selectedCoin?.id]);

  const valid = coinId && Number(amount) > 0;

  return (
    <Dialog open={user !== null} onOpenChange={(o) => { if (!o) { reset(); onClose(); } }}>
      <DialogContent className="max-w-md">
        <DialogHeader><DialogTitle>Fund User Wallet</DialogTitle></DialogHeader>
        {user && (
          <div className="space-y-3 text-sm">
            <Card className="p-3 text-xs">
              <div><span className="text-muted-foreground">User:</span> <span className="font-medium">{user.email}</span></div>
              <div><span className="text-muted-foreground">UID:</span> <span className="font-mono">{user.uid}</span></div>
            </Card>

            <div>
              <label className="text-xs text-muted-foreground mb-1 block">Coin</label>
              <Select value={coinId} onValueChange={setCoinId}>
                <SelectTrigger><SelectValue placeholder="Select coin" /></SelectTrigger>
                <SelectContent>
                  {coins.filter((c) => c.status === "active").map((c) => (
                    <SelectItem key={c.id} value={String(c.id)}>{c.symbol} — {c.name}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div>
              <label className="text-xs text-muted-foreground mb-1 block">Wallet Type</label>
              <Select value={walletType} onValueChange={(v) => setWalletType(v as "spot" | "inr")}>
                <SelectTrigger><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="spot">Spot</SelectItem>
                  <SelectItem value="inr">INR</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <label className="text-xs text-muted-foreground mb-1 block">Amount</label>
              <Input type="number" step="0.00000001" min="0" value={amount} onChange={(e) => setAmount(e.target.value)} placeholder="0.00" />
            </div>

            <div>
              <label className="text-xs text-muted-foreground mb-1 block">Note (optional)</label>
              <Input value={note} onChange={(e) => setNote(e.target.value)} placeholder="Reason / reference" />
            </div>

            {error && <div className="text-xs text-destructive">{error}</div>}
          </div>
        )}
        <DialogFooter>
          <Button variant="outline" onClick={() => { reset(); onClose(); }}>Cancel</Button>
          <Button disabled={!valid || fund.isPending} onClick={() => { setError(""); fund.mutate(); }}>
            {fund.isPending ? "Crediting…" : "Credit Wallet"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
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
