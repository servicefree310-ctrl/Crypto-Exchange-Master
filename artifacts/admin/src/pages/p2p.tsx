import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  Users, ShoppingCart, AlertTriangle, ShieldCheck, Loader2, RefreshCw,
  Check, X, Power, Search,
} from "lucide-react";
import { get, post, patch, ApiError } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { useToast } from "@/hooks/use-toast";
import { PageHeader } from "@/components/premium/PageHeader";
import { PremiumStatCard } from "@/components/premium/PremiumStatCard";
import { StatusPill } from "@/components/premium/StatusPill";
import { EmptyState } from "@/components/premium/EmptyState";
import { Button } from "@/components/ui/button";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Textarea } from "@/components/ui/textarea";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter,
} from "@/components/ui/dialog";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";

// ─── Types (mirror server hydrators) ────────────────────────────────────
type Coin = { id: number; symbol: string; name: string };
type Merchant = { id: number; name: string; handle: string; kycLevel: number; vipTier: number; createdAt: string };
type Offer = {
  id: number; uid: string; userId: number; side: string;
  fiat: string; price: number; totalQty: number; availableQty: number;
  minFiat: number; maxFiat: number; paymentMethods: string[];
  status: string; minKycLevel: number;
  coin: Coin | null; merchant: Merchant; createdAt: string;
};
type Order = {
  id: number; uid: string; offerId: number; buyerId: number; sellerId: number;
  fiat: string; price: number; qty: number; fiatAmount: number;
  paymentMethod: string; paymentLabel: string; paymentUtr: string | null;
  status: string; createdAt: string; expiresAt: string;
  paidAt: string | null; releasedAt: string | null;
  disputeReason: string | null; disputeOpenedBy: number | null; disputeOpenedAt: string | null;
  coin: Coin | null;
  buyer: Merchant; seller: Merchant;
};
type Stats = { onlineOffers: number; activeOrders: number; openDisputes: number; completedOrders: number };

function fmtINR(n: number): string {
  return Number(n).toLocaleString("en-IN", { maximumFractionDigits: 2 });
}
function fmtCrypto(n: number, dp = 6): string {
  return Number(n).toFixed(dp).replace(/\.?0+$/, "");
}
function relTime(s: string | null): string {
  if (!s) return "—";
  const diff = Date.now() - new Date(s).getTime();
  const sec = Math.floor(diff / 1000);
  if (sec < 60) return `${sec}s ago`;
  const m = Math.floor(sec / 60);
  if (m < 60) return `${m}m ago`;
  const h = Math.floor(m / 60);
  if (h < 48) return `${h}h ago`;
  return `${Math.floor(h / 24)}d ago`;
}
function methodLabel(m: string): string {
  const map: Record<string, string> = {
    upi: "UPI", imps: "IMPS", neft: "NEFT", bank: "Bank",
    paytm: "Paytm", phonepe: "PhonePe", gpay: "GPay",
  };
  return map[m] ?? m.toUpperCase();
}

export default function P2PAdminPage() {
  const { user: me } = useAuth();
  const { toast } = useToast();
  const qc = useQueryClient();
  const canModerate = me?.role === "admin" || me?.role === "superadmin";

  const statsQ = useQuery<Stats>({
    queryKey: ["/admin/p2p/stats"],
    queryFn: () => get<Stats>("/admin/p2p/stats"),
    refetchInterval: 10_000,
  });

  return (
    <div className="space-y-6 p-4 md:p-6">
      <PageHeader
        eyebrow="P2P Moderation"
        title="P2P Marketplace"
        description="Monitor offers, deals, and resolve disputes for the peer-to-peer market."
        actions={
          <Button variant="outline" size="sm" onClick={() => { qc.invalidateQueries({ queryKey: ["/admin/p2p/stats"] }); }}>
            <RefreshCw className="w-4 h-4 mr-2" /> Refresh
          </Button>
        }
      />

      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <PremiumStatCard label="Online Offers" value={statsQ.data?.onlineOffers ?? "—"} icon={ShoppingCart} accent="success" />
        <PremiumStatCard label="Active Orders" value={statsQ.data?.activeOrders ?? "—"} icon={Users} accent="info" />
        <PremiumStatCard label="Open Disputes" value={statsQ.data?.openDisputes ?? "—"} icon={AlertTriangle} accent={statsQ.data?.openDisputes ? "warning" : "neutral"} />
        <PremiumStatCard label="Completed (all-time)" value={statsQ.data?.completedOrders ?? "—"} icon={Check} accent="gold" />
      </div>

      <Tabs defaultValue="disputes" className="space-y-4">
        <TabsList className="grid grid-cols-3 max-w-xl">
          <TabsTrigger value="disputes" data-testid="p2padmin-tab-disputes">
            Disputes {statsQ.data?.openDisputes ? <Badge className="ml-2 bg-amber-500/20 text-amber-300">{statsQ.data.openDisputes}</Badge> : null}
          </TabsTrigger>
          <TabsTrigger value="orders" data-testid="p2padmin-tab-orders">Orders</TabsTrigger>
          <TabsTrigger value="offers" data-testid="p2padmin-tab-offers">Offers</TabsTrigger>
        </TabsList>

        <TabsContent value="disputes"><DisputesTab canModerate={canModerate} /></TabsContent>
        <TabsContent value="orders"><OrdersTab /></TabsContent>
        <TabsContent value="offers"><OffersTab canModerate={canModerate} /></TabsContent>
      </Tabs>
    </div>
  );
}

// ─── Disputes ──────────────────────────────────────────────────────────

function DisputesTab({ canModerate }: { canModerate: boolean }) {
  const qc = useQueryClient();
  const { toast } = useToast();
  const [resolveTarget, setResolveTarget] = useState<Order | null>(null);
  const [action, setAction] = useState<"release" | "refund">("release");
  const [notes, setNotes] = useState("");

  const disputesQ = useQuery<Order[]>({
    queryKey: ["/admin/p2p/disputes"],
    queryFn: () => get<Order[]>("/admin/p2p/disputes"),
    refetchInterval: 10_000,
  });

  const resolveMut = useMutation({
    mutationFn: (a: { id: number; action: "release" | "refund"; notes: string }) =>
      post(`/admin/p2p/disputes/${a.id}/resolve`, { action: a.action, notes: a.notes }),
    onSuccess: () => {
      toast({ title: "Dispute resolved" });
      qc.invalidateQueries({ queryKey: ["/admin/p2p/disputes"] });
      qc.invalidateQueries({ queryKey: ["/admin/p2p/stats"] });
      setResolveTarget(null); setNotes("");
    },
    onError: (e: ApiError) => toast({ title: "Resolve failed", description: e.message, variant: "destructive" }),
  });

  if (disputesQ.isLoading) return <Skeleton className="h-32" />;
  const rows = disputesQ.data ?? [];
  if (rows.length === 0) {
    return (
      <div className="premium-card rounded-xl">
        <EmptyState icon={ShieldCheck} title="No open disputes" description="Sab kuch shaant hai — buyers and sellers are happy." />
      </div>
    );
  }

  return (
    <div className="premium-card rounded-xl overflow-x-auto">
      <table className="w-full text-sm">
        <thead className="text-xs text-muted-foreground border-b border-border/60">
          <tr>
            <th className="text-left p-3">Order</th>
            <th className="text-left p-3">Parties</th>
            <th className="text-right p-3">Amount</th>
            <th className="text-left p-3">Reason</th>
            <th className="text-left p-3">Opened</th>
            <th className="text-right p-3">Action</th>
          </tr>
        </thead>
        <tbody>
          {rows.map(o => (
            <tr key={o.id} className="border-b border-border/40 hover:bg-muted/30" data-testid={`p2padmin-dispute-${o.id}`}>
              <td className="p-3">
                <div className="font-mono text-xs">#{o.id}</div>
                <div className="text-xs text-muted-foreground">{o.coin?.symbol}</div>
              </td>
              <td className="p-3">
                <div className="text-xs"><span className="text-muted-foreground">Buyer:</span> {o.buyer.name}</div>
                <div className="text-xs"><span className="text-muted-foreground">Seller:</span> {o.seller.name}</div>
                {o.disputeOpenedBy && (
                  <div className="text-[10px] text-amber-300 mt-1">
                    Opened by: {o.disputeOpenedBy === o.buyerId ? "Buyer" : "Seller"}
                  </div>
                )}
              </td>
              <td className="p-3 text-right tabular-nums">
                <div className="font-bold">₹{fmtINR(o.fiatAmount)}</div>
                <div className="text-xs text-muted-foreground">{fmtCrypto(o.qty)} {o.coin?.symbol}</div>
              </td>
              <td className="p-3 text-xs max-w-[280px]">
                <div className="line-clamp-3" title={o.disputeReason || ""}>{o.disputeReason || "—"}</div>
              </td>
              <td className="p-3 text-xs text-muted-foreground">{relTime(o.disputeOpenedAt)}</td>
              <td className="p-3 text-right">
                {canModerate ? (
                  <Button
                    size="sm"
                    onClick={() => { setResolveTarget(o); setAction("release"); setNotes(""); }}
                    data-testid={`p2padmin-resolve-${o.id}`}
                  >
                    Resolve
                  </Button>
                ) : (
                  <span className="text-xs text-muted-foreground">View only</span>
                )}
              </td>
            </tr>
          ))}
        </tbody>
      </table>

      {resolveTarget && (
        <Dialog open onOpenChange={() => setResolveTarget(null)}>
          <DialogContent data-testid="p2padmin-resolve-dialog">
            <DialogHeader>
              <DialogTitle>Resolve Dispute #{resolveTarget.id}</DialogTitle>
              <DialogDescription>
                {resolveTarget.coin?.symbol} · ₹{fmtINR(resolveTarget.fiatAmount)} · {fmtCrypto(resolveTarget.qty)} units in escrow.
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-3">
              <div className="rounded-md border border-border/60 bg-muted/30 p-3 text-xs">
                <div className="font-semibold mb-1">Buyer's claim / reason</div>
                <div className="text-muted-foreground">{resolveTarget.disputeReason}</div>
              </div>
              <div>
                <label className="text-xs font-medium">Resolution</label>
                <Select value={action} onValueChange={(v: any) => setAction(v)}>
                  <SelectTrigger data-testid="p2padmin-resolve-action">
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="release">Release crypto to buyer (buyer wins)</SelectItem>
                    <SelectItem value="refund">Refund crypto to seller (seller wins)</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div>
                <label className="text-xs font-medium">Internal notes</label>
                <Textarea
                  rows={3}
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  placeholder="Decision rationale, evidence reviewed, etc."
                  data-testid="p2padmin-resolve-notes"
                />
              </div>
            </div>
            <DialogFooter>
              <Button variant="outline" onClick={() => setResolveTarget(null)}>Cancel</Button>
              <Button
                onClick={() => resolveMut.mutate({ id: resolveTarget.id, action, notes })}
                disabled={resolveMut.isPending}
                data-testid="p2padmin-resolve-submit"
              >
                {resolveMut.isPending && <Loader2 className="w-4 h-4 mr-2 animate-spin" />}
                Apply Resolution
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}

// ─── Orders ────────────────────────────────────────────────────────────

function OrdersTab() {
  const [status, setStatus] = useState("all");

  const ordersQ = useQuery<Order[]>({
    queryKey: ["/admin/p2p/orders", status],
    queryFn: () => {
      const p = new URLSearchParams();
      if (status !== "all") p.set("status", status);
      return get<Order[]>(`/admin/p2p/orders${p.toString() ? "?" + p.toString() : ""}`);
    },
  });

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2">
        <Select value={status} onValueChange={setStatus}>
          <SelectTrigger className="w-[180px]" data-testid="p2padmin-orders-status">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All statuses</SelectItem>
            <SelectItem value="pending">Pending</SelectItem>
            <SelectItem value="paid">Paid</SelectItem>
            <SelectItem value="released">Released</SelectItem>
            <SelectItem value="cancelled">Cancelled</SelectItem>
            <SelectItem value="disputed">Disputed</SelectItem>
            <SelectItem value="expired">Expired</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div className="premium-card rounded-xl overflow-x-auto">
        {ordersQ.isLoading ? <Skeleton className="h-40" /> : (ordersQ.data ?? []).length === 0 ? (
          <EmptyState icon={Search} title="No orders" description="Try a different filter." />
        ) : (
          <table className="w-full text-sm">
            <thead className="text-xs text-muted-foreground border-b border-border/60">
              <tr>
                <th className="text-left p-3">Order</th>
                <th className="text-left p-3">Buyer / Seller</th>
                <th className="text-right p-3">Amount</th>
                <th className="text-left p-3">Method</th>
                <th className="text-left p-3">Status</th>
                <th className="text-left p-3">Opened</th>
              </tr>
            </thead>
            <tbody>
              {(ordersQ.data ?? []).map(o => (
                <tr key={o.id} className="border-b border-border/40" data-testid={`p2padmin-order-${o.id}`}>
                  <td className="p-3 font-mono text-xs">
                    #{o.id}
                    <div className="text-muted-foreground">{o.coin?.symbol}</div>
                  </td>
                  <td className="p-3 text-xs">
                    <div>{o.buyer.name}</div>
                    <div className="text-muted-foreground">{o.seller.name}</div>
                  </td>
                  <td className="p-3 text-right tabular-nums">
                    <div className="font-semibold">₹{fmtINR(o.fiatAmount)}</div>
                    <div className="text-xs text-muted-foreground">{fmtCrypto(o.qty)} {o.coin?.symbol}</div>
                  </td>
                  <td className="p-3 text-xs">
                    {methodLabel(o.paymentMethod)}
                    <div className="text-muted-foreground">{o.paymentLabel}</div>
                  </td>
                  <td className="p-3"><StatusPill status={o.status} /></td>
                  <td className="p-3 text-xs text-muted-foreground">{relTime(o.createdAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}

// ─── Offers ────────────────────────────────────────────────────────────

function OffersTab({ canModerate }: { canModerate: boolean }) {
  const [status, setStatus] = useState("all");
  const qc = useQueryClient();
  const { toast } = useToast();

  const offersQ = useQuery<Offer[]>({
    queryKey: ["/admin/p2p/offers", status],
    queryFn: () => {
      const p = new URLSearchParams();
      if (status !== "all") p.set("status", status);
      return get<Offer[]>(`/admin/p2p/offers${p.toString() ? "?" + p.toString() : ""}`);
    },
  });

  const setStatusMut = useMutation({
    mutationFn: ({ id, status }: { id: number; status: string }) =>
      patch(`/admin/p2p/offers/${id}`, { status }),
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["/admin/p2p/offers"] });
      toast({ title: "Status updated" });
    },
    onError: (e: ApiError) => toast({ title: "Update failed", description: e.message, variant: "destructive" }),
  });

  return (
    <div className="space-y-3">
      <div className="flex items-center gap-2">
        <Select value={status} onValueChange={setStatus}>
          <SelectTrigger className="w-[180px]" data-testid="p2padmin-offers-status">
            <SelectValue />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All</SelectItem>
            <SelectItem value="online">Online</SelectItem>
            <SelectItem value="offline">Offline</SelectItem>
            <SelectItem value="suspended">Suspended</SelectItem>
            <SelectItem value="closed">Closed</SelectItem>
          </SelectContent>
        </Select>
      </div>

      <div className="premium-card rounded-xl overflow-x-auto">
        {offersQ.isLoading ? <Skeleton className="h-40" /> : (offersQ.data ?? []).length === 0 ? (
          <EmptyState icon={Search} title="No offers" description="Try a different filter." />
        ) : (
          <table className="w-full text-sm">
            <thead className="text-xs text-muted-foreground border-b border-border/60">
              <tr>
                <th className="text-left p-3">ID / Side</th>
                <th className="text-left p-3">Merchant</th>
                <th className="text-left p-3">Coin</th>
                <th className="text-right p-3">Price</th>
                <th className="text-right p-3">Avail.</th>
                <th className="text-left p-3">Status</th>
                <th className="text-right p-3">Actions</th>
              </tr>
            </thead>
            <tbody>
              {(offersQ.data ?? []).map(o => (
                <tr key={o.id} className="border-b border-border/40" data-testid={`p2padmin-offer-${o.id}`}>
                  <td className="p-3">
                    <div className="font-mono text-xs">#{o.id}</div>
                    <Badge className={o.side === "sell" ? "bg-rose-500/20 text-rose-300 border-rose-500/30" : "bg-emerald-500/20 text-emerald-300 border-emerald-500/30"}>
                      {o.side.toUpperCase()}
                    </Badge>
                  </td>
                  <td className="p-3 text-xs">
                    {o.merchant.name}
                    <div className="text-muted-foreground">KYC L{o.merchant.kycLevel}</div>
                  </td>
                  <td className="p-3 font-semibold">{o.coin?.symbol}</td>
                  <td className="p-3 text-right tabular-nums">₹{fmtINR(o.price)}</td>
                  <td className="p-3 text-right tabular-nums text-xs">
                    {fmtCrypto(o.availableQty)} / {fmtCrypto(o.totalQty)}
                  </td>
                  <td className="p-3"><StatusPill status={o.status} /></td>
                  <td className="p-3 text-right">
                    {canModerate && (
                      <div className="inline-flex gap-1">
                        {o.status !== "suspended" ? (
                          <Button
                            size="sm" variant="outline"
                            onClick={() => { if (confirm(`Suspend offer #${o.id}? Merchant will not be able to edit.`)) setStatusMut.mutate({ id: o.id, status: "suspended" }); }}
                            disabled={setStatusMut.isPending}
                            data-testid={`p2padmin-suspend-${o.id}`}
                          >
                            <Power className="w-3 h-3 mr-1 text-rose-400" /> Suspend
                          </Button>
                        ) : (
                          <Button
                            size="sm" variant="outline"
                            onClick={() => setStatusMut.mutate({ id: o.id, status: "online" })}
                            disabled={setStatusMut.isPending}
                            data-testid={`p2padmin-unsuspend-${o.id}`}
                          >
                            <Check className="w-3 h-3 mr-1 text-emerald-400" /> Restore
                          </Button>
                        )}
                      </div>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
