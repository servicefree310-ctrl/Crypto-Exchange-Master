import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { useState, useMemo } from "react";
import { get, post } from "@/lib/api";
import { Button } from "@/components/ui/button";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { toast } from "sonner";
import { ListOrdered, RefreshCw, FileText, X, Layers, ArrowLeftRight } from "lucide-react";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { Link } from "wouter";
import { PageHeader } from "@/components/premium/PageHeader";
import { SectionCard } from "@/components/premium/SectionCard";
import { EmptyState } from "@/components/premium/EmptyState";
import { StatusPill } from "@/components/premium/StatusPill";
import { OrderFillsDialog } from "@/components/OrderFillsDialog";
import { cn } from "@/lib/utils";

type Order = {
  id: number;
  symbol: string;
  type: string;
  side: "buy" | "sell";
  price?: string | number | null;
  avgPrice?: string | number | null;
  filledQty?: string | number | null;
  amount: string | number;
  status: string;
  createdAt: string;
};

/**
 * Open Orders page — premium-themed.
 *
 * Pulls live orders from the API, lets the user cancel any open order via a
 * branded confirmation dialog (no native window.confirm — keeps the UX
 * consistent with the rest of the portal), and uses the shared
 * PageHeader/SectionCard/EmptyState/StatusPill primitives so it matches the
 * Wallet, Profile, etc. visual language at launch.
 */
type ConvertRow = {
  id: number;
  fromCoin: string;
  toCoin: string;
  fromAmount: number;
  toAmount: number;
  rate: number;
  feeAmount: number;
  status: string;
  createdAt: string;
};

type FilterTab = "all" | "spot" | "futures" | "convert";

export default function Orders() {
  const queryClient = useQueryClient();
  const [confirmId, setConfirmId] = useState<number | null>(null);
  const [fillsOrderId, setFillsOrderId] = useState<number | null>(null);
  const [filter, setFilter] = useState<FilterTab>("all");

  const { data: ordersData, isLoading, isFetching, refetch } = useQuery<unknown>({
    queryKey: ["orders"],
    queryFn: () => get("/orders"),
  });

  const convertQ = useQuery<ConvertRow[]>({
    queryKey: ["/convert/history"],
    queryFn: () => get<ConvertRow[]>("/convert/history"),
    refetchInterval: 30_000,
  });

  const allOrders: Order[] = useMemo(() => {
    const d = ordersData as { orders?: Order[]; data?: Order[] } | Order[] | undefined;
    if (Array.isArray(d)) return d;
    if (d?.orders && Array.isArray(d.orders)) return d.orders;
    if (d?.data && Array.isArray(d.data)) return d.data;
    return [];
  }, [ordersData]);

  // Spot vs futures heuristic — futures pairs end in -PERP / -SWAP / contain
  // "PERP" markers, otherwise treated as spot. Matches how the symbol field
  // is rendered everywhere else in the portal (Trade, Wallet, etc.).
  function isFutures(o: Order) {
    const s = String(o.symbol || "").toUpperCase();
    const ty = String(o.type || "").toLowerCase();
    return s.includes("PERP") || s.endsWith("-SWAP") || ty.includes("perp") || ty.includes("futures");
  }

  const orders: Order[] = useMemo(() => {
    if (filter === "all" || filter === "convert") return allOrders;
    if (filter === "spot")    return allOrders.filter((o) => !isFutures(o));
    if (filter === "futures") return allOrders.filter((o) =>  isFutures(o));
    return allOrders;
  }, [allOrders, filter]);

  const showConvert = filter === "all" || filter === "convert";

  const cancelMutation = useMutation({
    mutationFn: (id: number) => post(`/orders/${id}/cancel`),
    onSuccess: () => {
      toast.success("Order cancelled");
      setConfirmId(null);
      queryClient.invalidateQueries({ queryKey: ["orders"] });
    },
    onError: (e: unknown) => {
      const msg = e instanceof Error ? e.message : "Failed to cancel order";
      toast.error(msg);
    },
  });

  return (
    <div className="container mx-auto px-4 py-8 max-w-6xl">
      <PageHeader
        eyebrow="Trading"
        title="My Orders"
        description="Live, cancelled aur filled orders ka complete history."
        actions={
          <Button
            variant="outline"
            size="sm"
            onClick={() => refetch()}
            disabled={isFetching}
            data-testid="orders-refresh"
            aria-label="Refresh orders"
          >
            <RefreshCw className={cn("w-4 h-4 mr-2", isFetching && "animate-spin")} />
            Refresh
          </Button>
        }
      />

      <Tabs value={filter} onValueChange={(v) => setFilter(v as FilterTab)} className="mt-4">
        <TabsList data-testid="orders-filter">
          <TabsTrigger value="all" data-testid="orders-filter-all">All</TabsTrigger>
          <TabsTrigger value="spot" data-testid="orders-filter-spot">Spot</TabsTrigger>
          <TabsTrigger value="futures" data-testid="orders-filter-futures">Futures</TabsTrigger>
          <TabsTrigger value="convert" data-testid="orders-filter-convert">Convert</TabsTrigger>
        </TabsList>
      </Tabs>

      {showConvert && (
        <SectionCard
          title="Convert History"
          description={convertQ.data?.length ? `${convertQ.data.length} swaps` : undefined}
          icon={ArrowLeftRight}
          padded={false}
          className="mt-4"
        >
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead className="bg-muted/30 border-b border-border/60">
                <tr className="text-xs uppercase tracking-wide text-muted-foreground text-left">
                  <th className="px-4 py-3 font-medium">Date</th>
                  <th className="px-4 py-3 font-medium">From → To</th>
                  <th className="px-4 py-3 font-medium text-right">From</th>
                  <th className="px-4 py-3 font-medium text-right">To</th>
                  <th className="px-4 py-3 font-medium text-right">Rate</th>
                  <th className="px-4 py-3 font-medium">Status</th>
                </tr>
              </thead>
              <tbody>
                {convertQ.isLoading ? (
                  <tr><td colSpan={6} className="p-4"><div className="h-4 bg-muted/30 rounded animate-pulse" /></td></tr>
                ) : (convertQ.data?.length ?? 0) === 0 ? (
                  <tr><td colSpan={6} className="p-0">
                    <EmptyState
                      icon={ArrowLeftRight}
                      title="Koi conversion nahi"
                      description="Quick Convert pe ek click — instant swap ho jayega."
                      action={<Link href="/convert"><Button size="sm" data-testid="orders-go-convert">Try Convert</Button></Link>}
                    />
                  </td></tr>
                ) : (
                  convertQ.data!.map((r) => (
                    <tr key={`cvt-${r.id}`} className="border-b border-border/40" data-testid={`convert-row-${r.id}`}>
                      <td className="px-4 py-3 text-muted-foreground tabular-nums text-xs">
                        {new Date(r.createdAt).toLocaleString("en-IN", { dateStyle: "short", timeStyle: "short" })}
                      </td>
                      <td className="px-4 py-3 font-medium">{r.fromCoin} <span className="text-muted-foreground">→</span> {r.toCoin}</td>
                      <td className="px-4 py-3 font-mono tabular-nums text-right">{Number(r.fromAmount).toLocaleString("en-IN", { maximumFractionDigits: 8 })}</td>
                      <td className="px-4 py-3 font-mono tabular-nums text-right text-emerald-400">{Number(r.toAmount).toLocaleString("en-IN", { maximumFractionDigits: 8 })}</td>
                      <td className="px-4 py-3 font-mono tabular-nums text-right text-xs text-muted-foreground">{Number(r.rate).toLocaleString("en-IN", { maximumFractionDigits: 6 })}</td>
                      <td className="px-4 py-3"><StatusPill status={r.status} /></td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          </div>
        </SectionCard>
      )}

      {filter !== "convert" && <SectionCard
        title={filter === "all" ? "All Orders" : filter === "spot" ? "Spot Orders" : "Futures Orders"}
        description={orders.length ? `${orders.length} total` : undefined}
        icon={ListOrdered}
        padded={false}
        className="mt-4"
      >
        <div className="overflow-x-auto">
          <table className="w-full text-left text-sm">
            <thead className="bg-muted/30 border-b border-border/60">
              <tr className="text-xs uppercase tracking-wide text-muted-foreground">
                <th className="px-4 py-3 font-medium">Date</th>
                <th className="px-4 py-3 font-medium">Pair</th>
                <th className="px-4 py-3 font-medium">Type</th>
                <th className="px-4 py-3 font-medium">Side</th>
                <th className="px-4 py-3 font-medium text-right">Price</th>
                <th className="px-4 py-3 font-medium text-right">Amount</th>
                <th className="px-4 py-3 font-medium">Status</th>
                <th className="px-4 py-3 font-medium text-right">Action</th>
              </tr>
            </thead>
            <tbody>
              {isLoading ? (
                Array.from({ length: 4 }).map((_, i) => (
                  <tr key={i} className="border-b border-border/40">
                    <td colSpan={8} className="px-4 py-4">
                      <div className="h-4 w-full bg-muted/30 rounded animate-pulse" />
                    </td>
                  </tr>
                ))
              ) : orders.length === 0 ? (
                <tr>
                  <td colSpan={8} className="p-0">
                    <EmptyState
                      icon={FileText}
                      title="Koi order nahi mila"
                      description="Aapne abhi tak koi order place nahi kiya. Spot ya Futures pe trade shuru karein."
                    />
                  </td>
                </tr>
              ) : (
                orders.map((o) => {
                  const isOpen = String(o.status).toLowerCase() === "open";
                  const openFills = () => setFillsOrderId(o.id);
                  return (
                    <tr
                      key={o.id}
                      className="border-b border-border/40 hover:bg-muted/20 transition-colors cursor-pointer"
                      data-testid={`order-row-${o.id}`}
                      onClick={openFills}
                      onKeyDown={(e) => {
                        if (e.key === "Enter" || e.key === " ") {
                          e.preventDefault();
                          openFills();
                        }
                      }}
                      role="button"
                      tabIndex={0}
                      aria-label={`View fills for order ${o.id}`}
                    >
                      <td className="px-4 py-3 text-muted-foreground tabular-nums">
                        {new Date(o.createdAt).toLocaleString("en-IN", {
                          dateStyle: "short",
                          timeStyle: "short",
                        })}
                      </td>
                      <td className="px-4 py-3 font-semibold text-foreground">
                        <span className="inline-flex items-center gap-1.5">
                          {o.symbol}
                          <Layers className="w-3 h-3 text-muted-foreground/60" />
                        </span>
                      </td>
                      <td className="px-4 py-3 uppercase text-xs text-muted-foreground tracking-wide">
                        {o.type}
                      </td>
                      <td
                        className={cn(
                          "px-4 py-3 font-bold uppercase text-xs tracking-wide",
                          o.side === "buy" ? "text-emerald-400" : "text-red-400",
                        )}
                      >
                        {o.side}
                      </td>
                      <td className="px-4 py-3 font-mono tabular-nums text-right">
                        {(() => {
                          const isMarket = String(o.type).toLowerCase() === "market";
                          const avg = Number(o.avgPrice ?? 0);
                          const filled = Number(o.filledQty ?? 0);
                          // Filled / partial → show actual avg fill price (truth)
                          if (filled > 0 && avg > 0) {
                            return (
                              <span className="inline-flex flex-col items-end leading-tight">
                                <span>{avg.toLocaleString("en-IN", { maximumFractionDigits: 4 })}</span>
                                <span className="text-[10px] text-muted-foreground">avg fill</span>
                              </span>
                            );
                          }
                          // Open market order with no fill yet → just say "Market"
                          if (isMarket) return <span className="text-muted-foreground">Market</span>;
                          // Open limit order → user's limit price
                          const lim = Number(o.price ?? 0);
                          return lim > 0 ? lim.toLocaleString("en-IN", { maximumFractionDigits: 4 }) : "—";
                        })()}
                      </td>
                      <td className="px-4 py-3 font-mono tabular-nums text-right">
                        {Number(o.amount).toLocaleString("en-IN", { maximumFractionDigits: 8 })}
                      </td>
                      <td className="px-4 py-3">
                        <StatusPill status={o.status} />
                      </td>
                      <td className="px-4 py-3 text-right">
                        {isOpen ? (
                          <Button
                            size="sm"
                            variant="outline"
                            onClick={(e) => {
                              e.stopPropagation();
                              setConfirmId(o.id);
                            }}
                            data-testid={`order-cancel-${o.id}`}
                            aria-label={`Cancel order ${o.id}`}
                            className="text-red-400 border-red-500/30 hover:bg-red-500/10"
                          >
                            <X className="w-3.5 h-3.5 mr-1" />
                            Cancel
                          </Button>
                        ) : (
                          <span className="text-muted-foreground text-xs">—</span>
                        )}
                      </td>
                    </tr>
                  );
                })
              )}
            </tbody>
          </table>
        </div>
      </SectionCard>}

      <OrderFillsDialog
        orderId={fillsOrderId}
        open={fillsOrderId !== null}
        onOpenChange={(o) => !o && setFillsOrderId(null)}
      />

      <AlertDialog open={confirmId !== null} onOpenChange={(o) => !o && setConfirmId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Order cancel karein?</AlertDialogTitle>
            <AlertDialogDescription>
              Yeh order book se hata diya jayega. Filled portion (agar koi hai)
              aapke wallet mein settle ho chuka hoga. Kya aap sure hain?
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel data-testid="order-cancel-dismiss">Wapas</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => confirmId !== null && cancelMutation.mutate(confirmId)}
              disabled={cancelMutation.isPending}
              data-testid="order-cancel-confirm"
              className="bg-red-500 hover:bg-red-600 text-white"
            >
              {cancelMutation.isPending ? "Cancelling…" : "Haan, Cancel"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
