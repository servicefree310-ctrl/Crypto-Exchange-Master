import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, del, patch } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger, DialogFooter } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Switch } from "@/components/ui/switch";
import { Textarea } from "@/components/ui/textarea";
import { Progress } from "@/components/ui/progress";
import {
  Plus, Trash2, Pencil, Search, Star, Lock, TrendingUp, Coins,
  Users, Wallet, Sparkles,
} from "lucide-react";
import { useState, useMemo } from "react";
import { useAuth } from "@/lib/auth";

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
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";

  const { data: coins = [] } = useQuery<Coin[]>({
    queryKey: ["/admin/coins"],
    queryFn: () => get<Coin[]>("/admin/coins"),
  });
  const { data: products = [] } = useQuery<Product[]>({
    queryKey: ["/admin/earn-products"],
    queryFn: () => get<Product[]>("/admin/earn-products"),
  });
  const { data: positions = [] } = useQuery<Position[]>({
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

  const [addOpen, setAddOpen] = useState(false);
  const [editing, setEditing] = useState<Product | null>(null);
  const [draft, setDraft] = useState<Partial<Product>>(blank);

  const create = useMutation({
    mutationFn: () => post("/admin/earn-products", draft),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["/admin/earn-products"] });
      qc.invalidateQueries({ queryKey: ["/admin/earn-stats"] });
      setAddOpen(false);
      setDraft(blank);
    },
  });
  const update = useMutation({
    mutationFn: ({ id, body }: { id: number; body: Partial<Product> }) =>
      patch(`/admin/earn-products/${id}`, body),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["/admin/earn-products"] });
      qc.invalidateQueries({ queryKey: ["/admin/earn-stats"] });
      setEditing(null);
    },
  });
  const remove = useMutation({
    mutationFn: (id: number) => del(`/admin/earn-products/${id}`),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["/admin/earn-products"] });
      qc.invalidateQueries({ queryKey: ["/admin/earn-stats"] });
    },
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

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <StatCard icon={<Coins className="w-4 h-4" />} label="Products" value={`${stats?.activeProducts ?? 0} / ${stats?.totalProducts ?? 0}`} sub="Active / Total" />
        <StatCard icon={<Wallet className="w-4 h-4" />} label="Subscribed" value={fmt(stats?.totalSubscribed ?? 0, 4)} sub={`Cap: ${fmt(stats?.totalCap ?? 0, 0)}`} />
        <StatCard icon={<Users className="w-4 h-4" />} label="Active Positions" value={fmt(stats?.activePositions ?? 0, 0)} sub={`Locked: ${fmt(stats?.totalPositionAmount ?? 0, 4)}`} />
        <StatCard icon={<TrendingUp className="w-4 h-4" />} label="Total Yield Paid" value={fmt(stats?.totalEarned ?? 0, 4)} sub="All time" highlight />
      </div>

      <Tabs defaultValue="products">
        <TabsList>
          <TabsTrigger value="products" data-testid="tab-products">Products ({products.length})</TabsTrigger>
          <TabsTrigger value="positions" data-testid="tab-positions">Subscriptions ({positions.length})</TabsTrigger>
        </TabsList>

        <TabsContent value="products" className="space-y-4">
          <Card className="p-3">
            <div className="flex flex-wrap gap-2 items-center">
              <div className="relative flex-1 min-w-[220px]">
                <Search className="w-4 h-4 absolute left-2 top-2.5 text-muted-foreground" />
                <Input
                  placeholder="Search by coin, name, description…"
                  value={search}
                  onChange={(e) => setSearch(e.target.value)}
                  className="pl-8"
                  data-testid="input-search"
                />
              </div>
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
                  <SelectItem value="simple">Simple</SelectItem>
                  <SelectItem value="advanced">Advanced</SelectItem>
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
              {isAdmin && (
                <Button
                  onClick={() => { setDraft(blank); setAddOpen(true); }}
                  data-testid="button-add-product"
                >
                  <Plus className="w-4 h-4 mr-1" /> Add Product
                </Button>
              )}
            </div>
          </Card>

          <Card>
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="w-12">#</TableHead>
                    <TableHead>Product</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Duration</TableHead>
                    <TableHead className="text-right">APY</TableHead>
                    <TableHead>Range</TableHead>
                    <TableHead className="min-w-[140px]">Subscribed</TableHead>
                    <TableHead>Flags</TableHead>
                    <TableHead>Status</TableHead>
                    {isAdmin && <TableHead className="text-right">Actions</TableHead>}
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filtered.length === 0 && (
                    <TableRow>
                      <TableCell colSpan={isAdmin ? 10 : 9} className="text-center text-muted-foreground py-8">
                        No products match filters.
                      </TableCell>
                    </TableRow>
                  )}
                  {filtered.map((p) => {
                    const coin = coinMap.get(p.coinId);
                    const sym = coin?.symbol ?? `#${p.coinId}`;
                    const cap = Number(p.totalCap);
                    const sub = Number(p.currentSubscribed);
                    const pct = cap > 0 ? Math.min(100, (sub / cap) * 100) : 0;
                    return (
                      <TableRow key={p.id} data-testid={`row-product-${p.id}`}>
                        <TableCell className="text-xs text-muted-foreground">{p.displayOrder || "—"}</TableCell>
                        <TableCell>
                          <div className="flex flex-col">
                            <div className="flex items-center gap-2">
                              <span className="font-bold">{sym}</span>
                              {p.name && <span className="text-xs text-muted-foreground">· {p.name}</span>}
                            </div>
                            {p.description && (
                              <span className="text-xs text-muted-foreground line-clamp-1 max-w-[260px]">{p.description}</span>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge variant={p.type === "advanced" ? "default" : "outline"} className="capitalize">
                            {p.type}
                          </Badge>
                        </TableCell>
                        <TableCell className="text-sm">
                          {p.durationDays === 0 ? "Flexible" : `${p.durationDays}d`}
                          <div className="text-xs text-muted-foreground capitalize">{p.payoutInterval}</div>
                        </TableCell>
                        <TableCell className="text-right">
                          <span className="font-bold text-primary">{fmt(p.apy, 2)}%</span>
                        </TableCell>
                        <TableCell className="text-xs">
                          <div>min {fmt(p.minAmount, 4)}</div>
                          <div className="text-muted-foreground">max {Number(p.maxAmount) > 0 ? fmt(p.maxAmount, 4) : "∞"}</div>
                        </TableCell>
                        <TableCell>
                          {cap > 0 ? (
                            <div className="space-y-1">
                              <Progress value={pct} className="h-1.5" />
                              <div className="text-xs text-muted-foreground">
                                {fmt(sub, 2)} / {fmt(cap, 2)} ({pct.toFixed(1)}%)
                              </div>
                            </div>
                          ) : (
                            <div className="text-xs text-muted-foreground">No cap · {fmt(sub, 2)}</div>
                          )}
                        </TableCell>
                        <TableCell>
                          <div className="flex flex-wrap gap-1">
                            {p.featured && <Badge variant="secondary" className="text-xs gap-0.5"><Star className="w-3 h-3" /> Featured</Badge>}
                            {p.compounding && <Badge variant="outline" className="text-xs gap-0.5"><Sparkles className="w-3 h-3" /> Compound</Badge>}
                            {p.earlyRedemption && <Badge variant="outline" className="text-xs">Early Exit</Badge>}
                            {p.minVipTier > 0 && <Badge variant="outline" className="text-xs gap-0.5"><Lock className="w-3 h-3" /> VIP {p.minVipTier}+</Badge>}
                          </div>
                        </TableCell>
                        <TableCell>
                          {isAdmin ? (
                            <Select
                              value={p.status}
                              onValueChange={(s) => update.mutate({ id: p.id, body: { status: s } })}
                            >
                              <SelectTrigger className="h-8 w-28" data-testid={`status-${p.id}`}><SelectValue /></SelectTrigger>
                              <SelectContent>
                                <SelectItem value="active">Active</SelectItem>
                                <SelectItem value="paused">Paused</SelectItem>
                                <SelectItem value="ended">Ended</SelectItem>
                              </SelectContent>
                            </Select>
                          ) : (
                            <Badge>{p.status}</Badge>
                          )}
                        </TableCell>
                        {isAdmin && (
                          <TableCell className="text-right">
                            <div className="flex justify-end gap-1">
                              <Button
                                size="icon"
                                variant="ghost"
                                onClick={() => { setDraft(p); setEditing(p); }}
                                data-testid={`button-edit-${p.id}`}
                              >
                                <Pencil className="w-4 h-4" />
                              </Button>
                              <Button
                                size="icon"
                                variant="ghost"
                                onClick={() => { if (confirm(`Delete product ${sym} ${p.name}?`)) remove.mutate(p.id); }}
                                data-testid={`button-delete-${p.id}`}
                              >
                                <Trash2 className="w-4 h-4 text-destructive" />
                              </Button>
                            </div>
                          </TableCell>
                        )}
                      </TableRow>
                    );
                  })}
                </TableBody>
              </Table>
            </div>
          </Card>
        </TabsContent>

        <TabsContent value="positions">
          <Card>
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>ID</TableHead>
                    <TableHead>User</TableHead>
                    <TableHead>Product</TableHead>
                    <TableHead className="text-right">Amount</TableHead>
                    <TableHead className="text-right">Earned</TableHead>
                    <TableHead>Started</TableHead>
                    <TableHead>Matures</TableHead>
                    <TableHead>Auto</TableHead>
                    <TableHead>Status</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {positions.length === 0 && (
                    <TableRow>
                      <TableCell colSpan={9} className="text-center text-muted-foreground py-8">No subscriptions yet.</TableCell>
                    </TableRow>
                  )}
                  {positions.map((pos) => {
                    const prod = products.find((x) => x.id === pos.productId);
                    const sym = prod ? (coinMap.get(prod.coinId)?.symbol ?? `#${prod.coinId}`) : `prod ${pos.productId}`;
                    return (
                      <TableRow key={pos.id} data-testid={`row-position-${pos.id}`}>
                        <TableCell className="font-mono text-xs">{pos.id}</TableCell>
                        <TableCell className="font-mono text-xs">user-{pos.userId}</TableCell>
                        <TableCell>
                          <div className="font-bold">{sym}</div>
                          <div className="text-xs text-muted-foreground">{prod?.name || `#${pos.productId}`} · {prod?.apy ?? "—"}%</div>
                        </TableCell>
                        <TableCell className="text-right font-mono">{fmt(pos.amount, 8)}</TableCell>
                        <TableCell className="text-right font-mono text-primary">{fmt(pos.totalEarned, 8)}</TableCell>
                        <TableCell className="text-xs">{new Date(pos.startedAt).toLocaleDateString()}</TableCell>
                        <TableCell className="text-xs">{pos.maturedAt ? new Date(pos.maturedAt).toLocaleDateString() : "—"}</TableCell>
                        <TableCell>{pos.autoMaturity ? <Badge variant="outline">Auto</Badge> : <span className="text-xs text-muted-foreground">—</span>}</TableCell>
                        <TableCell>
                          <Badge variant={pos.status === "active" ? "default" : "outline"} className="capitalize">{pos.status}</Badge>
                        </TableCell>
                      </TableRow>
                    );
                  })}
                </TableBody>
              </Table>
            </div>
          </Card>
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
    </div>
  );
}

function StatCard({
  icon, label, value, sub, highlight,
}: { icon: React.ReactNode; label: string; value: string; sub?: string; highlight?: boolean }) {
  return (
    <Card className={`p-3 ${highlight ? "border-primary/40 bg-primary/5" : ""}`}>
      <div className="flex items-center gap-2 text-xs text-muted-foreground mb-1">{icon}{label}</div>
      <div className="text-xl font-bold">{value}</div>
      {sub && <div className="text-xs text-muted-foreground mt-0.5">{sub}</div>}
    </Card>
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
      <DialogContent className="max-w-2xl max-h-[85vh] overflow-y-auto" aria-describedby={undefined}>
        <DialogHeader><DialogTitle>{title}</DialogTitle></DialogHeader>
        <div className="space-y-4">
          <Section title="Basics">
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
          </Section>

          <Section title="Yield & Duration">
            <Grid2>
              <Field label="APY % *">
                <Input value={draft.apy ?? ""} onChange={(e) => set("apy", e.target.value)} data-testid="dialog-apy" />
              </Field>
              <Field label="Duration (days, 0 = flexible)">
                <Input
                  type="number"
                  value={draft.durationDays ?? 0}
                  onChange={(e) => set("durationDays", Number(e.target.value))}
                  data-testid="dialog-duration"
                />
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
              <Field label="Compounding">
                <ToggleRow
                  checked={!!draft.compounding}
                  onChange={(v) => set("compounding", v)}
                  hint="Auto-reinvest earned rewards"
                  testid="dialog-compounding"
                />
              </Field>
            </Grid2>
          </Section>

          <Section title="Limits & Cap">
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
                <Input
                  type="number"
                  value={draft.minVipTier ?? 0}
                  onChange={(e) => set("minVipTier", Number(e.target.value))}
                  data-testid="dialog-vip"
                />
              </Field>
            </Grid2>
          </Section>

          <Section title="Early Redemption">
            <Grid2>
              <Field label="Allow early exit">
                <ToggleRow
                  checked={!!draft.earlyRedemption}
                  onChange={(v) => set("earlyRedemption", v)}
                  hint="Users can unstake before maturity"
                  testid="dialog-early"
                />
              </Field>
              <Field label="Early exit penalty %">
                <Input
                  value={draft.earlyRedemptionPenaltyPct ?? "0"}
                  onChange={(e) => set("earlyRedemptionPenaltyPct", e.target.value)}
                  disabled={!draft.earlyRedemption}
                  data-testid="dialog-penalty"
                />
              </Field>
            </Grid2>
          </Section>

          <Section title="Visibility & Sale Window">
            <Grid2>
              <Field label="Featured">
                <ToggleRow
                  checked={!!draft.featured}
                  onChange={(v) => set("featured", v)}
                  hint="Highlight on app home"
                  testid="dialog-featured"
                />
              </Field>
              <Field label="Display order (higher first)">
                <Input
                  type="number"
                  value={draft.displayOrder ?? 0}
                  onChange={(e) => set("displayOrder", Number(e.target.value))}
                  data-testid="dialog-order"
                />
              </Field>
              <Field label="Sale start">
                <Input
                  type="datetime-local"
                  value={toDateInput(draft.saleStartAt)}
                  onChange={(e) => set("saleStartAt", e.target.value || null)}
                  data-testid="dialog-start"
                />
              </Field>
              <Field label="Sale end">
                <Input
                  type="datetime-local"
                  value={toDateInput(draft.saleEndAt)}
                  onChange={(e) => set("saleEndAt", e.target.value || null)}
                  data-testid="dialog-end"
                />
              </Field>
            </Grid2>
          </Section>

          <Section title="Status">
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
          </Section>
        </div>
        <DialogFooter>
          <Button variant="outline" onClick={() => onOpenChange(false)}>Cancel</Button>
          <Button
            onClick={onSubmit}
            disabled={submitting || (isCreate && !draft.coinId)}
            data-testid="dialog-submit"
          >
            {submitting ? "Saving…" : isCreate ? "Create Product" : "Save Changes"}
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="space-y-2">
      <div className="text-xs font-semibold uppercase tracking-wide text-muted-foreground">{title}</div>
      <div className="space-y-3">{children}</div>
    </div>
  );
}
function Grid2({ children }: { children: React.ReactNode }) {
  return <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">{children}</div>;
}
function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="space-y-1">
      <Label className="text-xs">{label}</Label>
      {children}
    </div>
  );
}
function ToggleRow({
  checked, onChange, hint, testid,
}: { checked: boolean; onChange: (v: boolean) => void; hint?: string; testid?: string }) {
  return (
    <div className="flex items-center gap-3 h-9">
      <Switch checked={checked} onCheckedChange={onChange} data-testid={testid} />
      {hint && <span className="text-xs text-muted-foreground">{hint}</span>}
    </div>
  );
}
