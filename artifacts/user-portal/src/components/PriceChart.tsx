import { useEffect, useRef, useState } from "react";
import { createChart, CandlestickSeries, type IChartApi, type ISeriesApi, type Time } from "lightweight-charts";
import { get } from "@/lib/api";
import { useOhlcv, type Candle } from "@/lib/marketSocket";

const INTERVALS = ["1m", "5m", "15m", "1h", "4h", "1d"] as const;
type Interval = (typeof INTERVALS)[number];

export function PriceChart({ symbol }: { symbol: string }) {
  const containerRef = useRef<HTMLDivElement>(null);
  const chartRef = useRef<IChartApi | null>(null);
  const seriesRef = useRef<ISeriesApi<"Candlestick"> | null>(null);
  const lastTimeRef = useRef<number>(0);
  const [interval, setInterval] = useState<Interval>("1h");
  const [seedLoaded, setSeedLoaded] = useState(false);
  const liveCandles = useOhlcv(symbol, interval);

  // Init chart
  useEffect(() => {
    if (!containerRef.current) return;
    const chart = createChart(containerRef.current, {
      layout: {
        background: { color: "transparent" },
        textColor: "#9ca3af",
        fontFamily: "JetBrains Mono, Menlo, monospace",
      },
      grid: {
        vertLines: { color: "rgba(148, 163, 184, 0.08)" },
        horzLines: { color: "rgba(148, 163, 184, 0.08)" },
      },
      rightPriceScale: { borderColor: "rgba(148, 163, 184, 0.15)" },
      timeScale: { borderColor: "rgba(148, 163, 184, 0.15)", timeVisible: true, secondsVisible: false },
      crosshair: { mode: 1 },
      autoSize: true,
    });
    const series = chart.addSeries(CandlestickSeries, {
      upColor: "#22c55e",
      downColor: "#ef4444",
      wickUpColor: "#22c55e",
      wickDownColor: "#ef4444",
      borderVisible: false,
    });
    chartRef.current = chart;
    seriesRef.current = series;
    return () => {
      chart.remove();
      chartRef.current = null;
      seriesRef.current = null;
    };
  }, []);

  // Seed from REST whenever symbol/interval changes. Reset live-candle state
  // first so a stale lastTimeRef from the previous symbol can't reject the
  // first live tick of the new one.
  useEffect(() => {
    let cancelled = false;
    setSeedLoaded(false);
    lastTimeRef.current = 0;
    if (seriesRef.current) {
      try { seriesRef.current.setData([]); } catch {}
    }
    (async () => {
      try {
        const data = await get<any>(`/exchange/chart?symbol=${encodeURIComponent(symbol)}&interval=${interval}&limit=300`);
        const raw = Array.isArray(data) ? data : Array.isArray(data?.candles) ? data.candles : [];
        const candles: Candle[] = raw
          .map((c: any) => {
            if (Array.isArray(c)) {
              return { time: Math.floor(Number(c[0]) / 1000) as number, open: Number(c[1]), high: Number(c[2]), low: Number(c[3]), close: Number(c[4]), volume: Number(c[5] ?? 0) };
            }
            return { time: Math.floor(Number(c.time ?? c.ts ?? c.timestamp ?? 0) / 1000) as number, open: Number(c.open ?? c.o), high: Number(c.high ?? c.h), low: Number(c.low ?? c.l), close: Number(c.close ?? c.c), volume: Number(c.volume ?? c.v ?? 0) };
          })
          .filter((c: Candle) => c.time > 0 && c.close > 0)
          .sort((a: Candle, b: Candle) => a.time - b.time);
        if (cancelled || !seriesRef.current) return;
        // De-duplicate timestamps (lightweight-charts requires strictly increasing time)
        const seen = new Set<number>();
        const unique = candles.filter((c) => {
          if (seen.has(c.time)) return false;
          seen.add(c.time);
          return true;
        });
        seriesRef.current.setData(
          unique.map((c) => ({ time: c.time as Time, open: c.open, high: c.high, low: c.low, close: c.close })),
        );
        lastTimeRef.current = unique.length > 0 ? unique[unique.length - 1].time : 0;
        chartRef.current?.timeScale().fitContent();
      } catch (err) {
        console.warn("chart seed failed", err);
      } finally {
        // Allow live updates even when REST seed failed (empty chart that
        // populates from WS is better than a permanently frozen one).
        if (!cancelled) setSeedLoaded(true);
      }
    })();
    return () => {
      cancelled = true;
    };
  }, [symbol, interval]);

  // Apply live OHLCV updates from WS — only forward-moving timestamps
  useEffect(() => {
    if (!seedLoaded || !seriesRef.current || !liveCandles || liveCandles.length === 0) return;
    const sorted = [...liveCandles].sort((a, b) => a.time - b.time);
    for (const c of sorted) {
      if (!(c.time > 0)) continue;
      // lightweight-charts only allows update() with time >= last applied time.
      if (c.time < lastTimeRef.current) continue;
      try {
        seriesRef.current.update({ time: c.time as Time, open: c.open, high: c.high, low: c.low, close: c.close });
        lastTimeRef.current = c.time;
      } catch (err) {
        console.warn("chart update skipped", err);
      }
    }
  }, [liveCandles, seedLoaded]);

  return (
    <div className="flex flex-col h-full w-full">
      <div className="flex items-center gap-1 px-3 py-2 border-b border-border bg-card/40">
        <span className="text-xs text-muted-foreground mr-2">Interval</span>
        {INTERVALS.map((iv) => (
          <button
            key={iv}
            onClick={() => setInterval(iv)}
            className={`px-2 py-1 text-xs rounded font-mono transition-colors ${
              interval === iv ? "bg-primary text-primary-foreground" : "text-muted-foreground hover:bg-muted/40"
            }`}
          >
            {iv}
          </button>
        ))}
      </div>
      <div ref={containerRef} className="flex-1 min-h-[320px]" />
    </div>
  );
}
