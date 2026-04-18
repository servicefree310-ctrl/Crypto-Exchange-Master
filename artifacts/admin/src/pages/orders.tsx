import { useQuery } from "@tanstack/react-query";
import { get } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Input } from "@/components/ui/input";
import { ArrowDownUp, Activity, Bot as BotIcon, User as UserIcon, TrendingUp, TrendingDown, CheckCircle2, XCircle, Clock } from "lucide-react";
import { useState, useMemo } from "react";

type Order = {
  id: number; userId: number; pairId: number; side: "buy" | "sell"; type: string;
  price: string; qty: string; filledQty: string; avgPrice: string;
  fee: string; tds: string; status: string; isBot: number; botId: number | null;
  createdAt: string;
};
type Trade = { id: number; orderId: number; userId: number; pairId: number; side: string; price: string; qty: string; createdAt: string };
type Pair = { id: number; symbol: string };
type Stats = {
  total: number; open_count: number; filled_count: number; cancelled_count: number;
  buy_count: number; sell_count: number; bot_count: number; user_count: number;
  bot_filled: number; user_filled: number; filled_value: string;
};

function StatCard({ label, value, sub, icon: Icon, tone }: { label: string; value: string | number; sub?: string; icon: any; tone?: string }) {
  return (
    <Card className="p-4">
      <div className="flex items-center justify-between mb-1">
        <span className="text-xs text-muted-foreground">{label}</span>
        <Icon className={`size-4 ${tone || "text-muted-foreground"}`} />
      </div>
      <div className="text-2xl font-bold tabular-nums">{value}</div>
      {sub && <div className="text-xs text-muted-foreground mt-1">{sub}</div>}
    </Card>
  );
}

export default function OrdersPage() {
  const [side, setSide] = useState<string>("all");
  const [status, setStatus] = useState<string>("all");
  const [actor, setActor] = useState<string>("all");
  const [pairId, setPairId] = useState<string>("all");
  const [userIdFilter, setUserIdFilter] = useState<string>("");

  const { data: pairs = [] } = useQuery<Pair[]>({ queryKey: ["pairs"], queryFn: () => get("/admin/pairs") });
  const { data: stats } = useQuery<Stats>({ queryKey: ["orders-stats"], queryFn: () => get("/admin/orders/stats"), refetchInterval: 5000 });

  const params = new URLSearchParams();
  if (side !== "all") params.set("side", side);
  if (status !== "all") params.set("status", status);
  if (actor === "bot") params.set("isBot", "1");
  if (actor === "user") params.set("isBot", "0");
  if (pairId !== "all") params.set("pairId", pairId);
  if (userIdFilter.trim()) params.set("userId", userIdFilter.trim());
  const qs = params.toString();

  const { data: orders = [] } = useQuery<Order[]>({
    queryKey: ["admin-orders", qs], queryFn: () => get(`/admin/orders${qs ? `?${qs}` : ""}`),
    refetchInterval: 4000,
  });
  const { data: trades = [] } = useQuery<Trade[]>({
    queryKey: ["admin-trades", pairId, userIdFilter, side],
    queryFn: () => {
      const tp = new URLSearchParams();
      if (pairId !== "all") tp.set("pairId", pairId);
      if (userIdFilter.trim()) tp.set("userId", userIdFilter.trim());
      if (side !== "all") tp.set("side", side);
      const t = tp.toString();
      return get(`/admin/trades${t ? `?${t}` : ""}`);
    },
    refetchInterval: 4000,
  });

  const pairById = useMemo(() => new Map(pairs.map(p => [p.id, p.symbol])), [pairs]);

  const statusBadge = (s: string) => {
    if (s === "filled") return <Badge className="bg-emerald-500"><CheckCircle2 className="size-3 mr-1" />Filled</Badge>;
    if (s === "open") return <Badge className="bg-blue-500"><Clock className="size-3 mr-1" />Open</Badge>;
    if (s === "cancelled") return <Badge className="bg-zinc-500"><XCircle className="size-3 mr-1" />Cancelled</Badge>;
    return <Badge>{s}</Badge>;
  };

  const filledValue = stats ? Number(stats.filled_value).toLocaleString("en-IN", { maximumFractionDigits: 2 }) : "0";

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-bold flex items-center gap-2"><ArrowDownUp className="size-6" /> Orders & Trades</h1>
        <p className="text-sm text-muted-foreground">Live view of all platform orders. Filter by side, status, actor (user/bot), pair, or user id.</p>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-3">
        <StatCard label="Total Orders" value={stats?.total ?? "—"} icon={Activity} />
        <StatCard label="Open" value={stats?.open_count ?? "—"} icon={Clock} tone="text-blue-500" />
        <StatCard label="Filled" value={stats?.filled_count ?? "—"} sub={`Vol ≈ ${filledValue}`} icon={CheckCircle2} tone="text-emerald-500" />
        <StatCard label="Buy / Sell" value={stats ? `${stats.buy_count} / ${stats.sell_count}` : "—"} icon={TrendingUp} />
        <StatCard label="Bot Filled" value={stats?.bot_filled ?? "—"} sub={`of ${stats?.bot_count ?? 0} bot orders`} icon={BotIcon} tone="text-purple-500" />
        <StatCard label="User Filled" value={stats?.user_filled ?? "—"} sub={`of ${stats?.user_count ?? 0} user orders`} icon={UserIcon} tone="text-amber-500" />
      </div>

      {/* Filters */}
      <Card className="p-3">
        <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
          <div>
            <label className="text-xs text-muted-foreground mb-1 block">Side</label>
            <Select value={side} onValueChange={setSide}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All sides</SelectItem>
                <SelectItem value="buy">Buy only</SelectItem>
                <SelectItem value="sell">Sell only</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div>
            <label className="text-xs text-muted-foreground mb-1 block">Status</label>
            <Select value={status} onValueChange={setStatus}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All statuses</SelectItem>
                <SelectItem value="open">Open</SelectItem>
                <SelectItem value="filled">Filled</SelectItem>
                <SelectItem value="cancelled">Cancelled</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div>
            <label className="text-xs text-muted-foreground mb-1 block">Actor</label>
            <Select value={actor} onValueChange={setActor}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All</SelectItem>
                <SelectItem value="user">User orders</SelectItem>
                <SelectItem value="bot">Bot orders</SelectItem>
              </SelectContent>
            </Select>
          </div>
          <div>
            <label className="text-xs text-muted-foreground mb-1 block">Pair</label>
            <Select value={pairId} onValueChange={setPairId}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All pairs</SelectItem>
                {pairs.map(p => <SelectItem key={p.id} value={String(p.id)}>{p.symbol}</SelectItem>)}
              </SelectContent>
            </Select>
          </div>
          <div>
            <label className="text-xs text-muted-foreground mb-1 block">User ID</label>
            <Input placeholder="e.g. 2" value={userIdFilter} onChange={(e) => setUserIdFilter(e.target.value)} />
          </div>
        </div>
        <div className="flex justify-end mt-2">
          <Button size="sm" variant="ghost" onClick={() => { setSide("all"); setStatus("all"); setActor("all"); setPairId("all"); setUserIdFilter(""); }}>Reset</Button>
        </div>
      </Card>

      <Tabs defaultValue="orders">
        <TabsList>
          <TabsTrigger value="orders">Orders ({orders.length})</TabsTrigger>
          <TabsTrigger value="trades">Trade History ({trades.length})</TabsTrigger>
        </TabsList>

        <TabsContent value="orders" className="mt-3">
          <Card>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>UID</TableHead>
                  <TableHead>Pair</TableHead>
                  <TableHead>Side</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Price</TableHead>
                  <TableHead>Qty</TableHead>
                  <TableHead>Filled</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Actor</TableHead>
                  <TableHead>User</TableHead>
                  <TableHead>Time</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {orders.length === 0 ? (
                  <TableRow><TableCell colSpan={11} className="text-center text-muted-foreground py-8">No orders match the filters.</TableCell></TableRow>
                ) : orders.map(o => (
                  <TableRow key={o.id}>
                    <TableCell className="font-mono text-[10px] text-muted-foreground" title={(o as any).uid}>{((o as any).uid || `#${o.id}`).slice(0, 10)}…</TableCell>
                    <TableCell className="font-mono">{pairById.get(o.pairId) || `#${o.pairId}`}</TableCell>
                    <TableCell>
                      {o.side === "buy"
                        ? <Badge className="bg-emerald-600"><TrendingUp className="size-3 mr-1" />BUY</Badge>
                        : <Badge className="bg-red-600"><TrendingDown className="size-3 mr-1" />SELL</Badge>}
                    </TableCell>
                    <TableCell className="uppercase text-xs">{o.type}</TableCell>
                    <TableCell className="tabular-nums">{Number(o.price).toLocaleString("en-US", { maximumFractionDigits: 8 })}</TableCell>
                    <TableCell className="tabular-nums">{Number(o.qty).toFixed(4)}</TableCell>
                    <TableCell className="tabular-nums">{Number(o.filledQty).toFixed(4)} {Number(o.avgPrice) > 0 && <span className="text-xs text-muted-foreground">@{Number(o.avgPrice).toFixed(4)}</span>}</TableCell>
                    <TableCell>{statusBadge(o.status)}</TableCell>
                    <TableCell>
                      {o.isBot ? <Badge variant="outline" className="border-purple-500 text-purple-500"><BotIcon className="size-3 mr-1" />Bot{o.botId ? `#${o.botId}` : ""}</Badge>
                                : <Badge variant="outline"><UserIcon className="size-3 mr-1" />User</Badge>}
                    </TableCell>
                    <TableCell className="text-xs text-muted-foreground">#{o.userId}</TableCell>
                    <TableCell className="text-xs text-muted-foreground">{new Date(o.createdAt).toLocaleString()}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </Card>
        </TabsContent>

        <TabsContent value="trades" className="mt-3">
          <Card>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>UID</TableHead>
                  <TableHead>Pair</TableHead>
                  <TableHead>Side</TableHead>
                  <TableHead>Price</TableHead>
                  <TableHead>Qty</TableHead>
                  <TableHead>Value</TableHead>
                  <TableHead>Order</TableHead>
                  <TableHead>User</TableHead>
                  <TableHead>Time</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {trades.length === 0 ? (
                  <TableRow><TableCell colSpan={9} className="text-center text-muted-foreground py-8">No trades yet.</TableCell></TableRow>
                ) : trades.map(t => (
                  <TableRow key={t.id}>
                    <TableCell className="font-mono text-[10px] text-muted-foreground" title={(t as any).uid}>{((t as any).uid || `#${t.id}`).slice(0, 10)}…</TableCell>
                    <TableCell className="font-mono">{pairById.get(t.pairId) || `#${t.pairId}`}</TableCell>
                    <TableCell>{t.side === "buy" ? <Badge className="bg-emerald-600">BUY</Badge> : <Badge className="bg-red-600">SELL</Badge>}</TableCell>
                    <TableCell className="tabular-nums">{Number(t.price).toLocaleString("en-US", { maximumFractionDigits: 8 })}</TableCell>
                    <TableCell className="tabular-nums">{Number(t.qty).toFixed(4)}</TableCell>
                    <TableCell className="tabular-nums">{(Number(t.price) * Number(t.qty)).toFixed(2)}</TableCell>
                    <TableCell className="font-mono text-xs">#{t.orderId}</TableCell>
                    <TableCell className="text-xs text-muted-foreground">#{t.userId}</TableCell>
                    <TableCell className="text-xs text-muted-foreground">{new Date(t.createdAt).toLocaleString()}</TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
