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
import { ListOrdered, RefreshCw, FileText, X } from "lucide-react";
import { PageHeader } from "@/components/premium/PageHeader";
import { SectionCard } from "@/components/premium/SectionCard";
import { EmptyState } from "@/components/premium/EmptyState";
import { StatusPill } from "@/components/premium/StatusPill";
import { cn } from "@/lib/utils";

type Order = {
  id: number;
  symbol: string;
  type: string;
  side: "buy" | "sell";
  price?: string | number | null;
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
export default function Orders() {
  const queryClient = useQueryClient();
  const [confirmId, setConfirmId] = useState<number | null>(null);

  const { data: ordersData, isLoading, isFetching, refetch } = useQuery<unknown>({
    queryKey: ["orders"],
    queryFn: () => get("/orders"),
  });

  const orders: Order[] = useMemo(() => {
    const d = ordersData as { orders?: Order[]; data?: Order[] } | Order[] | undefined;
    if (Array.isArray(d)) return d;
    if (d?.orders && Array.isArray(d.orders)) return d.orders;
    if (d?.data && Array.isArray(d.data)) return d.data;
    return [];
  }, [ordersData]);

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

      <SectionCard
        title="All Orders"
        description={orders.length ? `${orders.length} total` : undefined}
        icon={ListOrdered}
        padded={false}
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
                  return (
                    <tr
                      key={o.id}
                      className="border-b border-border/40 hover:bg-muted/20 transition-colors"
                      data-testid={`order-row-${o.id}`}
                    >
                      <td className="px-4 py-3 text-muted-foreground tabular-nums">
                        {new Date(o.createdAt).toLocaleString("en-IN", {
                          dateStyle: "short",
                          timeStyle: "short",
                        })}
                      </td>
                      <td className="px-4 py-3 font-semibold text-foreground">{o.symbol}</td>
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
                        {o.price && Number(o.price) > 0 ? Number(o.price).toLocaleString("en-IN") : "Market"}
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
                            onClick={() => setConfirmId(o.id)}
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
      </SectionCard>

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
