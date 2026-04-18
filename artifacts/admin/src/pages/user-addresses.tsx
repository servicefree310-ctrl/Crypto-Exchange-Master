import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch, post } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { useAuth } from "@/lib/auth";
import { Search, KeyRound, Eye, EyeOff, Lock, ShieldCheck, Copy, AlertTriangle, Check } from "lucide-react";

type Addr = {
  id: number; userId: number; networkId: number; address: string; memo: string | null;
  status: string; derivationPath: string | null; derivationIndex: number | null;
  hasPrivateKey: boolean; createdAt: string; lastUsedAt: string | null;
  userEmail: string | null; userName: string | null; userPhone: string | null;
};
type Stats = {
  total: number; active: number; disabled: number; withPk: number; withoutPk: number;
  perNetwork: Record<number, { total: number; withPk: number }>;
};
type Net = { id: number; name: string; chain: string; explorerUrl?: string | null };
type VaultStatus = { passwordSet: boolean; mnemonicConfigured: boolean };

export default function UserAddressesPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [networkFilter, setNetworkFilter] = useState<string>("all");

  const [pwdSetupOpen, setPwdSetupOpen] = useState(false);
  const [revealOpen, setRevealOpen] = useState<Addr | null>(null);
  const [revealedPk, setRevealedPk] = useState<string | null>(null);
  const [pwdInput, setPwdInput] = useState("");
  const [showPk, setShowPk] = useState(false);
  const [copyOk, setCopyOk] = useState(false);
  const [revealError, setRevealError] = useState("");
  const [setupCurrent, setSetupCurrent] = useState("");
  const [setupNew, setSetupNew] = useState("");
  const [setupConfirm, setSetupConfirm] = useState("");
  const [setupError, setSetupError] = useState("");

  const { data: vault } = useQuery<VaultStatus>({
    queryKey: ["/admin/vault/status"],
    queryFn: () => get<VaultStatus>("/admin/vault/status"),
    refetchInterval: 10000,
  });
  const { data: stats } = useQuery<Stats>({
    queryKey: ["/admin/user-addresses/stats"],
    queryFn: () => get<Stats>("/admin/user-addresses/stats"),
    refetchInterval: 8000,
  });
  const { data: nets = [] } = useQuery<Net[]>({
    queryKey: ["/admin/networks"], queryFn: () => get<Net[]>("/admin/networks"),
  });

  const qsParts: string[] = [];
  if (search) qsParts.push(`search=${encodeURIComponent(search)}`);
  if (statusFilter !== "all") qsParts.push(`status=${statusFilter}`);
  if (networkFilter !== "all") qsParts.push(`networkId=${networkFilter}`);
  const qsStr = qsParts.join("&");
  const { data: rows = [] } = useQuery<Addr[]>({
    queryKey: ["/admin/user-addresses", search, statusFilter, networkFilter],
    queryFn: () => get<Addr[]>(`/admin/user-addresses${qsStr ? `?${qsStr}` : ""}`),
    refetchInterval: 8000,
  });

  const toggleStatus = useMutation({
    mutationFn: ({ id, status }: { id: number; status: string }) =>
      patch(`/admin/user-addresses/${id}`, { status }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["/admin/user-addresses"] });
      qc.invalidateQueries({ queryKey: ["/admin/user-addresses/stats"] });
    },
  });

  const setPassword = useMutation({
    mutationFn: (body: { password: string; currentPassword?: string }) =>
      post("/admin/vault/set-password", body),
    onSuccess: () => {
      setPwdSetupOpen(false);
      setSetupCurrent(""); setSetupNew(""); setSetupConfirm(""); setSetupError("");
      qc.invalidateQueries({ queryKey: ["/admin/vault/status"] });
    },
    onError: (e: any) => setSetupError(e?.message || "Failed to set password"),
  });

  const reveal = useMutation({
    mutationFn: ({ id, password }: { id: number; password: string }) =>
      post<{ privateKey: string }>(`/admin/user-addresses/${id}/reveal`, { password }),
    onSuccess: (d) => { setRevealedPk(d.privateKey); setRevealError(""); },
    onError: (e: any) => { setRevealError(e?.message || "Reveal failed"); setRevealedPk(null); },
  });

  function openReveal(a: Addr) {
    setRevealOpen(a);
    setRevealedPk(null); setPwdInput(""); setShowPk(false); setCopyOk(false); setRevealError("");
  }
  function closeReveal() {
    setRevealOpen(null); setRevealedPk(null); setPwdInput(""); setShowPk(false); setCopyOk(false); setRevealError("");
  }

  function submitSetup() {
    setSetupError("");
    if (setupNew.length < 8) { setSetupError("Password must be at least 8 characters"); return; }
    if (setupNew !== setupConfirm) { setSetupError("Passwords do not match"); return; }
    setPassword.mutate(vault?.passwordSet ? { password: setupNew, currentPassword: setupCurrent } : { password: setupNew });
  }

  const netById = new Map(nets.map((n) => [n.id, n]));

  function explorerLink(a: Addr) {
    const n = netById.get(a.networkId);
    if (!n?.explorerUrl) return null;
    return `${n.explorerUrl.replace(/\/$/, "")}/address/${a.address}`;
  }

  return (
    <div className="space-y-4">
      {/* Vault status banner */}
      {!vault?.passwordSet && (
        <Card className="p-4 border-yellow-500/50 bg-yellow-500/10">
          <div className="flex items-start gap-3">
            <AlertTriangle className="h-5 w-5 text-yellow-500 mt-0.5" />
            <div className="flex-1">
              <div className="font-semibold">Vault password not set</div>
              <div className="text-sm text-muted-foreground">Set an admin vault password to enable revealing user private keys. Without it, private keys remain encrypted at rest with the server secret only.</div>
            </div>
            {isAdmin && <Button onClick={() => setPwdSetupOpen(true)}><Lock className="h-4 w-4 mr-1" /> Set password</Button>}
          </div>
        </Card>
      )}
      {vault?.passwordSet && isAdmin && (
        <div className="flex justify-end">
          <Button size="sm" variant="outline" onClick={() => setPwdSetupOpen(true)}>
            <ShieldCheck className="h-4 w-4 mr-1" /> Change vault password
          </Button>
        </div>
      )}

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
        <Card className="p-3"><div className="text-xs text-muted-foreground">Total Addresses</div><div className="text-2xl font-bold">{stats?.total ?? 0}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Active</div><div className="text-2xl font-bold text-emerald-500">{stats?.active ?? 0}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Disabled</div><div className="text-2xl font-bold text-red-500">{stats?.disabled ?? 0}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">With Private Key</div><div className="text-2xl font-bold text-blue-500">{stats?.withPk ?? 0}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Legacy (no PK)</div><div className="text-2xl font-bold text-yellow-500">{stats?.withoutPk ?? 0}</div></Card>
      </div>

      {/* Filters */}
      <Card className="p-3">
        <div className="flex flex-wrap items-center gap-3">
          <div className="relative flex-1 min-w-[240px] max-w-[400px]">
            <Search className="absolute left-2 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input placeholder="Search user ID, email, name, phone, address…" value={search} onChange={(e) => setSearch(e.target.value)} className="pl-8" />
          </div>
          <Tabs value={statusFilter} onValueChange={setStatusFilter}>
            <TabsList>
              <TabsTrigger value="all">All</TabsTrigger>
              <TabsTrigger value="active">Active</TabsTrigger>
              <TabsTrigger value="disabled">Disabled</TabsTrigger>
            </TabsList>
          </Tabs>
          <select value={networkFilter} onChange={(e) => setNetworkFilter(e.target.value)} className="border rounded px-2 py-1 bg-background text-sm">
            <option value="all">All networks</option>
            {nets.map((n) => <option key={n.id} value={n.id}>{n.name}/{n.chain}</option>)}
          </select>
        </div>
      </Card>

      {/* Addresses table */}
      <Card>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader><TableRow>
              <TableHead>User</TableHead><TableHead>Network</TableHead>
              <TableHead>Address (shared per EVM network)</TableHead>
              <TableHead>Path</TableHead>
              <TableHead>Status</TableHead>
              <TableHead>PK</TableHead>
              <TableHead>Created</TableHead>
              <TableHead>Actions</TableHead>
            </TableRow></TableHeader>
            <TableBody>
              {rows.map((a) => {
                const n = netById.get(a.networkId);
                const link = explorerLink(a);
                return (
                  <TableRow key={a.id}>
                    <TableCell>
                      <div className="text-sm font-medium">#{a.userId}</div>
                      <div className="text-xs text-muted-foreground truncate max-w-[180px]" title={a.userEmail || ""}>{a.userEmail || a.userPhone || "—"}</div>
                      {a.userName && <div className="text-xs text-muted-foreground truncate max-w-[180px]">{a.userName}</div>}
                    </TableCell>
                    <TableCell>{n ? `${n.name}/${n.chain}` : `#${a.networkId}`}</TableCell>
                    <TableCell className="font-mono text-xs">
                      {link ? (
                        <a href={link} target="_blank" rel="noreferrer" className="hover:underline text-blue-500">
                          {a.address}
                        </a>
                      ) : a.address}
                      {a.memo && <div className="text-muted-foreground text-[10px]">memo: {a.memo}</div>}
                    </TableCell>
                    <TableCell className="text-xs font-mono text-muted-foreground">{a.derivationPath || "—"}</TableCell>
                    <TableCell>
                      <Badge variant={a.status === "active" ? "default" : "destructive"}>{a.status}</Badge>
                    </TableCell>
                    <TableCell>
                      {a.hasPrivateKey
                        ? <Badge variant="outline" className="border-blue-500 text-blue-500"><KeyRound className="h-3 w-3 mr-1" />encrypted</Badge>
                        : <Badge variant="outline" className="border-yellow-500 text-yellow-500">legacy</Badge>}
                    </TableCell>
                    <TableCell className="text-xs">{new Date(a.createdAt).toLocaleString("en-IN")}</TableCell>
                    <TableCell className="space-x-1">
                      {isAdmin && a.hasPrivateKey && (
                        <Button size="sm" variant="outline" onClick={() => openReveal(a)} disabled={!vault?.passwordSet}>
                          <Eye className="h-3.5 w-3.5 mr-1" /> Reveal PK
                        </Button>
                      )}
                      {isAdmin && (
                        <Button size="sm" variant={a.status === "active" ? "destructive" : "default"}
                          onClick={() => toggleStatus.mutate({ id: a.id, status: a.status === "active" ? "disabled" : "active" })}>
                          {a.status === "active" ? "Disable" : "Enable"}
                        </Button>
                      )}
                    </TableCell>
                  </TableRow>
                );
              })}
              {rows.length === 0 && <TableRow><TableCell colSpan={8} className="text-center py-6 text-muted-foreground">No addresses</TableCell></TableRow>}
            </TableBody>
          </Table>
        </div>
      </Card>

      {/* Set/Change password dialog */}
      <Dialog open={pwdSetupOpen} onOpenChange={(o) => { if (!o) { setPwdSetupOpen(false); setSetupError(""); } }}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{vault?.passwordSet ? "Change vault password" : "Set vault password"}</DialogTitle>
          </DialogHeader>
          <div className="space-y-3">
            {vault?.passwordSet && (
              <div>
                <Label>Current password</Label>
                <Input type="password" value={setupCurrent} onChange={(e) => setSetupCurrent(e.target.value)} />
              </div>
            )}
            <div>
              <Label>New password (min 8 chars)</Label>
              <Input type="password" value={setupNew} onChange={(e) => setSetupNew(e.target.value)} />
            </div>
            <div>
              <Label>Confirm new password</Label>
              <Input type="password" value={setupConfirm} onChange={(e) => setSetupConfirm(e.target.value)} />
            </div>
            {setupError && <div className="text-sm text-red-500">{setupError}</div>}
            <div className="text-xs text-muted-foreground bg-muted/50 p-2 rounded">
              ⚠ Save this password somewhere safe. It is required to view user private keys and (in future) to authorize hot-wallet withdrawals. There is no recovery.
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setPwdSetupOpen(false)}>Cancel</Button>
            <Button onClick={submitSetup} disabled={setPassword.isPending}>Save</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Reveal private key dialog */}
      <Dialog open={!!revealOpen} onOpenChange={(o) => { if (!o) closeReveal(); }}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Reveal private key</DialogTitle>
          </DialogHeader>
          {revealOpen && (
            <div className="space-y-3">
              <div className="text-sm">
                <div><span className="text-muted-foreground">User: </span>#{revealOpen.userId} {revealOpen.userEmail && `(${revealOpen.userEmail})`}</div>
                <div className="font-mono text-xs break-all"><span className="text-muted-foreground font-sans">Address: </span>{revealOpen.address}</div>
                <div className="text-xs text-muted-foreground font-mono">Path: {revealOpen.derivationPath}</div>
              </div>
              {!revealedPk ? (
                <>
                  <div>
                    <Label>Enter vault password</Label>
                    <Input type="password" value={pwdInput} onChange={(e) => setPwdInput(e.target.value)} autoFocus
                      onKeyDown={(e) => { if (e.key === "Enter" && pwdInput) reveal.mutate({ id: revealOpen.id, password: pwdInput }); }} />
                  </div>
                  {revealError && <div className="text-sm text-red-500">{revealError}</div>}
                </>
              ) : (
                <>
                  <div>
                    <Label>Private key</Label>
                    <div className="flex gap-2 items-center">
                      <Input type={showPk ? "text" : "password"} value={revealedPk} readOnly className="font-mono text-xs" />
                      <Button size="icon" variant="outline" type="button" onClick={() => setShowPk(!showPk)}>{showPk ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}</Button>
                      <Button size="icon" variant="outline" type="button" onClick={() => { navigator.clipboard.writeText(revealedPk); setCopyOk(true); setTimeout(() => setCopyOk(false), 1500); }}>
                        {copyOk ? <Check className="h-4 w-4 text-emerald-500" /> : <Copy className="h-4 w-4" />}
                      </Button>
                    </div>
                  </div>
                  <div className="text-xs text-red-500 bg-red-500/10 p-2 rounded">
                    ⚠ Sensitive data. Anyone with this key can spend funds at this address. Do not share or screenshot.
                  </div>
                </>
              )}
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={closeReveal}>Close</Button>
            {revealOpen && !revealedPk && (
              <Button onClick={() => reveal.mutate({ id: revealOpen.id, password: pwdInput })} disabled={!pwdInput || reveal.isPending}>
                <KeyRound className="h-4 w-4 mr-1" /> Decrypt
              </Button>
            )}
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
