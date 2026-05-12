import { useState, useEffect, useRef, useCallback, useMemo } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { useToast } from "@/hooks/use-toast";
import { Link } from "wouter";
import { cn } from "@/lib/utils";
import {
  Globe, RefreshCw, Info, Link2, ChevronRight, Star, StarOff,
  TrendingUp, TrendingDown, Activity, Clock, Shield, Zap,
  BarChart3, BookOpen, ChevronDown, ChevronUp, X, Settings,
  Calculator, AlertTriangle, CheckCircle2, Wifi, WifiOff,
  Terminal, Eye, EyeOff, Plug, PlugZap, ExternalLink,
} from "lucide-react";

// ─── Types ────────────────────────────────────────────────────────────────────
type Instrument = {
  id: number; symbol: string; name: string; assetClass: string;
  exchange: string; quoteCurrency: string; currentPrice: string;
  previousClose: string; change24h: string; high24h: string; low24h: string;
  volume24h: string; tradingEnabled: boolean; lotSize: string;
  minQty: string; maxQty: string; maxLeverage: number;
  marginRequired: string; takerFee: string; pricePrecision: number;
  qtyPrecision: number; sector: string | null; countryCode?: string;
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

type MT5Account = {
  id: number; server: string; login: string; name: string | null;
  currency: string | null; leverage: number | null; balance: string | null;
  equity: string | null; margin: string | null; freeMargin: string | null;
  status: string; isDemo: boolean; connectionType: string | null;
  lastError: string | null; lastConnectedAt: string | null;
  sessionToken?: string; createdAt: string;
};

type OHLC = { t: number; o: number; h: number; l: number; c: number; v: number };
type TF = "M1" | "M5" | "M15" | "H1" | "H4" | "D1";

// ─── Helpers ──────────────────────────────────────────────────────────────────
function p(n: number, dp = 5) { return isFinite(n) && n ? n.toFixed(dp) : "—"; }
function pct(n: number) { return (n >= 0 ? "+" : "") + n.toFixed(3) + "%"; }
function pip(n: number, pp: number) { return (n * Math.pow(10, pp)).toFixed(1); }
function fmtTime(ts: number) {
  const d = new Date(ts);
  return d.getHours().toString().padStart(2, "0") + ":" + d.getMinutes().toString().padStart(2, "0");
}
function fmtCurrency(n: number, cur = "INR") {
  if (!isFinite(n)) return "—";
  const prefix = cur === "INR" ? "₹" : cur === "USD" ? "$" : cur + " ";
  return prefix + Math.abs(n).toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

// Generate simulated OHLC data
function genOHLC(base: number, count: number, tfMs: number): OHLC[] {
  const bars: OHLC[] = [];
  let price = base;
  const now = Date.now();
  for (let i = count; i >= 0; i--) {
    const t = now - i * tfMs;
    const volatility = base * 0.0018;
    const o = price;
    const move1 = (Math.random() - 0.49) * volatility;
    const move2 = (Math.random() - 0.49) * volatility;
    const move3 = (Math.random() - 0.49) * volatility;
    const c = o + move1 + move2;
    const h = Math.max(o, c) + Math.abs(move3) * 0.5;
    const l = Math.min(o, c) - Math.abs(move3) * 0.5;
    const v = Math.floor(Math.random() * 50000 + 10000);
    bars.push({ t, o: +o.toFixed(5), h: +h.toFixed(5), l: +l.toFixed(5), c: +c.toFixed(5), v });
    price = c;
  }
  return bars;
}

const TF_OPTIONS: { label: TF; ms: number }[] = [
  { label: "M1", ms: 60_000 },
  { label: "M5", ms: 300_000 },
  { label: "M15", ms: 900_000 },
  { label: "H1", ms: 3_600_000 },
  { label: "H4", ms: 14_400_000 },
  { label: "D1", ms: 86_400_000 },
];

const FOREX_SESSIONS = [
  { name: "Tokyo", open: 0, close: 9, color: "text-blue-400" },
  { name: "London", open: 8, close: 17, color: "text-purple-400" },
  { name: "New York", open: 13, close: 22, color: "text-amber-400" },
  { name: "Sydney", open: 22, close: 7, color: "text-emerald-400" },
];

const PAIR_FLAGS: Record<string, string> = {
  AUD: "🇦🇺", CAD: "🇨🇦", CHF: "🇨🇭", EUR: "🇪🇺", GBP: "🇬🇧",
  JPY: "🇯🇵", NZD: "🇳🇿", USD: "🇺🇸", INR: "🇮🇳", SGD: "🇸🇬",
  HKD: "🇭🇰", SEK: "🇸🇪", NOK: "🇳🇴", DKK: "🇩🇰", MXN: "🇲🇽",
};

// ─── CandlestickChart (SVG) ──────────────────────────────────────────────────
function CandlestickChart({ bars, symbol, tf, pp }: {
  bars: OHLC[]; symbol: string; tf: TF; pp: number;
}) {
  const W = 900, H = 340, PAD_L = 64, PAD_R = 60, PAD_T = 16, PAD_B = 28;
  const visibleBars = bars.slice(-80);
  const allH = visibleBars.map(b => b.h);
  const allL = visibleBars.map(b => b.l);
  const maxH = Math.max(...allH);
  const minL = Math.min(...allL);
  const range = maxH - minL || 0.0001;

  const toY = (v: number) => PAD_T + ((maxH - v) / range) * (H - PAD_T - PAD_B);
  const barW = Math.max(2, (W - PAD_L - PAD_R) / visibleBars.length - 1);
  const barX = (i: number) => PAD_L + i * ((W - PAD_L - PAD_R) / visibleBars.length) + barW / 4;

  // Volume
  const maxVol = Math.max(...visibleBars.map(b => b.v));
  const volH = 50;

  // Price levels
  const priceLevels = 6;
  const levels = Array.from({ length: priceLevels + 1 }, (_, i) =>
    minL + (range * i) / priceLevels
  );

  return (
    <svg width="100%" viewBox={`0 0 ${W} ${H + volH}`} className="w-full" preserveAspectRatio="none">
      {/* Grid */}
      {levels.map((lv, i) => (
        <g key={i}>
          <line x1={PAD_L} x2={W - PAD_R} y1={toY(lv)} y2={toY(lv)}
            stroke="rgba(255,255,255,0.05)" strokeWidth="1" />
          <text x={W - PAD_R + 4} y={toY(lv) + 4} fill="rgba(255,255,255,0.35)"
            fontSize="9" textAnchor="start">{lv.toFixed(pp)}</text>
        </g>
      ))}

      {/* Candles */}
      {visibleBars.map((b, i) => {
        const isUp = b.c >= b.o;
        const color = isUp ? "#22c55e" : "#ef4444";
        const x = barX(i);
        const cO = toY(b.o), cC = toY(b.c), cH = toY(b.h), cL = toY(b.l);
        const bodyTop = Math.min(cO, cC);
        const bodyH = Math.max(Math.abs(cO - cC), 1);
        return (
          <g key={i}>
            <line x1={x + barW / 2} x2={x + barW / 2} y1={cH} y2={cL}
              stroke={color} strokeWidth="1" />
            <rect x={x} y={bodyTop} width={barW} height={bodyH} fill={color} rx="0.5" />
          </g>
        );
      })}

      {/* Current price line */}
      {visibleBars.length > 0 && (() => {
        const last = visibleBars[visibleBars.length - 1];
        const y = toY(last.c);
        const isUp = last.c >= last.o;
        return (
          <g>
            <line x1={PAD_L} x2={W - PAD_R} y1={y} y2={y}
              stroke={isUp ? "#22c55e" : "#ef4444"} strokeWidth="1" strokeDasharray="4 3" opacity="0.7" />
            <rect x={W - PAD_R + 2} y={y - 8} width={52} height={16}
              fill={isUp ? "#22c55e" : "#ef4444"} rx="2" />
            <text x={W - PAD_R + 28} y={y + 4} fill="white" fontSize="9"
              textAnchor="middle" fontWeight="bold">{last.c.toFixed(pp)}</text>
          </g>
        );
      })()}

      {/* Volume bars */}
      {visibleBars.map((b, i) => {
        const isUp = b.c >= b.o;
        const vH = (b.v / maxVol) * volH * 0.9;
        const x = barX(i);
        return (
          <rect key={i} x={x} y={H + volH - vH} width={barW} height={vH}
            fill={isUp ? "rgba(34,197,94,0.3)" : "rgba(239,68,68,0.3)"} rx="0.5" />
        );
      })}

      {/* Time labels */}
      {visibleBars.filter((_, i) => i % Math.floor(visibleBars.length / 6) === 0).map((b, i) => (
        <text key={i} x={barX(i * Math.floor(visibleBars.length / 6))}
          y={H + volH - 2} fill="rgba(255,255,255,0.3)" fontSize="8">{fmtTime(b.t)}</text>
      ))}
    </svg>
  );
}

// ─── MT5 Connect Modal ────────────────────────────────────────────────────────
const KNOWN_MT5_SERVERS = [
  "ICMarkets-Demo", "ICMarkets-Live01", "Pepperstone-MT5", "Pepperstone-Demo",
  "XM.COM-Demo", "XM.COM-Real", "Exness-MT5Trial", "Exness-MT5Real",
  "FXTM-MT5", "FXTM-Demo", "Alpari-MT5Demo", "Alpari-MT5Real",
  "FusionMarkets-MT5Demo", "FusionMarkets-MT5", "Admiral-MT5Demo",
  "ZerodhaFX-Demo", "AngelOne-MT5Demo", "AngelOne-MT5Live",
  "Zebvix-MT5Demo", "Zebvix-MT5Live",
];

function MT5ConnectModal({ onClose, onConnected }: {
  onClose: () => void;
  onConnected: (acct: MT5Account) => void;
}) {
  const { toast } = useToast();
  const qc = useQueryClient();
  const [server, setServer] = useState("");
  const [login, setLogin] = useState("");
  const [password, setPassword] = useState("");
  const [showPw, setShowPw] = useState(false);
  const [connType, setConnType] = useState<"investor" | "master">("investor");
  const [serverSuggest, setServerSuggest] = useState(false);

  const connectMutation = useMutation({
    mutationFn: async () => {
      const r = await fetch("/api/mt5/connect", {
        method: "POST",
        credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ server, login, password, connectionType: connType }),
      });
      const data = await r.json();
      if (!r.ok) throw new Error(data.error ?? "Connection failed");
      return data;
    },
    onSuccess: (data) => {
      toast({ title: "MT5 Connected", description: `${data.account.server} · ${data.account.login} (${data.account.isDemo ? "Demo" : "Live"})` });
      qc.invalidateQueries({ queryKey: ["mt5-accounts"] });
      onConnected(data.account);
      onClose();
    },
    onError: (e: Error) => toast({ title: "MT5 Connection Failed", description: e.message, variant: "destructive" }),
  });

  const filtered = KNOWN_MT5_SERVERS.filter(s => s.toLowerCase().includes(server.toLowerCase()) && server.length > 0);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/70 backdrop-blur-sm" onClick={onClose}>
      <div className="bg-[#111827] border border-white/12 rounded-2xl w-[440px] shadow-2xl" onClick={e => e.stopPropagation()}>
        {/* Header */}
        <div className="flex items-center justify-between px-6 py-4 border-b border-white/8">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-blue-500/15 flex items-center justify-center">
              <Terminal size={16} className="text-blue-400" />
            </div>
            <div>
              <div className="font-semibold text-sm">Connect MetaTrader 5</div>
              <div className="text-[10px] text-white/30">Live & demo accounts supported</div>
            </div>
          </div>
          <button onClick={onClose} className="text-white/30 hover:text-white transition-colors">
            <X size={18} />
          </button>
        </div>

        <div className="p-6 space-y-4">
          {/* Info banner */}
          <div className="bg-blue-500/8 border border-blue-500/20 rounded-xl p-3 flex gap-2.5 text-xs">
            <Info size={13} className="text-blue-400 flex-shrink-0 mt-0.5" />
            <div className="text-white/50 leading-relaxed">
              Enter your MT5 broker server, account login, and <span className="text-blue-300">investor (read-only)</span> or master password.
              Your credentials are encrypted with bcrypt — never stored in plaintext.
            </div>
          </div>

          {/* Connection type */}
          <div>
            <div className="text-[10px] text-white/35 mb-1.5 font-medium">Connection Type</div>
            <div className="flex gap-1.5">
              {(["investor", "master"] as const).map(t => (
                <button key={t} onClick={() => setConnType(t)}
                  className={cn("flex-1 py-2 rounded-lg text-xs font-semibold capitalize transition-all border",
                    connType === t
                      ? "bg-blue-500/20 border-blue-500/40 text-blue-300"
                      : "border-white/8 text-white/30 hover:text-white/50")}>
                  {t === "investor" ? "🔍 Investor (Read-only)" : "⚡ Master (Full access)"}
                </button>
              ))}
            </div>
            {connType === "master" && (
              <div className="mt-1.5 text-[10px] text-amber-400/70 flex items-center gap-1">
                <AlertTriangle size={10} /> Master password gives full trade access. Use with caution.
              </div>
            )}
          </div>

          {/* Server */}
          <div className="relative">
            <div className="text-[10px] text-white/35 mb-1 font-medium">Broker Server</div>
            <input value={server} onChange={e => { setServer(e.target.value); setServerSuggest(true); }}
              onBlur={() => setTimeout(() => setServerSuggest(false), 200)}
              placeholder="e.g. ICMarkets-Demo, Pepperstone-MT5"
              className="w-full bg-white/5 border border-white/10 px-3 h-10 text-sm rounded-xl text-white placeholder-white/20 focus:border-blue-500/50 focus:outline-none" />
            {serverSuggest && filtered.length > 0 && (
              <div className="absolute top-full mt-1 left-0 right-0 bg-[#1a2035] border border-white/12 rounded-xl overflow-hidden z-10 shadow-xl">
                {filtered.slice(0, 6).map(s => (
                  <button key={s} onClick={() => { setServer(s); setServerSuggest(false); }}
                    className="w-full text-left px-3 py-2 text-xs hover:bg-white/8 transition-colors text-white/70 flex items-center gap-2">
                    <Terminal size={10} className="text-blue-400" />
                    {s}
                    {s.toLowerCase().includes("demo") && <span className="ml-auto text-[9px] bg-amber-500/15 text-amber-400 px-1.5 py-0.5 rounded">DEMO</span>}
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Login */}
          <div>
            <div className="text-[10px] text-white/35 mb-1 font-medium">Account Login (Number)</div>
            <input value={login} onChange={e => setLogin(e.target.value)}
              placeholder="e.g. 12345678"
              className="w-full bg-white/5 border border-white/10 px-3 h-10 text-sm rounded-xl text-white placeholder-white/20 focus:border-blue-500/50 focus:outline-none font-mono" />
          </div>

          {/* Password */}
          <div>
            <div className="text-[10px] text-white/35 mb-1 font-medium">Password</div>
            <div className="relative">
              <input type={showPw ? "text" : "password"} value={password} onChange={e => setPassword(e.target.value)}
                placeholder="Investor or master password"
                className="w-full bg-white/5 border border-white/10 px-3 pr-10 h-10 text-sm rounded-xl text-white placeholder-white/20 focus:border-blue-500/50 focus:outline-none" />
              <button onClick={() => setShowPw(s => !s)}
                className="absolute right-3 top-1/2 -translate-y-1/2 text-white/25 hover:text-white/60">
                {showPw ? <EyeOff size={14} /> : <Eye size={14} />}
              </button>
            </div>
          </div>

          {/* Connect button */}
          <button onClick={() => connectMutation.mutate()}
            disabled={!server || !login || !password || connectMutation.isPending}
            className="w-full py-3 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm transition-colors disabled:opacity-40 flex items-center justify-center gap-2">
            {connectMutation.isPending ? (
              <>
                <RefreshCw size={14} className="animate-spin" /> Connecting...
              </>
            ) : (
              <>
                <PlugZap size={14} /> Connect MT5 Account
              </>
            )}
          </button>

          <div className="text-[10px] text-white/20 text-center leading-relaxed">
            Demo accounts: Use server names containing "Demo" or "Trial" · 
            Supports all MT5 brokers with WebAPI/HTTP bridge
          </div>
        </div>
      </div>
    </div>
  );
}

// ─── MT5 Account Card ─────────────────────────────────────────────────────────
function MT5AccountCard({ account, onDisconnect }: { account: MT5Account; onDisconnect: () => void }) {
  const isConnected = account.status === "connected";
  const balance = parseFloat(account.balance ?? "0");
  const equity = parseFloat(account.equity ?? "0");
  const freeMargin = parseFloat(account.freeMargin ?? "0");
  const marginPct = account.equity && account.margin
    ? (parseFloat(account.margin) / parseFloat(account.equity)) * 100 : 0;

  return (
    <div className={cn("rounded-xl border p-3 text-xs",
      isConnected
        ? account.isDemo ? "bg-amber-500/6 border-amber-500/20" : "bg-blue-500/6 border-blue-500/20"
        : "bg-white/3 border-white/8")}>
      <div className="flex items-center justify-between mb-2">
        <div className="flex items-center gap-1.5">
          <Terminal size={10} className={isConnected ? (account.isDemo ? "text-amber-400" : "text-blue-400") : "text-white/20"} />
          <span className={cn("font-semibold text-[11px]", isConnected ? "text-white" : "text-white/30")}>
            MT5 · {account.login}
          </span>
          <span className={cn("px-1 py-0.5 rounded text-[9px] font-bold",
            !isConnected ? "bg-white/5 text-white/20" :
            account.isDemo ? "bg-amber-500/15 text-amber-400" : "bg-blue-500/15 text-blue-300")}>
            {!isConnected ? "OFF" : account.isDemo ? "DEMO" : "LIVE"}
          </span>
        </div>
        <button onClick={onDisconnect}
          className="text-[10px] text-white/20 hover:text-red-400 transition-colors flex items-center gap-1">
          <X size={9} /> Disconnect
        </button>
      </div>

      {isConnected && (
        <>
          <div className="text-[10px] text-white/25 mb-1.5 truncate">{account.server}</div>
          <div className="grid grid-cols-3 gap-1.5 mb-2">
            {[
              ["Balance", balance.toFixed(2)],
              ["Equity", equity.toFixed(2)],
              ["Free", freeMargin.toFixed(2)],
            ].map(([k, v]) => (
              <div key={k} className="bg-white/5 rounded-lg p-1.5 text-center">
                <div className="text-white/25 text-[9px]">{k}</div>
                <div className="font-mono font-semibold mt-0.5 text-[10px]">{v}</div>
              </div>
            ))}
          </div>
          <div className="flex justify-between text-[9px] text-white/25 mb-1">
            <span>Margin used</span>
            <span>{marginPct.toFixed(1)}% · {account.leverage}× leverage</span>
          </div>
          <div className="w-full bg-white/8 rounded-full h-1">
            <div className={cn("h-1 rounded-full transition-all",
              marginPct > 80 ? "bg-red-500" : marginPct > 50 ? "bg-amber-500" : "bg-blue-500")}
              style={{ width: `${Math.min(marginPct, 100)}%` }} />
          </div>
        </>
      )}
    </div>
  );
}

// ─── Session Clock ────────────────────────────────────────────────────────────
function SessionBadges() {
  const [hour] = useState(() => new Date().getUTCHours());
  return (
    <div className="flex items-center gap-2">
      {FOREX_SESSIONS.map(s => {
        const active = s.open < s.close
          ? hour >= s.open && hour < s.close
          : hour >= s.open || hour < s.close;
        return (
          <div key={s.name} className={cn(
            "flex items-center gap-1 text-[10px] px-2 py-0.5 rounded-full border",
            active ? `${s.color} border-current bg-current/10` : "text-white/20 border-white/10",
          )}>
            <span className={cn("w-1.5 h-1.5 rounded-full", active ? "bg-current animate-pulse" : "bg-white/20")} />
            {s.name}
          </div>
        );
      })}
    </div>
  );
}

// ─── OrderBook (simulated) ───────────────────────────────────────────────────
function OrderBook({ ltp, pp }: { ltp: number; pp: number }) {
  const spread = ltp * 0.00025;
  const bid = ltp - spread / 2;
  const ask = ltp + spread / 2;

  const levels = Array.from({ length: 8 }, (_, i) => ({
    bidPrice: bid - i * ltp * 0.0001,
    bidQty: +(Math.random() * 4 + 0.5).toFixed(2),
    askPrice: ask + i * ltp * 0.0001,
    askQty: +(Math.random() * 4 + 0.5).toFixed(2),
  }));

  const maxQty = Math.max(...levels.map(l => Math.max(l.bidQty, l.askQty)));

  return (
    <div className="h-full overflow-hidden">
      <div className="grid grid-cols-3 text-[10px] text-white/40 px-2 py-1 border-b border-white/5">
        <span>Size</span><span className="text-center">Price</span><span className="text-right">Size</span>
      </div>
      {levels.map((l, i) => (
        <div key={i} className="grid grid-cols-3 text-[11px] px-2 py-0.5 relative hover:bg-white/5">
          <div className="relative z-10 text-emerald-400 tabular-nums">{l.bidQty.toFixed(2)}</div>
          <div className="relative z-10 text-center">
            <span className="text-emerald-400">{l.bidPrice.toFixed(pp)}</span>
            <span className="text-white/20 mx-1">|</span>
            <span className="text-red-400">{l.askPrice.toFixed(pp)}</span>
          </div>
          <div className="relative z-10 text-right text-red-400 tabular-nums">{l.askQty.toFixed(2)}</div>
          <div className="absolute inset-y-0 left-0 bg-emerald-500/10 rounded-sm"
            style={{ width: `${(l.bidQty / maxQty) * 40}%` }} />
          <div className="absolute inset-y-0 right-0 bg-red-500/10 rounded-sm"
            style={{ width: `${(l.askQty / maxQty) * 40}%` }} />
        </div>
      ))}
      <div className="border-t border-white/10 mt-1 px-2 py-1.5 flex justify-between text-xs">
        <div className="text-emerald-400 font-bold">{bid.toFixed(pp)}</div>
        <div className="text-white/40 text-[10px]">Spread: {(spread * Math.pow(10, pp)).toFixed(1)} pips</div>
        <div className="text-red-400 font-bold">{ask.toFixed(pp)}</div>
      </div>
    </div>
  );
}

// ─── Analysis Panel ──────────────────────────────────────────────────────────
function AnalysisPanel({ inst, ltp }: { inst: Instrument | null; ltp: number }) {
  if (!inst) return <div className="p-4 text-white/30 text-sm text-center">Select a pair</div>;
  const prev = Number(inst.previousClose) || ltp;
  const chg = prev ? ((ltp - prev) / prev) * 100 : 0;
  const high = Number(inst.high24h) || ltp * 1.005;
  const low = Number(inst.low24h) || ltp * 0.995;
  const r1 = high + (high - low) * 0.382;
  const s1 = low - (high - low) * 0.382;
  const pivot = (high + low + ltp) / 3;

  const sentiment = chg >= 0 ? "Bullish" : "Bearish";
  const rsi = 40 + Math.random() * 30;
  const macdSignal = Math.random() > 0.5 ? "Buy" : "Sell";
  const maValue = ltp * (1 + (Math.random() - 0.5) * 0.002);

  return (
    <div className="p-4 space-y-4 overflow-auto h-full">
      <div className="grid grid-cols-2 gap-3">
        <div className="bg-white/5 rounded-lg p-3">
          <div className="text-[10px] text-white/40 mb-1">Overall Sentiment</div>
          <div className={cn("font-bold text-sm flex items-center gap-1.5",
            chg >= 0 ? "text-emerald-400" : "text-red-400")}>
            {chg >= 0 ? <TrendingUp size={14} /> : <TrendingDown size={14} />}
            {sentiment}
          </div>
          <div className="text-[10px] text-white/40 mt-1">{chg.toFixed(3)}% today</div>
        </div>
        <div className="bg-white/5 rounded-lg p-3">
          <div className="text-[10px] text-white/40 mb-1">RSI (14)</div>
          <div className={cn("font-bold text-sm", rsi > 70 ? "text-red-400" : rsi < 30 ? "text-emerald-400" : "text-white")}>
            {rsi.toFixed(1)}
          </div>
          <div className="text-[10px] text-white/40 mt-1">
            {rsi > 70 ? "Overbought" : rsi < 30 ? "Oversold" : "Neutral"}
          </div>
          <div className="w-full bg-white/10 rounded-full h-1 mt-1.5">
            <div className={cn("h-1 rounded-full", rsi > 70 ? "bg-red-400" : rsi < 30 ? "bg-emerald-400" : "bg-amber-400")}
              style={{ width: `${rsi}%` }} />
          </div>
        </div>
      </div>

      <div className="bg-white/5 rounded-lg p-3">
        <div className="text-[10px] text-white/40 mb-2">Pivot Points (Classic)</div>
        <div className="space-y-1.5 text-xs">
          {[
            ["R2", (r1 + (pivot - s1)).toFixed(inst.pricePrecision), "text-red-300"],
            ["R1", r1.toFixed(inst.pricePrecision), "text-red-400"],
            ["Pivot", pivot.toFixed(inst.pricePrecision), "text-amber-400 font-bold"],
            ["S1", s1.toFixed(inst.pricePrecision), "text-emerald-400"],
            ["S2", (s1 - (pivot - s1)).toFixed(inst.pricePrecision), "text-emerald-300"],
          ].map(([label, val, cls]) => (
            <div key={label} className="flex justify-between items-center">
              <span className="text-white/40">{label}</span>
              <span className={cn("tabular-nums font-mono", cls)}>{val}</span>
            </div>
          ))}
        </div>
      </div>

      <div className="bg-white/5 rounded-lg p-3 space-y-2">
        <div className="text-[10px] text-white/40 mb-1">Technical Indicators</div>
        {[
          { name: "MACD (12,26,9)", signal: macdSignal, color: macdSignal === "Buy" ? "text-emerald-400" : "text-red-400" },
          { name: "MA (50)", signal: ltp > maValue ? "Buy" : "Sell", color: ltp > maValue ? "text-emerald-400" : "text-red-400" },
          { name: "Bollinger Bands", signal: rsi > 60 ? "Upper Band" : rsi < 40 ? "Lower Band" : "Middle", color: "text-white/60" },
          { name: "Stochastic (14,3)", signal: rsi > 65 ? "Overbought" : rsi < 35 ? "Oversold" : "Neutral", color: "text-white/60" },
        ].map(ind => (
          <div key={ind.name} className="flex justify-between text-xs">
            <span className="text-white/40">{ind.name}</span>
            <span className={ind.color}>{ind.signal}</span>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-2 gap-2 text-xs">
        {[
          ["Swap Long", `${(ltp * -0.00003).toFixed(5)}`],
          ["Swap Short", `${(ltp * 0.00001).toFixed(5)}`],
          ["Tick Value", `${(ltp * 0.00001 * 1000).toFixed(2)} ${inst.quoteCurrency}`],
          ["Lot Size", inst.lotSize],
        ].map(([k, v]) => (
          <div key={k} className="bg-white/5 rounded p-2">
            <div className="text-white/30">{k}</div>
            <div className="font-mono mt-0.5">{v}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

// ─── Main Forex Terminal ──────────────────────────────────────────────────────
export default function Forex() {
  const { user } = useAuth();
  const { toast } = useToast();
  const qc = useQueryClient();

  // UI state
  const [selectedSymbol, setSelectedSymbol] = useState<string | null>(null);
  const [category, setCategory] = useState("Major");
  const [search, setSearch] = useState("");
  const [favorites, setFavorites] = useState<Set<string>>(new Set());
  const [tf, setTf] = useState<TF>("H1");
  const [centerTab, setCenterTab] = useState<"chart" | "depth" | "analysis">("chart");
  const [bottomTab, setBottomTab] = useState<"positions" | "history" | "mt5">("positions");

  // Order state
  const [side, setSide] = useState<"buy" | "sell">("buy");
  const [orderType, setOrderType] = useState<"MARKET" | "LIMIT" | "STOP">("MARKET");
  const [qty, setQty] = useState("0.01");
  const [limitPrice, setLimitPrice] = useState("");
  const [stopLoss, setStopLoss] = useState("");
  const [takeProfit, setTakeProfit] = useState("");
  const [slMode, setSlMode] = useState<"pips" | "price">("pips");
  const [showCalc, setShowCalc] = useState(false);
  const [oneClick, setOneClick] = useState(false);

  // MT5 state
  const [showMt5Modal, setShowMt5Modal] = useState(false);
  const [activeMt5, setActiveMt5] = useState<MT5Account | null>(null);

  // Data queries
  const { data: instrData, isLoading } = useQuery({
    queryKey: ["instruments", "forex"],
    queryFn: () => get<{ instruments: Instrument[] }>("/instruments?assetClass=forex"),
    refetchInterval: 15000,
  });

  const { data: posData, refetch: refetchPos } = useQuery({
    queryKey: ["instrument-positions"],
    queryFn: () => get<{ positions: Position[] }>("/instruments/positions"),
    enabled: !!user,
    refetchInterval: 5000,
  });

  const { data: orderData } = useQuery({
    queryKey: ["instrument-orders"],
    queryFn: () => get<{ orders: OrderRow[] }>("/instruments/orders"),
    enabled: !!user && bottomTab === "history",
  });

  const { data: quoteData, refetch: refetchQuote } = useQuery({
    queryKey: ["instrument-quote", selectedSymbol],
    queryFn: () => get<{ quote: { ltp: number; open: number; high: number; low: number; changePct: number; volume: number } }>(`/instruments/${selectedSymbol}/quote`),
    enabled: !!selectedSymbol,
    refetchInterval: 3000,
  });

  const { data: brokerData } = useQuery({
    queryKey: ["broker-account"],
    queryFn: async () => {
      const r = await fetch("/api/broker/account", { credentials: "include" });
      if (!r.ok) return null;
      return r.json();
    },
    enabled: !!user,
    staleTime: 60_000,
  });

  const { data: mt5Data, refetch: refetchMt5 } = useQuery({
    queryKey: ["mt5-accounts"],
    queryFn: async () => {
      const r = await fetch("/api/mt5/account", { credentials: "include" });
      if (!r.ok) return null;
      return r.json();
    },
    enabled: !!user,
    staleTime: 30_000,
  });

  // Use first connected MT5 account, else activeMt5 from state
  const mt5Accounts: MT5Account[] = mt5Data?.accounts ?? [];
  const connectedMt5 = activeMt5 ?? mt5Accounts.find(a => a.status === "connected") ?? null;

  const mt5DisconnectMutation = useMutation({
    mutationFn: async (id: number) => {
      const r = await fetch("/api/mt5/disconnect", {
        method: "POST", credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ id }),
      });
      if (!r.ok) throw new Error("Disconnect failed");
      return r.json();
    },
    onSuccess: () => {
      toast({ title: "MT5 Disconnected" });
      setActiveMt5(null);
      qc.invalidateQueries({ queryKey: ["mt5-accounts"] });
    },
  });

  const mt5PlaceMutation = useMutation({
    mutationFn: async (body: object) => {
      const r = await fetch("/api/mt5/orders", {
        method: "POST", credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body),
      });
      const data = await r.json();
      if (!r.ok) throw new Error(data.error ?? "Order failed");
      return data;
    },
    onSuccess: (data) => {
      toast({ title: "MT5 Order Placed", description: `Ticket: ${data.ticket}` });
    },
    onError: (e: Error) => toast({ title: "MT5 Order Failed", description: e.message, variant: "destructive" }),
  });

  const instruments = instrData?.instruments ?? [];
  const positions = posData?.positions?.filter(p => p.assetClass === "forex") ?? [];
  const orders = orderData?.orders?.filter(o => o.assetClass === "forex") ?? [];
  const brokerAccount = brokerData?.account;
  const brokerActive = brokerAccount?.status === "active" && !!brokerAccount?.angelClientId;
  const brokerSimulated = brokerActive && brokerAccount?.jwtToken?.startsWith("sim.");

  const selected = instruments.find(i => i.symbol === selectedSymbol) ?? null;
  const quote = quoteData?.quote ?? null;
  const ltp = quote?.ltp ?? (selected ? Number(selected.currentPrice) : 0);
  const changePct = quote?.changePct ?? (selected ? Number(selected.change24h) : 0);
  const pp = selected?.pricePrecision ?? 5;

  // Bid / Ask
  const spread = ltp * 0.00025;
  const bid = ltp - spread / 2;
  const ask = ltp + spread / 2;
  const spreadPips = spread * Math.pow(10, pp);

  // OHLC chart data
  const tfMs = TF_OPTIONS.find(t => t.label === tf)?.ms ?? 3_600_000;
  const chartBars = useMemo(() => {
    if (!ltp) return [];
    return genOHLC(ltp, 100, tfMs);
  }, [selectedSymbol, tf, ltp ? Math.floor(ltp * 1000) : 0]);

  // Pip value (per lot)
  const pipValue = ltp ? (Math.pow(10, -pp) * Number(selected?.lotSize ?? 1000)) : 0;
  const lots = parseFloat(qty) || 0;
  const notional = lots * Number(selected?.lotSize ?? 1000) * ltp;
  const margin = notional ? notional * Number(selected?.marginRequired ?? 0.02) : 0;
  const pipValueLots = pipValue * lots;

  // SL/TP calculations
  const slPrice = stopLoss ? (slMode === "pips"
    ? (side === "buy" ? ltp - parseFloat(stopLoss) * Math.pow(10, -pp) : ltp + parseFloat(stopLoss) * Math.pow(10, -pp))
    : parseFloat(stopLoss)) : null;
  const tpPrice = takeProfit ? (slMode === "pips"
    ? (side === "buy" ? ltp + parseFloat(takeProfit) * Math.pow(10, -pp) : ltp - parseFloat(takeProfit) * Math.pow(10, -pp))
    : parseFloat(takeProfit)) : null;
  const slPnl = slPrice && pipValueLots ? Math.abs(slPrice - ltp) * Math.pow(10, pp) * pipValueLots : null;
  const tpPnl = tpPrice && pipValueLots ? Math.abs(tpPrice - ltp) * Math.pow(10, pp) * pipValueLots : null;

  // Categories
  const CATEGORIES = ["Major", "Minor", "INR", "Exotic", "All", "★"];
  const majorPairs = new Set(["EURUSD","GBPUSD","USDJPY","USDCHF","AUDUSD","NZDUSD","USDCAD"]);
  const filtered = instruments.filter(i => {
    if (search) return i.symbol.includes(search.toUpperCase()) || i.name.toUpperCase().includes(search.toUpperCase());
    if (category === "★") return favorites.has(i.symbol);
    if (category === "Major") return majorPairs.has(i.symbol);
    if (category === "INR") return i.quoteCurrency === "INR" || i.symbol.includes("INR");
    if (category === "Minor") return !majorPairs.has(i.symbol) && !i.symbol.includes("INR") && !i.symbol.includes("JPY");
    if (category === "Exotic") return i.symbol.includes("JPY") || i.symbol.includes("CHF") || i.symbol.includes("NOK");
    return true;
  });

  useEffect(() => {
    if (!selectedSymbol && instruments.length > 0) setSelectedSymbol(instruments[0].symbol);
  }, [instruments]);

  const placeMutation = useMutation({
    mutationFn: (body: object) => post("/instruments/orders", body),
    onSuccess: () => {
      toast({ title: `Order placed`, description: `${side.toUpperCase()} ${qty} lots ${selectedSymbol}` });
      if (!oneClick) { setQty("0.01"); setLimitPrice(""); }
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
  });

  const handlePlace = (forceSide?: "buy" | "sell") => {
    const activeSide = forceSide ?? side;
    if (!selectedSymbol || !qty) return;

    // If MT5 connected → route through MT5
    if (connectedMt5) {
      mt5PlaceMutation.mutate({
        mt5AccountId: connectedMt5.id,
        symbol: selectedSymbol,
        side: activeSide,
        orderType: orderType.toLowerCase(),
        volume: Number(qty),
        ...(slPrice ? { stopLoss: slPrice } : {}),
        ...(tpPrice ? { takeProfit: tpPrice } : {}),
        comment: `Zebvix Forex ${activeSide.toUpperCase()}`,
      });
      return;
    }

    // Default: platform instruments order
    placeMutation.mutate({
      symbol: selectedSymbol, side: activeSide, qty: Number(qty),
      type: orderType,
      ...(orderType !== "MARKET" && limitPrice ? { price: Number(limitPrice) } : {}),
      leverage: 10,
    });
  };

  // total unrealized PnL
  const totalUnrealizedPnl = positions.reduce((sum, p) => sum + Number(p.unrealizedPnl ?? 0), 0);

  const toggleFav = (sym: string) => {
    setFavorites(f => {
      const n = new Set(f);
      n.has(sym) ? n.delete(sym) : n.add(sym);
      return n;
    });
  };

  return (
    <div className="min-h-screen bg-[#0b0e17] text-white flex flex-col overflow-hidden" style={{ height: "100vh" }}>

      {/* ── Top Header ─────────────────────────────────────────────────────── */}
      <div className="border-b border-white/8 bg-[#0c0f1a] px-4 py-2 flex items-center gap-4 flex-shrink-0">
        <div className="flex items-center gap-2">
          <Globe className="w-4 h-4 text-amber-400" />
          <span className="font-bold text-sm tracking-tight">Forex CFD</span>
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
          <span className="text-[10px] text-white/40">Live</span>
        </div>

        {/* Selected pair ticker */}
        {selected && ltp > 0 && (
          <div className="flex items-center gap-4 pl-3 border-l border-white/10">
            <div className="flex items-center gap-2">
              <span className="text-sm font-bold">{selected.symbol}</span>
              <span className={cn("text-lg font-bold tabular-nums",
                changePct >= 0 ? "text-emerald-400" : "text-red-400")}>
                {p(ltp, pp)}
              </span>
              <span className={cn("text-xs", changePct >= 0 ? "text-emerald-400" : "text-red-400")}>
                {pct(changePct)}
              </span>
            </div>
            <div className="flex items-center gap-3 text-[11px] text-white/40">
              <span>Bid: <span className="text-emerald-400 font-mono">{p(bid, pp)}</span></span>
              <span>Ask: <span className="text-red-400 font-mono">{p(ask, pp)}</span></span>
              <span>Spread: <span className="text-amber-400">{spreadPips.toFixed(1)} pips</span></span>
              <span>H: <span className="text-white">{quote?.high ? p(quote.high, pp) : "—"}</span></span>
              <span>L: <span className="text-white">{quote?.low ? p(quote.low, pp) : "—"}</span></span>
            </div>
          </div>
        )}

        <div className="ml-auto flex items-center gap-2">
          <SessionBadges />

          {/* Angel One badge */}
          {brokerActive && (
            <div className={cn("flex items-center gap-1.5 text-[10px] px-2 py-1 rounded-full border",
              brokerSimulated ? "text-yellow-400 border-yellow-500/30 bg-yellow-500/10"
                : "text-emerald-400 border-emerald-500/30 bg-emerald-500/10")}>
              {brokerSimulated ? <WifiOff size={10} /> : <Wifi size={10} />}
              AO {brokerSimulated ? "Sim" : "Live"} · {brokerAccount.angelClientId}
            </div>
          )}

          {/* MT5 badge */}
          {connectedMt5 ? (
            <div className={cn("flex items-center gap-1.5 text-[10px] px-2 py-1 rounded-full border cursor-pointer hover:opacity-80",
              connectedMt5.isDemo ? "text-amber-400 border-amber-500/30 bg-amber-500/10"
                : "text-blue-400 border-blue-500/30 bg-blue-500/10")}
              onClick={() => setBottomTab("mt5")}>
              <Terminal size={10} />
              MT5 {connectedMt5.isDemo ? "Demo" : "Live"} · {connectedMt5.login}
            </div>
          ) : user && (
            <button onClick={() => setShowMt5Modal(true)}
              className="flex items-center gap-1 text-[10px] px-2 py-1 rounded-full border border-white/15 text-white/30 hover:text-white/60 hover:border-white/30 transition-colors">
              <PlugZap size={10} /> MT5
            </button>
          )}

          <button onClick={() => refetchQuote()} className="text-white/30 hover:text-white transition-colors">
            <RefreshCw className="w-3.5 h-3.5" />
          </button>
        </div>
      </div>

      {/* ── Main 3-column layout ───────────────────────────────────────────── */}
      <div className="flex flex-1 overflow-hidden">

        {/* ── LEFT: Watchlist ─────────────────────────────────────────────── */}
        <div className="w-56 border-r border-white/8 flex flex-col bg-[#0c0f1a] flex-shrink-0">
          {/* Search */}
          <div className="p-2 border-b border-white/8">
            <input
              value={search} onChange={e => setSearch(e.target.value)}
              placeholder="Search pairs..."
              className="w-full bg-white/5 text-xs px-2.5 py-1.5 rounded-md text-white placeholder-white/25 border border-white/10 focus:border-amber-500/40 focus:outline-none"
            />
          </div>

          {/* Category tabs */}
          <div className="flex flex-wrap gap-0.5 p-1.5 border-b border-white/8">
            {CATEGORIES.map(cat => (
              <button key={cat} onClick={() => { setCategory(cat); setSearch(""); }}
                className={cn("px-2 py-0.5 text-[10px] rounded transition-colors font-medium",
                  category === cat && !search ? "bg-amber-500/20 text-amber-400" : "text-white/30 hover:text-white/60")}>
                {cat}
              </button>
            ))}
          </div>

          {/* Instrument list */}
          <div className="flex-1 overflow-y-auto">
            {isLoading ? Array.from({ length: 8 }).map((_, i) => (
              <div key={i} className="px-3 py-2.5 border-b border-white/5 animate-pulse">
                <div className="h-3 bg-white/10 rounded w-16 mb-1" />
                <div className="h-2.5 bg-white/5 rounded w-12" />
              </div>
            )) : filtered.length === 0 ? (
              <div className="text-center py-8 text-white/20 text-xs">No pairs found</div>
            ) : filtered.map(inst => {
              const chg = Number(inst.change24h);
              const isUp = chg >= 0;
              const isActive = inst.symbol === selectedSymbol;
              const isFav = favorites.has(inst.symbol);
              const base = inst.symbol.slice(0, 3);
              const quote2 = inst.symbol.slice(3, 6);
              return (
                <div key={inst.symbol}
                  className={cn("flex items-center gap-1 px-2 py-2 border-b border-white/5 cursor-pointer hover:bg-white/4 transition-colors group",
                    isActive && "bg-amber-500/8 border-l-2 border-l-amber-500")}>
                  <button onClick={() => toggleFav(inst.symbol)}
                    className={cn("opacity-0 group-hover:opacity-100 transition-opacity flex-shrink-0",
                      isFav && "opacity-100")}>
                    {isFav ? <Star size={10} className="text-amber-400 fill-amber-400" /> : <StarOff size={10} className="text-white/30" />}
                  </button>
                  <button className="flex-1 text-left" onClick={() => setSelectedSymbol(inst.symbol)}>
                    <div className="flex items-center justify-between">
                      <div className="flex items-center gap-1">
                        <span className="text-[10px]">{PAIR_FLAGS[base] ?? "🏳️"}</span>
                        <span className="text-xs font-semibold">{inst.symbol}</span>
                      </div>
                      <span className={cn("text-[11px] font-medium tabular-nums",
                        isUp ? "text-emerald-400" : "text-red-400")}>
                        {pct(chg)}
                      </span>
                    </div>
                    <div className="flex justify-between mt-0.5">
                      <span className="text-[10px] text-white/30">{PAIR_FLAGS[quote2] ?? ""} {quote2}</span>
                      <span className="text-[11px] tabular-nums text-white/70 font-mono">
                        {Number(inst.currentPrice).toFixed(pp)}
                      </span>
                    </div>
                  </button>
                </div>
              );
            })}
          </div>

          {/* Account summary mini */}
          <div className="border-t border-white/8 p-2 space-y-1">
            <div className="text-[10px] text-white/30 mb-1.5">Open Positions ({positions.length})</div>
            {positions.length > 0 && (
              <div className={cn("text-xs font-bold",
                totalUnrealizedPnl >= 0 ? "text-emerald-400" : "text-red-400")}>
                {totalUnrealizedPnl >= 0 ? "+" : ""}{totalUnrealizedPnl.toFixed(2)} P&L
              </div>
            )}
            <div className="text-[10px] text-white/25 flex justify-between">
              <span>Margin used</span>
              <span>{positions.reduce((s, p) => s + Number(p.marginUsed), 0).toFixed(2)}</span>
            </div>
          </div>
        </div>

        {/* ── CENTER: Chart + Bottom positions ────────────────────────────── */}
        <div className="flex-1 flex flex-col overflow-hidden min-w-0">

          {/* Timeframe + tabs bar */}
          <div className="flex items-center gap-0 border-b border-white/8 bg-[#0c0f1a] px-3 flex-shrink-0">
            <div className="flex items-center gap-0 mr-4">
              {TF_OPTIONS.map(t => (
                <button key={t.label} onClick={() => setTf(t.label)}
                  className={cn("px-2.5 py-2 text-[11px] font-semibold transition-colors",
                    tf === t.label ? "text-amber-400 border-b-2 border-amber-400" : "text-white/30 hover:text-white/60")}>
                  {t.label}
                </button>
              ))}
            </div>
            <div className="h-4 w-px bg-white/10 mr-3" />
            {(["chart", "depth", "analysis"] as const).map(tab => (
              <button key={tab} onClick={() => setCenterTab(tab)}
                className={cn("px-3 py-2 text-[11px] capitalize transition-colors",
                  centerTab === tab ? "text-amber-400 border-b-2 border-amber-400" : "text-white/30 hover:text-white/60")}>
                {tab === "depth" ? "Order Book" : tab === "analysis" ? "Analysis" : "Chart"}
              </button>
            ))}
          </div>

          {/* Chart area */}
          <div className="flex-1 overflow-hidden relative bg-[#0b0e17]" style={{ minHeight: 0 }}>
            {centerTab === "chart" && (
              <div className="w-full h-full overflow-hidden">
                {ltp > 0 && selected ? (
                  <CandlestickChart bars={chartBars} symbol={selected.symbol} tf={tf} pp={pp} />
                ) : (
                  <div className="flex items-center justify-center h-full text-white/20 text-sm">
                    Select a pair to view chart
                  </div>
                )}
              </div>
            )}
            {centerTab === "depth" && ltp > 0 && selected && (
              <OrderBook ltp={ltp} pp={pp} />
            )}
            {centerTab === "analysis" && (
              <AnalysisPanel inst={selected} ltp={ltp} />
            )}
          </div>

          {/* ── Bottom: positions / history ─────────────────────────────── */}
          <div className="border-t border-white/8 bg-[#0c0f1a]" style={{ height: "200px" }}>
            <div className="flex items-center gap-0 border-b border-white/8 px-3">
              <button onClick={() => setBottomTab("positions")}
                className={cn("px-3 py-2 text-[11px] flex items-center gap-1.5 transition-colors",
                  bottomTab === "positions" ? "text-amber-400 border-b-2 border-amber-400" : "text-white/30 hover:text-white/60")}>
                Open Positions
                {positions.length > 0 && (
                  <span className="bg-amber-500/20 text-amber-400 text-[9px] px-1.5 py-0.5 rounded-full">{positions.length}</span>
                )}
              </button>
              <button onClick={() => setBottomTab("history")}
                className={cn("px-3 py-2 text-[11px] flex items-center gap-1.5 transition-colors",
                  bottomTab === "history" ? "text-amber-400 border-b-2 border-amber-400" : "text-white/30 hover:text-white/60")}>
                Order History
              </button>
              <button onClick={() => setBottomTab("mt5")}
                className={cn("px-3 py-2 text-[11px] flex items-center gap-1.5 transition-colors",
                  bottomTab === "mt5" ? "text-blue-400 border-b-2 border-blue-400" : "text-white/30 hover:text-white/60")}>
                <Terminal size={10} /> MT5
                {connectedMt5 && (
                  <span className={cn("text-[9px] px-1.5 py-0.5 rounded-full",
                    connectedMt5.isDemo ? "bg-amber-500/20 text-amber-400" : "bg-blue-500/20 text-blue-400")}>
                    {connectedMt5.isDemo ? "Demo" : "Live"}
                  </span>
                )}
              </button>
              {totalUnrealizedPnl !== 0 && (
                <div className={cn("ml-auto text-xs font-bold tabular-nums",
                  totalUnrealizedPnl >= 0 ? "text-emerald-400" : "text-red-400")}>
                  {totalUnrealizedPnl >= 0 ? "+" : ""}{totalUnrealizedPnl.toFixed(2)} Unrealized
                </div>
              )}
            </div>

            <div className="overflow-y-auto" style={{ height: "152px" }}>
              {bottomTab === "positions" && (
                !user ? (
                  <div className="text-center py-8 text-white/20 text-xs">Login to view positions</div>
                ) : positions.length === 0 ? (
                  <div className="text-center py-8 text-white/20 text-xs">No open forex positions</div>
                ) : (
                  <table className="w-full text-xs">
                    <thead>
                      <tr className="text-white/25 border-b border-white/5">
                        {["Symbol", "Side", "Lots", "Open Price", "Current", "P&L", "Margin", "Leverage", "Time", ""].map(h => (
                          <th key={h} className="px-3 py-1.5 text-left font-medium whitespace-nowrap">{h}</th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {positions.map(pos => {
                        const pnl = Number(pos.unrealizedPnl ?? 0);
                        const isProfit = pnl >= 0;
                        const pnlPips = pos.avgEntryPrice ? Math.abs(pos.currentPrice - pos.avgEntryPrice) * Math.pow(10, pp) : 0;
                        return (
                          <tr key={pos.id} className="border-b border-white/5 hover:bg-white/3">
                            <td className="px-3 py-1.5 font-semibold">{pos.symbol}</td>
                            <td className={cn("px-3 py-1.5 font-bold", pos.side === "buy" ? "text-emerald-400" : "text-red-400")}>
                              {pos.side === "buy" ? "▲ BUY" : "▼ SELL"}
                            </td>
                            <td className="px-3 py-1.5 tabular-nums">{pos.qty}</td>
                            <td className="px-3 py-1.5 tabular-nums font-mono">{pos.avgEntryPrice.toFixed(pp)}</td>
                            <td className="px-3 py-1.5 tabular-nums font-mono">{pos.currentPrice.toFixed(pp)}</td>
                            <td className={cn("px-3 py-1.5 font-bold tabular-nums", isProfit ? "text-emerald-400" : "text-red-400")}>
                              {isProfit ? "+" : ""}{pnl.toFixed(2)} {pos.quoteCurrency}
                              <span className="text-white/30 font-normal ml-1">({pnlPips.toFixed(1)} pips)</span>
                            </td>
                            <td className="px-3 py-1.5 tabular-nums text-white/50">{Number(pos.marginUsed).toFixed(2)}</td>
                            <td className="px-3 py-1.5 text-amber-400">{pos.leverage}×</td>
                            <td className="px-3 py-1.5 text-white/30 whitespace-nowrap">{new Date(pos.createdAt).toLocaleTimeString()}</td>
                            <td className="px-3 py-1.5">
                              <button onClick={() => closeMutation.mutate(pos.id)}
                                disabled={closeMutation.isPending}
                                className="px-2 py-0.5 text-[10px] text-red-400 border border-red-500/30 rounded hover:bg-red-500/10 transition-colors">
                                Close
                              </button>
                            </td>
                          </tr>
                        );
                      })}
                    </tbody>
                  </table>
                )
              )}

              {bottomTab === "history" && (
                !user ? (
                  <div className="text-center py-8 text-white/20 text-xs">Login to view orders</div>
                ) : orders.length === 0 ? (
                  <div className="text-center py-8 text-white/20 text-xs">No forex orders yet</div>
                ) : (
                  <table className="w-full text-xs">
                    <thead>
                      <tr className="text-white/25 border-b border-white/5">
                        {["Symbol", "Side", "Type", "Qty", "Fill Price", "Fee", "P&L", "Status", "Time"].map(h => (
                          <th key={h} className="px-3 py-1.5 text-left font-medium whitespace-nowrap">{h}</th>
                        ))}
                      </tr>
                    </thead>
                    <tbody>
                      {orders.map(o => (
                        <tr key={o.id} className="border-b border-white/5 hover:bg-white/3">
                          <td className="px-3 py-1.5 font-semibold">{o.symbol}</td>
                          <td className={cn("px-3 py-1.5 font-bold", o.side === "buy" ? "text-emerald-400" : "text-red-400")}>
                            {o.side.toUpperCase()}
                          </td>
                          <td className="px-3 py-1.5 text-white/40">{o.type}</td>
                          <td className="px-3 py-1.5 tabular-nums">{o.filledQty}/{o.qty}</td>
                          <td className="px-3 py-1.5 tabular-nums font-mono">{o.avgFillPrice ? Number(o.avgFillPrice).toFixed(pp) : "—"}</td>
                          <td className="px-3 py-1.5 tabular-nums text-white/40">{Number(o.fee).toFixed(4)}</td>
                          <td className={cn("px-3 py-1.5 tabular-nums font-bold",
                            Number(o.pnl) >= 0 ? "text-emerald-400" : "text-red-400")}>
                            {Number(o.pnl) !== 0 ? (Number(o.pnl) >= 0 ? "+" : "") + Number(o.pnl).toFixed(2) : "—"}
                          </td>
                          <td className="px-3 py-1.5">
                            <span className={cn("px-1.5 py-0.5 rounded text-[10px] font-semibold",
                              o.status === "filled" ? "bg-emerald-500/15 text-emerald-400" :
                              o.status === "rejected" ? "bg-red-500/15 text-red-400" :
                              "bg-amber-500/15 text-amber-400")}>
                              {o.status}
                            </span>
                          </td>
                          <td className="px-3 py-1.5 text-white/30 whitespace-nowrap">
                            {new Date(o.createdAt).toLocaleTimeString()}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                )
              )}

              {/* ── MT5 Tab ─────────────────────────────────────────────── */}
              {bottomTab === "mt5" && (
                !user ? (
                  <div className="text-center py-8 text-white/20 text-xs">Login to connect MT5</div>
                ) : (
                  <div className="p-3 space-y-2">
                    {/* Connected accounts */}
                    {mt5Accounts.length > 0 ? mt5Accounts.map(acct => (
                      <MT5AccountCard key={acct.id} account={acct}
                        onDisconnect={() => mt5DisconnectMutation.mutate(acct.id)} />
                    )) : (
                      <div className="text-center py-4 text-white/20 text-xs">No MT5 accounts connected</div>
                    )}

                    {/* Add new MT5 account */}
                    <button onClick={() => setShowMt5Modal(true)}
                      className="w-full flex items-center justify-center gap-2 py-2 rounded-xl border border-dashed border-blue-500/30 text-blue-400/70 hover:text-blue-400 hover:border-blue-500/50 text-xs transition-colors">
                      <PlugZap size={12} /> Connect another MT5 account
                    </button>

                    {/* Supported brokers */}
                    <div className="text-[10px] text-white/20 text-center pt-1">
                      Supports: IC Markets · Pepperstone · XM · Exness · FXTM · Alpari · Admiral · and more
                    </div>
                  </div>
                )
              )}
            </div>
          </div>
        </div>

        {/* ── RIGHT: Order panel ──────────────────────────────────────────── */}
        <div className="w-72 border-l border-white/8 bg-[#0c0f1a] flex flex-col flex-shrink-0 overflow-y-auto">

          {/* Pair header */}
          {selected && ltp > 0 && (
            <div className="px-4 pt-4 pb-3 border-b border-white/8">
              <div className="flex items-start justify-between">
                <div>
                  <div className="flex items-center gap-2">
                    <span className="text-sm font-bold">{selected.symbol}</span>
                    <span className={cn("text-[10px] px-1.5 py-0.5 rounded font-semibold",
                      changePct >= 0 ? "text-emerald-400 bg-emerald-500/10" : "text-red-400 bg-red-500/10")}>
                      {pct(changePct)}
                    </span>
                  </div>
                  <div className="text-[10px] text-white/30 mt-0.5">{selected.name}</div>
                </div>
                <button onClick={() => setShowCalc(s => !s)}
                  className={cn("p-1.5 rounded transition-colors", showCalc ? "bg-amber-500/20 text-amber-400" : "text-white/20 hover:text-white/50")}>
                  <Calculator size={13} />
                </button>
              </div>

              {/* Bid / Ask big display */}
              <div className="grid grid-cols-2 gap-2 mt-3">
                <button onClick={() => setSide("sell")}
                  className={cn("py-2 rounded-lg transition-all text-center",
                    side === "sell" ? "bg-red-600 ring-1 ring-red-500" : "bg-red-600/15 hover:bg-red-600/25")}>
                  <div className="text-[10px] text-red-300/70 mb-0.5">SELL</div>
                  <div className="text-lg font-bold text-red-400 tabular-nums font-mono leading-none">{p(bid, pp)}</div>
                </button>
                <button onClick={() => setSide("buy")}
                  className={cn("py-2 rounded-lg transition-all text-center",
                    side === "buy" ? "bg-emerald-600 ring-1 ring-emerald-500" : "bg-emerald-600/15 hover:bg-emerald-600/25")}>
                  <div className="text-[10px] text-emerald-300/70 mb-0.5">BUY</div>
                  <div className="text-lg font-bold text-emerald-400 tabular-nums font-mono leading-none">{p(ask, pp)}</div>
                </button>
              </div>
              <div className="text-center text-[10px] text-white/25 mt-1">
                Spread {spreadPips.toFixed(1)} pips · {selected.exchange}
              </div>
            </div>
          )}

          <div className="flex-1 p-3 space-y-3">

            {/* Order type */}
            <div className="flex gap-0.5 bg-white/5 rounded-lg p-0.5">
              {(["MARKET", "LIMIT", "STOP"] as const).map(t => (
                <button key={t} onClick={() => setOrderType(t)}
                  className={cn("flex-1 py-1.5 text-[11px] font-semibold rounded-md transition-colors",
                    orderType === t ? "bg-amber-500/20 text-amber-400" : "text-white/30 hover:text-white/60")}>
                  {t}
                </button>
              ))}
            </div>

            {/* Lot size */}
            <div>
              <div className="flex justify-between text-[10px] text-white/35 mb-1">
                <span>Volume (lots)</span>
                <span>Min: {selected?.minQty ?? "0.01"}</span>
              </div>
              <div className="flex gap-1">
                <button onClick={() => setQty(q => Math.max(0.01, parseFloat(q) - 0.01).toFixed(2))}
                  className="w-8 h-9 flex items-center justify-center bg-white/5 hover:bg-white/10 rounded-lg text-white/50 text-lg">−</button>
                <input type="number" value={qty} onChange={e => setQty(e.target.value)} step="0.01"
                  className="flex-1 bg-white/5 border border-white/10 text-center text-sm font-bold rounded-lg h-9 text-white focus:border-amber-500/50 focus:outline-none tabular-nums" />
                <button onClick={() => setQty(q => (parseFloat(q) + 0.01).toFixed(2))}
                  className="w-8 h-9 flex items-center justify-center bg-white/5 hover:bg-white/10 rounded-lg text-white/50 text-lg">+</button>
              </div>
              <div className="flex gap-1.5 mt-1.5">
                {["0.01", "0.05", "0.1", "0.5", "1.0"].map(v => (
                  <button key={v} onClick={() => setQty(v)}
                    className={cn("flex-1 py-0.5 text-[10px] rounded border transition-colors",
                      qty === v ? "border-amber-500/50 text-amber-400 bg-amber-500/10" : "border-white/10 text-white/30 hover:text-white/50")}>
                    {v}
                  </button>
                ))}
              </div>
            </div>

            {/* Limit/Stop price */}
            {orderType !== "MARKET" && (
              <div>
                <div className="text-[10px] text-white/35 mb-1">{orderType === "LIMIT" ? "Limit" : "Stop"} Price</div>
                <input type="number" value={limitPrice} onChange={e => setLimitPrice(e.target.value)}
                  placeholder={p(side === "buy" ? ask : bid, pp)}
                  className="w-full bg-white/5 border border-white/10 px-3 h-9 text-sm font-mono rounded-lg text-white focus:border-amber-500/50 focus:outline-none" />
              </div>
            )}

            {/* SL / TP */}
            <div className="bg-white/3 rounded-xl p-3 space-y-2 border border-white/8">
              <div className="flex items-center justify-between mb-1">
                <span className="text-[10px] text-white/35 font-semibold">Risk Management</span>
                <div className="flex gap-0.5 bg-white/5 rounded-md p-0.5">
                  {(["pips", "price"] as const).map(m => (
                    <button key={m} onClick={() => setSlMode(m)}
                      className={cn("px-1.5 py-0.5 text-[9px] rounded transition-colors",
                        slMode === m ? "bg-white/10 text-white" : "text-white/25")}>
                      {m}
                    </button>
                  ))}
                </div>
              </div>

              <div>
                <div className="flex justify-between text-[10px] text-white/30 mb-0.5">
                  <span className="flex items-center gap-1"><Shield size={9} className="text-red-400" /> Stop Loss</span>
                  {slPrice && <span className="font-mono text-red-400">{p(slPrice, pp)}</span>}
                </div>
                <div className="flex gap-1.5">
                  <input type="number" value={stopLoss} onChange={e => setStopLoss(e.target.value)}
                    placeholder={slMode === "pips" ? "e.g. 20" : p(bid * 0.998, pp)}
                    className="flex-1 bg-white/5 border border-red-500/20 px-2 h-8 text-xs font-mono rounded-md text-white focus:border-red-500/50 focus:outline-none" />
                  {stopLoss && <button onClick={() => setStopLoss("")} className="text-white/20 hover:text-white/50"><X size={12} /></button>}
                </div>
                {slPnl && <div className="text-[10px] text-red-400/70 mt-0.5">Risk: −{fmtCurrency(slPnl, selected?.quoteCurrency)}</div>}
              </div>

              <div>
                <div className="flex justify-between text-[10px] text-white/30 mb-0.5">
                  <span className="flex items-center gap-1"><Zap size={9} className="text-emerald-400" /> Take Profit</span>
                  {tpPrice && <span className="font-mono text-emerald-400">{p(tpPrice, pp)}</span>}
                </div>
                <div className="flex gap-1.5">
                  <input type="number" value={takeProfit} onChange={e => setTakeProfit(e.target.value)}
                    placeholder={slMode === "pips" ? "e.g. 40" : p(ask * 1.002, pp)}
                    className="flex-1 bg-white/5 border border-emerald-500/20 px-2 h-8 text-xs font-mono rounded-md text-white focus:border-emerald-500/50 focus:outline-none" />
                  {takeProfit && <button onClick={() => setTakeProfit("")} className="text-white/20 hover:text-white/50"><X size={12} /></button>}
                </div>
                {tpPnl && <div className="text-[10px] text-emerald-400/70 mt-0.5">Reward: +{fmtCurrency(tpPnl, selected?.quoteCurrency)}</div>}
              </div>

              {stopLoss && takeProfit && slPnl && tpPnl && (
                <div className="text-[10px] text-white/30 flex justify-between pt-1 border-t border-white/5">
                  <span>R:R Ratio</span>
                  <span className={cn("font-semibold", tpPnl / slPnl >= 2 ? "text-emerald-400" : tpPnl / slPnl >= 1 ? "text-amber-400" : "text-red-400")}>
                    1:{(tpPnl / slPnl).toFixed(2)}
                  </span>
                </div>
              )}
            </div>

            {/* Pip calculator */}
            {showCalc && (
              <div className="bg-amber-500/5 border border-amber-500/15 rounded-xl p-3 space-y-1.5">
                <div className="text-[10px] text-amber-400 font-semibold mb-1.5 flex items-center gap-1.5">
                  <Calculator size={10} /> Pip Calculator
                </div>
                {[
                  ["Pip Value", `${fmtCurrency(pipValue, selected?.quoteCurrency ?? "INR")}/pip`],
                  ["Lots", lots.toFixed(2)],
                  ["Value/Lot", fmtCurrency(pipValueLots, selected?.quoteCurrency ?? "INR")],
                  ["Notional", fmtCurrency(notional, selected?.quoteCurrency ?? "INR")],
                  ["Margin Req.", fmtCurrency(margin, selected?.quoteCurrency ?? "INR")],
                ].map(([k, v]) => (
                  <div key={k} className="flex justify-between text-xs">
                    <span className="text-white/30">{k}</span>
                    <span className="font-mono text-amber-300/80">{v}</span>
                  </div>
                ))}
              </div>
            )}

            {/* ── MT5 section ── */}
            {user && (
              connectedMt5 ? (
                <MT5AccountCard account={connectedMt5}
                  onDisconnect={() => mt5DisconnectMutation.mutate(connectedMt5.id)} />
              ) : (
                <button onClick={() => setShowMt5Modal(true)}
                  className="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-xl border border-blue-500/20 bg-blue-500/5 hover:bg-blue-500/10 transition-colors text-left">
                  <div className="w-7 h-7 rounded-lg bg-blue-500/15 flex items-center justify-center flex-shrink-0">
                    <Terminal size={13} className="text-blue-400" />
                  </div>
                  <div>
                    <div className="text-xs font-semibold text-blue-300">Connect MetaTrader 5</div>
                    <div className="text-[10px] text-white/25 mt-0.5">Route orders via your MT5 broker account</div>
                  </div>
                  <PlugZap size={12} className="ml-auto text-blue-400/50" />
                </button>
              )
            )}

            {/* MT5 active indicator */}
            {connectedMt5 && (
              <div className="bg-blue-500/5 border border-blue-500/15 rounded-lg px-3 py-2 flex items-center gap-1.5 text-[10px]">
                <CheckCircle2 size={10} className="text-blue-400" />
                <span className="text-blue-300/70">
                  Orders routing via MT5 · {connectedMt5.server}
                </span>
              </div>
            )}

            {/* Angel One status */}
            {user && !connectedMt5 && (
              brokerActive ? (
                <div className={cn("rounded-xl p-2.5 border text-xs",
                  brokerSimulated ? "bg-yellow-500/8 border-yellow-500/25" : "bg-emerald-500/8 border-emerald-500/25")}>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-1.5">
                      {brokerSimulated ? <WifiOff size={10} className="text-yellow-400" /> : <Wifi size={10} className="text-emerald-400" />}
                      <span className={brokerSimulated ? "text-yellow-300" : "text-emerald-300"}>
                        {brokerSimulated ? "Simulated" : "Live"} · {brokerAccount.angelClientId}
                      </span>
                    </div>
                    <Link href="/broker/onboarding" className="text-amber-400 hover:underline text-[10px]">Manage</Link>
                  </div>
                  {brokerSimulated && (
                    <div className="text-yellow-500/60 text-[10px] mt-1">
                      Add SmartAPI key for live orders →&nbsp;
                      <Link href="/broker/onboarding" className="text-amber-400 underline">Setup</Link>
                    </div>
                  )}
                </div>
              ) : (
                <div className="bg-amber-500/8 border border-amber-500/25 rounded-xl p-3">
                  <div className="text-xs font-semibold text-amber-300 mb-1.5 flex items-center gap-1.5">
                    <Link2 size={11} /> Connect Angel One
                  </div>
                  <div className="text-[10px] text-white/35 mb-2.5 leading-relaxed">
                    Link your Angel One account to execute live Forex CFD orders via our AP license.
                  </div>
                  <div className="flex gap-2">
                    <Link href="/broker/onboarding"
                      className="flex-1 flex items-center justify-center gap-1 py-1.5 rounded-lg bg-amber-500 hover:bg-amber-600 text-black text-[11px] font-bold transition-colors">
                      <Link2 size={10} /> Connect
                    </Link>
                    <Link href="/broker/onboarding"
                      className="flex-1 flex items-center justify-center gap-1 py-1.5 rounded-lg bg-white/8 hover:bg-white/12 text-white text-[11px] transition-colors">
                      Open Account <ChevronRight size={10} />
                    </Link>
                  </div>
                </div>
              )
            )}

            {/* One-click toggle */}
            {user && (
              <div className="flex items-center justify-between text-[10px] text-white/30 px-1">
                <span>One-click trading</span>
                <button onClick={() => setOneClick(s => !s)}
                  className={cn("w-8 h-4 rounded-full transition-colors relative",
                    oneClick ? "bg-amber-500" : "bg-white/15")}>
                  <span className={cn("absolute top-0.5 w-3 h-3 rounded-full bg-white transition-transform",
                    oneClick ? "translate-x-4" : "translate-x-0.5")} />
                </button>
              </div>
            )}

            {/* Place order button */}
            {!user ? (
              <a href="/login" className="block w-full py-3 rounded-xl bg-amber-500 hover:bg-amber-600 text-black font-bold text-sm text-center transition-colors">
                Login to Trade
              </a>
            ) : (
              <div className="space-y-1.5">
                {/* Sell button */}
                <button onClick={() => handlePlace("sell")}
                  disabled={!selectedSymbol || !qty || placeMutation.isPending || mt5PlaceMutation.isPending}
                  className="w-full py-2.5 rounded-xl bg-red-600 hover:bg-red-700 text-white font-bold text-sm transition-colors disabled:opacity-40 flex items-center justify-center gap-2">
                  <TrendingDown size={14} />
                  {connectedMt5 ? "MT5 " : ""}Sell {qty} {selectedSymbol ?? "—"}
                  <span className="font-mono text-xs opacity-80">{p(bid, pp)}</span>
                </button>

                {/* Buy button */}
                <button onClick={() => handlePlace("buy")}
                  disabled={!selectedSymbol || !qty || placeMutation.isPending || mt5PlaceMutation.isPending}
                  className="w-full py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm transition-colors disabled:opacity-40 flex items-center justify-center gap-2">
                  <TrendingUp size={14} />
                  {connectedMt5 ? "MT5 " : ""}Buy {qty} {selectedSymbol ?? "—"}
                  <span className="font-mono text-xs opacity-80">{p(ask, pp)}</span>
                </button>

                {(placeMutation.isPending || mt5PlaceMutation.isPending) && (
                  <div className="text-center text-xs animate-pulse flex items-center justify-center gap-1.5">
                    <RefreshCw size={10} className={connectedMt5 ? "text-blue-400" : "text-amber-400"} />
                    <span className={connectedMt5 ? "text-blue-400" : "text-amber-400"}>
                      {connectedMt5 ? "Sending to MT5..." : "Placing order..."}
                    </span>
                  </div>
                )}
              </div>
            )}

            {/* Risk notice */}
            <div className="flex items-start gap-1.5 text-[10px] text-white/20 pb-2">
              <AlertTriangle size={10} className="flex-shrink-0 mt-0.5 text-amber-500/40" />
              <span>
                {connectedMt5
                  ? `${connectedMt5.isDemo ? "Demo" : "Live"} execution via MT5 · ${connectedMt5.server}. CFDs carry risk.`
                  : brokerActive && !brokerSimulated
                  ? `Live execution via Angel One (${brokerAccount.angelClientId}). CFDs carry risk.`
                  : "CFDs carry significant risk. 74% of retail investors lose money."}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* ── MT5 Connect Modal ──────────────────────────────────────────────── */}
      {showMt5Modal && (
        <MT5ConnectModal
          onClose={() => setShowMt5Modal(false)}
          onConnected={(acct) => setActiveMt5(acct)}
        />
      )}
    </div>
  );
}
