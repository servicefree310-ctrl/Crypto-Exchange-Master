import { useParams, Link, useLocation } from "wouter";
import {
  useTicker,
  useTickers,
  useOrderbook,
  useRecentTrades,
  decodeSymbol,
  encodeSymbol,
} from "@/lib/marketSocket";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, del } from "@/lib/api";
import { useMemo, useState, useEffect, useRef, useCallback } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Slider } from "@/components/ui/slider";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import { Popover, PopoverContent, PopoverTrigger } from "@/components/ui/popover";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { toast } from "sonner";
import { useAuth } from "@/lib/auth";
import { PriceChart } from "@/components/PriceChart";
import { OrderFillsDialog } from "@/components/OrderFillsDialog";
import { cn } from "@/lib/utils";
import {
  Star,
  ChevronDown,
  Search,
  TrendingUp,
  TrendingDown,
  X,
  ArrowUpDown,
  Wallet as WalletIcon,
  Info,
  LayoutGrid,
  LayoutPanelLeft,
  Sparkles,
} from "lucide-react";

const LAYOUT_KEY = "zebvix:trade:layout";
type LayoutMode = "simple" | "advanced" | "pro";

// ──────────────────────────────────────────────────────────────────
// Helpers (inlined; mirrors Markets.tsx)
// ──────────────────────────────────────────────────────────────────
function isInr(sym: string) {
  return sym.endsWith("/INR") || sym.endsWith("INR");
}
function baseAsset(sym: string) {
  return sym.split("/")[0] || sym;
}
function quoteAsset(sym: string) {
  return sym.split("/")[1] || "";
}
function fmtNum(n: number, digits = 2): string {
  if (!isFinite(n) || n === 0) return "—";
  return n.toLocaleString(undefined, { minimumFractionDigits: digits, maximumFractionDigits: digits });
}
function fmtPrice(n: number, quote: string): string {
  if (!isFinite(n) || n === 0) return "—";
  const inr = quote === "INR";
  const digits = inr ? 2 : n < 1 ? 6 : n < 100 ? 4 : 2;
  const prefix = inr ? "₹" : "";
  return prefix + n.toLocaleString(undefined, { minimumFractionDigits: digits, maximumFractionDigits: digits });
}
function fmtCompact(n: number, prefix = "") {
  if (!isFinite(n) || n === 0) return prefix + "0";
  const abs = Math.abs(n);
  if (abs >= 1e9) return prefix + (n / 1e9).toFixed(2) + "B";
  if (abs >= 1e6) return prefix + (n / 1e6).toFixed(2) + "M";
  if (abs >= 1e3) return prefix + (n / 1e3).toFixed(2) + "K";
  return prefix + n.toFixed(2);
}
function hashStr(s: string): number {
  let h = 0;
  for (let i = 0; i < s.length; i++) h = (h * 31 + s.charCodeAt(i)) >>> 0;
  return h;
}

const FAV_KEY = "zebvix:favorites";
function useFavorites() {
  const [favs, setFavs] = useState<Set<string>>(() => new Set());
  useEffect(() => {
    try {
      const raw = window.localStorage.getItem(FAV_KEY);
      if (raw) {
        const arr = JSON.parse(raw);
        if (Array.isArray(arr)) setFavs(new Set(arr.filter((x) => typeof x === "string")));
      }
    } catch { /* ignore */ }
  }, []);
  const toggle = useCallback((sym: string) => {
    setFavs((prev) => {
      const next = new Set(prev);
      if (next.has(sym)) next.delete(sym);
      else next.add(sym);
      try { window.localStorage.setItem(FAV_KEY, JSON.stringify([...next])); } catch { /* ignore */ }
      return next;
    });
  }, []);
  return { favs, toggle };
}

// ──────────────────────────────────────────────────────────────────
// Asset icon
// ──────────────────────────────────────────────────────────────────
function AssetIcon({ symbol, size = 9 }: { symbol: string; size?: 6 | 7 | 8 | 9 | 10 }) {
  const b = baseAsset(symbol);
  const palette = [
    "from-amber-500 to-orange-600",
    "from-sky-500 to-blue-600",
    "from-violet-500 to-purple-600",
    "from-emerald-500 to-teal-600",
    "from-rose-500 to-pink-600",
    "from-fuchsia-500 to-indigo-600",
    "from-yellow-500 to-amber-600",
    "from-cyan-500 to-sky-600",
  ];
  const grad = palette[hashStr(b) % palette.length];
  const dim =
    size === 6 ? "h-6 w-6 text-[10px]"
    : size === 7 ? "h-7 w-7 text-[11px]"
    : size === 8 ? "h-8 w-8 text-xs"
    : size === 10 ? "h-10 w-10 text-sm"
    : "h-9 w-9 text-sm";
  return (
    <div className={`${dim} rounded-full bg-gradient-to-br ${grad} text-white flex items-center justify-center font-bold shadow-md flex-shrink-0`}>
      {b.slice(0, 1)}
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────
// Symbol switcher (popover with live search across tickers)
// Only shows pairs that are ENABLED on the server (active + tradingEnabled
// + both coins listed). The set comes from /api/pairs.
// ──────────────────────────────────────────────────────────────────
function SymbolSwitcher({ current, enabledPairSet }: { current: string; enabledPairSet: Set<string> }) {
  const tickers = useTickers();
  const [open, setOpen] = useState(false);
  const [search, setSearch] = useState("");
  const [, navigate] = useLocation();
  const { favs } = useFavorites();

  const list = useMemo(() => {
    const all = Object.values(tickers)
      .filter((t) => enabledPairSet.size === 0 || enabledPairSet.has(t.symbol))
      .sort((a, b) => (b.quoteVolume || 0) - (a.quoteVolume || 0));
    const trimmed = search.trim().toLowerCase();
    if (!trimmed) return all;
    return all.filter((t) => t.symbol.toLowerCase().includes(trimmed));
  }, [tickers, search, enabledPairSet]);

  const favList = useMemo(() => list.filter((t) => favs.has(t.symbol)), [list, favs]);
  const otherList = useMemo(() => list.filter((t) => !favs.has(t.symbol)), [list, favs]);

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <button
          type="button"
          className="flex items-center gap-2 hover:bg-muted/40 rounded-md px-2 py-1 transition-colors group"
        >
          <AssetIcon symbol={current} />
          <div className="flex flex-col items-start">
            <div className="flex items-center gap-1.5">
              <span className="text-base sm:text-lg font-extrabold leading-none tracking-tight">{baseAsset(current)}</span>
              <span className="text-xs text-muted-foreground leading-none">/{quoteAsset(current)}</span>
            </div>
            <span className="text-[10px] text-muted-foreground mt-0.5">Spot · Click to switch</span>
          </div>
          <ChevronDown className="h-4 w-4 text-muted-foreground group-hover:text-foreground transition-colors" />
        </button>
      </PopoverTrigger>
      <PopoverContent align="start" sideOffset={8} className="w-80 p-0">
        <div className="p-2 border-b border-border">
          <div className="relative">
            <Search className="absolute left-2.5 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground pointer-events-none" />
            <Input
              autoFocus
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder="Search market…"
              className="pl-8 h-8 text-sm"
            />
          </div>
        </div>
        <div className="max-h-80 overflow-auto">
          {favList.length > 0 && (
            <div>
              <div className="px-3 py-1.5 text-[10px] uppercase tracking-wider text-muted-foreground font-medium bg-muted/20">
                Favorites
              </div>
              {favList.map((t) => (
                <SwitcherRow key={`fav-${t.symbol}`} t={t} active={t.symbol === current} onPick={() => { setOpen(false); navigate(`/trade/${encodeSymbol(t.symbol)}`); }} />
              ))}
            </div>
          )}
          <div className="px-3 py-1.5 text-[10px] uppercase tracking-wider text-muted-foreground font-medium bg-muted/20">
            All markets
          </div>
          {otherList.map((t) => (
            <SwitcherRow key={t.symbol} t={t} active={t.symbol === current} onPick={() => { setOpen(false); navigate(`/trade/${encodeSymbol(t.symbol)}`); }} />
          ))}
          {list.length === 0 && (
            <div className="px-4 py-6 text-center text-xs text-muted-foreground">No matches.</div>
          )}
        </div>
      </PopoverContent>
    </Popover>
  );
}

function SwitcherRow({ t, active, onPick }: { t: { symbol: string; lastPrice: number; priceChangePercent: number }; active: boolean; onPick: () => void }) {
  const positive = t.priceChangePercent >= 0;
  return (
    <button
      type="button"
      onClick={onPick}
      className={`w-full flex items-center gap-2 px-3 py-2 hover:bg-muted/40 text-left transition-colors ${active ? "bg-primary/10" : ""}`}
    >
      <AssetIcon symbol={t.symbol} size={7} />
      <div className="flex-1 min-w-0">
        <div className="text-sm font-bold truncate">
          {baseAsset(t.symbol)}<span className="text-[10px] text-muted-foreground font-normal">/{quoteAsset(t.symbol)}</span>
        </div>
      </div>
      <div className="text-right">
        <div className="text-xs font-mono">{fmtPrice(t.lastPrice, quoteAsset(t.symbol))}</div>
        <div className={`text-[10px] font-bold ${positive ? "text-success" : "text-destructive"}`}>
          {positive ? "+" : ""}{t.priceChangePercent.toFixed(2)}%
        </div>
      </div>
    </button>
  );
}

// ──────────────────────────────────────────────────────────────────
// Animated price (flashes on update)
// ──────────────────────────────────────────────────────────────────
function useFlashOnChange(value: number) {
  const [flash, setFlash] = useState<"up" | "down" | null>(null);
  const prev = useRef<number>(value);
  useEffect(() => {
    if (value === prev.current || prev.current === 0) { prev.current = value; return; }
    setFlash(value > prev.current ? "up" : "down");
    prev.current = value;
    const t = window.setTimeout(() => setFlash(null), 450);
    return () => window.clearTimeout(t);
  }, [value]);
  return flash;
}

// ──────────────────────────────────────────────────────────────────
// Main Trade page
// ──────────────────────────────────────────────────────────────────
type OrderType = "limit" | "market" | "stop";

const FEE_TAKER = 0.001; // 0.10%
const FEE_MAKER = 0.0008; // 0.08%

export default function Trade() {
  const params = useParams<{ symbol?: string }>();
  const symbol = decodeSymbol(params.symbol || "BTC_INR");
  const [base, quote = "INR"] = symbol.split("/");
  const ticker = useTicker(symbol);
  const orderbook = useOrderbook(symbol, 25);
  const trades = useRecentTrades(symbol, 30);
  const { user } = useAuth();
  const qc = useQueryClient();
  const { favs, toggle: toggleFav } = useFavorites();
  const isFav = favs.has(symbol);

  const [side, setSide] = useState<"buy" | "sell">("buy");
  const [type, setType] = useState<OrderType>("limit");
  const [price, setPrice] = useState("");
  const [stopPrice, setStopPrice] = useState("");
  const [amount, setAmount] = useState("");
  const [pctSlider, setPctSlider] = useState<number[]>([0]);
  const [postOnly, setPostOnly] = useState(false);
  const [reduceOnly, setReduceOnly] = useState(false);
  const [bookAggregation, setBookAggregation] = useState<"0.01" | "0.1" | "1" | "10">("0.1");
  const [bottomTab, setBottomTab] = useState<"open" | "history">("open");
  const [fillsOrderId, setFillsOrderId] = useState<number | null>(null);
  // "Recent Trades" panel toggle: market-wide tape (default) vs only this user's
  // own fills for this pair. The market tape comes from the WebSocket feed
  // (everyone's prints) — that's the standard exchange behaviour but it can
  // confuse users who think they're seeing other people's orders. The "Mine"
  // tab shows only their own filled trades for the current symbol.
  const [tradeFeed, setTradeFeed] = useState<"market" | "mine">("market");
  const [layoutMode, setLayoutMode] = useState<LayoutMode>(() => {
    try {
      const v = window.localStorage.getItem(LAYOUT_KEY);
      if (v === "simple" || v === "advanced" || v === "pro") return v;
    } catch { /* ignore */ }
    return "advanced";
  });
  useEffect(() => {
    try { window.localStorage.setItem(LAYOUT_KEY, layoutMode); } catch { /* ignore */ }
    if (layoutMode === "simple" && type === "stop") setType("limit");
  }, [layoutMode, type]);
  const isSimple = layoutMode === "simple";
  const isPro = layoutMode === "pro";
  const bookRows = isPro ? 16 : 12;

  const lastPx = ticker?.lastPrice || 0;
  const pct = ticker?.priceChangePercent || 0;
  const high = ticker?.high || 0;
  const low = ticker?.low || 0;
  const vol = ticker?.volume || 0;
  const quoteVol = ticker?.quoteVolume || 0;
  const flash = useFlashOnChange(lastPx);

  // ─── Active pairs (server-filtered: status=active + tradingEnabled
  //     + both coins listed). Used to filter the SymbolSwitcher and to
  //     normalize compact pair labels in the orders table without any
  //     hardcoded quote-coin list. ────────────────────────────────────
  const { data: pairsData } = useQuery<any[]>({
    queryKey: ["pairs", "active"],
    queryFn: () => get("/pairs"),
    staleTime: 60_000,
    refetchOnWindowFocus: false,
  });
  const enabledPairSet = useMemo(() => {
    const s = new Set<string>();
    for (const p of pairsData || []) {
      const b = p?.baseSymbol; const q = p?.quoteSymbol;
      if (b && q) s.add(`${b}/${q}`);
    }
    return s;
  }, [pairsData]);
  const enabledQuotes = useMemo(() => {
    const s = new Set<string>();
    for (const p of pairsData || []) if (p?.quoteSymbol) s.add(String(p.quoteSymbol));
    // Sort longest-first so "USDT" matches before "USD" (if both ever exist).
    return Array.from(s).sort((a, b) => b.length - a.length);
  }, [pairsData]);

  // ─── Wallet + balances ────────────────────────────
  // 5s polling + window-focus refetch keeps the buy/sell "Available"
  // strip live without us needing to invalidate from every interaction.
  const { data: walletData } = useQuery<any>({
    queryKey: ["wallet"],
    queryFn: () => get("/finance/wallet"),
    enabled: !!user,
    refetchInterval: 5000,
    refetchOnWindowFocus: true,
  });
  const wallets: any[] = useMemo(() => {
    if (!walletData) return [];
    if (Array.isArray(walletData)) return walletData;
    if (Array.isArray(walletData.items)) return walletData.items;
    if (Array.isArray(walletData.wallets)) return walletData.wallets;
    if (Array.isArray(walletData.data)) return walletData.data;
    return [];
  }, [walletData]);
  const findWallet = (sym: string) => wallets.find((w) => (w.currency || w.symbol || w.coin) === sym);
  const availOf = (w: any) => {
    if (!w) return 0;
    if (w.available != null) return Number(w.available);
    if (w.free != null) return Number(w.free);
    return Math.max(0, Number(w.balance ?? 0) - Number(w.inOrder ?? w.locked ?? 0));
  };
  const baseBal = findWallet(base);
  const quoteBal = findWallet(quote);
  const availBuy = availOf(quoteBal);
  const availSell = availOf(baseBal);

  // Refresh wallet, orders and history the instant the user switches pair
  // so the right "Available" / orderbook depth / open orders show up
  // without waiting for the next polling tick.
  useEffect(() => {
    qc.invalidateQueries({ queryKey: ["wallet"] });
    qc.invalidateQueries({ queryKey: ["orders"] });
  }, [symbol, qc]);

  // ─── Orders ────────────────────────────
  const { data: openOrders } = useQuery<any>({
    queryKey: ["orders", "open", base, quote],
    queryFn: () => get(`/exchange/order?status=OPEN&currency=${encodeURIComponent(base)}&pair=${encodeURIComponent(quote)}`),
    enabled: !!user,
    refetchInterval: 5000,
  });
  const orderRows: any[] = useMemo(() => {
    if (!openOrders) return [];
    if (Array.isArray(openOrders)) return openOrders;
    if (Array.isArray(openOrders.items)) return openOrders.items;
    if (Array.isArray(openOrders.orders)) return openOrders.orders;
    if (Array.isArray(openOrders.data)) return openOrders.data;
    return [];
  }, [openOrders]);

  const { data: historyData } = useQuery<any>({
    queryKey: ["orders", "history", base, quote, bottomTab],
    queryFn: () => get(`/exchange/order?currency=${encodeURIComponent(base)}&pair=${encodeURIComponent(quote)}&limit=30`),
    enabled: !!user && bottomTab === "history",
    refetchInterval: 15000,
  });
  const historyRows: any[] = useMemo(() => {
    if (!historyData) return [];
    if (Array.isArray(historyData)) return historyData;
    if (Array.isArray(historyData.items)) return historyData.items;
    if (Array.isArray(historyData.orders)) return historyData.orders;
    if (Array.isArray(historyData.data)) return historyData.data;
    return [];
  }, [historyData]);

  // ─── My Trades (per-symbol) ──────────────────
  // /api/trades is server-scoped to the logged-in user (filters out bot orders
  // via NOT EXISTS). Adding ?symbol=BTCINR also restricts to the active pair.
  const compactSym = `${base}${quote}`;
  const { data: myTradesData } = useQuery<any[]>({
    queryKey: ["my-trades", compactSym],
    queryFn: () => get(`/trades?symbol=${encodeURIComponent(compactSym)}&limit=50`),
    enabled: !!user && tradeFeed === "mine",
    refetchInterval: 10000,
  });
  const myTrades = useMemo(() => {
    const rows = Array.isArray(myTradesData) ? myTradesData : [];
    return rows.map((r) => ({
      side: String(r.side || "").toLowerCase() as "buy" | "sell",
      price: Number(r.price ?? 0),
      qty: Number(r.qty ?? 0),
      ts: r.createdAt ? new Date(r.createdAt).getTime() : Date.now(),
    }));
  }, [myTradesData]);

  // ─── Mutations ────────────────────────────
  const orderMutation = useMutation({
    mutationFn: (data: any) => post("/exchange/order", data),
    onSuccess: () => {
      toast.success(`${side === "buy" ? "Buy" : "Sell"} order placed`);
      setPrice("");
      setAmount("");
      setStopPrice("");
      setPctSlider([0]);
      qc.invalidateQueries({ queryKey: ["orders"] });
      qc.invalidateQueries({ queryKey: ["wallet"] });
      // Refresh "Mine" tab too — the order may have filled instantly so a new
      // trade row should appear in the user's per-pair fills.
      qc.invalidateQueries({ queryKey: ["my-trades"] });
    },
    onError: (err: any) => toast.error(err?.message || "Failed to place order"),
  });

  const cancelMutation = useMutation({
    mutationFn: (id: string | number) => del(`/exchange/order/${id}`),
    onSuccess: () => {
      toast.success("Order cancelled");
      qc.invalidateQueries({ queryKey: ["orders"] });
      qc.invalidateQueries({ queryKey: ["wallet"] });
    },
    onError: (err: any) => toast.error(err?.message || "Cancel failed"),
  });

  const cancelAllMutation = useMutation({
    mutationFn: async () => {
      await Promise.all(orderRows.map((o) => del(`/exchange/order/${o.id}`).catch(() => null)));
    },
    onSuccess: () => {
      toast.success("All open orders cancelled");
      qc.invalidateQueries({ queryKey: ["orders"] });
      qc.invalidateQueries({ queryKey: ["wallet"] });
    },
  });

  // ─── Handlers ────────────────────────────
  const handleOrder = () => {
    if (!user) { toast.error("Please log in to trade"); return; }
    const amt = Number(amount);
    if (!(amt > 0)) { toast.error("Enter an amount"); return; }
    if (type !== "market" && !(Number(price) > 0)) { toast.error("Enter a price"); return; }
    if (type === "stop" && !(Number(stopPrice) > 0)) { toast.error("Enter a stop trigger price"); return; }
    orderMutation.mutate({
      currency: base,
      pair: quote,
      side,
      type: type === "stop" ? "limit" : type,
      amount: amt,
      price: type !== "market" ? Number(price) : undefined,
      stopPrice: type === "stop" ? Number(stopPrice) : undefined,
      postOnly: type === "limit" ? postOnly : undefined,
      reduceOnly: type !== "market" ? reduceOnly : undefined,
    });
  };

  const setPct = (p: number) => {
    setPctSlider([Math.round(p * 100)]);
    const px = type !== "market" ? Number(price) : lastPx;
    if (side === "buy") {
      const total = availBuy * p;
      if (px > 0) setAmount((total / px).toFixed(6));
    } else {
      setAmount((availSell * p).toFixed(6));
    }
  };

  // Sync amount when slider changes manually
  const onSliderChange = (vals: number[]) => {
    setPctSlider(vals);
    setPct((vals[0] || 0) / 100);
  };

  const fillFromOrderbook = (px: number, qty: number, asSide: "buy" | "sell") => {
    setSide(asSide);
    if (type === "market") setType("limit");
    setPrice(String(px));
    setAmount(String(qty));
  };

  // ─── Derived ────────────────────────────
  const effectivePx = type !== "market" ? Number(price) || 0 : lastPx;
  const total = Number(amount || 0) * effectivePx;
  const fee = total * (postOnly ? FEE_MAKER : FEE_TAKER);
  const totalWithFee = side === "buy" ? total + fee : total - fee;

  const maxBidQty = Math.max(1, ...orderbook.bids.slice(0, 14).map(([, q]) => q));
  const maxAskQty = Math.max(1, ...orderbook.asks.slice(0, 14).map(([, q]) => q));
  const bestBid = orderbook.bids[0]?.[0] || 0;
  const bestAsk = orderbook.asks[0]?.[0] || 0;
  const spread = bestAsk && bestBid ? bestAsk - bestBid : 0;
  const spreadPct = bestBid > 0 ? (spread / bestBid) * 100 : 0;

  // Bottom Open Orders / History panel — used on desktop inside the chart
  // column and on mobile as a standalone section at the bottom.
  const bottomOrdersJsx = !isSimple && (
    <Tabs value={bottomTab} onValueChange={(v) => setBottomTab(v as "open" | "history")} className="flex flex-col h-full">
      <div className="flex items-center justify-between px-3 border-b border-border">
        <TabsList className="bg-transparent h-9 p-0 gap-1">
          <TabsTrigger value="open" className="text-xs h-9 px-3 data-[state=active]:bg-transparent data-[state=active]:shadow-none data-[state=active]:border-b-2 data-[state=active]:border-primary data-[state=active]:text-foreground rounded-none">
            Open Orders <span className="ml-1.5 text-[10px] text-muted-foreground">({orderRows.length})</span>
          </TabsTrigger>
          <TabsTrigger value="history" className="text-xs h-9 px-3 data-[state=active]:bg-transparent data-[state=active]:shadow-none data-[state=active]:border-b-2 data-[state=active]:border-primary data-[state=active]:text-foreground rounded-none">
            Order History
          </TabsTrigger>
        </TabsList>
        {bottomTab === "open" && orderRows.length > 0 && (
          <Button
            variant="ghost"
            size="sm"
            className="h-7 text-[11px] text-destructive hover:text-destructive hover:bg-destructive/10"
            onClick={() => cancelAllMutation.mutate()}
            disabled={cancelAllMutation.isPending}
          >
            Cancel all
          </Button>
        )}
      </div>
      <TabsContent value="open" className="flex-1 m-0 overflow-auto">
        <OrdersTable rows={orderRows} loading={!user} mode="open" onCancel={(id) => cancelMutation.mutate(id)} cancelingId={cancelMutation.variables as any} quotesForLabel={enabledQuotes} onViewFills={(id) => setFillsOrderId(Number(id))} />
      </TabsContent>
      <TabsContent value="history" className="flex-1 m-0 overflow-auto">
        <OrdersTable rows={historyRows} loading={!user} mode="history" quotesForLabel={enabledQuotes} onViewFills={(id) => setFillsOrderId(Number(id))} />
      </TabsContent>
    </Tabs>
  );

  return (
    <div className="flex-1 flex flex-col min-h-[calc(100vh-56px)] lg:h-[calc(100vh-56px)] bg-background">
      {/* ── Header strip ───────────────────────────────── */}
      <div className="border-b border-border bg-card/60 backdrop-blur shrink-0">
        <div className="flex items-center px-2 sm:px-4 gap-2 sm:gap-5 h-16 overflow-x-auto">
          <button
            type="button"
            onClick={() => toggleFav(symbol)}
            className={`p-1.5 rounded hover:bg-muted/40 transition flex-shrink-0 ${isFav ? "text-amber-400" : "text-muted-foreground/40 hover:text-amber-400"}`}
            aria-label={isFav ? "Remove from favorites" : "Add to favorites"}
          >
            <Star className={`h-4 w-4 ${isFav ? "fill-current" : ""}`} />
          </button>
          <SymbolSwitcher current={symbol} enabledPairSet={enabledPairSet} />

          {/* Spot / Futures mode toggle */}
          <div className="flex items-center gap-0.5 p-0.5 bg-muted/40 rounded-md border border-border flex-shrink-0">
            <span className="px-3 py-1 text-[11px] font-bold rounded-sm bg-card text-foreground shadow-sm">Spot</span>
            <Link href={`/futures`} className="px-3 py-1 text-[11px] font-medium text-muted-foreground hover:text-foreground rounded-sm transition-colors">Futures</Link>
          </div>

          <div className="h-8 w-px bg-border flex-shrink-0" />

          <div className="flex flex-col items-start flex-shrink-0">
            <div className="text-[10px] uppercase text-muted-foreground tracking-wider">Last Price</div>
            <div className={`font-mono font-extrabold text-base sm:text-xl tabular-nums leading-tight transition-colors ${
              flash === "up" ? "text-success" : flash === "down" ? "text-destructive" : pct >= 0 ? "text-success" : "text-destructive"
            }`}>
              {fmtPrice(lastPx, quote)}
            </div>
          </div>

          <Stat label="24h Change" tone={pct >= 0 ? "success" : "destructive"}>
            <span className="font-mono tabular-nums">
              {pct >= 0 ? "+" : ""}{fmtNum(pct, 2)}%
            </span>
          </Stat>
          <Stat label="24h High">{fmtPrice(high, quote)}</Stat>
          <Stat label="24h Low">{fmtPrice(low, quote)}</Stat>
          <Stat label={`24h Vol (${base})`}>{fmtCompact(vol)}</Stat>
          <Stat label={`24h Vol (${quote})`}>{fmtCompact(quoteVol, quote === "INR" ? "₹" : "$")}</Stat>

          {/* Layout switcher (right) */}
          <div className="ml-auto flex items-center gap-1.5 flex-shrink-0">
            <span className="text-[10px] uppercase text-muted-foreground tracking-wider hidden xl:inline">View</span>
            <div className="inline-flex items-center bg-muted/30 rounded-md p-0.5 border border-border">
              {([
                { id: "simple" as const, label: "Simple", icon: LayoutPanelLeft },
                { id: "advanced" as const, label: "Advanced", icon: LayoutGrid },
                { id: "pro" as const, label: "Pro", icon: Sparkles },
              ]).map((m) => {
                const Icon = m.icon;
                const active = layoutMode === m.id;
                return (
                  <button
                    key={m.id}
                    type="button"
                    onClick={() => setLayoutMode(m.id)}
                    title={`${m.label} layout`}
                    className={`px-2 sm:px-2.5 py-1 text-[11px] font-semibold rounded inline-flex items-center gap-1 transition-colors ${
                      active
                        ? "bg-primary text-primary-foreground shadow-sm"
                        : "text-muted-foreground hover:text-foreground hover:bg-muted/40"
                    }`}
                  >
                    <Icon className="h-3 w-3" />
                    <span className="hidden sm:inline">{m.label}</span>
                  </button>
                );
              })}
            </div>
          </div>
        </div>
      </div>

      {/* ── Body ───────────────────────────────── */}
      <div className="flex-1 flex flex-col lg:flex-row min-h-0 lg:overflow-hidden">
        {/* Orderbook + Recent trades. Side-by-side on mobile, stacked column on desktop LEFT. */}
        {!isSimple && (
        <div className={`order-3 lg:order-1 w-full ${isPro ? "lg:w-72" : "lg:w-64"} flex flex-col bg-card/40 shrink-0 border-t lg:border-t-0 lg:border-r border-border h-[44vh] lg:h-auto`}>
          <div className="flex flex-row lg:flex-col h-full min-h-0">
          {/* Orderbook */}
          <div className="w-1/2 lg:w-full lg:h-1/2 flex flex-col border-r lg:border-r-0 lg:border-b border-border min-h-0">
            <div className="px-3 py-2 flex items-center justify-between border-b border-border">
              <span className="font-semibold text-[11px] uppercase tracking-wider text-muted-foreground">Order Book</span>
              <Popover>
                <PopoverTrigger asChild>
                  <button className="text-[10px] text-muted-foreground hover:text-foreground inline-flex items-center gap-1">
                    Tick {bookAggregation} <ChevronDown className="h-3 w-3" />
                  </button>
                </PopoverTrigger>
                <PopoverContent align="end" className="w-28 p-1">
                  {(["0.01", "0.1", "1", "10"] as const).map((v) => (
                    <button
                      key={v}
                      type="button"
                      onClick={() => setBookAggregation(v)}
                      className={`w-full text-left px-2 py-1 rounded text-xs hover:bg-muted/50 ${bookAggregation === v ? "bg-primary/15 text-primary" : ""}`}
                    >
                      Tick {v}
                    </button>
                  ))}
                </PopoverContent>
              </Popover>
            </div>
            <div className="flex-1 overflow-auto px-2 py-1 text-xs font-mono">
              <div className="grid grid-cols-3 text-[10px] text-muted-foreground py-1 px-1 sticky top-0 bg-card/40 backdrop-blur z-10">
                <span>Price ({quote})</span>
                <span className="text-right">Amount ({base})</span>
                <span className="text-right">Total</span>
              </div>
              {/* Asks reversed (lowest near spread) */}
              {orderbook.asks.slice(0, bookRows).reverse().map(([px, qty], i) => {
                const cumulative = orderbook.asks.slice(0, bookRows - i).reduce((s, [, q]) => s + q, 0);
                return (
                  <button
                    key={`ask-${i}`}
                    type="button"
                    onClick={() => fillFromOrderbook(px, qty, "buy")}
                    className="relative grid grid-cols-3 py-[2px] px-1 w-full hover:bg-destructive/5 transition-colors"
                  >
                    <div className="absolute right-0 top-0 bottom-0 bg-destructive/10 pointer-events-none" style={{ width: `${(qty / maxAskQty) * 100}%` }} />
                    <span className="relative text-destructive tabular-nums text-left">{fmtNum(px, quote === "INR" ? 2 : 4)}</span>
                    <span className="relative text-right tabular-nums">{fmtNum(qty, 4)}</span>
                    <span className="relative text-right tabular-nums text-muted-foreground/70">{fmtNum(cumulative, 2)}</span>
                  </button>
                );
              })}
              {/* Spread row */}
              <div className="my-1 border-y border-border bg-muted/20 px-2 py-1.5 flex items-center justify-between">
                <span className={`font-bold text-sm tabular-nums ${pct >= 0 ? "text-success" : "text-destructive"}`}>
                  {fmtPrice(lastPx, quote)}
                </span>
                <span className="text-[10px] text-muted-foreground inline-flex items-center gap-1">
                  <ArrowUpDown className="h-3 w-3" />
                  Spread {spread > 0 ? `${fmtNum(spread, quote === "INR" ? 2 : 4)} (${spreadPct.toFixed(3)}%)` : "—"}
                </span>
              </div>
              {/* Bids */}
              {orderbook.bids.slice(0, bookRows).map(([px, qty], i) => {
                const cumulative = orderbook.bids.slice(0, i + 1).reduce((s, [, q]) => s + q, 0);
                return (
                  <button
                    key={`bid-${i}`}
                    type="button"
                    onClick={() => fillFromOrderbook(px, qty, "sell")}
                    className="relative grid grid-cols-3 py-[2px] px-1 w-full hover:bg-success/5 transition-colors"
                  >
                    <div className="absolute right-0 top-0 bottom-0 bg-success/10 pointer-events-none" style={{ width: `${(qty / maxBidQty) * 100}%` }} />
                    <span className="relative text-success tabular-nums text-left">{fmtNum(px, quote === "INR" ? 2 : 4)}</span>
                    <span className="relative text-right tabular-nums">{fmtNum(qty, 4)}</span>
                    <span className="relative text-right tabular-nums text-muted-foreground/70">{fmtNum(cumulative, 2)}</span>
                  </button>
                );
              })}
              {orderbook.bids.length === 0 && orderbook.asks.length === 0 && (
                <div className="py-6 text-center text-muted-foreground text-xs">No depth yet</div>
              )}
            </div>
          </div>
          {/* Recent trades */}
          <div className="w-1/2 lg:w-full lg:h-1/2 flex flex-col min-h-0">
            <div className="px-3 py-2 flex items-center justify-between border-b border-border gap-2">
              {/* Market vs Mine toggle. "Market" = public tape (everyone's prints,
                  standard exchange feature). "Mine" = only this user's filled
                  trades for the current pair (server-scoped). */}
              <div className="flex items-center gap-1 text-[10px] font-bold uppercase tracking-wider">
                <button
                  type="button"
                  onClick={() => setTradeFeed("market")}
                  className={cn(
                    "px-2 py-0.5 rounded transition-colors",
                    tradeFeed === "market"
                      ? "bg-primary/15 text-primary"
                      : "text-muted-foreground hover:text-foreground",
                  )}
                  data-testid="recent-trades-tab-market"
                >
                  Market
                </button>
                <button
                  type="button"
                  onClick={() => setTradeFeed("mine")}
                  disabled={!user}
                  className={cn(
                    "px-2 py-0.5 rounded transition-colors",
                    tradeFeed === "mine"
                      ? "bg-primary/15 text-primary"
                      : "text-muted-foreground hover:text-foreground disabled:opacity-50",
                  )}
                  data-testid="recent-trades-tab-mine"
                >
                  Mine
                </button>
              </div>
              <span className="text-[10px] text-muted-foreground">
                {tradeFeed === "market" ? `${trades.length} prints` : `${myTrades.length} fills`}
              </span>
            </div>
            <div className="flex-1 overflow-auto px-2 py-1 text-xs font-mono">
              <div className="grid grid-cols-3 text-[10px] text-muted-foreground py-1 px-1 sticky top-0 bg-card/40 backdrop-blur z-10">
                <span>Price ({quote})</span>
                <span className="text-right">Amount ({base})</span>
                <span className="text-right">Time</span>
              </div>
              {(tradeFeed === "market" ? trades : myTrades).map((t, i) => (
                <div key={i} className="grid grid-cols-3 py-[2px] px-1">
                  <span className={`tabular-nums ${t.side === "buy" ? "text-success" : "text-destructive"}`}>{fmtNum(t.price, quote === "INR" ? 2 : 4)}</span>
                  <span className="text-right tabular-nums">{fmtNum(t.qty, 4)}</span>
                  <span className="text-right text-muted-foreground">{new Date(t.ts).toLocaleTimeString([], { hour12: false })}</span>
                </div>
              ))}
              {tradeFeed === "market" && trades.length === 0 && (
                <div className="py-6 text-center text-muted-foreground text-xs">No trades yet</div>
              )}
              {tradeFeed === "mine" && myTrades.length === 0 && (
                <div className="py-6 text-center text-muted-foreground text-xs">
                  {user ? "Aapne is pair par abhi tak koi trade nahi kiya." : "Login karke apni trades dekhein."}
                </div>
              )}
            </div>
          </div>
          </div>
        </div>
        )}

        {/* Chart + bottom orders — CENTER column on desktop */}
        <div className="flex flex-col min-w-0 order-1 lg:order-2 lg:flex-1 lg:border-r lg:border-border">
          <div className={`h-[42vh] sm:h-[48vh] lg:h-auto lg:flex-1 lg:min-h-0 lg:min-w-0 ${isSimple ? "lg:max-h-[68vh]" : ""}`}>
            <PriceChart symbol={symbol} />
          </div>

          {/* Bottom panel — desktop only (mobile renders it as a separate section below) */}
          {!isSimple && (
            <div className={`hidden lg:flex border-t border-border bg-card/60 ${isPro ? "h-60" : "h-56"} flex-col shrink-0`}>
              {bottomOrdersJsx}
            </div>
          )}
        </div>

        {/* Order Entry — full-width on mobile, fixed column on desktop */}
        <div className={`order-2 lg:order-3 w-full ${isSimple ? "lg:max-w-sm lg:mx-auto" : "lg:w-[280px]"} bg-card/40 flex flex-col shrink-0 lg:overflow-y-auto border-t lg:border-t-0 border-border`}>
          <div className="p-3 sm:p-4 space-y-3">
            {/* Buy/Sell pill */}
            <div className="grid grid-cols-2 gap-1 p-1 bg-muted/40 rounded-lg">
              <button
                type="button"
                onClick={() => setSide("buy")}
                className={`py-2 rounded-md text-sm font-bold transition-all ${
                  side === "buy"
                    ? "bg-gradient-to-b from-emerald-500 to-emerald-600 text-white shadow-sm shadow-emerald-500/30"
                    : "text-muted-foreground hover:text-foreground"
                }`}
              >
                <TrendingUp className="h-3.5 w-3.5 inline-block mr-1 -mt-0.5" />
                Buy {base}
              </button>
              <button
                type="button"
                onClick={() => setSide("sell")}
                className={`py-2 rounded-md text-sm font-bold transition-all ${
                  side === "sell"
                    ? "bg-gradient-to-b from-rose-500 to-rose-600 text-white shadow-sm shadow-rose-500/30"
                    : "text-muted-foreground hover:text-foreground"
                }`}
              >
                <TrendingDown className="h-3.5 w-3.5 inline-block mr-1 -mt-0.5" />
                Sell {base}
              </button>
            </div>

            {/* Order type */}
            <div className="flex gap-1 border-b border-border">
              {((isSimple ? ["limit", "market"] : ["limit", "market", "stop"]) as OrderType[]).map((t) => (
                <button
                  key={t}
                  type="button"
                  onClick={() => setType(t)}
                  className={`pb-2 px-2 text-xs font-semibold transition-colors capitalize ${
                    type === t
                      ? "text-primary border-b-2 border-primary -mb-px"
                      : "text-muted-foreground hover:text-foreground"
                  }`}
                >
                  {t === "stop" ? "Stop-Limit" : t}
                </button>
              ))}
            </div>

            {/* Stop trigger */}
            {type === "stop" && (
              <FieldRow label="Trigger Price" right={
                <button type="button" className="text-primary text-[10px] font-semibold hover:underline" onClick={() => setStopPrice(String(lastPx || ""))}>use last</button>
              }>
                <div className="relative">
                  <Input type="number" inputMode="decimal" value={stopPrice} onChange={(e) => setStopPrice(e.target.value)} placeholder="0.00" className="font-mono pr-12 h-9" />
                  <span className="absolute right-3 top-1/2 -translate-y-1/2 text-[11px] text-muted-foreground">{quote}</span>
                </div>
              </FieldRow>
            )}

            {/* Price */}
            {type !== "market" && (
              <FieldRow label="Price" right={
                <div className="flex gap-1">
                  <button type="button" className="text-[10px] px-1.5 py-0.5 rounded bg-muted/50 hover:bg-muted text-muted-foreground hover:text-foreground" onClick={() => setPrice(String(bestBid || lastPx))}>Bid</button>
                  <button type="button" className="text-[10px] px-1.5 py-0.5 rounded bg-muted/50 hover:bg-muted text-muted-foreground hover:text-foreground" onClick={() => setPrice(String(lastPx || ""))}>Last</button>
                  <button type="button" className="text-[10px] px-1.5 py-0.5 rounded bg-muted/50 hover:bg-muted text-muted-foreground hover:text-foreground" onClick={() => setPrice(String(bestAsk || lastPx))}>Ask</button>
                </div>
              }>
                <div className="relative">
                  <Input type="number" inputMode="decimal" value={price} onChange={(e) => setPrice(e.target.value)} placeholder="0.00" className="font-mono pr-12 h-9" />
                  <span className="absolute right-3 top-1/2 -translate-y-1/2 text-[11px] text-muted-foreground">{quote}</span>
                </div>
              </FieldRow>
            )}

            {/* Amount */}
            <FieldRow label="Amount">
              <div className="relative">
                <Input type="number" inputMode="decimal" value={amount} onChange={(e) => { setAmount(e.target.value); setPctSlider([0]); }} placeholder="0.00" className="font-mono pr-12 h-9" />
                <span className="absolute right-3 top-1/2 -translate-y-1/2 text-[11px] text-muted-foreground">{base}</span>
              </div>
            </FieldRow>

            {/* Slider */}
            <div className="px-1">
              <Slider value={pctSlider} onValueChange={onSliderChange} min={0} max={100} step={1} disabled={!user} className="my-3" />
              <div className="grid grid-cols-4 gap-1">
                {[0.25, 0.5, 0.75, 1].map((p) => (
                  <button
                    key={p}
                    type="button"
                    className={`text-[11px] py-1 rounded font-semibold transition-colors ${
                      pctSlider[0] === p * 100
                        ? "bg-primary/15 text-primary border border-primary/30"
                        : "bg-muted/30 hover:bg-muted/60 text-muted-foreground hover:text-foreground border border-transparent"
                    }`}
                    onClick={() => setPct(p)}
                  >
                    {p === 1 ? "100%" : `${p * 100}%`}
                  </button>
                ))}
              </div>
            </div>

            {/* Total */}
            <FieldRow label={side === "buy" ? "Total Spend" : "Total Receive"}>
              <div className="relative">
                <Input
                  readOnly
                  value={total > 0 ? fmtNum(total, 2) : ""}
                  placeholder="0.00"
                  className="font-mono pr-12 h-9 bg-muted/20"
                />
                <span className="absolute right-3 top-1/2 -translate-y-1/2 text-[11px] text-muted-foreground">{quote}</span>
              </div>
            </FieldRow>

            {/* Switches (Advanced/Pro only) */}
            {!isSimple && type !== "market" && (
              <div className="flex flex-col gap-2 py-1">
                {type === "limit" && (
                  <ToggleRow label="Post-only" hint="Maker-only fills (cancel if would take)" checked={postOnly} onCheckedChange={setPostOnly} />
                )}
                <ToggleRow label="Reduce-only" hint="Will not increase position size" checked={reduceOnly} onCheckedChange={setReduceOnly} />
              </div>
            )}

            {/* Summary */}
            <div className="text-[11px] text-muted-foreground space-y-1 border-t border-border pt-3">
              <SummaryRow label="Available">
                <span className="tabular-nums font-mono text-foreground">
                  {side === "buy" ? `${fmtNum(availBuy, 2)} ${quote}` : `${fmtNum(availSell, 6)} ${base}`}
                </span>
                {user && (
                  <Link href="/wallet" className="ml-1.5 text-primary hover:underline inline-flex items-center gap-0.5">
                    <WalletIcon className="h-3 w-3" />Deposit
                  </Link>
                )}
              </SummaryRow>
              {!isSimple && (
                <SummaryRow label={`Est. Fee · ${postOnly && type === "limit" ? "Maker 0.08%" : "Taker 0.10%"}`}>
                  <span className="tabular-nums font-mono text-foreground">{fmtNum(fee, 2)} {quote}</span>
                </SummaryRow>
              )}
              <SummaryRow label={side === "buy" ? "Total + Fee" : "You receive"}>
                <span className="tabular-nums font-mono text-foreground font-semibold">{fmtNum(totalWithFee, 2)} {quote}</span>
              </SummaryRow>
              {isPro && spread > 0 && (
                <>
                  <SummaryRow label="Best Bid">
                    <span className="tabular-nums font-mono text-success">{fmtPrice(bestBid, quote)}</span>
                  </SummaryRow>
                  <SummaryRow label="Best Ask">
                    <span className="tabular-nums font-mono text-destructive">{fmtPrice(bestAsk, quote)}</span>
                  </SummaryRow>
                  <SummaryRow label="Spread">
                    <span className="tabular-nums font-mono text-foreground">{fmtNum(spread, quote === "INR" ? 2 : 4)} ({spreadPct.toFixed(3)}%)</span>
                  </SummaryRow>
                </>
              )}
            </div>

            {/* CTA */}
            <Button
              className={`w-full font-bold h-11 text-sm transition-transform active:scale-[0.98] ${
                side === "buy"
                  ? "bg-gradient-to-b from-emerald-500 to-emerald-600 hover:from-emerald-400 hover:to-emerald-500 text-white shadow-md shadow-emerald-500/30"
                  : "bg-gradient-to-b from-rose-500 to-rose-600 hover:from-rose-400 hover:to-rose-500 text-white shadow-md shadow-rose-500/30"
              }`}
              onClick={handleOrder}
              disabled={orderMutation.isPending || !user}
            >
              {!user
                ? "Log in to Trade"
                : orderMutation.isPending
                  ? "Placing…"
                  : side === "buy"
                    ? `Buy ${base}`
                    : `Sell ${base}`}
            </Button>

            {!user && (
              <div className="text-[11px] text-center text-muted-foreground">
                <Link href="/login" className="text-primary font-semibold hover:underline">Log in</Link>
                {" or "}
                <Link href="/signup" className="text-primary font-semibold hover:underline">Sign up</Link>
                {" to start trading"}
              </div>
            )}

            {/* Pair badge */}
            <div className="flex items-center gap-1.5 text-[10px] text-muted-foreground border-t border-border pt-3">
              <Info className="h-3 w-3" />
              <span>Spot · Settled in {quote}</span>
              <Badge variant="outline" className="ml-auto h-4 px-1.5 text-[9px]">ZBX-20</Badge>
            </div>
          </div>
        </div>

        {/* Mobile-only bottom orders panel (Advanced/Pro). On desktop the same
            content lives inside the chart column, above. */}
        {!isSimple && (
          <div className="lg:hidden order-4 border-t border-border bg-card/60 h-[55vh] flex flex-col shrink-0">
            {bottomOrdersJsx}
          </div>
        )}
      </div>

      <OrderFillsDialog
        orderId={fillsOrderId}
        open={fillsOrderId !== null}
        onOpenChange={(o) => !o && setFillsOrderId(null)}
      />
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────
// Header stat
// ──────────────────────────────────────────────────────────────────
function Stat({ label, children, tone }: { label: string; children: React.ReactNode; tone?: "success" | "destructive" }) {
  const color = tone === "success" ? "text-success" : tone === "destructive" ? "text-destructive" : "text-foreground";
  return (
    <div className="flex flex-col items-start flex-shrink-0">
      <div className="text-[10px] uppercase text-muted-foreground tracking-wider">{label}</div>
      <div className={`font-mono text-sm tabular-nums ${color}`}>{children}</div>
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────
// Field row
// ──────────────────────────────────────────────────────────────────
function FieldRow({ label, right, children }: { label: string; right?: React.ReactNode; children: React.ReactNode }) {
  return (
    <div>
      <div className="text-[11px] text-muted-foreground mb-1 flex justify-between items-center">
        <span>{label}</span>
        {right}
      </div>
      {children}
    </div>
  );
}

function ToggleRow({ label, hint, checked, onCheckedChange }: { label: string; hint?: string; checked: boolean; onCheckedChange: (v: boolean) => void }) {
  return (
    <label className="flex items-center justify-between gap-2 cursor-pointer group">
      <div className="flex flex-col">
        <span className="text-xs font-medium">{label}</span>
        {hint && <span className="text-[10px] text-muted-foreground">{hint}</span>}
      </div>
      <Switch checked={checked} onCheckedChange={onCheckedChange} />
    </label>
  );
}

function SummaryRow({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex justify-between items-center">
      <span>{label}</span>
      <div>{children}</div>
    </div>
  );
}

// ──────────────────────────────────────────────────────────────────
// Bottom orders table
// ──────────────────────────────────────────────────────────────────
function OrdersTable({
  rows,
  loading,
  mode,
  onCancel,
  cancelingId,
  quotesForLabel = [],
  onViewFills,
}: {
  rows: any[];
  loading: boolean;
  mode: "open" | "history";
  onCancel?: (id: string | number) => void;
  cancelingId?: string | number;
  quotesForLabel?: string[];
  onViewFills?: (id: string | number) => void;
}) {
  if (loading) {
    return (
      <div className="px-4 py-6 text-xs text-center text-muted-foreground">
        <Link href="/login" className="text-primary hover:underline">Log in</Link> to see your orders.
      </div>
    );
  }
  if (rows.length === 0) {
    return (
      <div className="px-4 py-6 text-xs text-center text-muted-foreground">
        {mode === "open" ? "No open orders." : "No order history."}
      </div>
    );
  }
  return (
    <table className="w-full text-xs">
      <thead className="bg-muted/20 text-[10px] uppercase tracking-wider text-muted-foreground sticky top-0">
        <tr>
          <th className="text-left px-3 py-1.5 font-medium">Pair</th>
          <th className="text-left px-2 py-1.5 font-medium">Side</th>
          <th className="text-left px-2 py-1.5 font-medium">Type</th>
          <th className="text-right px-2 py-1.5 font-medium">Price</th>
          <th className="text-right px-2 py-1.5 font-medium">Amount</th>
          <th className="text-right px-2 py-1.5 font-medium">Filled</th>
          {mode === "history" && <th className="text-right px-2 py-1.5 font-medium">Status</th>}
          <th className="text-right px-2 py-1.5 font-medium">Time</th>
          {mode === "open" && <th className="text-right px-3 py-1.5 font-medium">Action</th>}
        </tr>
      </thead>
      <tbody>
        {rows.map((o: any) => {
          const sideStr = String(o.side || "").toLowerCase();
          const typeStr = String(o.type || "limit").toLowerCase();
          const isMarket = typeStr === "market";
          const limitPx = Number(o.price ?? 0);
          const avgPx = Number(o.avgPrice ?? 0);
          const qty = Number(o.amount ?? o.qty ?? 0);
          // API returns `filledQty`; keep `filled` as fallback for legacy payloads.
          const filled = Number(o.filledQty ?? o.filled ?? 0);
          // For market orders the stored `price` is the ±10% slippage cap, not a
          // real fill price. Show "Market" when nothing has filled yet, otherwise
          // surface the avg fill (truth) for both market and limit rows.
          const showAvg = filled > 0 && avgPx > 0;
          const px = showAvg ? avgPx : (isMarket ? 0 : limitPx);
          const ts = Number(o.createdAt ? new Date(o.createdAt).getTime() : o.ts ?? Date.now());
          const status = String(o.status || "OPEN").toUpperCase();
          // Pair label — API returns `symbol` (either "BTC/USDT" or "BTCUSDT").
          // Older payloads may carry `currency`+`pair` instead. Normalize to BASE/QUOTE.
          // Quote suffix list comes from /api/pairs (no hardcoded coins).
          const pairLabel = (() => {
            const sym = String(o.symbol ?? "").trim();
            if (sym.includes("/")) return sym;
            if (o.currency && o.pair) return `${o.currency}/${o.pair}`;
            if (sym) {
              for (const q of quotesForLabel) {
                if (sym.endsWith(q) && sym.length > q.length) {
                  return `${sym.slice(0, -q.length)}/${q}`;
                }
              }
              return sym;
            }
            return "—";
          })();
          const handleRowClick = () => onViewFills?.(o.id);
          return (
            <tr
              key={o.id}
              className={cn(
                "border-b border-border last:border-b-0 hover:bg-muted/15",
                onViewFills && "cursor-pointer",
              )}
              onClick={onViewFills ? handleRowClick : undefined}
              onKeyDown={
                onViewFills
                  ? (e) => {
                      if (e.key === "Enter" || e.key === " ") {
                        e.preventDefault();
                        handleRowClick();
                      }
                    }
                  : undefined
              }
              role={onViewFills ? "button" : undefined}
              tabIndex={onViewFills ? 0 : undefined}
              aria-label={onViewFills ? `View fills for order ${o.id}` : undefined}
            >
              <td className="px-3 py-1.5 font-semibold whitespace-nowrap">{pairLabel}</td>
              <td className={`px-2 py-1.5 font-bold ${sideStr === "buy" ? "text-success" : "text-destructive"}`}>{sideStr.toUpperCase()}</td>
              <td className="px-2 py-1.5 capitalize text-muted-foreground">{typeStr}</td>
              <td className="px-2 py-1.5 text-right font-mono tabular-nums">
                {px > 0 ? (
                  showAvg ? (
                    <span className="inline-flex flex-col items-end leading-tight">
                      <span>{fmtNum(px, 2)}</span>
                      <span className="text-[9px] text-muted-foreground">avg</span>
                    </span>
                  ) : (
                    fmtNum(px, 2)
                  )
                ) : isMarket ? (
                  <span className="text-muted-foreground">Market</span>
                ) : (
                  "—"
                )}
              </td>
              <td className="px-2 py-1.5 text-right font-mono tabular-nums">{fmtNum(qty, 6)}</td>
              <td className="px-2 py-1.5 text-right font-mono tabular-nums">{fmtNum(filled, 6)}</td>
              {mode === "history" && (
                <td className="px-2 py-1.5 text-right">
                  <Badge variant="outline" className={`text-[9px] h-4 px-1.5 ${
                    status === "CLOSED" || status === "FILLED" ? "border-success/30 text-success bg-success/5"
                    : status === "CANCELED" || status === "CANCELLED" ? "border-muted-foreground/30 text-muted-foreground"
                    : "border-amber-500/30 text-amber-400 bg-amber-500/5"
                  }`}>{status}</Badge>
                </td>
              )}
              <td className="px-2 py-1.5 text-right text-[10px] text-muted-foreground tabular-nums">
                {new Date(ts).toLocaleString([], { month: "short", day: "numeric", hour: "2-digit", minute: "2-digit", hour12: false })}
              </td>
              {mode === "open" && (
                <td className="px-3 py-1.5 text-right">
                  <button
                    className="text-destructive text-xs hover:bg-destructive/10 px-1.5 py-0.5 rounded"
                    onClick={() => onCancel?.(o.id)}
                    disabled={cancelingId === o.id}
                    aria-label="Cancel order"
                  >
                    <X className="h-3 w-3 inline-block" /> Cancel
                  </button>
                </td>
              )}
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}
