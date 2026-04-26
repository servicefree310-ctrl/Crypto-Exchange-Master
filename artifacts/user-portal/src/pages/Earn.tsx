import { useState, useMemo } from "react";
import { Link } from "wouter";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  Coins, TrendingUp, Calendar, Lock, Unlock, Star, Zap, Loader2, AlertCircle,
  ArrowRight, Wallet as WalletIcon, Activity, ShieldCheck, Info, Filter,
  Layers, ChevronDown, Hourglass,
} from "lucide-react";
import { useAuth } from "@/lib/auth";
import { get, post, ApiError } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Separator } from "@/components/ui/separator";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter,
} from "@/components/ui/dialog";
import {
  AlertDialog, AlertDialogAction, AlertDialogCancel, AlertDialogContent,
  AlertDialogDescription, AlertDialogFooter, AlertDialogHeader, AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { toast } from "@/hooks/use-toast";

type EarnProduct = {
  id: number;
  coinId: number;
  name: string;
  description: string | null;
  type: "simple" | "advanced";
  durationDays: number;
  apy: string | number;
  minAmount: string | number;
  maxAmount: string | number;
  totalCap: string | number;
  currentSubscribed: string | number;
  payoutInterval: string;
  compounding: boolean;
  earlyRedemption: boolean;
  earlyRedemptionPenaltyPct: string | number;
  minVipTier: number;
  featured: boolean;
  coinSymbol: string;
  coinName: string;
  coinIcon: string | null;
};

type EarnPosition = {
  id: number;
  productId: number;
  amount: string | number;
  totalEarned: string | number;
  status: "active" | "matured" | "redeemed" | "early_redeemed" | "cancelled";
  startedAt: string;
  maturityAt: string | null;
  lastAccruedAt: string | null;
  autoRenew: boolean;
};

function fmtNum(n: number | string, dp = 4): string {
  const num = Number(n);
  if (!Number.isFinite(num)) return "—";
  if (num === 0) return "0";
  if (Math.abs(num) >= 1000) return num.toLocaleString("en-US", { maximumFractionDigits: 2 });
  return num.toFixed(dp).replace(/\.?0+$/, "");
}

function fmtPct(n: number | string) {
  const v = Number(n);
  if (!Number.isFinite(v)) return "—";
  return `${v.toFixed(2)}%`;
}

function daysBetween(a: string, b: string): number {
  return Math.max(0, Math.round((new Date(b).getTime() - new Date(a).getTime()) / 86400000));
}

export default function Earn() {
  const { user } = useAuth();
  const qc = useQueryClient();

  const productsQ = useQuery<EarnProduct[]>({
    queryKey: ["/earn/products"],
    queryFn: () => get<EarnProduct[]>("/earn/products"),
  });

  const positionsQ = useQuery<EarnPosition[]>({
    queryKey: ["/earn/positions"],
    queryFn: () => get<EarnPosition[]>("/earn/positions"),
    retry: false,
  });

  const [coinFilter, setCoinFilter] = useState<string>("all");
  const [typeFilter, setTypeFilter] = useState<string>("all");
  const [sortBy, setSortBy] = useState<string>("apy");
  const [subProduct, setSubProduct] = useState<EarnProduct | null>(null);
  const [redeemFor, setRedeemFor] = useState<EarnPosition | null>(null);

  const products = productsQ.data ?? [];
  const positions = positionsQ.data ?? [];

  const coinOptions = useMemo(() => {
    const set = new Set(products.map((p) => p.coinSymbol));
    return ["all", ...Array.from(set).sort()];
  }, [products]);

  const filtered = useMemo(() => {
    let list = products;
    if (coinFilter !== "all") list = list.filter((p) => p.coinSymbol === coinFilter);
    if (typeFilter !== "all") list = list.filter((p) => p.type === typeFilter);
    list = [...list].sort((a, b) => {
      if (sortBy === "apy") return Number(b.apy) - Number(a.apy);
      if (sortBy === "duration") return a.durationDays - b.durationDays;
      if (sortBy === "min") return Number(a.minAmount) - Number(b.minAmount);
      return 0;
    });
    // featured first within sort
    return [...list].sort((a, b) => Number(b.featured) - Number(a.featured));
  }, [products, coinFilter, typeFilter, sortBy]);

  // Stats
  const activePositions = positions.filter((p) => p.status === "active");
  const totalLocked = activePositions.reduce((s, p) => s + Number(p.amount || 0), 0);
  const totalEarned = positions.reduce((s, p) => s + Number(p.totalEarned || 0), 0);

  const kycLevel = (user as any)?.kycLevel ?? 0;
  const canEarnSimple = kycLevel >= 1;
  const canEarnAdvanced = kycLevel >= 2;

  return (
    <div className="container mx-auto max-w-6xl p-4 sm:p-6 space-y-5">
      {/* Hero */}
      <Card className="overflow-hidden border-border/60 bg-gradient-to-br from-amber-500/10 via-card to-emerald-500/5 p-5 sm:p-7">
        <div className="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2">
              <Coins className="h-6 w-6 text-amber-400" />
              <h1 className="text-2xl sm:text-3xl font-bold">Zebvix Earn</h1>
              <Badge className="bg-emerald-500/15 text-emerald-400 border-transparent text-[10px] font-bold uppercase">
                <Star className="h-2.5 w-2.5 mr-0.5" /> Up to 18.5% APY
              </Badge>
            </div>
            <p className="text-sm text-muted-foreground mt-1 max-w-xl">
              Put your idle crypto to work. Choose flexible savings (withdraw any time)
              or locked products for the best yields.
            </p>
          </div>
          <div className="grid grid-cols-2 gap-3 lg:gap-4 lg:min-w-[280px]">
            <Card className="p-3 bg-muted/40 border-border/40">
              <div className="text-[10px] font-semibold uppercase text-muted-foreground tracking-wider flex items-center gap-1">
                <Lock className="h-3 w-3" /> Total locked
              </div>
              <div className="text-xl font-bold tabular-nums mt-1" data-testid="stat-total-locked">{fmtNum(totalLocked, 2)}</div>
            </Card>
            <Card className="p-3 bg-muted/40 border-border/40">
              <div className="text-[10px] font-semibold uppercase text-muted-foreground tracking-wider flex items-center gap-1">
                <TrendingUp className="h-3 w-3" /> Total earned
              </div>
              <div className="text-xl font-bold tabular-nums mt-1 text-emerald-400" data-testid="stat-total-earned">{fmtNum(totalEarned, 4)}</div>
            </Card>
          </div>
        </div>
      </Card>

      {/* KYC notice */}
      {kycLevel < 1 && (
        <Card className="p-3 border-amber-500/30 bg-amber-500/5">
          <div className="flex items-start gap-2 text-sm">
            <ShieldCheck className="h-4 w-4 text-amber-400 mt-0.5 flex-shrink-0" />
            <div className="flex-1">
              <span className="font-medium text-amber-400">Complete KYC Level 1</span>
              <span className="text-muted-foreground"> to subscribe to Earn products.</span>
            </div>
            <Button asChild size="sm" variant="outline">
              <Link href="/kyc">Verify now <ArrowRight className="h-3.5 w-3.5 ml-1" /></Link>
            </Button>
          </div>
        </Card>
      )}

      <Tabs defaultValue="products" className="space-y-4">
        <TabsList>
          <TabsTrigger value="products" data-testid="tab-products">
            <Layers className="h-4 w-4 mr-1.5" /> Products
          </TabsTrigger>
          <TabsTrigger value="positions" data-testid="tab-positions">
            <Activity className="h-4 w-4 mr-1.5" /> My Positions
            {activePositions.length > 0 && (
              <Badge variant="outline" className="ml-2 text-[9px] h-4">{activePositions.length}</Badge>
            )}
          </TabsTrigger>
        </TabsList>

        {/* PRODUCTS */}
        <TabsContent value="products" className="space-y-4 mt-0">
          {/* Filters */}
          <div className="flex flex-wrap items-center gap-3">
            <div className="flex items-center gap-1.5 text-sm">
              <Filter className="h-3.5 w-3.5 text-muted-foreground" />
              <span className="text-xs font-semibold uppercase text-muted-foreground tracking-wider">Filter</span>
            </div>
            <Select value={coinFilter} onValueChange={setCoinFilter}>
              <SelectTrigger className="w-[140px] h-8" data-testid="select-coin"><SelectValue /></SelectTrigger>
              <SelectContent>
                {coinOptions.map((c) => (
                  <SelectItem key={c} value={c}>{c === "all" ? "All coins" : c}</SelectItem>
                ))}
              </SelectContent>
            </Select>
            <Select value={typeFilter} onValueChange={setTypeFilter}>
              <SelectTrigger className="w-[150px] h-8" data-testid="select-type"><SelectValue /></SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All types</SelectItem>
                <SelectItem value="simple">Flexible</SelectItem>
                <SelectItem value="advanced">Locked</SelectItem>
              </SelectContent>
            </Select>
            <div className="ml-auto flex items-center gap-2">
              <span className="text-xs text-muted-foreground">Sort by</span>
              <Select value={sortBy} onValueChange={setSortBy}>
                <SelectTrigger className="w-[140px] h-8" data-testid="select-sort"><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="apy">Highest APY</SelectItem>
                  <SelectItem value="duration">Shortest term</SelectItem>
                  <SelectItem value="min">Lowest min</SelectItem>
                </SelectContent>
              </Select>
            </div>
          </div>

          {/* Grid */}
          {productsQ.isLoading ? (
            <Card className="p-8 flex items-center justify-center">
              <Loader2 className="h-6 w-6 animate-spin text-primary" />
            </Card>
          ) : productsQ.isError ? (
            <Card className="p-4 border-rose-500/30 bg-rose-500/5">
              <div className="flex items-center gap-3 text-rose-400 text-sm">
                <AlertCircle className="h-4 w-4" />
                <span>Failed to load products.</span>
                <Button size="sm" variant="outline" onClick={() => productsQ.refetch()}>Retry</Button>
              </div>
            </Card>
          ) : filtered.length === 0 ? (
            <Card className="p-12 text-center border-dashed">
              <Coins className="h-12 w-12 text-muted-foreground mx-auto mb-3 opacity-40" />
              <p className="text-muted-foreground">No products match your filters.</p>
            </Card>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-4">
              {filtered.map((p) => {
                const apy = Number(p.apy);
                const isSimple = p.type === "simple";
                const allowed = isSimple ? canEarnSimple : canEarnAdvanced;
                const subscribed = Number(p.currentSubscribed);
                const cap = Number(p.totalCap);
                const capPct = cap > 0 ? Math.min(100, (subscribed / cap) * 100) : 0;
                const capFull = cap > 0 && subscribed >= cap;

                return (
                  <Card
                    key={p.id}
                    className={`p-4 relative overflow-hidden border ${p.featured ? "border-amber-500/40 bg-gradient-to-br from-amber-500/5 to-card" : "border-border/60"} flex flex-col`}
                    data-testid={`product-card-${p.id}`}
                  >
                    {p.featured && (
                      <Badge className="absolute top-3 right-3 bg-amber-500/20 text-amber-400 border-transparent text-[9px] font-bold uppercase">
                        <Star className="h-2.5 w-2.5 mr-0.5 fill-current" /> Featured
                      </Badge>
                    )}

                    {/* Coin */}
                    <div className="flex items-center gap-3 mb-2">
                      <div className="h-10 w-10 rounded-full bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center text-black font-bold text-sm flex-shrink-0">
                        {p.coinSymbol.charAt(0)}
                      </div>
                      <div>
                        <div className="font-semibold text-sm">{p.coinSymbol}</div>
                        <div className="text-[10px] text-muted-foreground">{p.coinName}</div>
                      </div>
                    </div>

                    <h3 className="font-bold text-base leading-tight mb-1 pr-16">{p.name || `${p.coinSymbol} ${p.type === "simple" ? "Flexible" : `${p.durationDays}d Locked`}`}</h3>
                    {p.description && <p className="text-xs text-muted-foreground mb-3 line-clamp-2">{p.description}</p>}

                    {/* APY */}
                    <div className="my-3">
                      <div className="text-[10px] text-muted-foreground uppercase tracking-wider">Estimated APY</div>
                      <div className="text-3xl font-extrabold tabular-nums bg-gradient-to-r from-amber-400 to-emerald-400 bg-clip-text text-transparent">
                        {fmtPct(apy)}
                      </div>
                    </div>

                    <Separator className="my-2" />

                    {/* Specs */}
                    <div className="grid grid-cols-2 gap-2 text-xs my-2">
                      <div>
                        <div className="text-[10px] text-muted-foreground uppercase">Type</div>
                        <div className="font-medium flex items-center gap-1">
                          {isSimple ? <><Unlock className="h-3 w-3" /> Flexible</> : <><Lock className="h-3 w-3" /> Locked</>}
                        </div>
                      </div>
                      <div>
                        <div className="text-[10px] text-muted-foreground uppercase">Duration</div>
                        <div className="font-medium flex items-center gap-1">
                          <Calendar className="h-3 w-3" /> {p.durationDays === 0 ? "Flexible" : `${p.durationDays}d`}
                        </div>
                      </div>
                      <div>
                        <div className="text-[10px] text-muted-foreground uppercase">Min</div>
                        <div className="font-medium tabular-nums">{fmtNum(p.minAmount)} {p.coinSymbol}</div>
                      </div>
                      <div>
                        <div className="text-[10px] text-muted-foreground uppercase">Max per user</div>
                        <div className="font-medium tabular-nums">{fmtNum(p.maxAmount)} {p.coinSymbol}</div>
                      </div>
                    </div>

                    {/* Cap progress */}
                    {cap > 0 && (
                      <div className="my-2">
                        <div className="flex items-center justify-between text-[10px] text-muted-foreground mb-1">
                          <span>Pool filled</span>
                          <span className="tabular-nums">{capPct.toFixed(1)}%</span>
                        </div>
                        <div className="h-1.5 bg-muted rounded-full overflow-hidden">
                          <div className="h-full bg-gradient-to-r from-amber-500 to-orange-500 transition-all" style={{ width: `${capPct}%` }} />
                        </div>
                      </div>
                    )}

                    <div className="mt-auto pt-3">
                      <Button
                        onClick={() => setSubProduct(p)}
                        disabled={capFull || !allowed}
                        className="w-full bg-gradient-to-r from-amber-500 to-orange-500 text-black hover:from-amber-400 hover:to-orange-400 font-semibold disabled:opacity-50 disabled:from-zinc-600 disabled:to-zinc-700"
                        data-testid={`button-subscribe-${p.id}`}
                      >
                        {capFull ? "Pool Full" : !allowed ? `KYC L${isSimple ? 1 : 2} required` : <>Subscribe <ArrowRight className="h-4 w-4 ml-1.5" /></>}
                      </Button>
                    </div>
                  </Card>
                );
              })}
            </div>
          )}
        </TabsContent>

        {/* POSITIONS */}
        <TabsContent value="positions" className="space-y-3 mt-0">
          {positionsQ.isLoading ? (
            <Card className="p-8 flex items-center justify-center">
              <Loader2 className="h-6 w-6 animate-spin text-primary" />
            </Card>
          ) : positionsQ.isError ? (
            <Card className="p-4 border-rose-500/30 bg-rose-500/5">
              <div className="flex items-center gap-3 text-rose-400 text-sm">
                <AlertCircle className="h-4 w-4" />
                <span>Sign in to view your positions.</span>
                <Button asChild size="sm" variant="outline">
                  <Link href="/login">Sign in</Link>
                </Button>
              </div>
            </Card>
          ) : positions.length === 0 ? (
            <Card className="p-12 text-center border-dashed">
              <Activity className="h-12 w-12 text-muted-foreground mx-auto mb-3 opacity-40" />
              <h3 className="text-lg font-semibold mb-1">No active positions</h3>
              <p className="text-sm text-muted-foreground mb-4">Subscribe to a product above to start earning passive yield.</p>
            </Card>
          ) : (
            <div className="space-y-2">
              {positions.map((pos) => {
                const product = products.find((p) => p.id === pos.productId);
                const isActive = pos.status === "active";
                const isLocked = (product?.durationDays ?? 0) > 0;
                const matured = pos.maturityAt && new Date(pos.maturityAt) <= new Date();
                const remainingDays = pos.maturityAt && !matured ? daysBetween(new Date().toISOString(), pos.maturityAt) : 0;

                return (
                  <Card key={pos.id} className="p-4 border-border/60" data-testid={`position-${pos.id}`}>
                    <div className="flex flex-col sm:flex-row sm:items-center gap-4">
                      <div className="h-10 w-10 rounded-full bg-gradient-to-br from-amber-400 to-orange-500 flex items-center justify-center text-black font-bold text-sm flex-shrink-0">
                        {(product?.coinSymbol ?? "?").charAt(0)}
                      </div>
                      <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2 flex-wrap">
                          <span className="font-semibold">{product?.name || `Product #${pos.productId}`}</span>
                          <PositionBadge status={pos.status} matured={!!matured} />
                          {pos.autoRenew && (
                            <Badge variant="outline" className="text-[9px]"><Zap className="h-2.5 w-2.5 mr-0.5" /> Auto-renew</Badge>
                          )}
                        </div>
                        <div className="text-xs text-muted-foreground mt-0.5">
                          {fmtNum(pos.amount)} {product?.coinSymbol} · {fmtPct(product?.apy ?? 0)} APY
                          {isLocked && pos.maturityAt && (
                            <> · Matures {new Date(pos.maturityAt).toLocaleDateString()}</>
                          )}
                        </div>
                        {isActive && isLocked && pos.maturityAt && !matured && (
                          <div className="text-xs text-amber-400 mt-1 flex items-center gap-1">
                            <Hourglass className="h-3 w-3" /> {remainingDays}d remaining
                          </div>
                        )}
                      </div>
                      <div className="text-right">
                        <div className="text-[10px] text-muted-foreground uppercase">Earned</div>
                        <div className="text-lg font-bold tabular-nums text-emerald-400">{fmtNum(pos.totalEarned, 6)}</div>
                      </div>
                      {isActive && (
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => setRedeemFor(pos)}
                          data-testid={`button-redeem-${pos.id}`}
                        >
                          {matured || !isLocked ? "Redeem" : "Early redeem"}
                        </Button>
                      )}
                    </div>
                  </Card>
                );
              })}
            </div>
          )}
        </TabsContent>
      </Tabs>

      {/* Subscribe dialog */}
      <SubscribeDialog
        product={subProduct}
        onOpenChange={(v) => { if (!v) setSubProduct(null); }}
        onSuccess={() => {
          qc.invalidateQueries({ queryKey: ["/earn/positions"] });
          qc.invalidateQueries({ queryKey: ["/earn/products"] });
          qc.invalidateQueries({ queryKey: ["/wallets"] });
          setSubProduct(null);
        }}
      />

      {/* Redeem dialog */}
      <RedeemDialog
        position={redeemFor}
        product={redeemFor ? products.find((p) => p.id === redeemFor.productId) ?? null : null}
        onOpenChange={(v) => { if (!v) setRedeemFor(null); }}
        onSuccess={() => {
          qc.invalidateQueries({ queryKey: ["/earn/positions"] });
          qc.invalidateQueries({ queryKey: ["/wallets"] });
          setRedeemFor(null);
        }}
      />
    </div>
  );
}

function PositionBadge({ status, matured }: { status: string; matured: boolean }) {
  if (status === "active" && matured) return <Badge className="bg-emerald-500/15 text-emerald-400 border-transparent text-[9px]">MATURED</Badge>;
  if (status === "active") return <Badge className="bg-sky-500/15 text-sky-400 border-transparent text-[9px]">ACTIVE</Badge>;
  if (status === "matured") return <Badge className="bg-emerald-500/15 text-emerald-400 border-transparent text-[9px]">MATURED</Badge>;
  if (status === "redeemed") return <Badge className="bg-zinc-500/15 text-zinc-400 border-transparent text-[9px]">REDEEMED</Badge>;
  if (status === "cancelled") return <Badge className="bg-rose-500/15 text-rose-400 border-transparent text-[9px]">CANCELLED</Badge>;
  return <Badge variant="outline" className="text-[9px]">{status.toUpperCase()}</Badge>;
}

// ───────────────── Subscribe dialog ─────────────────
function SubscribeDialog({
  product, onOpenChange, onSuccess,
}: { product: EarnProduct | null; onOpenChange: (v: boolean) => void; onSuccess: () => void }) {
  const [amount, setAmount] = useState("");
  const [autoRenew, setAutoRenew] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  // Wallet balances
  const walletQ = useQuery<Array<{ coinId: number; balance: string; walletType: string }>>({
    queryKey: ["/wallets"],
    queryFn: () => get("/wallets"),
    enabled: product !== null,
  });
  const balance = useMemo(() => {
    if (!product || !walletQ.data) return 0;
    const spot = walletQ.data.find((w) => w.coinId === product.coinId && w.walletType === "spot");
    return Number(spot?.balance ?? 0);
  }, [walletQ.data, product]);

  const reset = () => { setAmount(""); setAutoRenew(false); setSubmitting(false); };
  const num = Number(amount);
  const min = Number(product?.minAmount ?? 0);
  const max = Number(product?.maxAmount ?? 0);
  const apy = Number(product?.apy ?? 0);
  const days = product?.durationDays ?? 0;
  const projectedEarn = days > 0 ? (num * apy / 100) * (days / 365) : (num * apy / 100); // 1y for flex
  const isLocked = days > 0;

  const validation =
    !product ? null
    : !amount || num <= 0 ? "Enter an amount"
    : num < min ? `Minimum ${fmtNum(min)} ${product.coinSymbol}`
    : max > 0 && num > max ? `Maximum ${fmtNum(max)} ${product.coinSymbol}`
    : num > balance ? `Insufficient balance (${fmtNum(balance)} ${product.coinSymbol} available)`
    : null;

  const submit = async () => {
    if (validation || !product) return;
    setSubmitting(true);
    try {
      await post("/earn/subscribe", { productId: product.id, amount: num, autoRenew });
      toast({ title: "Subscribed!", description: `${fmtNum(num)} ${product.coinSymbol} earning ${fmtPct(apy)} APY.` });
      reset();
      onSuccess();
    } catch (e: any) {
      const msg = e instanceof ApiError ? (e.data?.error || e.message) : e?.message;
      toast({ title: "Subscribe failed", description: msg, variant: "destructive" });
      setSubmitting(false);
    }
  };

  return (
    <Dialog open={!!product} onOpenChange={(v) => { if (!v) reset(); onOpenChange(v); }}>
      <DialogContent className="sm:max-w-md">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Coins className="h-5 w-5 text-amber-400" /> Subscribe to {product?.name}
          </DialogTitle>
          <DialogDescription>
            {isLocked ? `Locked for ${days} days at ${fmtPct(apy)} APY.` : `Flexible savings at ${fmtPct(apy)} APY — withdraw any time.`}
          </DialogDescription>
        </DialogHeader>

        {product && (
          <div className="space-y-3">
            <div className="flex items-center justify-between text-sm">
              <span className="text-muted-foreground">Available</span>
              <button
                type="button"
                onClick={() => setAmount(String(Math.min(balance, max > 0 ? max : balance)))}
                className="font-mono font-medium hover:text-amber-400"
                data-testid="button-max"
              >
                {fmtNum(balance)} {product.coinSymbol}
              </button>
            </div>

            <div>
              <Label htmlFor="amt">Amount</Label>
              <div className="relative">
                <Input
                  id="amt"
                  value={amount}
                  onChange={(e) => setAmount(e.target.value.replace(/[^0-9.]/g, ""))}
                  placeholder={`Min ${fmtNum(min)}`}
                  inputMode="decimal"
                  className="pr-16 font-mono"
                  data-testid="input-amount"
                />
                <span className="absolute right-3 top-1/2 -translate-y-1/2 text-sm text-muted-foreground">{product.coinSymbol}</span>
              </div>
            </div>

            {/* Specs */}
            <div className="rounded-lg bg-muted/30 p-3 space-y-1.5 text-xs">
              <Row label="Estimated APY" value={fmtPct(apy)} highlight />
              <Row label="Duration" value={isLocked ? `${days} days` : "Flexible"} />
              <Row label="Payout interval" value={product.payoutInterval} />
              <Row label="Compounding" value={product.compounding ? "Yes (auto)" : "No"} />
              {isLocked && (
                <Row
                  label="Early redemption"
                  value={product.earlyRedemption ? `Allowed (${fmtPct(product.earlyRedemptionPenaltyPct)} penalty)` : "Not allowed"}
                />
              )}
              <Separator className="my-1" />
              <Row
                label={isLocked ? `Projected earn over ${days}d` : "Projected earn (1y)"}
                value={`${fmtNum(projectedEarn, 6)} ${product.coinSymbol}`}
                highlight
              />
            </div>

            {isLocked && (
              <div className="flex items-center justify-between p-3 rounded-lg bg-muted/30 border border-border/40">
                <div className="text-sm">
                  <div className="font-medium">Auto-renew on maturity</div>
                  <p className="text-xs text-muted-foreground">Re-subscribe automatically when this position matures.</p>
                </div>
                <Switch checked={autoRenew} onCheckedChange={setAutoRenew} data-testid="switch-auto-renew" />
              </div>
            )}

            {validation && (
              <p className="text-xs text-rose-400 flex items-center gap-1.5"><AlertCircle className="h-3.5 w-3.5" /> {validation}</p>
            )}
          </div>
        )}

        <DialogFooter>
          <Button variant="ghost" onClick={() => onOpenChange(false)}>Cancel</Button>
          <Button onClick={submit} disabled={!!validation || submitting} data-testid="button-confirm-subscribe">
            {submitting ? <Loader2 className="h-4 w-4 mr-1.5 animate-spin" /> : <Coins className="h-4 w-4 mr-1.5" />}
            Confirm
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function Row({ label, value, highlight }: { label: string; value: string; highlight?: boolean }) {
  return (
    <div className="flex items-center justify-between">
      <span className="text-muted-foreground">{label}</span>
      <span className={highlight ? "font-bold text-emerald-400 tabular-nums" : "tabular-nums"}>{value}</span>
    </div>
  );
}

// ───────────────── Redeem dialog ─────────────────
function RedeemDialog({
  position, product, onOpenChange, onSuccess,
}: { position: EarnPosition | null; product: EarnProduct | null; onOpenChange: (v: boolean) => void; onSuccess: () => void }) {
  const [submitting, setSubmitting] = useState(false);

  const isLocked = (product?.durationDays ?? 0) > 0;
  const matured = position?.maturityAt ? new Date(position.maturityAt) <= new Date() : !isLocked;
  const isEarly = !matured;
  const penalty = Number(product?.earlyRedemptionPenaltyPct ?? 0);
  const amount = Number(position?.amount ?? 0);
  const earned = Number(position?.totalEarned ?? 0);
  const penaltyAmt = isEarly ? amount * penalty / 100 : 0;
  const expectedReturn = amount + earned - penaltyAmt;

  const submit = async () => {
    if (!position) return;
    setSubmitting(true);
    try {
      await post(`/earn/positions/${position.id}/redeem`, {});
      toast({ title: "Redeemed", description: `${fmtNum(expectedReturn, 6)} ${product?.coinSymbol ?? ""} returned to your spot wallet.` });
      onSuccess();
    } catch (e: any) {
      const msg = e instanceof ApiError ? (e.data?.error || e.message) : e?.message;
      toast({ title: "Redeem failed", description: msg, variant: "destructive" });
      setSubmitting(false);
    }
  };

  return (
    <AlertDialog open={!!position} onOpenChange={onOpenChange}>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle className="flex items-center gap-2">
            {isEarly ? <Hourglass className="h-5 w-5 text-amber-400" /> : <Unlock className="h-5 w-5 text-emerald-400" />}
            {isEarly ? "Redeem early?" : "Redeem position"}
          </AlertDialogTitle>
          <AlertDialogDescription>
            {isEarly && product?.earlyRedemption === false ? (
              <span className="text-rose-400">Early redemption is not allowed for this product. The position will be available after maturity.</span>
            ) : (
              <>
                {isEarly && (
                  <span className="block mb-2 text-amber-400">
                    Redeeming before maturity incurs a {fmtPct(penalty)} penalty on your principal.
                  </span>
                )}
                <span className="block mt-1">You'll receive:</span>
              </>
            )}
          </AlertDialogDescription>
        </AlertDialogHeader>

        {position && product && (isEarly ? product.earlyRedemption : true) && (
          <div className="rounded-lg bg-muted/40 p-3 space-y-1.5 text-sm">
            <Row label="Principal" value={`${fmtNum(amount, 6)} ${product.coinSymbol}`} />
            <Row label="Earned" value={`${fmtNum(earned, 6)} ${product.coinSymbol}`} />
            {isEarly && penalty > 0 && (
              <Row label={`Penalty (${fmtPct(penalty)})`} value={`-${fmtNum(penaltyAmt, 6)} ${product.coinSymbol}`} />
            )}
            <Separator className="my-1" />
            <Row label="You receive" value={`${fmtNum(expectedReturn, 6)} ${product.coinSymbol}`} highlight />
          </div>
        )}

        <AlertDialogFooter>
          <AlertDialogCancel>Cancel</AlertDialogCancel>
          <AlertDialogAction
            onClick={submit}
            disabled={submitting || (isEarly && product?.earlyRedemption === false)}
            className="bg-gradient-to-r from-amber-500 to-orange-500 text-black hover:from-amber-400 hover:to-orange-400 font-semibold"
            data-testid="button-confirm-redeem"
          >
            {submitting ? <Loader2 className="h-4 w-4 mr-1.5 animate-spin" /> : <ChevronDown className="h-4 w-4 mr-1.5" />}
            Confirm Redeem
          </AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
