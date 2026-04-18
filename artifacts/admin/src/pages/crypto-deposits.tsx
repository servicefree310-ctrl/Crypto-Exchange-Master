import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useAuth } from "@/lib/auth";

type D = {
  id: number; userId: number; coinId: number; networkId: number; amount: string;
  address: string; txHash: string | null; confirmations: number; status: string; createdAt: string;
};

export default function CryptoDepositsPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data = [] } = useQuery<D[]>({ queryKey: ["/admin/crypto-deposits"], queryFn: () => get<D[]>("/admin/crypto-deposits") });
  const update = useMutation({
    mutationFn: ({ id, body }: { id: number; body: Record<string, unknown> }) => patch(`/admin/crypto-deposits/${id}`, body),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/crypto-deposits"] }),
  });

  return (
    <Card>
      <div className="overflow-x-auto">
        <Table>
          <TableHeader><TableRow>
            <TableHead>User</TableHead><TableHead>Coin</TableHead><TableHead>Network</TableHead>
            <TableHead>Amount</TableHead><TableHead>Address</TableHead><TableHead>Tx Hash</TableHead>
            <TableHead>Confirms</TableHead><TableHead>Status</TableHead><TableHead>Date</TableHead>
            <TableHead>Actions</TableHead>
          </TableRow></TableHeader>
          <TableBody>
            {data.map((d) => (
              <TableRow key={d.id}>
                <TableCell>#{d.userId}</TableCell>
                <TableCell>#{d.coinId}</TableCell>
                <TableCell>#{d.networkId}</TableCell>
                <TableCell className="tabular-nums">{d.amount}</TableCell>
                <TableCell className="font-mono text-xs truncate max-w-[180px]" title={d.address}>{d.address}</TableCell>
                <TableCell className="font-mono text-xs truncate max-w-[180px]" title={d.txHash || ""}>{d.txHash || "—"}</TableCell>
                <TableCell>{d.confirmations}</TableCell>
                <TableCell><Badge variant={d.status === "completed" ? "default" : d.status === "rejected" ? "destructive" : "secondary"}>{d.status}</Badge></TableCell>
                <TableCell className="text-xs">{new Date(d.createdAt).toLocaleString("en-IN")}</TableCell>
                <TableCell className="space-x-1">
                  {isAdmin && d.status === "pending" && (
                    <>
                      <Button size="sm" onClick={() => {
                        const conf = prompt("Confirmations on chain?", String(d.confirmations || 12));
                        update.mutate({ id: d.id, body: { status: "completed", confirmations: Number(conf || 12) } });
                      }}>Approve</Button>
                      <Button size="sm" variant="destructive" onClick={() => {
                        if (confirm("Reject this deposit?")) update.mutate({ id: d.id, body: { status: "rejected" } });
                      }}>Reject</Button>
                    </>
                  )}
                </TableCell>
              </TableRow>
            ))}
            {data.length === 0 && <TableRow><TableCell colSpan={10} className="text-center py-6 text-muted-foreground">No deposits</TableCell></TableRow>}
          </TableBody>
        </Table>
      </div>
    </Card>
  );
}
