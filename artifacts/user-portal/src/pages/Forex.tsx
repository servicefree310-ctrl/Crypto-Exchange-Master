import { useState, useEffect, useCallback } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { useToast } from "@/hooks/use-toast";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Skeleton } from "@/components/ui/skeleton";
import { cn } from "@/lib/utils";
import {
  TrendingUp, TrendingDown, Globe, ArrowUpDown, RefreshCw,
  ChevronDown, X, AlertCircle, Info, Zap, BarChart3,
} from "lucide-react";

type Instrument = {
  id: number; symbol: string; name: string; assetClass: string;
  exchange: string; quoteCurrency: string; currentPrice: string;
  previousClose: string; change24h: string; high24h: string; low24h: string;
  volume24h: string; tradingEnabled: boolean; lotSize: string;
  minQty: string; maxQty: string; maxLeverage: number;
  marginRequired: string; takerFee: string; pricePrecision: number;
  qtyPrecision: number; sector: string | null;
};

type Position = {
  id: number; symbol: string; name: string; side: string; qty: string;
  avgEntryPrice: number; currentPrice: number; unrealizedPnl: number;
  realizedPnl: number; leverage: number; marginUsed: number;
  quoteCurrency: string; assetClass: string; createdAt: string;
};

type OrderRow = {
  id: number; symbol: string; name: string; side: string; type: string;
  qty: string; price: string | null; filledQty: string; avgFillPrice: string | null;
  status: string; fee: string; pnl: string; createdAt: string;
  assetClass: string; quoteCurrency: string;
};

function fmtPrice(n: number, precision = 4, currency = "INR") {
  if (!isFinite(n) || n === 0) return "—";
  const prefix = currency === "INR" ? "₹" : currency === "USD" ? "$" : currency + " ";
  return prefix + n.toLocaleString("en-IN", { minimumFractionDigits: precision, maximumFractionDigits: precision });
}
function fmtChange(n: number) {
  const sign = n >= 0 ? "+" : "";
  return sign + n.toFixed(3) + "%";
}
function fmtCompact(n: number) {
  if (n >= 1e7) return (n / 1e7).toFixed(2) + " Cr";
  if (n >= 1e5) return (n / 1e5).toFixed(2) + " L";
  return n.toLocaleString("en-IN");
}

const FOREX_CATEGORIES = [
  { id: "all", label: "All Forex" },
  { id: "INR", label: "INR Pairs" },
  { id: "GLOBAL", label: "Global Pairs" },
];

export default function Forex() {
  const { user } = useAuth();
  const { toast } = useToast();
  const qc = useQueryClient();

  const [selectedSymbol, setSelectedSymbol] = useState<string | null>(null);
  const [category, setCategory] = useState("all");
  const [side, setSide] = useState<"buy" | "sell">("buy");
  const [qty, setQty] = useState("");
  const [orderType, setOrderType] = useState<"MARKET" | "LIMIT">("MARKET");
  const [limitPrice, setLimitPrice] = useState("");
  const [leverage, setLeverage] = useState(10);
  const [activeTab, setActiveTab] = useState("markets");

  const { data: instrData, isLoading } = useQuery({
    queryKey: ["instruments", "forex"],
    queryFn: () => get<{ instruments: Instrument[] }>("/instruments?assetClass=forex"),
    refetchInterval: 15000,
  });

  const { data: posData } = useQuery({
    queryKey: ["instrument-positions"],
    queryFn: () => get<{ positions: Position[] }>("/instruments/positions"),
    enabled: !!user,
    refetchInterval: 10000,
  });

  const { data: orderData } = useQuery({
    queryKey: ["instrument-orders"],
    queryFn: () => get<{ orders: OrderRow[] }>("/instruments/orders"),
    enabled: !!user && activeTab === "orders",
  });

  const { data: quoteData, refetch: refetchQuote } = useQuery({
    queryKey: ["instrument-quote", selectedSymbol],
    queryFn: () => get<{ quote: { ltp: number; open: number; high: number; low: number; changePct: number; volume: number } }>(`/instruments/${selectedSymbol}/quote`),
    enabled: !!selectedSymbol,
    refetchInterval: 5000,
  });

  const instruments = instrData?.instruments ?? [];
  const positions = posData?.positions?.filter((p) => p.assetClass === "forex") ?? [];
  const orders = orderData?.orders?.filter((o) => o.assetClass === "forex") ?? [];

  const filtered = instruments.filter((i) => {
    if (category === "INR") return i.quoteCurrency === "INR";
    if (category === "GLOBAL") return i.countryCode !== "IN";
    return true;
  });

  const selected = instruments.find((i) => i.symbol === selectedSymbol) ?? null;
  const quote = quoteData?.quote ?? null;
  const ltp = quote?.ltp ?? (selected ? Number(selected.currentPrice) : 0);
  const changePct = quote?.changePct ?? (selected ? Number(selected.change24h) : 0);

  useEffect(() => {
    if (!selectedSymbol && instruments.length > 0) setSelectedSymbol(instruments[0].symbol);
  }, [instruments, selectedSymbol]);

  const placeMutation = useMutation({
    mutationFn: (body: object) => post("/instruments/orders", body),
    onSuccess: () => {
      toast({ title: "Order placed", description: `${side.toUpperCase()} ${qty} ${selectedSymbol}` });
      setQty("");
      setLimitPrice("");
      qc.invalidateQueries({ queryKey: ["instrument-positions"] });
      qc.invalidateQueries({ queryKey: ["instrument-orders"] });
    },
    onError: (e: Error) => toast({ title: "Order failed", description: e.message, variant: "destructive" }),
  });

  const closeMutation = useMutation({
    mutationFn: (id: number) => post(`/instruments/positions/${id}/close`),
    onSuccess: () => {
      toast({ title: "Position closed" });
      qc.invalidateQueries({ queryKey: ["instrument-positions"] });
    },
    onError: (e: Error) => toast({ title: "Failed to close", description: e.message, variant: "destructive" }),
  });

  const handlePlaceOrder = () => {
    if (!selectedSymbol || !qty) return;
    placeMutation.mutate({
      symbol: selectedSymbol,
      side,
      qty: Number(qty),
      type: orderType,
      ...(orderType === "LIMIT" && limitPrice ? { price: Number(limitPrice) } : {}),
      leverage,
    });
  };

  const marginNeeded = selected && qty
    ? (ltp * Number(qty) * Number(selected.marginRequired)) / leverage
    : 0;

  return (
    <div className="min-h-screen bg-[#0b0e17] text-white">
      {/* Header */}
      <div className="border-b border-white/10 bg-[#0d1117] px-4 py-3 flex items-center gap-3">
        <div className="flex items-center gap-2">
          <Globe className="w-5 h-5 text-amber-400" />
          <span className="font-bold text-lg tracking-tight">Forex</span>
          <Badge variant="outline" className="border-amber-400/40 text-amber-400 text-[10px]">CFD</Badge>
        </div>
        <div className="ml-auto flex items-center gap-2 text-xs text-muted-foreground">
          <span className="w-2 h-2 rounded-full bg-emerald-400 inline-block animate-pulse" />
          Live prices
        </div>
      </div>

      <div className="flex h-[calc(100vh-112px)] overflow-hidden">
        {/* Left: Instrument list */}
        <div className="w-64 border-r border-white/10 flex flex-col bg-[#0d1117]">
          <div className="p-2 border-b border-white/10 flex gap-1">
            {FOREX_CATEGORIES.map((c) => (
              <button
                key={c.id}
                onClick={() => setCategory(c.id)}
                className={cn(
                  "flex-1 text-[11px] py-1 px-1.5 rounded transition-colors",
                  category === c.id ? "bg-amber-500/20 text-amber-400 font-semibold" : "text-muted-foreground hover:text-white",
                )}
              >
                {c.label}
              </button>
            ))}
          </div>
          <div className="flex-1 overflow-y-auto">
            {isLoading ? (
              Array.from({ length: 8 }).map((_, i) => (
                <div key={i} className="px-3 py-2.5 border-b border-white/5">
                  <Skeleton className="h-4 w-24 mb-1" />
                  <Skeleton className="h-3 w-16" />
                </div>
              ))
            ) : filtered.map((inst) => {
              const chg = Number(inst.change24h);
              const isUp = chg >= 0;
              const isActive = inst.symbol === selectedSymbol;
              return (
                <button
                  key={inst.symbol}
                  onClick={() => setSelectedSymbol(inst.symbol)}
                  className={cn(
                    "w-full px-3 py-2.5 border-b border-white/5 text-left transition-colors hover:bg-white/5",
                    isActive && "bg-amber-500/10 border-l-2 border-l-amber-500",
                  )}
                >
                  <div className="flex items-center justify-between">
                    <span className="text-[13px] font-semibold">{inst.symbol}</span>
                    <span className={cn("text-[12px] font-medium tabular-nums", isUp ? "text-emerald-400" : "text-red-400")}>
                      {fmtChange(chg)}
                    </span>
                  </div>
                  <div className="flex items-center justify-between mt-0.5">
                    <span className="text-[11px] text-muted-foreground truncate max-w-[100px]">{inst.name.split("/")[0]}</span>
                    <span className="text-[12px] tabular-nums text-white/80">
                      {Number(inst.currentPrice).toFixed(inst.pricePrecision)}
                    </span>
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Center: Chart area + Trade form */}
        <div className="flex-1 flex flex-col overflow-hidden">
          {/* Ticker bar */}
          {selected && (
            <div className="border-b border-white/10 bg-[#0d1117] px-4 py-2.5 flex items-center gap-6 flex-shrink-0">
              <div>
                <div className="text-base font-bold">{selected.symbol}</div>
                <div className="text-xs text-muted-foreground">{selected.name}</div>
              </div>
              <div>
                <div className={cn("text-2xl font-bold tabular-nums", changePct >= 0 ? "text-emerald-400" : "text-red-400")}>
                  {ltp.toFixed(selected.pricePrecision)}
                </div>
                <div className={cn("text-xs", changePct >= 0 ? "text-emerald-400" : "text-red-400")}>
                  {fmtChange(changePct)}
                </div>
              </div>
              <div className="text-xs space-y-0.5">
                <div className="text-muted-foreground">High <span className="text-white">{quote?.high ? quote.high.toFixed(selected.pricePrecision) : "—"}</span></div>
                <div className="text-muted-foreground">Low <span className="text-white">{quote?.low ? quote.low.toFixed(selected.pricePrecision) : "—"}</span></div>
              </div>
              <div className="text-xs space-y-0.5">
                <div className="text-muted-foreground">Spread <span className="text-amber-400">0.3 pips</span></div>
                <div className="text-muted-foreground">Vol <span className="text-white">{quote?.volume ? fmtCompact(quote.volume) : "—"}</span></div>
              </div>
              <div className="ml-auto flex gap-2">
                <button onClick={() => refetchQuote()} className="text-muted-foreground hover:text-white transition-colors">
                  <RefreshCw className="w-4 h-4" />
                </button>
              </div>
            </div>
          )}

          {/* Tabs */}
          <Tabs value={activeTab} onValueChange={setActiveTab} className="flex-1 flex flex-col overflow-hidden">
            <TabsList className="border-b border-white/10 bg-transparent rounded-none px-4 flex-shrink-0 justify-start h-10">
              <TabsTrigger value="markets" className="data-[state=active]:border-b-2 data-[state=active]:border-amber-400 rounded-none text-xs">Chart</TabsTrigger>
              <TabsTrigger value="positions" className="data-[state=active]:border-b-2 data-[state=active]:border-amber-400 rounded-none text-xs">
                Positions {positions.length > 0 && <Badge className="ml-1 bg-amber-500/20 text-amber-400 text-[10px]">{positions.length}</Badge>}
              </TabsTrigger>
              <TabsTrigger value="orders" className="data-[state=active]:border-b-2 data-[state=active]:border-amber-400 rounded-none text-xs">Order History</TabsTrigger>
            </TabsList>

            <TabsContent value="markets" className="flex-1 overflow-auto m-0">
              {/* Simulated chart placeholder */}
              <div className="h-72 bg-[#0b0e17] border-b border-white/10 flex items-center justify-center relative">
                <div className="text-center">
                  <BarChart3 className="w-12 h-12 text-amber-400/30 mx-auto mb-3" />
                  <p className="text-sm text-muted-foreground">Real-time chart</p>
                  <p className="text-xs text-muted-foreground/60">Connect Angel One API for live data</p>
                </div>
                {/* Fake candlestick bars for visual */}
                <div className="absolute bottom-0 left-0 right-0 h-40 flex items-end gap-0.5 px-4 pb-2 opacity-20">
                  {Array.from({ length: 60 }).map((_, i) => {
                    const h = 20 + Math.random() * 80;
                    const isUp = Math.random() > 0.45;
                    return <div key={i} style={{ height: `${h}%` }} className={cn("flex-1 rounded-sm", isUp ? "bg-emerald-500" : "bg-red-500")} />;
                  })}
                </div>
              </div>
              {/* Market info */}
              {selected && (
                <div className="p-4 grid grid-cols-3 gap-3 text-xs">
                  {[
                    ["Lot Size", selected.lotSize],
                    ["Min Qty", selected.minQty],
                    ["Max Leverage", `${selected.maxLeverage}×`],
                    ["Margin Req.", `${(Number(selected.marginRequired) * 100).toFixed(0)}%`],
                    ["Taker Fee", `${(Number(selected.takerFee) * 100).toFixed(3)}%`],
                    ["Exchange", selected.exchange],
                  ].map(([label, val]) => (
                    <div key={label} className="bg-white/5 rounded p-2">
                      <div className="text-muted-foreground mb-1">{label}</div>
                      <div className="font-semibold">{val}</div>
                    </div>
                  ))}
                </div>
              )}
            </TabsContent>

            <TabsContent value="positions" className="flex-1 overflow-auto m-0 p-4">
              {!user ? (
                <div className="text-center py-12 text-muted-foreground text-sm">Login to view positions</div>
              ) : positions.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground text-sm">No open forex positions</div>
              ) : (
                <div className="space-y-2">
                  {positions.map((p) => {
                    const pnl = Number(p.unrealizedPnl ?? 0);
                    const isProfit = pnl >= 0;
                    return (
                      <div key={p.id} className="bg-white/5 border border-white/10 rounded-lg p-3 flex items-center gap-4">
                        <div>
                          <div className="font-semibold text-sm">{p.symbol}</div>
                          <Badge variant="outline" className={cn("text-[10px] mt-0.5", p.side === "buy" ? "border-emerald-500/40 text-emerald-400" : "border-red-500/40 text-red-400")}>
                            {p.side.toUpperCase()} {p.leverage}×
                          </Badge>
                        </div>
                        <div className="text-xs space-y-0.5">
                          <div className="text-muted-foreground">Qty <span className="text-white">{p.qty}</span></div>
                          <div className="text-muted-foreground">Entry <span className="text-white">{Number(p.avgEntryPrice).toFixed(4)}</span></div>
                        </div>
                        <div className="text-xs space-y-0.5">
                          <div className="text-muted-foreground">LTP <span className="text-white">{Number(p.currentPrice).toFixed(4)}</span></div>
                          <div className="text-muted-foreground">Margin <span className="text-white">{Number(p.marginUsed).toFixed(2)} {p.quoteCurrency}</span></div>
                        </div>
                        <div className="ml-auto text-right">
                          <div className={cn("font-bold text-sm", isProfit ? "text-emerald-400" : "text-red-400")}>
                            {isProfit ? "+" : ""}{pnl.toFixed(2)} {p.quoteCurrency}
                          </div>
                          <div className="text-[10px] text-muted-foreground">Unrealized PnL</div>
                        </div>
                        <Button
                          size="sm"
                          variant="outline"
                          className="border-red-500/40 text-red-400 hover:bg-red-500/10 text-xs h-7"
                          onClick={() => closeMutation.mutate(p.id)}
                          disabled={closeMutation.isPending}
                        >
                          Close
                        </Button>
                      </div>
                    );
                  })}
                </div>
              )}
            </TabsContent>

            <TabsContent value="orders" className="flex-1 overflow-auto m-0 p-4">
              {!user ? (
                <div className="text-center py-12 text-muted-foreground text-sm">Login to view orders</div>
              ) : orders.length === 0 ? (
                <div className="text-center py-12 text-muted-foreground text-sm">No forex orders yet</div>
              ) : (
                <div className="overflow-x-auto">
                  <table className="w-full text-xs">
                    <thead>
                      <tr className="border-b border-white/10 text-muted-foreground">
                        <th className="text-left py-2 px-2">Symbol</th>
                        <th className="text-left py-2 px-2">Side</th>
                        <th className="text-left py-2 px-2">Type</th>
                        <th className="text-right py-2 px-2">Qty</th>
                        <th className="text-right py-2 px-2">Fill Price</th>
                        <th className="text-right py-2 px-2">Fee</th>
                        <th className="text-left py-2 px-2">Status</th>
                        <th className="text-left py-2 px-2">Time</th>
                      </tr>
                    </thead>
                    <tbody>
                      {orders.map((o) => (
                        <tr key={o.id} className="border-b border-white/5 hover:bg-white/3">
                          <td className="py-2 px-2 font-medium">{o.symbol}</td>
                          <td className={cn("py-2 px-2 font-semibold", o.side === "buy" ? "text-emerald-400" : "text-red-400")}>{o.side.toUpperCase()}</td>
                          <td className="py-2 px-2 text-muted-foreground">{o.type}</td>
                          <td className="py-2 px-2 text-right tabular-nums">{o.filledQty}/{o.qty}</td>
                          <td className="py-2 px-2 text-right tabular-nums">{o.avgFillPrice ? Number(o.avgFillPrice).toFixed(4) : "—"}</td>
                          <td className="py-2 px-2 text-right tabular-nums text-muted-foreground">{Number(o.fee).toFixed(2)}</td>
                          <td className="py-2 px-2">
                            <Badge variant="outline" className={cn("text-[10px]",
                              o.status === "filled" ? "border-emerald-500/40 text-emerald-400" :
                              o.status === "rejected" ? "border-red-500/40 text-red-400" :
                              "border-amber-500/40 text-amber-400",
                            )}>
                              {o.status}
                            </Badge>
                          </td>
                          <td className="py-2 px-2 text-muted-foreground">{new Date(o.createdAt).toLocaleTimeString()}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
            </TabsContent>
          </Tabs>
        </div>

        {/* Right: Order form */}
        <div className="w-72 border-l border-white/10 bg-[#0d1117] p-4 flex flex-col gap-4 overflow-y-auto flex-shrink-0">
          <div className="text-sm font-semibold text-white/80">Place Order</div>

          {/* Buy/Sell toggle */}
          <div className="flex rounded-lg overflow-hidden border border-white/10">
            <button
              onClick={() => setSide("buy")}
              className={cn("flex-1 py-2 text-sm font-semibold transition-colors", side === "buy" ? "bg-emerald-600 text-white" : "text-muted-foreground hover:text-white")}
            >
              Buy / Long
            </button>
            <button
              onClick={() => setSide("sell")}
              className={cn("flex-1 py-2 text-sm font-semibold transition-colors", side === "sell" ? "bg-red-600 text-white" : "text-muted-foreground hover:text-white")}
            >
              Sell / Short
            </button>
          </div>

          {/* Order type */}
          <div className="flex gap-1">
            {(["MARKET", "LIMIT"] as const).map((t) => (
              <button
                key={t}
                onClick={() => setOrderType(t)}
                className={cn("flex-1 py-1 text-xs rounded transition-colors", orderType === t ? "bg-amber-500/20 text-amber-400 font-semibold" : "text-muted-foreground hover:text-white")}
              >
                {t}
              </button>
            ))}
          </div>

          {/* Selected pair */}
          {selected && (
            <div className="bg-white/5 rounded p-2 text-xs">
              <div className="text-muted-foreground">Selected</div>
              <div className="font-bold">{selected.symbol}</div>
              <div className={cn("font-semibold", changePct >= 0 ? "text-emerald-400" : "text-red-400")}>
                {ltp.toFixed(selected.pricePrecision)} {fmtChange(changePct)}
              </div>
            </div>
          )}

          {/* Leverage */}
          <div>
            <label className="text-xs text-muted-foreground block mb-1">
              Leverage: <span className="text-amber-400 font-bold">{leverage}×</span>
            </label>
            <input
              type="range" min={1} max={selected?.maxLeverage ?? 50} value={leverage}
              onChange={(e) => setLeverage(Number(e.target.value))}
              className="w-full accent-amber-500"
            />
            <div className="flex justify-between text-[10px] text-muted-foreground">
              <span>1×</span><span>{selected?.maxLeverage ?? 50}×</span>
            </div>
          </div>

          {/* Qty */}
          <div>
            <label className="text-xs text-muted-foreground block mb-1">Quantity (lots)</label>
            <Input
              type="number" value={qty} onChange={(e) => setQty(e.target.value)}
              placeholder={`Min ${selected?.minQty ?? "1"}`}
              className="bg-white/5 border-white/20 text-sm h-9"
            />
          </div>

          {/* Limit price */}
          {orderType === "LIMIT" && (
            <div>
              <label className="text-xs text-muted-foreground block mb-1">Limit Price</label>
              <Input
                type="number" value={limitPrice} onChange={(e) => setLimitPrice(e.target.value)}
                placeholder={ltp.toFixed(selected?.pricePrecision ?? 4)}
                className="bg-white/5 border-white/20 text-sm h-9"
              />
            </div>
          )}

          {/* Margin summary */}
          {marginNeeded > 0 && (
            <div className="bg-amber-500/10 border border-amber-500/20 rounded p-2 text-xs space-y-1">
              <div className="flex justify-between">
                <span className="text-muted-foreground">Margin Required</span>
                <span className="font-semibold">{marginNeeded.toFixed(2)} {selected?.quoteCurrency}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Notional Value</span>
                <span>{(ltp * Number(qty)).toFixed(2)} {selected?.quoteCurrency}</span>
              </div>
            </div>
          )}

          {!user ? (
            <Button className="bg-amber-500 hover:bg-amber-600 text-black font-bold" asChild>
              <a href="/login">Login to Trade</a>
            </Button>
          ) : (
            <Button
              onClick={handlePlaceOrder}
              disabled={!selectedSymbol || !qty || placeMutation.isPending}
              className={cn(
                "font-bold",
                side === "buy" ? "bg-emerald-600 hover:bg-emerald-700" : "bg-red-600 hover:bg-red-700",
              )}
            >
              {placeMutation.isPending ? "Placing..." : `${side === "buy" ? "Buy" : "Sell"} ${selectedSymbol ?? ""}`}
            </Button>
          )}

          <div className="text-[10px] text-muted-foreground/60 flex items-start gap-1">
            <Info className="w-3 h-3 flex-shrink-0 mt-0.5" />
            <span>CFD trading involves risk. Currently in {selected ? selected.exchange : "—"} simulated mode. Connect Angel One for live execution.</span>
          </div>
        </div>
      </div>
    </div>
  );
}
