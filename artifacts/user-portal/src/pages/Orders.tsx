import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { toast } from "sonner";

export default function Orders() {
  const queryClient = useQueryClient();
  
  const { data: ordersData, isLoading } = useQuery<any>({
    queryKey: ["orders"],
    queryFn: () => get("/orders")
  });
  const orders: any[] = Array.isArray(ordersData)
    ? ordersData
    : Array.isArray(ordersData?.orders)
      ? ordersData.orders
      : Array.isArray(ordersData?.data)
        ? ordersData.data
        : [];

  const cancelMutation = useMutation({
    mutationFn: (id: number) => post(`/orders/${id}/cancel`),
    onSuccess: () => {
      toast.success("Order cancelled");
      queryClient.invalidateQueries({ queryKey: ["orders"] });
    },
    onError: () => toast.error("Failed to cancel order")
  });

  return (
    <div className="p-8 container mx-auto max-w-6xl">
      <h1 className="text-3xl font-bold mb-8">Orders</h1>

      <div className="bg-card border border-border rounded-lg overflow-hidden">
        <table className="w-full text-left text-sm">
          <thead className="bg-muted/50 border-b border-border">
            <tr>
              <th className="p-4">Date</th>
              <th className="p-4">Pair</th>
              <th className="p-4">Type</th>
              <th className="p-4">Side</th>
              <th className="p-4">Price</th>
              <th className="p-4">Amount</th>
              <th className="p-4">Status</th>
              <th className="p-4">Action</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan={8} className="p-8 text-center text-muted-foreground">Loading...</td></tr>
            ) : orders.length ? (
              orders.map((o: any) => (
                <tr key={o.id} className="border-b border-border">
                  <td className="p-4">{new Date(o.createdAt).toLocaleString()}</td>
                  <td className="p-4 font-bold">{o.symbol}</td>
                  <td className="p-4 uppercase">{o.type}</td>
                  <td className={`p-4 font-bold uppercase ${o.side === "buy" ? "text-success" : "text-destructive"}`}>{o.side}</td>
                  <td className="p-4 font-mono">{o.price || "Market"}</td>
                  <td className="p-4 font-mono">{o.amount}</td>
                  <td className="p-4">{o.status}</td>
                  <td className="p-4">
                    {o.status === "open" && (
                      <Button size="sm" variant="destructive" onClick={() => cancelMutation.mutate(o.id)}>
                        Cancel
                      </Button>
                    )}
                  </td>
                </tr>
              ))
            ) : (
              <tr><td colSpan={8} className="p-8 text-center text-muted-foreground">No orders found</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
