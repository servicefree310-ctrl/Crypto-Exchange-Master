import { useTickers, encodeSymbol } from "@/lib/marketSocket";
import { Link } from "wouter";
import { Button } from "@/components/ui/button";

function fmtPrice(n: number, sym: string): string {
  if (!isFinite(n) || n === 0) return "—";
  const isInr = sym.endsWith("/INR") || sym.endsWith("INR");
  const digits = isInr ? 2 : n < 1 ? 6 : n < 100 ? 4 : 2;
  const prefix = isInr ? "₹" : "";
  return prefix + n.toLocaleString(undefined, { minimumFractionDigits: digits, maximumFractionDigits: digits });
}

export default function Home() {
  const tickers = useTickers();

  return (
    <div className="flex flex-col items-center">
      <section className="w-full py-20 text-center bg-card">
        <h1 className="text-5xl font-bold mb-4">Trade Crypto with Confidence</h1>
        <p className="text-xl text-muted-foreground mb-8">The most trusted exchange for Indian retail traders.</p>
        <Button size="lg" className="bg-primary text-primary-foreground text-lg px-8" asChild>
          <Link href="/signup">Start Trading Now</Link>
        </Button>
      </section>

      <section className="w-full max-w-5xl mx-auto py-12 px-4">
        <h2 className="text-2xl font-bold mb-6">Market Trends</h2>
        <div className="bg-card border border-border rounded-lg overflow-hidden">
          <table className="w-full text-left">
            <thead className="bg-muted/50 border-b border-border text-sm">
              <tr>
                <th className="p-4">Pair</th>
                <th className="p-4">Last Price</th>
                <th className="p-4">24h Change</th>
                <th className="p-4">Action</th>
              </tr>
            </thead>
            <tbody>
              {Object.values(tickers)
                .sort((a, b) => (b.quoteVolume || 0) - (a.quoteVolume || 0))
                .slice(0, 10)
                .map((t) => (
                  <tr key={t.symbol} className="border-b border-border hover:bg-muted/20">
                    <td className="p-4 font-bold">{t.symbol}</td>
                    <td className="p-4 font-mono tabular-nums">{fmtPrice(t.lastPrice, t.symbol)}</td>
                    <td className={`p-4 tabular-nums ${t.priceChangePercent >= 0 ? "text-success" : "text-destructive"}`}>
                      {t.priceChangePercent >= 0 ? "+" : ""}{t.priceChangePercent.toFixed(2)}%
                    </td>
                    <td className="p-4">
                      <Button size="sm" variant="outline" asChild>
                        <Link href={`/trade/${encodeSymbol(t.symbol)}`}>Trade</Link>
                      </Button>
                    </td>
                  </tr>
                ))}
              {Object.keys(tickers).length === 0 && (
                <tr><td colSpan={4} className="p-8 text-center text-muted-foreground">Loading markets…</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}
