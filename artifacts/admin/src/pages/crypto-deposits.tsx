import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch, post } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useAuth } from "@/lib/auth";
import { Activity, RefreshCw, PlayCircle, PauseCircle, Search, Zap, ExternalLink } from "lucide-react";

type D = {
  id: number; userId: number; coinId: number; networkId: number; amount: string;
  address: string; fromAddress: string | null; txHash: string | null;
  blockNumber: number | null; logIndex: number | null;
  confirmations: number; requiredConfirmations: number;
  status: string; detectedBy: string; createdAt: string; processedAt: string | null;
};

type Stats = {
  total: number; pending: number; completed: number; rejected: number;
  autoDetected: number; manual: number; totalAmount: number; pendingAmount: number;
};

type SweepResult = {
  networkId: number; networkName: string;
  scanned: { from: number; to: number } | null;
  detected: number; confirmed: number; errors: string[];
};

type SweeperStatus = {
  running: boolean; intervalMs: number;
  lastTickAt: number | null; nextTickAt: number | null;
  lastResults: SweepResult[];
  consecutiveErrors: Record<number, number>;
};

type Net = { id: number; name: string; chain: string; explorerUrl?: string | null; coinId: number };
type Coin = { id: number; symbol: string };

export default function CryptoDepositsPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [detectedFilter, setDetectedFilter] = useState<string>("all");
  const [search, setSearch] = useState("");

  const { data: stats } = useQuery<Stats>({
    queryKey: ["/admin/crypto-deposits/stats"],
    queryFn: () => get<Stats>("/admin/crypto-deposits/stats"),
    refetchInterval: 5000,
  });
  const { data: sweeper } = useQuery<SweeperStatus>({
    queryKey: ["/admin/sweeper/status"],
    queryFn: () => get<SweeperStatus>("/admin/sweeper/status"),
    refetchInterval: 4000,
  });
  const { data: nets = [] } = useQuery<Net[]>({
    queryKey: ["/admin/networks"], queryFn: () => get<Net[]>("/admin/networks"),
  });
  const { data: coins = [] } = useQuery<Coin[]>({
    queryKey: ["/admin/coins"], queryFn: () => get<Coin[]>("/admin/coins"),
  });

  const qs = new URLSearchParams();
  if (statusFilter !== "all") qs.set("status", statusFilter);
  if (detectedFilter !== "all") qs.set("detectedBy", detectedFilter);
  const qsStr = qs.toString();
  const { data = [] } = useQuery<D[]>({
    queryKey: ["/admin/crypto-deposits", statusFilter, detectedFilter],
    queryFn: () => get<D[]>(`/admin/crypto-deposits${qsStr ? `?${qsStr}` : ""}`),
    refetchInterval: 5000,
  });

  const update = useMutation({
    mutationFn: ({ id, body }: { id: number; body: Record<string, unknown> }) =>
      patch(`/admin/crypto-deposits/${id}`, body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["/admin/crypto-deposits"] });
      qc.invalidateQueries({ queryKey: ["/admin/crypto-deposits/stats"] });
    },
  });

  const scanAll = useMutation({
    mutationFn: () => post("/admin/sweeper/scan", {}),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["/admin/sweeper/status"] });
      qc.invalidateQueries({ queryKey: ["/admin/crypto-deposits"] });
    },
  });
  const startSweeper = useMutation({
    mutationFn: () => post("/admin/sweeper/start", { intervalMs: 30000 }),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/sweeper/status"] }),
  });
  const stopSweeper = useMutation({
    mutationFn: () => post("/admin/sweeper/stop", {}),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/sweeper/status"] }),
  });

  const netById = new Map(nets.map((n) => [n.id, n]));
  const coinById = new Map(coins.map((c) => [c.id, c]));

  const filtered = data.filter((d) => {
    if (!search) return true;
    const s = search.toLowerCase();
    return String(d.userId).includes(s)
      || (d.txHash || "").toLowerCase().includes(s)
      || d.address.toLowerCase().includes(s)
      || (coinById.get(d.coinId)?.symbol || "").toLowerCase().includes(s);
  });

  function explorerLink(d: D) {
    const n = netById.get(d.networkId);
    if (!n?.explorerUrl || !d.txHash) return null;
    const base = n.explorerUrl.replace(/\/$/, "");
    return `${base}/tx/${d.txHash}`;
  }

  const lastTickStr = sweeper?.lastTickAt
    ? `${Math.max(0, Math.round((Date.now() - sweeper.lastTickAt) / 1000))}s ago`
    : "never";

  return (
    <div className="space-y-4">
      {/* Stats Cards */}
      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-3">
        <Card className="p-3"><div className="text-xs text-muted-foreground">Total</div><div className="text-2xl font-bold">{stats?.total ?? 0}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Pending</div><div className="text-2xl font-bold text-yellow-500">{stats?.pending ?? 0}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Completed</div><div className="text-2xl font-bold text-emerald-500">{stats?.completed ?? 0}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Rejected</div><div className="text-2xl font-bold text-red-500">{stats?.rejected ?? 0}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Auto-detected</div><div className="text-2xl font-bold text-blue-500">{stats?.autoDetected ?? 0}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Total Volume</div><div className="text-lg font-bold tabular-nums">{(stats?.totalAmount ?? 0).toFixed(4)}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Pending Volume</div><div className="text-lg font-bold tabular-nums text-yellow-500">{(stats?.pendingAmount ?? 0).toFixed(4)}</div></Card>
      </div>

      {/* Sweeper Panel */}
      <Card className="p-4">
        <div className="flex items-center justify-between flex-wrap gap-3">
          <div className="flex items-center gap-3">
            <div className={`p-2 rounded-full ${sweeper?.running ? "bg-emerald-500/20 text-emerald-500" : "bg-zinc-500/20 text-zinc-500"}`}>
              <Activity className="h-5 w-5" />
            </div>
            <div>
              <div className="font-semibold flex items-center gap-2">
                Auto Deposit Sweeper
                <Badge variant={sweeper?.running ? "default" : "secondary"}>
                  {sweeper?.running ? "RUNNING" : "STOPPED"}
                </Badge>
              </div>
              <div className="text-xs text-muted-foreground">
                Last scan: {lastTickStr} · Interval: {(sweeper?.intervalMs ?? 30000) / 1000}s · Networks scanned: {sweeper?.lastResults?.length ?? 0}
              </div>
            </div>
          </div>
          {isAdmin && (
            <div className="flex gap-2">
              <Button size="sm" variant="outline" onClick={() => scanAll.mutate()} disabled={scanAll.isPending}>
                <RefreshCw className={`h-4 w-4 mr-1 ${scanAll.isPending ? "animate-spin" : ""}`} />
                Scan Now
              </Button>
              {sweeper?.running ? (
                <Button size="sm" variant="destructive" onClick={() => stopSweeper.mutate()}>
                  <PauseCircle className="h-4 w-4 mr-1" /> Stop
                </Button>
              ) : (
                <Button size="sm" onClick={() => startSweeper.mutate()}>
                  <PlayCircle className="h-4 w-4 mr-1" /> Start
                </Button>
              )}
            </div>
          )}
        </div>

        {sweeper?.lastResults && sweeper.lastResults.length > 0 && (
          <div className="mt-3 grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-2">
            {sweeper.lastResults.map((r) => (
              <div key={r.networkId} className="text-xs bg-muted/50 p-2 rounded border">
                <div className="font-semibold flex items-center gap-1">
                  <Zap className="h-3 w-3" /> {r.networkName}
                </div>
                <div className="text-muted-foreground">
                  {r.scanned ? `Blocks ${r.scanned.from}–${r.scanned.to}` : "No new blocks"}
                  {" · "}Detected: <span className="text-blue-500">{r.detected}</span>
                  {" · "}Credited: <span className="text-emerald-500">{r.confirmed}</span>
                </div>
                {r.errors.length > 0 && <div className="text-red-500 mt-1 truncate" title={r.errors.join("; ")}>⚠ {r.errors[0]}</div>}
              </div>
            ))}
          </div>
        )}
      </Card>

      {/* Filters */}
      <Card className="p-3">
        <div className="flex flex-wrap items-center gap-3">
          <div className="relative flex-1 min-w-[200px] max-w-[320px]">
            <Search className="absolute left-2 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
            <Input placeholder="Search user, tx hash, address, coin…" value={search} onChange={(e) => setSearch(e.target.value)} className="pl-8" />
          </div>
          <Tabs value={statusFilter} onValueChange={setStatusFilter}>
            <TabsList>
              <TabsTrigger value="all">All</TabsTrigger>
              <TabsTrigger value="pending">Pending</TabsTrigger>
              <TabsTrigger value="completed">Completed</TabsTrigger>
              <TabsTrigger value="rejected">Rejected</TabsTrigger>
            </TabsList>
          </Tabs>
          <Tabs value={detectedFilter} onValueChange={setDetectedFilter}>
            <TabsList>
              <TabsTrigger value="all">Source: All</TabsTrigger>
              <TabsTrigger value="sweeper">Auto</TabsTrigger>
              <TabsTrigger value="manual">Manual</TabsTrigger>
            </TabsList>
          </Tabs>
        </div>
      </Card>

      {/* Deposits Table */}
      <Card>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader><TableRow>
              <TableHead>UID</TableHead>
              <TableHead>User</TableHead><TableHead>Coin</TableHead><TableHead>Network</TableHead>
              <TableHead>Amount</TableHead><TableHead>To Address</TableHead><TableHead>Tx Hash</TableHead>
              <TableHead>Block</TableHead><TableHead>Confirms</TableHead>
              <TableHead>Status</TableHead><TableHead>Source</TableHead>
              <TableHead>Date</TableHead><TableHead>Actions</TableHead>
            </TableRow></TableHeader>
            <TableBody>
              {filtered.map((d) => {
                const link = explorerLink(d);
                const c = coinById.get(d.coinId);
                const n = netById.get(d.networkId);
                const confPct = d.requiredConfirmations > 0 ? Math.min(100, (d.confirmations / d.requiredConfirmations) * 100) : 0;
                return (
                  <TableRow key={d.id}>
                    <TableCell className="font-mono text-[10px] text-muted-foreground" title={d.uid}>{(d.uid || "").slice(0, 10)}…</TableCell>
                    <TableCell>#{d.userId}</TableCell>
                    <TableCell>{c?.symbol || `#${d.coinId}`}</TableCell>
                    <TableCell>{n ? `${n.name}/${n.chain}` : `#${d.networkId}`}</TableCell>
                    <TableCell className="tabular-nums font-semibold">{Number(d.amount).toFixed(8)}</TableCell>
                    <TableCell className="font-mono text-xs truncate max-w-[140px]" title={d.address}>{d.address}</TableCell>
                    <TableCell className="font-mono text-xs">
                      {d.txHash ? (
                        <a href={link || "#"} target="_blank" rel="noreferrer" className="hover:underline inline-flex items-center gap-1 text-blue-500">
                          {d.txHash.slice(0, 8)}…{d.txHash.slice(-6)}
                          {link && <ExternalLink className="h-3 w-3" />}
                        </a>
                      ) : "—"}
                    </TableCell>
                    <TableCell className="text-xs tabular-nums">{d.blockNumber ?? "—"}</TableCell>
                    <TableCell>
                      <div className="flex items-center gap-2">
                        <span className="tabular-nums text-xs">{d.confirmations}/{d.requiredConfirmations}</span>
                        <div className="w-12 h-1.5 bg-muted rounded-full overflow-hidden">
                          <div className={`h-full ${confPct >= 100 ? "bg-emerald-500" : "bg-blue-500"}`} style={{ width: `${confPct}%` }} />
                        </div>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant={d.status === "completed" ? "default" : d.status === "rejected" ? "destructive" : "secondary"}>{d.status}</Badge>
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline" className={d.detectedBy === "sweeper" ? "border-blue-500 text-blue-500" : ""}>
                        {d.detectedBy === "sweeper" ? "AUTO" : "manual"}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-xs">{new Date(d.createdAt).toLocaleString("en-IN")}</TableCell>
                    <TableCell className="space-x-1">
                      {isAdmin && d.status === "pending" && (
                        <>
                          <Button size="sm" onClick={() => {
                            const conf = prompt("Confirmations on chain?", String(d.confirmations || d.requiredConfirmations));
                            if (conf === null) return;
                            update.mutate({ id: d.id, body: { status: "completed", confirmations: Number(conf) } });
                          }}>Approve</Button>
                          <Button size="sm" variant="destructive" onClick={() => {
                            if (confirm("Reject this deposit?")) update.mutate({ id: d.id, body: { status: "rejected" } });
                          }}>Reject</Button>
                        </>
                      )}
                    </TableCell>
                  </TableRow>
                );
              })}
              {filtered.length === 0 && <TableRow><TableCell colSpan={12} className="text-center py-6 text-muted-foreground">No deposits</TableCell></TableRow>}
            </TableBody>
          </Table>
        </div>
      </Card>
    </div>
  );
}
