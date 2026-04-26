import { useState, useMemo } from "react";
import { useTickers, encodeSymbol } from "@/lib/marketSocket";
import { Link } from "wouter";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

function fmtPrice(n: number, sym: string): string {
  if (!isFinite(n) || n === 0) return "—";
  const isInr = sym.endsWith("/INR") || sym.endsWith("INR");
  const digits = isInr ? 2 : n < 1 ? 6 : n < 100 ? 4 : 2;
  const prefix = isInr ? "₹" : "";
  return prefix + n.toLocaleString(undefined, { minimumFractionDigits: digits, maximumFractionDigits: digits });
}

export default function Markets() {
  const [search, setSearch] = useState("");
  const [quote, setQuote] = useState<"ALL" | "INR" | "USDT">("ALL");
  const tickers = useTickers();

  const filtered = useMemo(() => {
    return Object.values(tickers)
      .filter((t) => {
        if (search && !t.symbol.toLowerCase().includes(search.toLowerCase())) return false;
        if (quote !== "ALL" && !t.symbol.endsWith(`/${quote}`) && !t.symbol.endsWith(quote)) return false;
        return true;
      })
      .sort((a, b) => (b.quoteVolume || 0) - (a.quoteVolume || 0));
  }, [tickers, search, quote]);

  return (
    <div className="p-8 container mx-auto max-w-6xl">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold">Markets</h1>
        <Input
          placeholder="Search pairs…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="w-64"
        />
      </div>

      <div className="flex gap-2 mb-6">
        {(["ALL", "INR", "USDT"] as const).map((q) => (
          <Button key={q} variant={quote === q ? "default" : "outline"} onClick={() => setQuote(q)}>
            {q}
          </Button>
        ))}
      </div>

      <div className="bg-card border border-border rounded-lg overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-muted/50 border-b border-border text-sm text-muted-foreground">
            <tr>
              <th className="p-4 font-medium">Pair</th>
              <th className="p-4 font-medium">Last Price</th>
              <th className="p-4 font-medium">24h Change</th>
              <th className="p-4 font-medium">24h High</th>
              <th className="p-4 font-medium">24h Low</th>
              <th className="p-4 font-medium">24h Volume</th>
              <th className="p-4 font-medium">Action</th>
            </tr>
          </thead>
          <tbody>
            {filtered.map((t) => (
              <tr key={t.symbol} className="border-b border-border hover:bg-muted/20">
                <td className="p-4 font-bold">{t.symbol}</td>
                <td className="p-4 font-mono tabular-nums">{fmtPrice(t.lastPrice, t.symbol)}</td>
                <td className={`p-4 tabular-nums ${t.priceChangePercent >= 0 ? "text-success" : "text-destructive"}`}>
                  {t.priceChangePercent >= 0 ? "+" : ""}{t.priceChangePercent.toFixed(2)}%
                </td>
                <td className="p-4 font-mono tabular-nums text-sm">{fmtPrice(t.high, t.symbol)}</td>
                <td className="p-4 font-mono tabular-nums text-sm">{fmtPrice(t.low, t.symbol)}</td>
                <td className="p-4 font-mono tabular-nums text-sm">{t.volume.toLocaleString(undefined, { maximumFractionDigits: 2 })}</td>
                <td className="p-4">
                  <Button size="sm" variant="outline" asChild>
                    <Link href={`/trade/${encodeSymbol(t.symbol)}`}>Trade</Link>
                  </Button>
                </td>
              </tr>
            ))}
            {filtered.length === 0 && (
              <tr>
                <td colSpan={7} className="p-8 text-center text-muted-foreground">
                  {Object.keys(tickers).length === 0 ? "Loading markets…" : "No markets match your filter."}
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
