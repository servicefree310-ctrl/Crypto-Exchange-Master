import { useEffect, useMemo, useState } from "react";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { CheckCircle2, XCircle, Lock, Unlock, Loader2, AlertTriangle, Hammer, Server } from "lucide-react";

type AuthMode = "none" | "user" | "admin" | "optional";
type Status = "live" | "stub" | "not-implemented" | "deprecated";

type Endpoint = {
  method: "GET" | "POST" | "PUT" | "PATCH" | "DELETE";
  path: string;
  desc: string;
  auth: AuthMode;
  status: Status;
  pingable?: boolean;
};

type Group = {
  name: string;
  layer: "node" | "go" | "node+go";
  summary: string;
  endpoints: Endpoint[];
};

const GROUPS: Group[] = [
  {
    name: "Authentication",
    layer: "node",
    summary: "Flutter PoW register/login, JWT refresh, password reset, 2FA. Admin uses cookie-session login.",
    endpoints: [
      { method: "GET", path: "/auth/pow/challenge", desc: "Issues a Proof-of-Work challenge for register/login", auth: "none", status: "live", pingable: true },
      { method: "POST", path: "/auth/register", desc: "Flutter signup with PoW solution; returns JWT cookies", auth: "none", status: "live" },
      { method: "POST", path: "/auth/login/flutter", desc: "Flutter login with PoW; returns JWT cookies + user", auth: "none", status: "live" },
      { method: "POST", path: "/auth/refresh", desc: "Refresh access token (re-issues from current bearer)", auth: "user", status: "stub" },
      { method: "POST", path: "/auth/logout", desc: "Clears auth + legacy session cookies", auth: "none", status: "live" },
      { method: "POST", path: "/auth/login", desc: "Legacy admin cookie-session login", auth: "none", status: "live" },
      { method: "GET", path: "/auth/me", desc: "Legacy admin current user", auth: "admin", status: "live" },
      { method: "POST", path: "/auth/change-password", desc: "Update password for current user", auth: "user", status: "live" },
      { method: "POST", path: "/auth/reset", desc: "Request password reset email", auth: "none", status: "stub" },
      { method: "POST", path: "/auth/reset/confirm", desc: "Confirm password reset", auth: "none", status: "stub" },
      { method: "POST", path: "/auth/verify", desc: "Email verification", auth: "none", status: "stub" },
      { method: "POST", path: "/auth/2fa", desc: "2FA verification", auth: "none", status: "not-implemented" },
      { method: "POST", path: "/auth/otp/login", desc: "2FA OTP login", auth: "none", status: "not-implemented" },
      { method: "POST", path: "/auth/otp/resend", desc: "Resend OTP", auth: "none", status: "stub" },
      { method: "POST", path: "/auth/login/google", desc: "Google OAuth login", auth: "none", status: "not-implemented" },
      { method: "POST", path: "/auth/register/google", desc: "Google OAuth signup", auth: "none", status: "not-implemented" },
    ],
  },
  {
    name: "User Profile & Settings",
    layer: "node",
    summary: "Current user profile, preferences, watchlist, notifications, KYC, support.",
    endpoints: [
      { method: "GET", path: "/user/profile", desc: "Get current Flutter user profile", auth: "user", status: "live" },
      { method: "PUT", path: "/user/profile", desc: "Update profile fields", auth: "user", status: "live" },
      { method: "GET", path: "/user/settings", desc: "Get user preferences", auth: "user", status: "stub" },
      { method: "PUT", path: "/user/settings", desc: "Update user preferences", auth: "user", status: "stub" },
      { method: "GET", path: "/user/notification", desc: "List in-app notifications", auth: "user", status: "stub" },
      { method: "DELETE", path: "/user/notification/:id", desc: "Dismiss a notification", auth: "user", status: "stub" },
      { method: "GET", path: "/user/watchlist", desc: "Get user watchlist", auth: "user", status: "stub" },
      { method: "POST", path: "/user/watchlist", desc: "Add to watchlist", auth: "user", status: "stub" },
      { method: "GET", path: "/user/kyc/status", desc: "Get current KYC level + status", auth: "user", status: "live" },
      { method: "GET", path: "/user/kyc/level", desc: "List available KYC levels", auth: "none", status: "stub" },
      { method: "GET", path: "/user/kyc/application", desc: "List my KYC applications", auth: "user", status: "stub" },
      { method: "POST", path: "/user/kyc/application", desc: "Submit KYC application", auth: "user", status: "stub" },
      { method: "GET", path: "/user/support/ticket", desc: "List my support tickets", auth: "user", status: "stub" },
      { method: "POST", path: "/user/support/ticket", desc: "Create support ticket", auth: "user", status: "not-implemented" },
    ],
  },
  {
    name: "Wallet & Finance",
    layer: "node",
    summary: "Auto-creates INR/USDT/BTC spot wallets on first call. Live balances + currency listings.",
    endpoints: [
      { method: "GET", path: "/finance/wallet", desc: "All wallets grouped by type (auto-creates defaults)", auth: "user", status: "live" },
      { method: "GET", path: "/finance/wallet/:type/:currency", desc: "Single wallet detail + balance", auth: "user", status: "live" },
      { method: "GET", path: "/finance/wallet/symbol", desc: "Wallet balances by symbol list", auth: "user", status: "live" },
      { method: "GET", path: "/finance/wallet/transfer-options", desc: "Transferable wallet pairs", auth: "user", status: "stub" },
      { method: "GET", path: "/finance/transaction", desc: "Transaction history", auth: "user", status: "stub" },
      { method: "GET", path: "/finance/currency", desc: "All listed currencies (live from coins table)", auth: "none", status: "live", pingable: true },
      { method: "GET", path: "/finance/currency/:type", desc: "Filter currencies by type (FIAT/SPOT/...)", auth: "none", status: "live" },
      { method: "GET", path: "/finance/currency/:type/:currency", desc: "Currency detail (live)", auth: "none", status: "live" },
      { method: "POST", path: "/finance/deposit/spot", desc: "Spot deposit instructions", auth: "user", status: "stub" },
      { method: "POST", path: "/finance/withdraw", desc: "Generic withdraw (admin-managed)", auth: "user", status: "not-implemented" },
      { method: "POST", path: "/finance/withdraw/spot", desc: "Crypto withdraw", auth: "user", status: "not-implemented" },
      { method: "POST", path: "/finance/withdraw/fiat", desc: "Fiat (INR) withdraw", auth: "user", status: "not-implemented" },
      { method: "POST", path: "/finance/transfer", desc: "Internal transfer between wallets", auth: "user", status: "not-implemented" },
    ],
  },
  {
    name: "Spot Exchange",
    layer: "node",
    summary: "Market list, ticker, orderbook, recent trades, candle chart. Tick = {symbol, usdt, inr, change24h, volume24h, ts}.",
    endpoints: [
      { method: "GET", path: "/exchange/market", desc: "All trading pairs (BTC/USDT etc.)", auth: "none", status: "live", pingable: true },
      { method: "GET", path: "/exchange/ticker", desc: "All tickers with 24h change %, volume", auth: "none", status: "live", pingable: true },
      { method: "GET", path: "/exchange/ticker/:currency/:pair", desc: "Single pair ticker", auth: "none", status: "live" },
      { method: "GET", path: "/exchange/orderbook/:currency/:pair", desc: "Live orderbook (bids/asks)", auth: "none", status: "live" },
      { method: "GET", path: "/exchange/trades/:currency/:pair", desc: "Recent trades for pair", auth: "none", status: "live" },
      { method: "GET", path: "/exchange/chart", desc: "OHLCV candles (interval selectable)", auth: "none", status: "live" },
      { method: "GET", path: "/exchange/order", desc: "User open orders (use /api/orders)", auth: "user", status: "deprecated" },
      { method: "POST", path: "/exchange/order", desc: "Place order (use /api/orders)", auth: "user", status: "deprecated" },
      { method: "DELETE", path: "/exchange/order/:id", desc: "Cancel order (use /api/orders/:id/cancel)", auth: "user", status: "deprecated" },
    ],
  },
  {
    name: "Futures Trading",
    layer: "node",
    summary: "Stubs returning {data: ...} so Flutter UI renders. Real matching engine will move to Go service in next phase.",
    endpoints: [
      { method: "GET", path: "/futures/market", desc: "Futures markets list", auth: "none", status: "stub", pingable: true },
      { method: "GET", path: "/futures/position", desc: "User open futures positions", auth: "user", status: "stub" },
      { method: "GET", path: "/futures/order", desc: "User futures orders", auth: "user", status: "stub" },
      { method: "PUT", path: "/futures/leverage", desc: "Update leverage for a pair", auth: "user", status: "stub" },
      { method: "POST", path: "/futures/order", desc: "Place futures order", auth: "user", status: "stub" },
      { method: "DELETE", path: "/futures/order/:id", desc: "Cancel futures order", auth: "user", status: "stub" },
      { method: "DELETE", path: "/futures/position", desc: "Close futures position", auth: "user", status: "stub" },
      { method: "GET", path: "/futures/chart", desc: "Futures candle chart", auth: "none", status: "stub" },
    ],
  },
  {
    name: "Settings (Public)",
    layer: "node",
    summary: "App-wide settings + extension flags consumed by Flutter on boot.",
    endpoints: [
      { method: "GET", path: "/settings", desc: "Public app settings + enabled extensions", auth: "none", status: "live", pingable: true },
      { method: "PUT", path: "/settings", desc: "Upsert settings (admin)", auth: "user", status: "live" },
      { method: "POST", path: "/settings", desc: "Upsert settings (Flutter compat)", auth: "user", status: "live" },
    ],
  },
  {
    name: "INR Money Flow (Legacy)",
    layer: "node",
    summary: "INR deposits via UPI/IMPS/NEFT/RTGS, withdrawals to verified bank accounts. Atomic admin approval flow.",
    endpoints: [
      { method: "GET", path: "/gateways", desc: "List active payment gateways", auth: "none", status: "live", pingable: true },
      { method: "GET", path: "/inr-deposits", desc: "User INR deposit history", auth: "user", status: "live" },
      { method: "POST", path: "/inr-deposits", desc: "Submit INR deposit with UTR", auth: "user", status: "live" },
      { method: "GET", path: "/inr-withdrawals", desc: "User INR withdrawal history", auth: "user", status: "live" },
      { method: "POST", path: "/inr-withdrawals", desc: "Withdraw INR (requires OTP + verified bank)", auth: "user", status: "live" },
      { method: "GET", path: "/banks", desc: "User bank accounts", auth: "user", status: "live" },
      { method: "POST", path: "/banks", desc: "Add bank account (one verified at a time)", auth: "user", status: "live" },
    ],
  },
  {
    name: "Crypto Money Flow (Legacy)",
    layer: "node",
    summary: "On-chain deposit addresses + tx-hash claim, withdrawals to whitelisted addresses with OTP.",
    endpoints: [
      { method: "GET", path: "/crypto-deposits", desc: "User crypto deposit history", auth: "user", status: "live" },
      { method: "POST", path: "/crypto-deposits/notify", desc: "Notify on-chain deposit (txHash)", auth: "user", status: "live" },
      { method: "GET", path: "/crypto-withdrawals", desc: "User crypto withdrawal history", auth: "user", status: "live" },
      { method: "POST", path: "/crypto-withdrawals", desc: "Withdraw crypto (OTP gated)", auth: "user", status: "live" },
      { method: "GET", path: "/networks", desc: "Supported networks per coin", auth: "none", status: "live", pingable: true },
    ],
  },
  {
    name: "OTP & KYC (Legacy)",
    layer: "node",
    summary: "Single-use OTP for withdrawals (hashed, race-safe). KYC L1/L2/L3 with PAN/Aadhaar.",
    endpoints: [
      { method: "POST", path: "/otp/send", desc: "Send 6-digit OTP for purpose", auth: "user", status: "live" },
      { method: "POST", path: "/otp/verify", desc: "Verify OTP -> issues otpId", auth: "user", status: "live" },
      { method: "GET", path: "/kyc/settings", desc: "Per-level KYC requirements", auth: "none", status: "live", pingable: true },
      { method: "GET", path: "/kyc/my", desc: "My KYC applications", auth: "user", status: "live" },
      { method: "POST", path: "/kyc/submit", desc: "Submit KYC level (PAN/Aadhaar)", auth: "user", status: "live" },
      { method: "GET", path: "/refer/stats", desc: "Referrals + commission earned", auth: "user", status: "live" },
    ],
  },
  {
    name: "Admin Money Flow",
    layer: "node",
    summary: "Admin approval/rejection of money flow with row-level locking. Refunds locked balance on reject.",
    endpoints: [
      { method: "GET", path: "/admin/stats", desc: "Dashboard counters", auth: "admin", status: "live" },
      { method: "PATCH", path: "/admin/inr-deposits/:id", desc: "Approve/reject INR deposit (atomic)", auth: "admin", status: "live" },
      { method: "PATCH", path: "/admin/inr-withdrawals/:id", desc: "Approve/reject INR withdrawal (atomic)", auth: "admin", status: "live" },
      { method: "PATCH", path: "/admin/crypto-deposits/:id", desc: "Approve/reject crypto deposit (atomic)", auth: "admin", status: "live" },
      { method: "PATCH", path: "/admin/crypto-withdrawals/:id", desc: "Approve/reject crypto withdrawal (atomic)", auth: "admin", status: "live" },
      { method: "PATCH", path: "/admin/kyc/:id", desc: "Approve KYC (monotonic level bump)", auth: "admin", status: "live" },
    ],
  },
  {
    name: "Content & Misc (Bicrypto compat)",
    layer: "node",
    summary: "Empty-shaped responses so Flutter modules render without errors. Real CMS later.",
    endpoints: [
      { method: "GET", path: "/content/announcements", desc: "Announcements feed", auth: "none", status: "stub", pingable: true },
      { method: "GET", path: "/faq", desc: "FAQ list", auth: "none", status: "stub", pingable: true },
      { method: "GET", path: "/blog/post", desc: "Blog posts", auth: "none", status: "stub", pingable: true },
      { method: "GET", path: "/ecommerce/product", desc: "E-commerce products", auth: "none", status: "stub", pingable: true },
      { method: "GET", path: "/p2p/offer", desc: "P2P offers", auth: "none", status: "stub", pingable: true },
      { method: "GET", path: "/payment/gateway", desc: "Bicrypto-shape gateways", auth: "none", status: "stub", pingable: true },
    ],
  },
  {
    name: "Go Service",
    layer: "go",
    summary: "Skeleton service at /go-service/. Health + WebSocket stub. Will host matching engine + perf-critical streams next phase.",
    endpoints: [
      { method: "GET", path: "/go-service/healthz", desc: "Go service health probe", auth: "none", status: "live", pingable: true },
      { method: "GET", path: "/go-service/ws", desc: "WebSocket upgrade (origin-restricted)", auth: "none", status: "stub" },
    ],
  },
  {
    name: "Live WebSocket (Node)",
    layer: "node",
    summary: "Real-time price stream broadcasting jittered ticks for smooth UI; authoritative price kept separate.",
    endpoints: [
      { method: "GET", path: "/api/ws/prices", desc: "WS price stream (CoinGecko-backed)", auth: "none", status: "live" },
    ],
  },
];

const STATUS_META: Record<Status, { label: string; cls: string; icon: typeof CheckCircle2 }> = {
  live: { label: "Live", cls: "bg-emerald-500/15 text-emerald-700 border-emerald-500/30", icon: CheckCircle2 },
  stub: { label: "Stub", cls: "bg-amber-500/15 text-amber-700 border-amber-500/30", icon: Hammer },
  "not-implemented": { label: "501 Blocked", cls: "bg-rose-500/15 text-rose-700 border-rose-500/30", icon: XCircle },
  deprecated: { label: "Deprecated", cls: "bg-slate-400/15 text-slate-600 border-slate-400/30", icon: AlertTriangle },
};

const AUTH_META: Record<AuthMode, { label: string; cls: string; icon: typeof Lock }> = {
  none: { label: "Public", cls: "bg-sky-500/10 text-sky-700 border-sky-500/30", icon: Unlock },
  user: { label: "User JWT", cls: "bg-violet-500/10 text-violet-700 border-violet-500/30", icon: Lock },
  admin: { label: "Admin Session", cls: "bg-fuchsia-500/10 text-fuchsia-700 border-fuchsia-500/30", icon: Lock },
  optional: { label: "Optional Auth", cls: "bg-cyan-500/10 text-cyan-700 border-cyan-500/30", icon: Lock },
};

const METHOD_CLS: Record<string, string> = {
  GET: "bg-blue-500/10 text-blue-700 border-blue-500/30",
  POST: "bg-emerald-500/10 text-emerald-700 border-emerald-500/30",
  PUT: "bg-amber-500/10 text-amber-700 border-amber-500/30",
  PATCH: "bg-orange-500/10 text-orange-700 border-orange-500/30",
  DELETE: "bg-rose-500/10 text-rose-700 border-rose-500/30",
};

type PingResult = { ok: boolean; status: number; ms: number } | { error: string };

async function ping(url: string): Promise<PingResult> {
  const t = performance.now();
  try {
    const res = await fetch(url, { credentials: "include" });
    return { ok: res.ok, status: res.status, ms: Math.round(performance.now() - t) };
  } catch (e) {
    return { error: String(e) };
  }
}

export default function BackendStatusPage() {
  const [filter, setFilter] = useState("");
  const [pings, setPings] = useState<Record<string, PingResult | "loading">>({});

  const totals = useMemo(() => {
    const out = { total: 0, live: 0, stub: 0, ni: 0, dep: 0 };
    for (const g of GROUPS) for (const e of g.endpoints) {
      out.total++;
      if (e.status === "live") out.live++;
      else if (e.status === "stub") out.stub++;
      else if (e.status === "not-implemented") out.ni++;
      else if (e.status === "deprecated") out.dep++;
    }
    return out;
  }, []);

  const visibleGroups = useMemo(() => {
    const q = filter.trim().toLowerCase();
    if (!q) return GROUPS;
    return GROUPS
      .map(g => ({ ...g, endpoints: g.endpoints.filter(e =>
        e.path.toLowerCase().includes(q) ||
        e.desc.toLowerCase().includes(q) ||
        e.method.toLowerCase().includes(q) ||
        g.name.toLowerCase().includes(q)
      )}))
      .filter(g => g.endpoints.length > 0);
  }, [filter]);

  const pingAll = async () => {
    const targets: string[] = [];
    for (const g of GROUPS) for (const e of g.endpoints) if (e.pingable) {
      const url = e.path.startsWith("/go-service") ? e.path : "/api" + e.path;
      targets.push(url);
    }
    setPings(Object.fromEntries(targets.map(u => [u, "loading"])));
    const results = await Promise.all(targets.map(u => ping(u).then(r => [u, r] as const)));
    setPings(Object.fromEntries(results));
  };

  useEffect(() => { void pingAll(); }, []);

  return (
    <div className="space-y-6">
      <div className="flex flex-col md:flex-row md:items-end md:justify-between gap-3">
        <div>
          <h2 className="text-2xl font-bold">Backend Status</h2>
          <p className="text-sm text-muted-foreground">Saare backend endpoints — kya live hai, kya stub hai, aur auth chahiye ya nahi.</p>
        </div>
        <div className="flex gap-2">
          <Input placeholder="Search path / description…" value={filter} onChange={e => setFilter(e.target.value)} className="md:w-72" />
          <Button variant="outline" onClick={pingAll}>Re-ping public endpoints</Button>
        </div>
      </div>

      <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
        <Card><CardHeader className="pb-2"><CardTitle className="text-sm text-muted-foreground">Total Endpoints</CardTitle></CardHeader><CardContent className="text-2xl font-bold">{totals.total}</CardContent></Card>
        <Card><CardHeader className="pb-2"><CardTitle className="text-sm text-muted-foreground">Live</CardTitle></CardHeader><CardContent className="text-2xl font-bold text-emerald-600">{totals.live}</CardContent></Card>
        <Card><CardHeader className="pb-2"><CardTitle className="text-sm text-muted-foreground">Stubs</CardTitle></CardHeader><CardContent className="text-2xl font-bold text-amber-600">{totals.stub}</CardContent></Card>
        <Card><CardHeader className="pb-2"><CardTitle className="text-sm text-muted-foreground">501 Blocked</CardTitle></CardHeader><CardContent className="text-2xl font-bold text-rose-600">{totals.ni}</CardContent></Card>
        <Card><CardHeader className="pb-2"><CardTitle className="text-sm text-muted-foreground">Deprecated</CardTitle></CardHeader><CardContent className="text-2xl font-bold text-slate-500">{totals.dep}</CardContent></Card>
      </div>

      <div className="space-y-6">
        {visibleGroups.map(g => (
          <Card key={g.name}>
            <CardHeader>
              <div className="flex items-start justify-between gap-3">
                <div>
                  <CardTitle className="flex items-center gap-2">
                    <Server className="w-4 h-4 text-muted-foreground" />
                    {g.name}
                    <Badge variant="outline" className="text-xs ml-2">
                      {g.layer === "node" ? "Node" : g.layer === "go" ? "Go" : "Node + Go"}
                    </Badge>
                  </CardTitle>
                  <p className="text-sm text-muted-foreground mt-1">{g.summary}</p>
                </div>
                <div className="text-xs text-muted-foreground whitespace-nowrap">{g.endpoints.length} endpoints</div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="text-xs uppercase text-muted-foreground border-b">
                    <tr>
                      <th className="text-left py-2 pr-3">Method</th>
                      <th className="text-left py-2 pr-3">Path</th>
                      <th className="text-left py-2 pr-3">Description</th>
                      <th className="text-left py-2 pr-3">Auth</th>
                      <th className="text-left py-2 pr-3">Status</th>
                      <th className="text-left py-2">Live Probe</th>
                    </tr>
                  </thead>
                  <tbody>
                    {g.endpoints.map(e => {
                      const sm = STATUS_META[e.status];
                      const am = AUTH_META[e.auth];
                      const SIcon = sm.icon;
                      const AIcon = am.icon;
                      const pingUrl = e.pingable ? (e.path.startsWith("/go-service") ? e.path : "/api" + e.path) : null;
                      const probe = pingUrl ? pings[pingUrl] : undefined;
                      return (
                        <tr key={e.method + e.path} className="border-b last:border-b-0 hover:bg-muted/30">
                          <td className="py-2 pr-3">
                            <span className={`inline-block px-2 py-0.5 rounded text-xs font-mono border ${METHOD_CLS[e.method] || ""}`}>{e.method}</span>
                          </td>
                          <td className="py-2 pr-3 font-mono text-xs">{e.path}</td>
                          <td className="py-2 pr-3 text-muted-foreground">{e.desc}</td>
                          <td className="py-2 pr-3">
                            <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs border ${am.cls}`}>
                              <AIcon className="w-3 h-3" />{am.label}
                            </span>
                          </td>
                          <td className="py-2 pr-3">
                            <span className={`inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs border ${sm.cls}`}>
                              <SIcon className="w-3 h-3" />{sm.label}
                            </span>
                          </td>
                          <td className="py-2 text-xs">
                            {!e.pingable ? (
                              <span className="text-muted-foreground/60">—</span>
                            ) : probe === "loading" || !probe ? (
                              <Loader2 className="w-3 h-3 animate-spin text-muted-foreground" />
                            ) : "error" in probe ? (
                              <span className="text-rose-600">net err</span>
                            ) : (
                              <span className={probe.ok ? "text-emerald-600" : "text-rose-600"}>
                                {probe.status} · {probe.ms}ms
                              </span>
                            )}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <Card>
        <CardHeader><CardTitle className="text-base">Legend</CardTitle></CardHeader>
        <CardContent className="text-sm space-y-2">
          <div><strong>Live:</strong> Production-ready, persists to DB, contract-stable.</div>
          <div><strong>Stub:</strong> Returns valid Bicrypto-shaped empty/placeholder data so Flutter UI renders. Backing logic pending.</div>
          <div><strong>501 Blocked:</strong> Intentionally refuses (security or scope) until proper implementation lands.</div>
          <div><strong>Deprecated:</strong> Compatibility shim — use the canonical endpoint listed in description.</div>
          <div className="pt-2"><strong>Auth modes:</strong> Public (no auth), User JWT (Flutter accessToken cookie), Admin Session (legacy cookie session), Optional (works either way).</div>
        </CardContent>
      </Card>
    </div>
  );
}
