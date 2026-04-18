import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch, post } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import {
  Search, Send, X, Check, RefreshCw, Wallet, AlertCircle, Clock,
  CheckCircle2, XCircle, Zap, ExternalLink, Copy,
} from "lucide-react";
import { useState, useMemo } from "react";
import { useAuth } from "@/lib/auth";

type W = {
  id: number; uid?: string; userId: number; coinId: number; networkId: number;
  amount: string; fee: string; toAddress: string; memo: string | null;
  txHash: string | null; status: string; rejectReason: string | null;
  createdAt: string; processedAt: string | null;
};
type Coin = { id: number; symbol: string; name?: string };
type Net = {
  id: number; name: string; chain: string; coinId: number;
  autoSendSupported: boolean; hotWalletConfigured: boolean; rpcConfigured: boolean; isEvm: boolean;
  minWithdraw: string; withdrawFee: string; withdrawEnabled: boolean;
};
type Stats = {
  pending: number; completed: number; rejected: number;
  today: number; todayVolume: number; totalLocked: number;
};
type HotBal = { native: string; token?: string; address: string; chain: string; symbol: string };

function fmt(n: number | string, dp = 4): string {
  const v = typeof n === "string" ? Number(n) : n;
  if (!Number.isFinite(v)) return "0";
  return v.toLocaleString("en-IN", { maximumFractionDigits: dp });
}

export default function CryptoWithdrawalsPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";

  const { data = [], refetch } = useQuery<W[]>({
    queryKey: ["/admin/crypto-withdrawals"],
    queryFn: () => get<W[]>("/admin/crypto-withdrawals"),
    refetchInterval: 15000,
  });
  const { data: stats } = useQuery<Stats>({
    queryKey: ["/admin/crypto-withdrawals/stats"],
    queryFn: () => get<Stats>("/admin/crypto-withdrawals/stats"),
    refetchInterval: 15000,
  });
  const { data: coins = [] } = useQuery<Coin[]>({
    queryKey: ["/admin/coins"],
    queryFn: () => get<Coin[]>("/admin/coins"),
  });
  const { data: networks = [] } = useQuery<Net[]>({
    queryKey: ["/admin/networks/auto-send-supported"],
    queryFn: () => get<Net[]>("/admin/networks/auto-send-supported"),
  });

  const coinMap = useMemo(() => {
    const m = new Map<number, Coin>();
    coins.forEach((c) => m.set(c.id, c));
    return m;
  }, [coins]);
  const netMap = useMemo(() => {
    const m = new Map<number, Net>();
    networks.forEach((n) => m.set(n.id, n));
    return m;
  }, [networks]);

  const [search, setSearch] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [coinFilter, setCoinFilter] = useState("all");

  const update = useMutation({
    mutationFn: ({ id, body }: { id: number; body: Record<string, unknown> }) => patch(`/admin/crypto-withdrawals/${id}`, body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["/admin/crypto-withdrawals"] });
      qc.invalidateQueries({ queryKey: ["/admin/crypto-withdrawals/stats"] });
    },
  });
  const autoSend = useMutation({
    mutationFn: (id: number) => post<{ ok: boolean; txHash: string }>(`/admin/crypto-withdrawals/${id}/auto-send`, {}),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["/admin/crypto-withdrawals"] });
      qc.invalidateQueries({ queryKey: ["/admin/crypto-withdrawals/stats"] });
    },
  });

  const [actionRow, setActionRow] = useState<W | null>(null);
  const [actionMode, setActionMode] = useState<"manual" | "reject" | "auto" | null>(null);
  const [txHash, setTxHash] = useState("");
  const [reason, setReason] = useState("");
  const [hotBalNet, setHotBalNet] = useState<number | null>(null);
  const { data: hotBal, isFetching: balFetching, refetch: refetchBal } = useQuery<HotBal>({
    queryKey: ["/admin/networks", hotBalNet, "hot-wallet"],
    queryFn: () => get<HotBal>(`/admin/networks/${hotBalNet}/hot-wallet`),
    enabled: hotBalNet != null,
    retry: false,
  });

  const filtered = useMemo(() => {
    return data.filter((w) => {
      if (statusFilter !== "all" && w.status !== statusFilter) return false;
      if (coinFilter !== "all" && String(w.coinId) !== coinFilter) return false;
      if (search) {
        const hay = `${w.uid ?? ""} ${w.userId} ${w.toAddress} ${w.txHash ?? ""}`.toLowerCase();
        if (!hay.includes(search.toLowerCase())) return false;
      }
      return true;
    });
  }, [data, statusFilter, coinFilter, search]);

  const pendingTotalByCoin = useMemo(() => {
    const m = new Map<string, number>();
    data.filter((w) => w.status === "pending").forEach((w) => {
      const sym = coinMap.get(w.coinId)?.symbol ?? `#${w.coinId}`;
      m.set(sym, (m.get(sym) ?? 0) + Number(w.amount));
    });
    return Array.from(m.entries()).sort((a, b) => b[1] - a[1]);
  }, [data, coinMap]);

  const closeAction = () => { setActionRow(null); setActionMode(null); setTxHash(""); setReason(""); };

  const submitAction = () => {
    if (!actionRow || !actionMode) return;
    if (actionMode === "manual") {
      update.mutate({ id: actionRow.id, body: { status: "completed", txHash: txHash.trim() || null } }, { onSuccess: closeAction });
    } else if (actionMode === "reject") {
      if (!reason.trim()) return;
      update.mutate({ id: actionRow.id, body: { status: "rejected", rejectReason: reason.trim() } }, { onSuccess: closeAction });
    } else if (actionMode === "auto") {
      autoSend.mutate(actionRow.id, { onSuccess: closeAction });
    }
  };

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <StatCard icon={<Clock className="w-4 h-4" />} label="Pending" value={fmt(stats?.pending ?? 0, 0)} sub={`Locked: ${fmt(stats?.totalLocked ?? 0, 4)}`} highlight />
        <StatCard icon={<CheckCircle2 className="w-4 h-4" />} label="Completed" value={fmt(stats?.completed ?? 0, 0)} sub="All time" />
        <StatCard icon={<XCircle className="w-4 h-4" />} label="Rejected" value={fmt(stats?.rejected ?? 0, 0)} sub="All time" />
        <StatCard icon={<Zap className="w-4 h-4" />} label="Today" value={fmt(stats?.today ?? 0, 0)} sub={`Volume: ${fmt(stats?.todayVolume ?? 0, 4)}`} />
      </div>

      <Tabs defaultValue="pending">
        <TabsList>
          <TabsTrigger value="pending" data-testid="tab-pending">Withdrawals</TabsTrigger>
          <TabsTrigger value="hot-wallets" data-testid="tab-hot-wallets">Hot Wallets ({networks.length})</TabsTrigger>
          <TabsTrigger value="locked" data-testid="tab-locked">Locked by Coin ({pendingTotalByCoin.length})</TabsTrigger>
        </TabsList>

        <TabsContent value="pending" className="space-y-3">
          <Card className="p-3">
            <div className="flex flex-wrap gap-2 items-center">
              <div className="relative flex-1 min-w-[220px]">
                <Search className="w-4 h-4 absolute left-2 top-2.5 text-muted-foreground" />
                <Input placeholder="Search UID, user, address, txhash…" value={search} onChange={(e) => setSearch(e.target.value)} className="pl-8" data-testid="input-search" />
              </div>
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-36" data-testid="filter-status"><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All status</SelectItem>
                  <SelectItem value="pending">Pending</SelectItem>
                  <SelectItem value="completed">Completed</SelectItem>
                  <SelectItem value="rejected">Rejected</SelectItem>
                </SelectContent>
              </Select>
              <Select value={coinFilter} onValueChange={setCoinFilter}>
                <SelectTrigger className="w-32" data-testid="filter-coin"><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All coins</SelectItem>
                  {coins.map((c) => <SelectItem key={c.id} value={String(c.id)}>{c.symbol}</SelectItem>)}
                </SelectContent>
              </Select>
              <Button variant="outline" size="icon" onClick={() => refetch()} data-testid="button-refresh">
                <RefreshCw className="w-4 h-4" />
              </Button>
            </div>
          </Card>

          <Card>
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>UID</TableHead>
                    <TableHead>User</TableHead>
                    <TableHead>Coin / Network</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                    <TableHead>To Address</TableHead>
                    <TableHead>Tx Hash</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Date</TableHead>
                    {isAdmin && <TableHead className="text-right">Actions</TableHead>}
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filtered.length === 0 && (
                    <TableRow><TableCell colSpan={isAdmin ? 9 : 8} className="text-center py-8 text-muted-foreground">No withdrawals match.</TableCell></TableRow>
                  )}
                  {filtered.map((w) => {
                    const coin = coinMap.get(w.coinId);
                    const net = netMap.get(w.networkId);
                    return (
                      <TableRow key={w.id} data-testid={`row-w-${w.id}`}>
                        <TableCell className="font-mono text-[10px] text-muted-foreground" title={w.uid}>
                          {(w.uid ?? "").slice(0, 10)}…
                        </TableCell>
                        <TableCell className="font-mono text-xs">user-{w.userId}</TableCell>
                        <TableCell>
                          <div className="font-bold">{coin?.symbol ?? `#${w.coinId}`}</div>
                          <div className="text-xs text-muted-foreground">{net?.name ?? `net-${w.networkId}`} · {net?.chain ?? ""}</div>
                        </TableCell>
                        <TableCell className="text-right">
                          <div className="font-mono">{fmt(w.amount, 8)}</div>
                          <div className="text-xs text-muted-foreground">fee {fmt(w.fee, 8)}</div>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-1 max-w-[180px]">
                            <span className="font-mono text-xs truncate" title={w.toAddress}>{w.toAddress}</span>
                            <button onClick={() => navigator.clipboard.writeText(w.toAddress)} className="opacity-50 hover:opacity-100"><Copy className="w-3 h-3" /></button>
                          </div>
                          {w.memo && <div className="text-[10px] text-muted-foreground">memo: {w.memo}</div>}
                        </TableCell>
                        <TableCell>
                          {w.txHash ? (
                            <div className="flex items-center gap-1 max-w-[160px]">
                              <span className="font-mono text-xs truncate" title={w.txHash}>{w.txHash.slice(0, 12)}…</span>
                              <button onClick={() => navigator.clipboard.writeText(w.txHash!)} className="opacity-50 hover:opacity-100"><Copy className="w-3 h-3" /></button>
                            </div>
                          ) : <span className="text-xs text-muted-foreground">—</span>}
                        </TableCell>
                        <TableCell>
                          <Badge variant={w.status === "completed" ? "default" : w.status === "rejected" ? "destructive" : "secondary"}>{w.status}</Badge>
                          {w.status === "rejected" && w.rejectReason && (
                            <div className="text-[10px] text-destructive mt-1 max-w-[140px] truncate" title={w.rejectReason}>{w.rejectReason}</div>
                          )}
                        </TableCell>
                        <TableCell className="text-xs whitespace-nowrap">{new Date(w.createdAt).toLocaleString("en-IN")}</TableCell>
                        {isAdmin && (
                          <TableCell className="text-right space-x-1 whitespace-nowrap">
                            {w.status === "pending" && (
                              <>
                                {net?.autoSendSupported && (
                                  <Button size="sm" onClick={() => { setActionRow(w); setActionMode("auto"); }} data-testid={`button-auto-${w.id}`}>
                                    <Zap className="w-3 h-3 mr-1" /> Auto Send
                                  </Button>
                                )}
                                <Button size="sm" variant="outline" onClick={() => { setActionRow(w); setActionMode("manual"); setTxHash(""); }} data-testid={`button-manual-${w.id}`}>
                                  <Check className="w-3 h-3 mr-1" /> Mark Sent
                                </Button>
                                <Button size="sm" variant="destructive" onClick={() => { setActionRow(w); setActionMode("reject"); setReason(""); }} data-testid={`button-reject-${w.id}`}>
                                  <X className="w-3 h-3" />
                                </Button>
                              </>
                            )}
                          </TableCell>
                        )}
                      </TableRow>
                    );
                  })}
                </TableBody>
              </Table>
            </div>
          </Card>
        </TabsContent>

        <TabsContent value="hot-wallets" className="space-y-3">
          <div className="text-sm text-muted-foreground">
            Configure hot wallets via the <a href="/admin/networks" className="underline">Networks</a> page. Auto-send works on EVM chains (ETH, BSC, Polygon, Arbitrum, Optimism, Base, AVAX) when hot wallet + RPC are set.
          </div>
          <Card>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Network</TableHead>
                  <TableHead>Chain</TableHead>
                  <TableHead>Coin</TableHead>
                  <TableHead className="text-right">Min Withdraw</TableHead>
                  <TableHead className="text-right">Fee</TableHead>
                  <TableHead>Withdraw</TableHead>
                  <TableHead>Hot Wallet</TableHead>
                  <TableHead>RPC</TableHead>
                  <TableHead>Auto Send</TableHead>
                  <TableHead className="text-right">Balance</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {networks.map((n) => (
                  <TableRow key={n.id} data-testid={`row-net-${n.id}`}>
                    <TableCell className="font-bold">{n.name}</TableCell>
                    <TableCell><Badge variant="outline">{n.chain}</Badge></TableCell>
                    <TableCell>{coinMap.get(n.coinId)?.symbol ?? `#${n.coinId}`}</TableCell>
                    <TableCell className="text-right text-xs">{fmt(n.minWithdraw, 8)}</TableCell>
                    <TableCell className="text-right text-xs">{fmt(n.withdrawFee, 8)}</TableCell>
                    <TableCell>{n.withdrawEnabled ? <Check className="w-4 h-4 text-green-500" /> : <X className="w-4 h-4 text-destructive" />}</TableCell>
                    <TableCell>{n.hotWalletConfigured ? <Check className="w-4 h-4 text-green-500" /> : <X className="w-4 h-4 text-muted-foreground" />}</TableCell>
                    <TableCell>{n.rpcConfigured ? <Check className="w-4 h-4 text-green-500" /> : <X className="w-4 h-4 text-muted-foreground" />}</TableCell>
                    <TableCell>
                      {n.autoSendSupported ? (
                        <Badge variant="default" className="gap-1"><Zap className="w-3 h-3" />Ready</Badge>
                      ) : n.isEvm ? (
                        <Badge variant="outline">Setup needed</Badge>
                      ) : (
                        <Badge variant="secondary">Manual only</Badge>
                      )}
                    </TableCell>
                    <TableCell className="text-right">
                      {n.autoSendSupported && (
                        <Button size="sm" variant="outline" onClick={() => { setHotBalNet(n.id); }} data-testid={`button-bal-${n.id}`}>
                          <Wallet className="w-3 h-3 mr-1" /> Check
                        </Button>
                      )}
                    </TableCell>
                  </TableRow>
                ))}
                {networks.length === 0 && <TableRow><TableCell colSpan={10} className="text-center py-6 text-muted-foreground">No networks configured.</TableCell></TableRow>}
              </TableBody>
            </Table>
          </Card>
        </TabsContent>

        <TabsContent value="locked">
          <Card>
            <Table>
              <TableHeader><TableRow><TableHead>Coin</TableHead><TableHead className="text-right">Total Locked (Pending)</TableHead></TableRow></TableHeader>
              <TableBody>
                {pendingTotalByCoin.length === 0 && <TableRow><TableCell colSpan={2} className="text-center py-6 text-muted-foreground">No pending withdrawals.</TableCell></TableRow>}
                {pendingTotalByCoin.map(([sym, total]) => (
                  <TableRow key={sym}>
                    <TableCell className="font-bold">{sym}</TableCell>
                    <TableCell className="text-right font-mono">{fmt(total, 8)}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Action dialog */}
      <Dialog open={!!actionRow} onOpenChange={(o) => { if (!o) closeAction(); }}>
        <DialogContent aria-describedby={undefined}>
          <DialogHeader>
            <DialogTitle>
              {actionMode === "auto" && "Auto-Send Withdrawal"}
              {actionMode === "manual" && "Mark as Sent (Manual)"}
              {actionMode === "reject" && "Reject Withdrawal"}
            </DialogTitle>
          </DialogHeader>
          {actionRow && (
            <div className="space-y-3 text-sm">
              <div className="bg-muted/30 rounded p-3 space-y-1 text-xs">
                <div><span className="text-muted-foreground">UID:</span> <span className="font-mono">{actionRow.uid}</span></div>
                <div><span className="text-muted-foreground">User:</span> #{actionRow.userId}</div>
                <div><span className="text-muted-foreground">Coin:</span> {coinMap.get(actionRow.coinId)?.symbol} on {netMap.get(actionRow.networkId)?.chain}</div>
                <div><span className="text-muted-foreground">Amount:</span> <span className="font-mono">{actionRow.amount}</span> (fee {actionRow.fee})</div>
                <div className="break-all"><span className="text-muted-foreground">To:</span> <span className="font-mono">{actionRow.toAddress}</span></div>
              </div>
              {actionMode === "auto" && (
                <div className="rounded border border-primary/40 bg-primary/5 p-3 text-xs space-y-2">
                  <div className="flex items-start gap-2"><Zap className="w-4 h-4 text-primary shrink-0 mt-0.5" />
                    <div>
                      <div className="font-semibold mb-1">Hot wallet broadcast</div>
                      <div>Transaction will be signed using the network's hot wallet and broadcast on-chain immediately. User's locked balance will be deducted.</div>
                    </div>
                  </div>
                  {autoSend.error && <div className="text-destructive"><AlertCircle className="w-3 h-3 inline mr-1" />{(autoSend.error as Error).message}</div>}
                </div>
              )}
              {actionMode === "manual" && (
                <div className="space-y-2">
                  <Label>Tx hash (optional)</Label>
                  <Input value={txHash} onChange={(e) => setTxHash(e.target.value)} placeholder="0x…" data-testid="input-txhash" />
                  <div className="text-xs text-muted-foreground">Use this if you've already broadcast the tx via another tool.</div>
                </div>
              )}
              {actionMode === "reject" && (
                <div className="space-y-2">
                  <Label>Reason *</Label>
                  <Textarea value={reason} onChange={(e) => setReason(e.target.value)} rows={3} placeholder="e.g. Suspicious destination, AML hit, KYC mismatch…" data-testid="input-reason" />
                  <div className="text-xs text-muted-foreground">User's locked funds will be returned to their balance.</div>
                </div>
              )}
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={closeAction}>Cancel</Button>
            <Button
              variant={actionMode === "reject" ? "destructive" : "default"}
              onClick={submitAction}
              disabled={
                update.isPending || autoSend.isPending ||
                (actionMode === "reject" && !reason.trim())
              }
              data-testid="button-submit-action"
            >
              {(update.isPending || autoSend.isPending) ? "Processing…" :
                actionMode === "auto" ? "Broadcast Now" :
                actionMode === "manual" ? "Confirm Sent" :
                "Reject"}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Hot wallet balance dialog */}
      <Dialog open={hotBalNet != null} onOpenChange={(o) => { if (!o) setHotBalNet(null); }}>
        <DialogContent aria-describedby={undefined}>
          <DialogHeader><DialogTitle>Hot Wallet Balance</DialogTitle></DialogHeader>
          <div className="space-y-3 text-sm">
            {balFetching && <div className="text-muted-foreground">Querying RPC…</div>}
            {!balFetching && hotBal && (
              <div className="space-y-2">
                <div className="bg-muted/30 rounded p-3 text-xs space-y-1">
                  <div><span className="text-muted-foreground">Chain:</span> {hotBal.chain}</div>
                  <div className="break-all"><span className="text-muted-foreground">Address:</span> <span className="font-mono">{hotBal.address}</span></div>
                </div>
                <div className="grid grid-cols-2 gap-2">
                  <Card className="p-3">
                    <div className="text-xs text-muted-foreground">Native ({hotBal.chain})</div>
                    <div className="text-lg font-bold font-mono">{fmt(hotBal.native, 6)}</div>
                  </Card>
                  {hotBal.token != null && (
                    <Card className="p-3 border-primary/40">
                      <div className="text-xs text-muted-foreground">Token ({hotBal.symbol})</div>
                      <div className="text-lg font-bold font-mono">{fmt(hotBal.token, 6)}</div>
                    </Card>
                  )}
                </div>
              </div>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => refetchBal()}><RefreshCw className="w-3 h-3 mr-1" /> Refresh</Button>
            <Button onClick={() => setHotBalNet(null)}>Close</Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function StatCard({
  icon, label, value, sub, highlight,
}: { icon: React.ReactNode; label: string; value: string; sub?: string; highlight?: boolean }) {
  return (
    <Card className={`p-3 ${highlight ? "border-primary/40 bg-primary/5" : ""}`}>
      <div className="flex items-center gap-2 text-xs text-muted-foreground mb-1">{icon}{label}</div>
      <div className="text-xl font-bold">{value}</div>
      {sub && <div className="text-xs text-muted-foreground mt-0.5">{sub}</div>}
    </Card>
  );
}
