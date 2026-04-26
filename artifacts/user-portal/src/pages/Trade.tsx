import { useParams } from "wouter";
import { useTicker, useOrderbook, useRecentTrades, decodeSymbol } from "@/lib/marketSocket";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, del } from "@/lib/api";
import { useMemo, useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { toast } from "sonner";
import { useAuth } from "@/lib/auth";
import { PriceChart } from "@/components/PriceChart";
import { Link } from "wouter";

function fmtNum(n: number, digits = 2): string {
  if (!isFinite(n) || n === 0) return "—";
  return n.toLocaleString(undefined, { minimumFractionDigits: digits, maximumFractionDigits: digits });
}

function fmtPrice(n: number, quote: string): string {
  if (!isFinite(n) || n === 0) return "—";
  const digits = quote === "INR" ? 2 : n < 1 ? 6 : n < 100 ? 4 : 2;
  const prefix = quote === "INR" ? "₹" : "";
  return prefix + n.toLocaleString(undefined, { minimumFractionDigits: digits, maximumFractionDigits: digits });
}

export default function Trade() {
  const params = useParams<{ symbol?: string }>();
  const symbol = decodeSymbol(params.symbol || "BTC_INR");
  const [base, quote = "INR"] = symbol.split("/");
  const ticker = useTicker(symbol);
  const orderbook = useOrderbook(symbol, 25);
  const trades = useRecentTrades(symbol, 30);
  const { user } = useAuth();
  const qc = useQueryClient();

  const [side, setSide] = useState<"buy" | "sell">("buy");
  const [type, setType] = useState<"limit" | "market">("limit");
  const [price, setPrice] = useState("");
  const [amount, setAmount] = useState("");

  const { data: walletData } = useQuery<any>({
    queryKey: ["wallet"],
    queryFn: () => get("/finance/wallet"),
    enabled: !!user,
    refetchInterval: 10000,
  });

  // /finance/wallet returns { items, pagination } in Bicrypto shape.
  const wallets: any[] = useMemo(() => {
    if (!walletData) return [];
    if (Array.isArray(walletData)) return walletData;
    if (Array.isArray(walletData.items)) return walletData.items;
    if (Array.isArray(walletData.wallets)) return walletData.wallets;
    if (Array.isArray(walletData.data)) return walletData.data;
    return [];
  }, [walletData]);

  // Bicrypto wallet items expose { currency, balance, inOrder } (no `available`
  // field). Fall back through several aliases and derive available from
  // balance - inOrder when an explicit field isn't present.
  const findWallet = (sym: string) =>
    wallets.find((w) => (w.currency || w.symbol || w.coin) === sym);
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

  const orderMutation = useMutation({
    mutationFn: (data: any) => post("/exchange/order", data),
    onSuccess: () => {
      toast.success(`${side === "buy" ? "Buy" : "Sell"} order placed`);
      setPrice("");
      setAmount("");
      qc.invalidateQueries({ queryKey: ["orders"] });
      qc.invalidateQueries({ queryKey: ["wallet"] });
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

  const handleOrder = () => {
    if (!user) { toast.error("Please log in to trade"); return; }
    const amt = Number(amount);
    if (!(amt > 0)) { toast.error("Enter an amount"); return; }
    if (type === "limit" && !(Number(price) > 0)) { toast.error("Enter a price"); return; }
    orderMutation.mutate({
      currency: base,
      pair: quote,
      side,
      type,
      amount: amt,
      price: type === "limit" ? Number(price) : undefined,
    });
  };

  const setPct = (pct: number) => {
    const px = type === "limit" ? Number(price) : ticker?.lastPrice || 0;
    if (side === "buy") {
      const total = availBuy * pct;
      if (px > 0) setAmount((total / px).toFixed(6));
    } else {
      setAmount((availSell * pct).toFixed(6));
    }
  };

  const lastPx = ticker?.lastPrice || 0;
  const pct = ticker?.priceChangePercent || 0;
  const high = ticker?.high || 0;
  const low = ticker?.low || 0;
  const vol = ticker?.volume || 0;

  const maxBidQty = Math.max(1, ...orderbook.bids.slice(0, 15).map(([, q]) => q));
  const maxAskQty = Math.max(1, ...orderbook.asks.slice(0, 15).map(([, q]) => q));

  return (
    <div className="flex-1 flex flex-col h-[calc(100vh-56px)] bg-background">
      {/* Header strip */}
      <div className="h-16 border-b border-border bg-card flex items-center px-4 gap-6 shrink-0 overflow-x-auto">
        <div className="flex items-baseline gap-2">
          <h1 className="text-xl font-bold tabular-nums">{symbol}</h1>
          <Link href="/markets" className="text-xs text-muted-foreground hover:text-primary">change</Link>
        </div>
        <div>
          <div className="text-[10px] uppercase text-muted-foreground tracking-wider">Last</div>
          <div className={`font-mono font-bold text-lg tabular-nums ${pct >= 0 ? "text-success" : "text-destructive"}`}>
            {fmtPrice(lastPx, quote)}
          </div>
        </div>
        <div>
          <div className="text-[10px] uppercase text-muted-foreground tracking-wider">24h Change</div>
          <div className={`font-mono tabular-nums ${pct >= 0 ? "text-success" : "text-destructive"}`}>
            {pct >= 0 ? "+" : ""}{fmtNum(pct, 2)}%
          </div>
        </div>
        <div>
          <div className="text-[10px] uppercase text-muted-foreground tracking-wider">24h High</div>
          <div className="font-mono text-sm tabular-nums">{fmtPrice(high, quote)}</div>
        </div>
        <div>
          <div className="text-[10px] uppercase text-muted-foreground tracking-wider">24h Low</div>
          <div className="font-mono text-sm tabular-nums">{fmtPrice(low, quote)}</div>
        </div>
        <div>
          <div className="text-[10px] uppercase text-muted-foreground tracking-wider">24h Vol ({base})</div>
          <div className="font-mono text-sm tabular-nums">{fmtNum(vol, 2)}</div>
        </div>
      </div>

      <div className="flex-1 flex flex-row overflow-hidden min-h-0">
        {/* Chart */}
        <div className="flex-1 border-r border-border flex flex-col min-w-0">
          <PriceChart symbol={symbol} />
        </div>

        {/* Orderbook & Trades */}
        <div className="w-80 border-r border-border flex flex-col bg-card shrink-0">
          <div className="h-1/2 flex flex-col border-b border-border min-h-0">
            <div className="px-3 py-2 font-semibold text-xs uppercase tracking-wider border-b border-border text-muted-foreground">Order Book</div>
            <div className="flex-1 overflow-auto px-2 py-1 text-xs font-mono">
              <div className="grid grid-cols-2 text-[10px] text-muted-foreground py-1 px-1">
                <span>Price ({quote})</span>
                <span className="text-right">Amount ({base})</span>
              </div>
              {orderbook.asks.slice(0, 12).reverse().map(([px, qty], i) => (
                <div key={`ask-${i}`} className="relative grid grid-cols-2 py-[2px] px-1">
                  <div className="absolute right-0 top-0 bottom-0 bg-destructive/10" style={{ width: `${(qty / maxAskQty) * 100}%` }} />
                  <span className="relative text-destructive tabular-nums">{fmtNum(px, quote === "INR" ? 2 : 4)}</span>
                  <span className="relative text-right tabular-nums">{fmtNum(qty, 4)}</span>
                </div>
              ))}
              <div className={`py-2 my-1 text-center text-base font-bold border-y border-border tabular-nums ${pct >= 0 ? "text-success" : "text-destructive"}`}>
                {fmtPrice(lastPx, quote)}
              </div>
              {orderbook.bids.slice(0, 12).map(([px, qty], i) => (
                <div key={`bid-${i}`} className="relative grid grid-cols-2 py-[2px] px-1">
                  <div className="absolute right-0 top-0 bottom-0 bg-success/10" style={{ width: `${(qty / maxBidQty) * 100}%` }} />
                  <span className="relative text-success tabular-nums">{fmtNum(px, quote === "INR" ? 2 : 4)}</span>
                  <span className="relative text-right tabular-nums">{fmtNum(qty, 4)}</span>
                </div>
              ))}
              {orderbook.bids.length === 0 && orderbook.asks.length === 0 && (
                <div className="py-6 text-center text-muted-foreground text-xs">No depth yet</div>
              )}
            </div>
          </div>
          <div className="h-1/2 flex flex-col min-h-0">
            <div className="px-3 py-2 font-semibold text-xs uppercase tracking-wider border-b border-border text-muted-foreground">Recent Trades</div>
            <div className="flex-1 overflow-auto px-2 py-1 text-xs font-mono">
              <div className="grid grid-cols-3 text-[10px] text-muted-foreground py-1 px-1">
                <span>Price</span>
                <span className="text-right">Amount</span>
                <span className="text-right">Time</span>
              </div>
              {trades.map((t, i) => (
                <div key={i} className="grid grid-cols-3 py-[2px] px-1">
                  <span className={`tabular-nums ${t.side === "buy" ? "text-success" : "text-destructive"}`}>{fmtNum(t.price, quote === "INR" ? 2 : 4)}</span>
                  <span className="text-right tabular-nums">{fmtNum(t.qty, 4)}</span>
                  <span className="text-right text-muted-foreground">{new Date(t.ts).toLocaleTimeString()}</span>
                </div>
              ))}
              {trades.length === 0 && <div className="py-6 text-center text-muted-foreground text-xs">No trades yet</div>}
            </div>
          </div>
        </div>

        {/* Order Entry */}
        <div className="w-80 bg-card p-4 flex flex-col shrink-0 overflow-y-auto">
          <div className="grid grid-cols-2 gap-1 mb-4 p-1 bg-muted/30 rounded-md">
            <button
              className={`py-2 rounded text-sm font-semibold transition-colors ${side === "buy" ? "bg-success text-success-foreground" : "text-muted-foreground hover:text-foreground"}`}
              onClick={() => setSide("buy")}
            >Buy {base}</button>
            <button
              className={`py-2 rounded text-sm font-semibold transition-colors ${side === "sell" ? "bg-destructive text-destructive-foreground" : "text-muted-foreground hover:text-foreground"}`}
              onClick={() => setSide("sell")}
            >Sell {base}</button>
          </div>

          <div className="flex gap-4 mb-4 text-sm border-b border-border pb-2">
            <button className={`pb-1 ${type === "limit" ? "text-primary font-semibold border-b-2 border-primary -mb-2" : "text-muted-foreground"}`} onClick={() => setType("limit")}>Limit</button>
            <button className={`pb-1 ${type === "market" ? "text-primary font-semibold border-b-2 border-primary -mb-2" : "text-muted-foreground"}`} onClick={() => setType("market")}>Market</button>
          </div>

          <div className="space-y-3">
            {type === "limit" && (
              <div>
                <div className="text-xs text-muted-foreground mb-1 flex justify-between">
                  <span>Price</span>
                  <button className="text-primary text-[10px]" onClick={() => setPrice(String(lastPx || ""))}>use last</button>
                </div>
                <div className="relative">
                  <Input type="number" value={price} onChange={(e) => setPrice(e.target.value)} placeholder="0.00" className="font-mono pr-12" />
                  <span className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">{quote}</span>
                </div>
              </div>
            )}
            <div>
              <div className="text-xs text-muted-foreground mb-1">Amount</div>
              <div className="relative">
                <Input type="number" value={amount} onChange={(e) => setAmount(e.target.value)} placeholder="0.00" className="font-mono pr-12" />
                <span className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">{base}</span>
              </div>
            </div>

            <div className="grid grid-cols-4 gap-1">
              {[0.25, 0.5, 0.75, 1].map((p) => (
                <button key={p} type="button" className="text-xs py-1 rounded bg-muted/30 hover:bg-muted/60 text-muted-foreground" onClick={() => setPct(p)}>
                  {p === 1 ? "100%" : `${p * 100}%`}
                </button>
              ))}
            </div>

            <div className="text-xs text-muted-foreground space-y-1 pt-1">
              <div className="flex justify-between"><span>Available</span><span className="tabular-nums">{side === "buy" ? `${fmtNum(availBuy, 2)} ${quote}` : `${fmtNum(availSell, 6)} ${base}`}</span></div>
              <div className="flex justify-between"><span>Total</span><span className="tabular-nums">{fmtNum(Number(amount) * (type === "limit" ? Number(price || 0) : lastPx), 2)} {quote}</span></div>
            </div>

            <Button
              className={`w-full font-semibold ${side === "buy" ? "bg-success hover:bg-success/90 text-success-foreground" : "bg-destructive hover:bg-destructive/90 text-destructive-foreground"}`}
              onClick={handleOrder}
              disabled={orderMutation.isPending || !user}
            >
              {!user ? "Log in to Trade" : orderMutation.isPending ? "Placing…" : side === "buy" ? `Buy ${base}` : `Sell ${base}`}
            </Button>
          </div>

          {/* Open orders */}
          {user && (
            <div className="mt-6 border-t border-border pt-3">
              <div className="text-xs uppercase tracking-wider text-muted-foreground mb-2">Open Orders ({orderRows.length})</div>
              <div className="space-y-1 max-h-48 overflow-auto text-xs font-mono">
                {orderRows.length === 0 && <div className="text-muted-foreground py-2">No open orders.</div>}
                {orderRows.map((o: any) => (
                  <div key={o.id} className="flex items-center justify-between gap-2 py-1 px-2 rounded hover:bg-muted/30">
                    <span className={o.side === "buy" ? "text-success" : "text-destructive"}>{o.side?.toUpperCase()}</span>
                    <span className="tabular-nums">{fmtNum(Number(o.price ?? o.priceFilled ?? lastPx), 2)}</span>
                    <span className="tabular-nums">{fmtNum(Number(o.amount ?? o.qty ?? 0) - Number(o.filled ?? 0), 4)}</span>
                    <button className="text-destructive text-xs hover:underline" onClick={() => cancelMutation.mutate(o.id)}>×</button>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
