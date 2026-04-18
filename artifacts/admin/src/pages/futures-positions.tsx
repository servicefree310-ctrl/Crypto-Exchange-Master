import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Search, Zap, AlertTriangle, TrendingUp, TrendingDown, RefreshCw } from "lucide-react";
import { useState, useMemo } from "react";
import { useAuth } from "@/lib/auth";

type Pos = {
  id: number; uid: string; userId: number; pairId: number; side: string; leverage: number;
  qty: string; entryPrice: string; markPrice: string; marginAmount: string; marginType: string;
  unrealizedPnl: string; liquidationPrice: string; status: string;
  openedAt: string; closedAt: string | null; closeReason: string | null; realizedPnl: string;
};
type Pair = { id: number; symbol: string };

function fmt(n: string | number, dp = 4): string {
  const v = typeof n === "string" ? Number(n) : n;
  return Number.isFinite(v) ? v.toLocaleString("en-IN", { maximumFractionDigits: dp }) : "0";
}

export default function FuturesPositionsPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const [tab, setTab] = useState("open");
  const [search, setSearch] = useState("");

  const { data: positions = [], refetch } = useQuery<Pos[]>({
    queryKey: ["/admin/futures-positions", tab],
    queryFn: () => get<Pos[]>(`/admin/futures-positions?status=${tab}`),
    refetchInterval: 5000,
  });
  const { data: pairs = [] } = useQuery<Pair[]>({ queryKey: ["/admin/pairs"], queryFn: () => get<Pair[]>("/admin/pairs") });
  const pairMap = useMemo(() => new Map(pairs.map(p => [p.id, p.symbol])), [pairs]);

  const liquidate = useMutation({
    mutationFn: (id: number) => post(`/admin/futures-positions/${id}/liquidate`, {}),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/futures-positions"] }),
  });
  const runRisk = useMutation({
    mutationFn: () => post<{ checked: number; liquidated: number; nearLiquidation: number }>("/admin/futures-engine/run-risk", {}),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/futures-positions"] }),
  });

  const filtered = useMemo(() => {
    return positions.filter(p => {
      if (!search) return true;
      const hay = `${p.uid} ${p.userId} ${pairMap.get(p.pairId) ?? ""}`.toLowerCase();
      return hay.includes(search.toLowerCase());
    });
  }, [positions, search, pairMap]);

  const openPositions = positions.filter(p => p.status === "open");
  const totalNotional = openPositions.reduce((s, p) => s + Number(p.entryPrice) * Number(p.qty), 0);
  const totalPnl = openPositions.reduce((s, p) => s + Number(p.unrealizedPnl), 0);
  const totalMargin = openPositions.reduce((s, p) => s + Number(p.marginAmount), 0);
  const nearLiq = openPositions.filter(p => {
    const mark = Number(p.markPrice);
    const liq = Number(p.liquidationPrice);
    if (!mark || !liq) return false;
    return Math.abs(mark - liq) / mark < 0.05;
  }).length;

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
        <Card className="p-3"><div className="text-xs text-muted-foreground">Open Positions</div><div className="text-xl font-bold">{openPositions.length}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Total Notional</div><div className="text-xl font-bold">${fmt(totalNotional, 2)}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Total Margin</div><div className="text-xl font-bold">${fmt(totalMargin, 2)}</div></Card>
        <Card className="p-3"><div className="text-xs text-muted-foreground">Total uPnL</div><div className={`text-xl font-bold ${totalPnl >= 0 ? "text-green-500" : "text-red-500"}`}>${fmt(totalPnl, 2)}</div></Card>
        <Card className={`p-3 ${nearLiq > 0 ? "border-destructive bg-destructive/5" : ""}`}>
          <div className="flex items-center gap-1 text-xs text-muted-foreground"><AlertTriangle className="w-3 h-3" />Near Liquidation</div>
          <div className={`text-xl font-bold ${nearLiq > 0 ? "text-destructive" : ""}`}>{nearLiq}</div>
        </Card>
      </div>

      <Card className="p-3 flex flex-wrap gap-2 items-center">
        <div className="relative flex-1 min-w-[220px]">
          <Search className="w-4 h-4 absolute left-2 top-2.5 text-muted-foreground" />
          <Input placeholder="Search UID, user, pair…" className="pl-8" value={search} onChange={(e) => setSearch(e.target.value)} data-testid="input-search" />
        </div>
        <Button size="sm" variant="outline" onClick={() => refetch()}><RefreshCw className="w-3 h-3 mr-1" />Refresh</Button>
        {isAdmin && <Button size="sm" onClick={() => runRisk.mutate()} disabled={runRisk.isPending} data-testid="button-run-risk"><Zap className="w-3 h-3 mr-1" />Run Risk Check</Button>}
      </Card>

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="open">Open</TabsTrigger>
          <TabsTrigger value="liquidated">Liquidated</TabsTrigger>
          <TabsTrigger value="closed">Closed</TabsTrigger>
          <TabsTrigger value="all">All</TabsTrigger>
        </TabsList>

        <TabsContent value={tab}>
          <Card>
            <div className="overflow-x-auto">
              <Table>
                <TableHeader><TableRow>
                  <TableHead>UID</TableHead><TableHead>User</TableHead><TableHead>Pair</TableHead>
                  <TableHead>Side</TableHead><TableHead>Lev</TableHead>
                  <TableHead className="text-right">Qty</TableHead>
                  <TableHead className="text-right">Entry</TableHead>
                  <TableHead className="text-right">Mark</TableHead>
                  <TableHead className="text-right">Liq Price</TableHead>
                  <TableHead className="text-right">Margin</TableHead>
                  <TableHead className="text-right">uPnL</TableHead>
                  <TableHead>Status</TableHead>
                  {isAdmin && <TableHead></TableHead>}
                </TableRow></TableHeader>
                <TableBody>
                  {filtered.length === 0 && <TableRow><TableCell colSpan={isAdmin ? 13 : 12} className="text-center py-8 text-muted-foreground">No positions in this tab.</TableCell></TableRow>}
                  {filtered.map(p => {
                    const pnl = Number(p.unrealizedPnl);
                    const mark = Number(p.markPrice);
                    const liq = Number(p.liquidationPrice);
                    const dist = mark && liq ? Math.abs(mark - liq) / mark : 1;
                    const isNear = p.status === "open" && dist < 0.05;
                    return (
                      <TableRow key={p.id} className={isNear ? "bg-destructive/5" : ""} data-testid={`pos-${p.id}`}>
                        <TableCell className="font-mono text-[10px] text-muted-foreground" title={p.uid}>{p.uid.slice(0, 10)}…</TableCell>
                        <TableCell className="text-xs">user-{p.userId}</TableCell>
                        <TableCell className="font-bold">{pairMap.get(p.pairId) ?? `#${p.pairId}`}</TableCell>
                        <TableCell>{p.side === "long" ? <Badge className="bg-green-500/20 text-green-500 border-green-500/40"><TrendingUp className="w-3 h-3 mr-1" />long</Badge> : <Badge className="bg-red-500/20 text-red-500 border-red-500/40"><TrendingDown className="w-3 h-3 mr-1" />short</Badge>}</TableCell>
                        <TableCell>{p.leverage}x</TableCell>
                        <TableCell className="text-right tabular-nums text-xs">{fmt(p.qty, 6)}</TableCell>
                        <TableCell className="text-right tabular-nums text-xs">{fmt(p.entryPrice, 4)}</TableCell>
                        <TableCell className="text-right tabular-nums text-xs">{fmt(p.markPrice, 4)}</TableCell>
                        <TableCell className={`text-right tabular-nums text-xs ${isNear ? "text-destructive font-bold" : ""}`}>{fmt(p.liquidationPrice, 4)}</TableCell>
                        <TableCell className="text-right tabular-nums text-xs">{fmt(p.marginAmount, 2)}</TableCell>
                        <TableCell className={`text-right tabular-nums font-bold ${pnl >= 0 ? "text-green-500" : "text-red-500"}`}>{pnl >= 0 ? "+" : ""}{fmt(pnl, 2)}</TableCell>
                        <TableCell>
                          {p.status === "open" && (isNear ? <Badge variant="destructive">⚠ near liq</Badge> : <Badge variant="default">open</Badge>)}
                          {p.status === "liquidated" && <Badge variant="destructive">liquidated</Badge>}
                          {p.status === "closed" && <Badge variant="secondary">closed</Badge>}
                          {p.closeReason && <div className="text-[10px] text-muted-foreground mt-1 max-w-[140px] truncate" title={p.closeReason}>{p.closeReason}</div>}
                        </TableCell>
                        {isAdmin && (
                          <TableCell className="text-right">
                            {p.status === "open" && <Button size="sm" variant="destructive" onClick={() => { if (confirm(`Force liquidate position ${p.id}?`)) liquidate.mutate(p.id); }} data-testid={`button-liq-${p.id}`}>Liquidate</Button>}
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
      </Tabs>
    </div>
  );
}
