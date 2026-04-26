import { useParams, Link } from "wouter";
import { useState, useMemo } from "react";
import { useTicker, useOrderbook, useRecentTrades, decodeSymbol, useTickers, encodeSymbol } from "@/lib/marketSocket";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, api } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { toast } from "sonner";
import { useAuth } from "@/lib/auth";
import { PriceChart } from "@/components/PriceChart";

function fmtNum(n: number, digits = 2): string {
  if (!isFinite(n) || n === 0) return "—";
  return n.toLocaleString(undefined, { minimumFractionDigits: digits, maximumFractionDigits: digits });
}
function fmtPrice(n: number, quote: string): string {
  if (!isFinite(n) || n === 0) return "—";
  const digits = quote === "INR" ? 2 : n < 1 ? 6 : n < 100 ? 4 : 2;
  return (quote === "INR" ? "₹" : "") + n.toLocaleString(undefined, { minimumFractionDigits: digits, maximumFractionDigits: digits });
}

const LEVERAGES = [1, 2, 5, 10, 20, 25, 50, 75, 100];

export default function Futures() {
  const params = useParams<{ symbol?: string }>();
  const symbol = decodeSymbol(params.symbol || "BTC_USDT");
  const [base, quote = "USDT"] = symbol.split("/");
  const ticker = useTicker(symbol);
  const orderbook = useOrderbook(symbol, 25);
  const trades = useRecentTrades(symbol, 30);
  const tickers = useTickers();
  const { user } = useAuth();
  const qc = useQueryClient();

  const [leverage, setLeverage] = useState(10);
  const [side, setSide] = useState<"long" | "short">("long");
  const [type, setType] = useState<"limit" | "market">("limit");
  const [price, setPrice] = useState("");
  const [amount, setAmount] = useState("");

  const { data: positionsData } = useQuery<any>({
    queryKey: ["futures", "positions"],
    queryFn: () => get("/futures/position").catch(() => ({ data: [] })),
    enabled: !!user,
    refetchInterval: 5000,
  });
  const positions: any[] = useMemo(() => {
    if (!positionsData) return [];
    if (Array.isArray(positionsData)) return positionsData;
    if (Array.isArray(positionsData.data)) return positionsData.data;
    if (Array.isArray(positionsData.items)) return positionsData.items;
    if (Array.isArray(positionsData.positions)) return positionsData.positions;
    return [];
  }, [positionsData]);

  const { data: walletData } = useQuery<any>({
    queryKey: ["wallet"],
    queryFn: () => get("/finance/wallet"),
    enabled: !!user,
  });
  // /finance/wallet returns { items, pagination }; items have { currency, available }.
  const wallets: any[] = useMemo(() => {
    if (!walletData) return [];
    if (Array.isArray(walletData)) return walletData;
    if (Array.isArray(walletData.items)) return walletData.items;
    if (Array.isArray(walletData.wallets)) return walletData.wallets;
    return [];
  }, [walletData]);
  const collateralWallet = wallets.find((w) => (w.currency || w.symbol || w.coin) === quote);
  const collateral = collateralWallet
    ? collateralWallet.available != null
      ? Number(collateralWallet.available)
      : collateralWallet.free != null
        ? Number(collateralWallet.free)
        : Math.max(0, Number(collateralWallet.balance ?? 0) - Number(collateralWallet.inOrder ?? collateralWallet.locked ?? 0))
    : 0;

  // Server expects buy/sell at /futures/order. UI uses long/short.
  const apiSide = side === "long" ? "buy" : "sell";
  const orderMutation = useMutation({
    mutationFn: (data: any) => post("/futures/order", data),
    onSuccess: () => {
      toast.success(`${side === "long" ? "Long" : "Short"} ${leverage}× position opened`);
      setPrice("");
      setAmount("");
      qc.invalidateQueries({ queryKey: ["futures"] });
      qc.invalidateQueries({ queryKey: ["wallet"] });
    },
    onError: (err: any) => toast.error(err?.message || "Failed to place order"),
  });

  // DELETE /futures/position takes a body { currency, pair, side: long|short }.
  const closeMutation = useMutation({
    mutationFn: (pos: any) => api(`/futures/position`, {
      method: "DELETE",
      body: JSON.stringify({
        currency: pos.currency || base,
        pair: pos.pair || quote,
        side: String(pos.side || "long").toLowerCase(),
      }),
    }),
    onSuccess: () => {
      toast.success("Position closed");
      qc.invalidateQueries({ queryKey: ["futures"] });
      qc.invalidateQueries({ queryKey: ["wallet"] });
    },
    onError: (err: any) => toast.error(err?.message || "Close failed"),
  });

  const handleOrder = () => {
    if (!user) { toast.error("Please log in"); return; }
    const amt = Number(amount);
    if (!(amt > 0)) { toast.error("Enter an amount"); return; }
    if (type === "limit" && !(Number(price) > 0)) { toast.error("Enter a price"); return; }
    orderMutation.mutate({
      currency: base,
      pair: quote,
      side: apiSide,
      type,
      amount: amt,
      price: type === "limit" ? Number(price) : undefined,
      leverage,
    });
  };

  const lastPx = ticker?.lastPrice || 0;
  const pct = ticker?.priceChangePercent || 0;
  const high = ticker?.high || 0;
  const low = ticker?.low || 0;

  const futuresMarkets = useMemo(() => Object.values(tickers).filter((t) => t.symbol.endsWith("/USDT")).slice(0, 8), [tickers]);

  const maxBidQty = Math.max(1, ...orderbook.bids.slice(0, 12).map(([, q]) => q));
  const maxAskQty = Math.max(1, ...orderbook.asks.slice(0, 12).map(([, q]) => q));

  const notional = Number(amount) * (type === "limit" ? Number(price || 0) : lastPx);
  const margin = notional / Math.max(leverage, 1);

  return (
    <div className="flex-1 flex flex-col h-[calc(100vh-56px)] bg-background">
      {/* Header */}
      <div className="h-16 border-b border-border bg-card flex items-center px-4 gap-6 shrink-0 overflow-x-auto">
        <div className="flex items-baseline gap-2">
          <h1 className="text-xl font-bold tabular-nums">{symbol}</h1>
          <span className="px-2 py-0.5 text-[10px] font-bold bg-primary/10 text-primary rounded">PERP</span>
        </div>
        <div>
          <div className="text-[10px] uppercase text-muted-foreground tracking-wider">Mark Price</div>
          <div className={`font-mono font-bold text-lg tabular-nums ${pct >= 0 ? "text-success" : "text-destructive"}`}>{fmtPrice(lastPx, quote)}</div>
        </div>
        <div>
          <div className="text-[10px] uppercase text-muted-foreground tracking-wider">24h Change</div>
          <div className={`font-mono tabular-nums ${pct >= 0 ? "text-success" : "text-destructive"}`}>{pct >= 0 ? "+" : ""}{fmtNum(pct, 2)}%</div>
        </div>
        <div>
          <div className="text-[10px] uppercase text-muted-foreground tracking-wider">24h High</div>
          <div className="font-mono text-sm tabular-nums">{fmtPrice(high, quote)}</div>
        </div>
        <div>
          <div className="text-[10px] uppercase text-muted-foreground tracking-wider">24h Low</div>
          <div className="font-mono text-sm tabular-nums">{fmtPrice(low, quote)}</div>
        </div>
      </div>

      <div className="flex-1 flex flex-row overflow-hidden min-h-0">
        {/* Left rail: market list */}
        <div className="w-44 border-r border-border bg-card shrink-0 overflow-y-auto">
          <div className="px-3 py-2 text-[10px] uppercase tracking-wider text-muted-foreground border-b border-border">Markets</div>
          {futuresMarkets.map((t) => (
            <Link key={t.symbol} href={`/futures/${encodeSymbol(t.symbol)}`}>
              <div className={`px-3 py-2 text-xs cursor-pointer hover:bg-muted/40 ${t.symbol === symbol ? "bg-muted/30 border-l-2 border-primary" : ""}`}>
                <div className="flex justify-between"><span className="font-semibold">{t.symbol.replace("/USDT", "")}</span><span className={`tabular-nums ${t.priceChangePercent >= 0 ? "text-success" : "text-destructive"}`}>{t.priceChangePercent >= 0 ? "+" : ""}{t.priceChangePercent.toFixed(2)}%</span></div>
                <div className="font-mono text-[11px] text-muted-foreground tabular-nums">{fmtNum(t.lastPrice, t.lastPrice < 1 ? 6 : 2)}</div>
              </div>
            </Link>
          ))}
        </div>

        {/* Chart */}
        <div className="flex-1 border-r border-border flex flex-col min-w-0">
          <PriceChart symbol={symbol} />
        </div>

        {/* Orderbook & Trades */}
        <div className="w-72 border-r border-border flex flex-col bg-card shrink-0">
          <div className="h-1/2 flex flex-col border-b border-border min-h-0">
            <div className="px-3 py-2 font-semibold text-xs uppercase tracking-wider border-b border-border text-muted-foreground">Order Book</div>
            <div className="flex-1 overflow-auto px-2 py-1 text-xs font-mono">
              {orderbook.asks.slice(0, 10).reverse().map(([px, qty], i) => (
                <div key={`ask-${i}`} className="relative grid grid-cols-2 py-[2px] px-1">
                  <div className="absolute right-0 top-0 bottom-0 bg-destructive/10" style={{ width: `${(qty / maxAskQty) * 100}%` }} />
                  <span className="relative text-destructive tabular-nums">{fmtNum(px, quote === "INR" ? 2 : 4)}</span>
                  <span className="relative text-right tabular-nums">{fmtNum(qty, 4)}</span>
                </div>
              ))}
              <div className={`py-2 my-1 text-center text-base font-bold border-y border-border tabular-nums ${pct >= 0 ? "text-success" : "text-destructive"}`}>{fmtPrice(lastPx, quote)}</div>
              {orderbook.bids.slice(0, 10).map(([px, qty], i) => (
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

        {/* Order entry + positions */}
        <div className="w-80 bg-card flex flex-col shrink-0 overflow-y-auto">
          <div className="p-4 border-b border-border">
            <div className="grid grid-cols-2 gap-1 mb-3 p-1 bg-muted/30 rounded-md">
              <button className={`py-2 rounded text-sm font-semibold transition-colors ${side === "long" ? "bg-success text-success-foreground" : "text-muted-foreground hover:text-foreground"}`} onClick={() => setSide("long")}>Long</button>
              <button className={`py-2 rounded text-sm font-semibold transition-colors ${side === "short" ? "bg-destructive text-destructive-foreground" : "text-muted-foreground hover:text-foreground"}`} onClick={() => setSide("short")}>Short</button>
            </div>

            <div className="flex gap-4 mb-3 text-sm border-b border-border pb-2">
              <button className={`pb-1 ${type === "limit" ? "text-primary font-semibold border-b-2 border-primary -mb-2" : "text-muted-foreground"}`} onClick={() => setType("limit")}>Limit</button>
              <button className={`pb-1 ${type === "market" ? "text-primary font-semibold border-b-2 border-primary -mb-2" : "text-muted-foreground"}`} onClick={() => setType("market")}>Market</button>
            </div>

            <div className="mb-3">
              <div className="flex justify-between items-center text-xs text-muted-foreground mb-1">
                <span>Leverage</span>
                <span className="font-mono font-bold text-primary text-base">{leverage}×</span>
              </div>
              <div className="grid grid-cols-9 gap-1">
                {LEVERAGES.map((lv) => (
                  <button key={lv} type="button"
                    className={`text-[10px] py-1 rounded font-mono ${leverage === lv ? "bg-primary text-primary-foreground" : "bg-muted/30 hover:bg-muted/60 text-muted-foreground"}`}
                    onClick={() => setLeverage(lv)}>{lv}×</button>
                ))}
              </div>
            </div>

            {type === "limit" && (
              <div className="mb-3">
                <div className="text-xs text-muted-foreground mb-1 flex justify-between">
                  <span>Price</span>
                  <button className="text-primary text-[10px]" onClick={() => setPrice(String(lastPx || ""))}>use mark</button>
                </div>
                <div className="relative">
                  <Input type="number" value={price} onChange={(e) => setPrice(e.target.value)} placeholder="0.00" className="font-mono pr-12" />
                  <span className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">{quote}</span>
                </div>
              </div>
            )}
            <div className="mb-3">
              <div className="text-xs text-muted-foreground mb-1">Size</div>
              <div className="relative">
                <Input type="number" value={amount} onChange={(e) => setAmount(e.target.value)} placeholder="0.00" className="font-mono pr-12" />
                <span className="absolute right-3 top-1/2 -translate-y-1/2 text-xs text-muted-foreground">{base}</span>
              </div>
            </div>

            <div className="text-xs text-muted-foreground space-y-1 mb-3">
              <div className="flex justify-between"><span>Available {quote}</span><span className="tabular-nums">{fmtNum(collateral, 2)}</span></div>
              <div className="flex justify-between"><span>Notional</span><span className="tabular-nums">{fmtNum(notional, 2)} {quote}</span></div>
              <div className="flex justify-between"><span>Required Margin</span><span className="tabular-nums">{fmtNum(margin, 2)} {quote}</span></div>
            </div>

            <Button
              className={`w-full font-semibold ${side === "long" ? "bg-success hover:bg-success/90 text-success-foreground" : "bg-destructive hover:bg-destructive/90 text-destructive-foreground"}`}
              onClick={handleOrder}
              disabled={orderMutation.isPending || !user}
            >
              {!user ? "Log in to Trade" : orderMutation.isPending ? "Placing…" : `${side === "long" ? "Open Long" : "Open Short"} ${leverage}×`}
            </Button>
          </div>

          {user && (
            <div className="p-4">
              <div className="text-xs uppercase tracking-wider text-muted-foreground mb-2">Open Positions ({positions.length})</div>
              <div className="space-y-2 text-xs font-mono">
                {positions.length === 0 && <div className="text-muted-foreground py-2">No open positions.</div>}
                {positions.map((p: any) => {
                  const pSide = String(p.side || "long").toLowerCase();
                  const entry = Number(p.entryPrice ?? p.openPrice ?? 0);
                  const size = Number(p.amount ?? p.size ?? p.qty ?? 0);
                  const mark = Number(p.markPrice ?? lastPx);
                  const pnl = Number(p.unrealizedPnl ?? p.unrealisedPnl ?? p.pnl ?? ((mark - entry) * size * (pSide === "long" ? 1 : -1)));
                  return (
                    <div key={p.id} className="border border-border rounded p-2 bg-muted/10">
                      <div className="flex justify-between mb-1">
                        <span className={pSide === "long" ? "text-success font-semibold" : "text-destructive font-semibold"}>{pSide.toUpperCase()} {p.leverage || 1}×</span>
                        <button
                          className="text-destructive text-xs hover:underline disabled:opacity-50"
                          disabled={closeMutation.isPending}
                          onClick={() => closeMutation.mutate({ ...p, side: pSide })}
                        >Close</button>
                      </div>
                      <div className="text-muted-foreground">{p.symbol || `${p.currency || base}/${p.pair || quote}`}</div>
                      <div className="grid grid-cols-2 gap-x-2 mt-1">
                        <span className="text-muted-foreground">Size</span><span className="text-right tabular-nums">{fmtNum(size, 4)}</span>
                        <span className="text-muted-foreground">Entry</span><span className="text-right tabular-nums">{fmtNum(entry, 2)}</span>
                        <span className="text-muted-foreground">Mark</span><span className="text-right tabular-nums">{fmtNum(mark, 2)}</span>
                        <span className="text-muted-foreground">PnL</span><span className={`text-right tabular-nums ${pnl >= 0 ? "text-success" : "text-destructive"}`}>{pnl >= 0 ? "+" : ""}{fmtNum(pnl, 2)}</span>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
