import { useMemo, useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, del, patch } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { useToast } from "@/hooks/use-toast";
import { cn } from "@/lib/utils";
import { PageHeader } from "@/components/premium/PageHeader";
import { PremiumStatCard } from "@/components/premium/PremiumStatCard";
import { StatusPill } from "@/components/premium/StatusPill";
import { EmptyState } from "@/components/premium/EmptyState";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Skeleton } from "@/components/ui/skeleton";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { Progress } from "@/components/ui/progress";
import {
  Select, SelectContent, SelectItem, SelectTrigger, SelectValue,
} from "@/components/ui/select";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter, DialogDescription,
} from "@/components/ui/dialog";
import {
  Plus, Trash2, Pencil, Search, Star, Lock, TrendingUp, Coins,
  Users, Wallet, Sparkles, PiggyBank, Loader2, AlertTriangle,
  Calendar, Award, Settings,
} from "lucide-react";

type Coin = { id: number; symbol: string; name?: string };
type Product = {
  id: number;
  coinId: number;
  name: string;
  description: string;
  type: string;
  durationDays: number;
  apy: string;
  minAmount: string;
  maxAmount: string;
  totalCap: string;
  currentSubscribed: string;
  payoutInterval: string;
  compounding: boolean;
  earlyRedemption: boolean;
  earlyRedemptionPenaltyPct: string;
  minVipTier: number;
  featured: boolean;
  displayOrder: number;
  saleStartAt: string | null;
  saleEndAt: string | null;
  status: string;
  createdAt: string;
};
type Position = {
  id: number;
  userId: number;
  productId: number;
  amount: string;
  totalEarned: string;
  autoMaturity: boolean;
  status: string;
  startedAt: string;
  maturedAt: string | null;
  closedAt: string | null;
};
type Stats = {
  totalProducts: number;
  activeProducts: number;
  totalCap: number;
  totalSubscribed: number;
  activePositions: number;
  totalPositionAmount: number;
  totalEarned: number;
};

const blank: Partial<Product> = {
  name: "",
  description: "",
  type: "simple",
  durationDays: 0,
  apy: "5",
  minAmount: "0",
  maxAmount: "0",
  totalCap: "0",
  payoutInterval: "daily",
  compounding: false,
  earlyRedemption: false,
  earlyRedemptionPenaltyPct: "0",
  minVipTier: 0,
  featured: false,
  displayOrder: 0,
  saleStartAt: null,
  saleEndAt: null,
  status: "active",
};

function fmt(n: number | string, dp = 2): string {
  const v = typeof n === "string" ? Number(n) : n;
  if (!Number.isFinite(v)) return "0";
  return v.toLocaleString("en-IN", { maximumFractionDigits: dp });
}

function toDateInput(iso: string | null | undefined): string {
  if (!iso) return "";
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return "";
  const pad = (x: number) => String(x).padStart(2, "0");
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}T${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

export default function EarnPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const { toast } = useToast();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";

  const { data: coins = [] } = useQuery<Coin[]>({
    queryKey: ["/admin/coins"],
    queryFn: () => get<Coin[]>("/admin/coins"),
  });
  const { data: products = [], isLoading: prodLoading } = useQuery<Product[]>({
    queryKey: ["/admin/earn-products"],
    queryFn: () => get<Product[]>("/admin/earn-products"),
  });
  const { data: positions = [], isLoading: posLoading } = useQuery<Position[]>({
    queryKey: ["/admin/earn-positions"],
    queryFn: () => get<Position[]>("/admin/earn-positions"),
  });
  const { data: stats } = useQuery<Stats>({
    queryKey: ["/admin/earn-stats"],
    queryFn: () => get<Stats>("/admin/earn-stats"),
  });

  const [search, setSearch] = useState("");
  const [coinFilter, setCoinFilter] = useState<string>("all");
  const [typeFilter, setTypeFilter] = useState<string>("all");
  const [statusFilter, setStatusFilter] = useState<string>("all");
  const [tab, setTab] = useState("products");

  const [addOpen, setAddOpen] = useState(false);
  const [editing, setEditing] = useState<Product | null>(null);
  const [deleteFor, setDeleteFor] = useState<Product | null>(null);
  const [draft, setDraft] = useState<Partial<Product>>(blank);

  const inv = () => {
    qc.invalidateQueries({ queryKey: ["/admin/earn-products"] });
    qc.invalidateQueries({ queryKey: ["/admin/earn-stats"] });
  };

  const create = useMutation({
    mutationFn: () => post("/admin/earn-products", draft),
    onSuccess: () => {
      inv(); setAddOpen(false); setDraft(blank);
      toast({ title: "Product created", description: draft.name || "New earn product live." });
    },
    onError: (e: Error) => toast({ title: "Create failed", description: e.message, variant: "destructive" }),
  });
  const update = useMutation({
    mutationFn: ({ id, body }: { id: number; body: Partial<Product> }) =>
      patch(`/admin/earn-products/${id}`, body),
    onSuccess: (_d, v) => {
      inv(); setEditing(null);
      toast({ title: "Product updated", description: v.body.status ? `Status → ${v.body.status}` : undefined });
    },
    onError: (e: Error) => toast({ title: "Update failed", description: e.message, variant: "destructive" }),
  });
  const remove = useMutation({
    mutationFn: (id: number) => del(`/admin/earn-products/${id}`),
    onSuccess: () => { inv(); setDeleteFor(null); toast({ title: "Product deleted" }); },
    onError: (e: Error) => toast({ title: "Delete failed", description: e.message, variant: "destructive" }),
  });

  const coinMap = useMemo(() => {
    const m = new Map<number, Coin>();
    coins.forEach((c) => m.set(c.id, c));
    return m;
  }, [coins]);

  const filtered = useMemo(() => {
    return products.filter((p) => {
      const sym = coinMap.get(p.coinId)?.symbol ?? "";
      const hay = `${sym} ${p.name} ${p.description}`.toLowerCase();
      if (search && !hay.includes(search.toLowerCase())) return false;
      if (coinFilter !== "all" && String(p.coinId) !== coinFilter) return false;
      if (typeFilter !== "all" && p.type !== typeFilter) return false;
      if (statusFilter !== "all" && p.status !== statusFilter) return false;
      return true;
    });
  }, [products, search, coinFilter, typeFilter, statusFilter, coinMap]);

  const featuredCount = useMemo(() => products.filter((p) => p.featured).length, [products]);

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Earn & CMS"
        title="Earn Products"
        description="Staking, savings & locked yield products. APY, lock duration, cap & VIP gating yahan se manage hota hai."
        actions={
          isAdmin && (
            <Button onClick={() => { setDraft(blank); setAddOpen(true); }} data-testid="button-add-product">
              <Plus className="w-4 h-4 mr-1" />Add Product
            </Button>
          )
        }
      />

      <div className="grid grid-cols-2 md:grid-cols-3 xl:grid-cols-6 gap-3 md:gap-4">
        <PremiumStatCard
          title="Active Products"
          value={`${stats?.activeProducts ?? 0} / ${stats?.totalProducts ?? 0}`}
          icon={Coins}
          hero
          hint="Active / Total"
        />
        <PremiumStatCard title="Subscribed" value={fmt(stats?.totalSubscribed ?? 0, 4)} icon={Wallet} hint={`Cap ${fmt(stats?.totalCap ?? 0, 0)}`} />
        <PremiumStatCard title="Active Positions" value={fmt(stats?.activePositions ?? 0, 0)} icon={Users} hint={`${fmt(stats?.totalPositionAmount ?? 0, 4)} locked`} />
        <PremiumStatCard title="Yield Paid" value={fmt(stats?.totalEarned ?? 0, 4)} icon={TrendingUp} hint="All-time" />
        <PremiumStatCard title="Featured" value={featuredCount} icon={Star} hint="On home" />
        <PremiumStatCard title="Subscriptions" value={positions.length} icon={PiggyBank} hint={`${positions.filter((p) => p.status === "active").length} active`} />
      </div>

      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="products" data-testid="tab-products">Products ({products.length})</TabsTrigger>
          <TabsTrigger value="positions" data-testid="tab-positions">Subscriptions ({positions.length})</TabsTrigger>
        </TabsList>

        <TabsContent value="products" className="space-y-4 mt-4">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-3">
            <div className="flex flex-wrap gap-2">
              <Select value={coinFilter} onValueChange={setCoinFilter}>
                <SelectTrigger className="w-32" data-testid="filter-coin"><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All coins</SelectItem>
                  {coins.map((c) => <SelectItem key={c.id} value={String(c.id)}>{c.symbol}</SelectItem>)}
                </SelectContent>
              </Select>
              <Select value={typeFilter} onValueChange={setTypeFilter}>
                <SelectTrigger className="w-36" data-testid="filter-type"><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All types</SelectItem>
                  <SelectItem value="simple">Simple (Flexible)</SelectItem>
                  <SelectItem value="advanced">Advanced (Locked)</SelectItem>
                </SelectContent>
              </Select>
              <Select value={statusFilter} onValueChange={setStatusFilter}>
                <SelectTrigger className="w-32" data-testid="filter-status"><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All status</SelectItem>
                  <SelectItem value="active">Active</SelectItem>
                  <SelectItem value="paused">Paused</SelectItem>
                  <SelectItem value="ended">Ended</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="relative w-full md:w-72">
              <Search className="w-4 h-4 absolute left-2.5 top-2.5 text-muted-foreground" />
              <Input placeholder="Coin, name, description…" value={search} onChange={(e) => setSearch(e.target.value)} className="pl-8" data-testid="input-search" />
            </div>
          </div>

          <div className="premium-card rounded-xl overflow-hidden border border-border/60">
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="bg-muted/30 text-[11px] uppercase tracking-wider text-muted-foreground">
                  <tr>
                    <th className="text-left font-medium px-4 py-3 pl-5">#</th>
                    <th className="text-left font-medium px-4 py-3">Product</th>
                    <th className="text-left font-medium px-4 py-3">Type</th>
                    <th className="text-left font-medium px-4 py-3">Duration</th>
                    <th className="text-right font-medium px-4 py-3">APY</th>
                    <th className="text-left font-medium px-4 py-3">Range</th>
                    <th className="text-left font-medium px-4 py-3 min-w-[160px]">Subscribed</th>
                    <th className="text-left font-medium px-4 py-3">Flags</th>
                    <th className="text-left font-medium px-4 py-3">Status</th>
                    {isAdmin && <th className="text-right font-medium px-4 py-3 pr-5">Actions</th>}
                  </tr>
                </thead>
                <tbody className="divide-y divide-border/50">
                  {prodLoading && Array.from({ length: 5 }).map((_, i) => (
                    <tr key={i}><td colSpan={isAdmin ? 10 : 9} className="px-4 py-3"><Skeleton className="h-9 w-full" /></td></tr>
                  ))}
                  {!prodLoading && filtered.length === 0 && (
                    <tr><td colSpan={isAdmin ? 10 : 9} className="px-4 py-3">
                      <EmptyState
                        icon={PiggyBank}
                        title="No products match"
                        description={search || coinFilter !== "all" || typeFilter !== "all" || statusFilter !== "all"
                          ? "Filter adjust karein."
                          : "Pehla earn product add karein — flexible savings ya locked staking."}
                        action={isAdmin && !search && coinFilter === "all" && typeFilter === "all" && statusFilter === "all"
                          ? <Button onClick={() => { setDraft(blank); setAddOpen(true); }}><Plus className="w-4 h-4 mr-1" />Add product</Button>
                          : undefined}
                      />
                    </td></tr>
                  )}
                  {!prodLoading && filtered.map((p) => {
                    const coin = coinMap.get(p.coinId);
                    const sym = coin?.symbol ?? `#${p.coinId}`;
                    const cap = Number(p.totalCap);
                    const sub = Number(p.currentSubscribed);
                    const pct = cap > 0 ? Math.min(100, (sub / cap) * 100) : 0;
                    return (
                      <tr key={p.id} className="hover:bg-muted/20 transition-colors" data-testid={`row-product-${p.id}`}>
                        <td className="px-4 py-3 pl-5 text-xs text-muted-foreground tabular-nums">{p.displayOrder || "—"}</td>
                        <td className="px-4 py-3 max-w-[260px]">
                          <div className="flex items-center gap-2">
                            <span className="font-bold">{sym}</span>
                            {p.name && <span className="text-xs text-muted-foreground truncate">· {p.name}</span>}
                          </div>
                          {p.description && (
                            <span className="text-[11px] text-muted-foreground line-clamp-1">{p.description}</span>
                          )}
                        </td>
                        <td className="px-4 py-3">
                          <span className={cn(
                            "px-1.5 py-0.5 rounded text-[10px] font-medium border",
                            p.type === "advanced"
                              ? "bg-amber-500/15 text-amber-300 border-amber-500/30"
                              : "bg-emerald-500/15 text-emerald-300 border-emerald-500/25",
                          )}>
                            {p.type === "advanced" ? "Locked" : "Flexible"}
                          </span>
                        </td>
                        <td className="px-4 py-3 text-xs">
                          <div className="font-medium">{p.durationDays === 0 ? "Flexible" : `${p.durationDays}d`}</div>
                          <div className="text-[10px] text-muted-foreground capitalize">{p.payoutInterval}</div>
                        </td>
                        <td className="px-4 py-3 text-right">
                          <span className="font-bold gold-text tabular-nums">{fmt(p.apy, 2)}%</span>
                        </td>
                        <td className="px-4 py-3 text-xs">
                          <div className="font-mono">min {fmt(p.minAmount, 4)}</div>
                          <div className="text-[10px] text-muted-foreground font-mono">max {Number(p.maxAmount) > 0 ? fmt(p.maxAmount, 4) : "∞"}</div>
                        </td>
                        <td className="px-4 py-3">
                          {cap > 0 ? (
                            <div className="space-y-1 min-w-[140px]">
                              <Progress value={pct} className="h-1.5" />
                              <div className="text-[10px] text-muted-foreground tabular-nums">
                                {fmt(sub, 2)} / {fmt(cap, 2)} <span className="gold-text">({pct.toFixed(1)}%)</span>
                              </div>
                            </div>
                          ) : (
                            <div className="text-xs text-muted-foreground">No cap · <span className="font-mono">{fmt(sub, 2)}</span></div>
                          )}
                        </td>
                        <td className="px-4 py-3">
                          <div className="flex flex-wrap gap-1">
                            {p.featured && <span className="inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded text-[10px] font-medium gold-bg-soft text-amber-300 border border-amber-500/30"><Star className="w-3 h-3" />Featured</span>}
                            {p.compounding && <span className="inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded text-[10px] font-medium bg-sky-500/15 text-sky-300 border border-sky-500/30"><Sparkles className="w-3 h-3" />Compound</span>}
                            {p.earlyRedemption && <span className="px-1.5 py-0.5 rounded text-[10px] font-medium bg-muted/40 border border-border/60">Early Exit</span>}
                            {p.minVipTier > 0 && <span className="inline-flex items-center gap-0.5 px-1.5 py-0.5 rounded text-[10px] font-medium bg-purple-500/15 text-purple-300 border border-purple-500/30"><Lock className="w-3 h-3" />VIP {p.minVipTier}+</span>}
                          </div>
                        </td>
                        <td className="px-4 py-3">
                          {isAdmin ? (
                            <Select
                              value={p.status}
                              onValueChange={(s) => update.mutate({ id: p.id, body: { status: s } })}
                            >
                              <SelectTrigger className="h-7 w-24 text-xs" data-testid={`status-${p.id}`}><SelectValue /></SelectTrigger>
                              <SelectContent>
                                <SelectItem value="active">Active</SelectItem>
                                <SelectItem value="paused">Paused</SelectItem>
                                <SelectItem value="ended">Ended</SelectItem>
                              </SelectContent>
                            </Select>
                          ) : (
                            <StatusPill status={p.status} />
                          )}
                        </td>
                        {isAdmin && (
                          <td className="px-4 py-3 pr-4 text-right whitespace-nowrap">
                            <div className="inline-flex items-center gap-1">
                              <Button size="icon" variant="ghost" onClick={() => { setDraft(p); setEditing(p); }} data-testid={`button-edit-${p.id}`}>
                                <Pencil className="w-3.5 h-3.5" />
                              </Button>
                              <Button size="icon" variant="ghost" onClick={() => setDeleteFor(p)} data-testid={`button-delete-${p.id}`}>
                                <Trash2 className="w-3.5 h-3.5 text-destructive" />
                              </Button>
                            </div>
                          </td>
                        )}
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
            <div className="border-t border-border/60 px-4 py-2.5 flex items-center justify-between text-xs text-muted-foreground bg-muted/10">
              <div>{filtered.length} of {products.length} products</div>
              <div className="flex items-center gap-3">
                <span className="inline-flex items-center gap-1"><span className="w-1.5 h-1.5 rounded-full bg-emerald-400" />{products.filter((p) => p.status === "active").length} active</span>
                <span className="inline-flex items-center gap-1"><span className="w-1.5 h-1.5 rounded-full bg-amber-400" />{products.filter((p) => p.status === "paused").length} paused</span>
                <span className="inline-flex items-center gap-1"><span className="w-1.5 h-1.5 rounded-full bg-muted-foreground/60" />{products.filter((p) => p.status === "ended").length} ended</span>
              </div>
            </div>
          </div>
        </TabsContent>

        <TabsContent value="positions" className="mt-4">
          <div className="premium-card rounded-xl overflow-hidden border border-border/60">
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="bg-muted/30 text-[11px] uppercase tracking-wider text-muted-foreground">
                  <tr>
                    <th className="text-left font-medium px-4 py-3 pl-5">ID</th>
                    <th className="text-left font-medium px-4 py-3">User</th>
                    <th className="text-left font-medium px-4 py-3">Product</th>
                    <th className="text-right font-medium px-4 py-3">Amount</th>
                    <th className="text-right font-medium px-4 py-3">Earned</th>
                    <th className="text-left font-medium px-4 py-3">Started</th>
                    <th className="text-left font-medium px-4 py-3">Matures</th>
                    <th className="text-center font-medium px-4 py-3">Auto</th>
                    <th className="text-left font-medium px-4 py-3 pr-5">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-border/50">
                  {posLoading && Array.from({ length: 4 }).map((_, i) => (
                    <tr key={i}><td colSpan={9} className="px-4 py-3"><Skeleton className="h-9 w-full" /></td></tr>
                  ))}
                  {!posLoading && positions.length === 0 && (
                    <tr><td colSpan={9} className="px-4 py-3">
                      <EmptyState icon={PiggyBank} title="No subscriptions yet" description="Users abhi tak kisi product me subscribe nahi kiye." />
                    </td></tr>
                  )}
                  {!posLoading && positions.map((pos) => {
                    const prod = products.find((x) => x.id === pos.productId);
                    const sym = prod ? (coinMap.get(prod.coinId)?.symbol ?? `#${prod.coinId}`) : `prod ${pos.productId}`;
                    return (
                      <tr key={pos.id} className="hover:bg-muted/20 transition-colors" data-testid={`row-position-${pos.id}`}>
                        <td className="px-4 py-3 pl-5 font-mono text-[10px] text-muted-foreground">#{pos.id}</td>
                        <td className="px-4 py-3 font-mono text-xs">user-{pos.userId}</td>
                        <td className="px-4 py-3">
                          <div className="font-bold">{sym}</div>
                          <div className="text-[10px] text-muted-foreground">{prod?.name || `#${pos.productId}`} · <span className="gold-text">{prod?.apy ?? "—"}%</span></div>
                        </td>
                        <td className="px-4 py-3 text-right font-mono tabular-nums">{fmt(pos.amount, 8)}</td>
                        <td className="px-4 py-3 text-right font-mono tabular-nums gold-text">{fmt(pos.totalEarned, 8)}</td>
                        <td className="px-4 py-3 text-xs text-muted-foreground">{new Date(pos.startedAt).toLocaleDateString("en-IN")}</td>
                        <td className="px-4 py-3 text-xs text-muted-foreground">{pos.maturedAt ? new Date(pos.maturedAt).toLocaleDateString("en-IN") : "—"}</td>
                        <td className="px-4 py-3 text-center">
                          {pos.autoMaturity ? <span className="inline-flex w-2 h-2 rounded-full bg-emerald-400" title="Auto-renew on" /> : <span className="text-muted-foreground text-xs">—</span>}
                        </td>
                        <td className="px-4 py-3 pr-4"><StatusPill status={pos.status} /></td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </TabsContent>
      </Tabs>

      <ProductDialog
        open={addOpen}
        onOpenChange={setAddOpen}
        title="Add Earn Product"
        coins={coins}
        draft={draft}
        setDraft={setDraft}
        onSubmit={() => create.mutate()}
        submitting={create.isPending}
        isCreate
      />
      <ProductDialog
        open={!!editing}
        onOpenChange={(o) => { if (!o) setEditing(null); }}
        title={editing ? `Edit · ${coinMap.get(editing.coinId)?.symbol ?? ""} ${editing.name}` : "Edit"}
        coins={coins}
        draft={draft}
        setDraft={setDraft}
        onSubmit={() => editing && update.mutate({ id: editing.id, body: draft })}
        submitting={update.isPending}
        isCreate={false}
      />

      <Dialog open={!!deleteFor} onOpenChange={(o) => { if (!o) setDeleteFor(null); }}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle className="flex items-center gap-2"><AlertTriangle className="w-5 h-5 text-destructive" />Delete Product?</DialogTitle>
            <DialogDescription>
              Yeh product permanently delete ho jayega. Active positions me koi asar nahi hoga, lekin nayi subscriptions band ho jayengi.
            </DialogDescription>
          </DialogHeader>
          {deleteFor && (
            <div className="rounded-lg border border-border/60 bg-muted/30 p-3 text-xs space-y-1">
              <div><span className="text-muted-foreground">Product:</span> <span className="font-semibold">{coinMap.get(deleteFor.coinId)?.symbol ?? "—"} {deleteFor.name}</span></div>
              <div><span className="text-muted-foreground">APY:</span> <span className="gold-text font-semibold">{fmt(deleteFor.apy, 2)}%</span></div>
              <div><span className="text-muted-foreground">Subscribed:</span> <span className="font-mono">{fmt(deleteFor.currentSubscribed, 4)}</span></div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteFor(null)}>Cancel</Button>
            <Button variant="destructive" onClick={() => deleteFor && remove.mutate(deleteFor.id)} disabled={remove.isPending} data-testid="button-confirm-delete">
              {remove.isPending ? <Loader2 className="w-4 h-4 mr-1.5 animate-spin" /> : <Trash2 className="w-4 h-4 mr-1.5" />}
              Delete
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

function ProductDialog({
  open, onOpenChange, title, coins, draft, setDraft, onSubmit, submitting, isCreate,
}: {
  open: boolean;
  onOpenChange: (o: boolean) => void;
  title: string;
  coins: Coin[];
  draft: Partial<Product>;
  setDraft: (p: Partial<Product>) => void;
  onSubmit: () => void;
  submitting: boolean;
  isCreate: boolean;
}) {
  const set = <K extends keyof Product>(k: K, v: Product[K] | undefined) => setDraft({ ...draft, [k]: v });
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-w-2xl max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <PiggyBank className="w-5 h-5 text-amber-300" />{title}
          </DialogTitle>
          <DialogDescription>
            {isCreate
              ? "Naya earn product create karein — coin, type, APY aur cap set karein."
              : "Existing product update karein. Live subscriptions par effect dheere se padega."}
          </DialogDescription>
        </DialogHeader>
        <div className="space-y-5">
          <FormSection title="Basics" icon={Coins}>
            <Grid2>
              <Field label="Coin *">
                <Select value={draft.coinId ? String(draft.coinId) : ""} onValueChange={(c) => set("coinId", Number(c))} disabled={!isCreate}>
                  <SelectTrigger data-testid="dialog-coin"><SelectValue placeholder="Select coin" /></SelectTrigger>
                  <SelectContent>
                    {coins.map((c) => <SelectItem key={c.id} value={String(c.id)}>{c.symbol}{c.name ? ` — ${c.name}` : ""}</SelectItem>)}
                  </SelectContent>
                </Select>
              </Field>
              <Field label="Type *">
                <Select value={draft.type ?? "simple"} onValueChange={(t) => set("type", t)}>
                  <SelectTrigger data-testid="dialog-type"><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="simple">Simple (Flexible)</SelectItem>
                    <SelectItem value="advanced">Advanced (Locked)</SelectItem>
                  </SelectContent>
                </Select>
              </Field>
            </Grid2>
            <Field label="Display name">
              <Input value={draft.name ?? ""} onChange={(e) => set("name", e.target.value)} placeholder="e.g. USDT Flexible Savings" data-testid="dialog-name" />
            </Field>
            <Field label="Description">
              <Textarea
                value={draft.description ?? ""}
                onChange={(e) => set("description", e.target.value)}
                rows={2}
                placeholder="Shown to users on the product card"
                data-testid="dialog-description"
              />
            </Field>
          </FormSection>

          <FormSection title="Yield & Duration" icon={TrendingUp}>
            <Grid2>
              <Field label="APY % *">
                <Input value={draft.apy ?? ""} onChange={(e) => set("apy", e.target.value)} data-testid="dialog-apy" />
              </Field>
              <Field label="Duration (days, 0 = flexible)">
                <Input type="number" value={draft.durationDays ?? 0} onChange={(e) => set("durationDays", Number(e.target.value))} data-testid="dialog-duration" />
              </Field>
              <Field label="Payout interval">
                <Select value={draft.payoutInterval ?? "daily"} onValueChange={(v) => set("payoutInterval", v)}>
                  <SelectTrigger data-testid="dialog-payout"><SelectValue /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="daily">Daily</SelectItem>
                    <SelectItem value="weekly">Weekly</SelectItem>
                    <SelectItem value="monthly">Monthly</SelectItem>
                    <SelectItem value="atMaturity">At Maturity</SelectItem>
                  </SelectContent>
                </Select>
              </Field>
              <ToggleField
                label="Compounding"
                hint="Auto-reinvest earned rewards"
                checked={!!draft.compounding}
                onChange={(v) => set("compounding", v)}
                testid="dialog-compounding"
              />
            </Grid2>
          </FormSection>

          <FormSection title="Limits & Cap" icon={Wallet}>
            <Grid2>
              <Field label="Min amount">
                <Input value={draft.minAmount ?? "0"} onChange={(e) => set("minAmount", e.target.value)} data-testid="dialog-min" />
              </Field>
              <Field label="Max per user (0 = no limit)">
                <Input value={draft.maxAmount ?? "0"} onChange={(e) => set("maxAmount", e.target.value)} data-testid="dialog-max" />
              </Field>
              <Field label="Total pool cap (0 = unlimited)">
                <Input value={draft.totalCap ?? "0"} onChange={(e) => set("totalCap", e.target.value)} data-testid="dialog-cap" />
              </Field>
              <Field label="Min VIP tier">
                <Input type="number" value={draft.minVipTier ?? 0} onChange={(e) => set("minVipTier", Number(e.target.value))} data-testid="dialog-vip" />
              </Field>
            </Grid2>
          </FormSection>

          <FormSection title="Early Redemption" icon={Lock}>
            <Grid2>
              <ToggleField
                label="Allow early exit"
                hint="Users can unstake before maturity"
                checked={!!draft.earlyRedemption}
                onChange={(v) => set("earlyRedemption", v)}
                testid="dialog-early"
              />
              <Field label="Early exit penalty %">
                <Input
                  value={draft.earlyRedemptionPenaltyPct ?? "0"}
                  onChange={(e) => set("earlyRedemptionPenaltyPct", e.target.value)}
                  disabled={!draft.earlyRedemption}
                  data-testid="dialog-penalty"
                />
              </Field>
            </Grid2>
          </FormSection>

          <FormSection title="Visibility & Sale Window" icon={Calendar}>
            <Grid2>
              <ToggleField
                label="Featured"
                hint="Highlight on app home"
                checked={!!draft.featured}
                onChange={(v) => set("featured", v)}
                testid="dialog-featured"
              />
              <Field label="Display order (higher first)">
                <Input type="number" value={draft.displayOrder ?? 0} onChange={(e) => set("displayOrder", Number(e.target.value))} data-testid="dialog-order" />
              </Field>
              <Field label="Sale start">
                <Input type="datetime-local" value={toDateInput(draft.saleStartAt)} onChange={(e) => set("saleStartAt", e.target.value || null)} data-testid="dialog-start" />
              </Field>
              <Field label="Sale end">
                <Input type="datetime-local" value={toDateInput(draft.saleEndAt)} onChange={(e) => set("saleEndAt", e.target.value || null)} data-testid="dialog-end" />
              </Field>
            </Grid2>
          </FormSection>

          <FormSection title="Status" icon={Settings}>
            <Field label="Status">
              <Select value={draft.status ?? "active"} onValueChange={(v) => set("status", v)}>
                <SelectTrigger data-testid="dialog-status"><SelectValue /></SelectTrigger>
                <SelectContent>
                  <SelectItem value="active">Active</SelectItem>
                  <SelectItem value="paused">Paused</SelectItem>
                  <SelectItem value="ended">Ended</SelectItem>
                </SelectContent>
              </Select>
            </Field>
          </FormSection>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>Cancel</Button>
          <Button onClick={onSubmit} disabled={submitting || (isCreate && !draft.coinId)} data-testid="dialog-submit">
            {submitting ? <Loader2 className="w-4 h-4 mr-1.5 animate-spin" /> : <Award className="w-4 h-4 mr-1.5" />}
            {submitting ? "Saving…" : isCreate ? "Create Product" : "Save Changes"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function FormSection({ title, icon: Icon, children }: { title: string; icon: typeof Coins; children: React.ReactNode }) {
  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2 pb-1.5 border-b border-border/40">
        <Icon className="w-3.5 h-3.5 text-amber-300" />
        <div className="text-[11px] font-semibold uppercase tracking-wider text-muted-foreground">{title}</div>
      </div>
      <div className="space-y-3">{children}</div>
    </div>
  );
}
function Grid2({ children }: { children: React.ReactNode }) {
  return <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">{children}</div>;
}
function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return <div className="space-y-1.5"><Label className="text-xs">{label}</Label>{children}</div>;
}
function ToggleField({
  label, hint, checked, onChange, testid,
}: { label: string; hint?: string; checked: boolean; onChange: (v: boolean) => void; testid?: string }) {
  return (
    <div className="space-y-1.5">
      <Label className="text-xs">{label}</Label>
      <label className={cn("flex items-center justify-between gap-2 rounded-lg border p-2.5 cursor-pointer transition-colors h-9",
        checked ? "border-emerald-500/40 bg-emerald-500/10" : "border-border/60 bg-muted/20 hover:bg-muted/30")}>
        {hint && <span className="text-xs text-muted-foreground truncate">{hint}</span>}
        <Switch checked={checked} onCheckedChange={onChange} data-testid={testid} />
      </label>
    </div>
  );
}
