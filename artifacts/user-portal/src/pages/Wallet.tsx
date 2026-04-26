import { useQuery } from "@tanstack/react-query";
import { get } from "@/lib/api";
import { useAuth } from "@/lib/auth";
import { Button } from "@/components/ui/button";

export default function Wallet() {
  const { user } = useAuth();
  
  const { data: wallet, isLoading } = useQuery<any>({
    queryKey: ["wallet"],
    queryFn: () => get("/finance/wallet"),
    enabled: !!user
  });

  return (
    <div className="p-8 container mx-auto max-w-5xl">
      <h1 className="text-3xl font-bold mb-8">Wallet Overview</h1>

      <div className="grid md:grid-cols-3 gap-6 mb-8">
        <div className="bg-card border border-border p-6 rounded-lg col-span-3 md:col-span-1">
          <div className="text-muted-foreground mb-2">Estimated Balance</div>
          <div className="text-4xl font-bold font-mono">
            ₹{wallet?.totalInrValue ? Number(wallet.totalInrValue).toLocaleString() : "0.00"}
          </div>
        </div>
      </div>

      <div className="bg-card border border-border rounded-lg overflow-hidden">
        <table className="w-full text-left">
          <thead className="bg-muted/50 border-b border-border text-sm">
            <tr>
              <th className="p-4">Coin</th>
              <th className="p-4">Free</th>
              <th className="p-4">Locked</th>
              <th className="p-4">Total</th>
              <th className="p-4">Action</th>
            </tr>
          </thead>
          <tbody>
            {isLoading ? (
              <tr><td colSpan={5} className="p-8 text-center text-muted-foreground">Loading...</td></tr>
            ) : wallet?.balances?.length ? (
              wallet.balances.map((b: any) => (
                <tr key={b.coin} className="border-b border-border">
                  <td className="p-4 font-bold">{b.coin}</td>
                  <td className="p-4 font-mono">{b.free}</td>
                  <td className="p-4 font-mono">{b.locked}</td>
                  <td className="p-4 font-mono">{Number(b.free) + Number(b.locked)}</td>
                  <td className="p-4 flex gap-2">
                    <Button size="sm" variant="outline">Deposit</Button>
                    <Button size="sm" variant="outline">Withdraw</Button>
                  </td>
                </tr>
              ))
            ) : (
              <tr><td colSpan={5} className="p-8 text-center text-muted-foreground">No balances found</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
