import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useAuth } from "@/lib/auth";

type W = {
  id: number; userId: number; coinId: number; networkId: number; amount: string; fee: string;
  toAddress: string; memo: string | null; txHash: string | null; status: string; rejectReason: string | null; createdAt: string;
};

export default function CryptoWithdrawalsPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data = [] } = useQuery<W[]>({ queryKey: ["/admin/crypto-withdrawals"], queryFn: () => get<W[]>("/admin/crypto-withdrawals") });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Record<string, unknown> }) => patch(`/admin/crypto-withdrawals/${id}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/crypto-withdrawals"] }) });

  return (
    <Card>
      <div className="overflow-x-auto">
        <Table>
          <TableHeader><TableRow>
            <TableHead>UID</TableHead>
            <TableHead>User</TableHead><TableHead>Coin/Net</TableHead><TableHead>Amount</TableHead>
            <TableHead>Address</TableHead><TableHead>TxHash</TableHead><TableHead>Status</TableHead>
            <TableHead>Date</TableHead><TableHead>Actions</TableHead>
          </TableRow></TableHeader>
          <TableBody>
            {data.map((w) => (
              <TableRow key={w.id}>
                <TableCell className="font-mono text-[10px] text-muted-foreground" title={(w as any).uid}>{((w as any).uid || "").slice(0, 10)}…</TableCell>
                <TableCell>#{w.userId}</TableCell>
                <TableCell>#{w.coinId}/{w.networkId}</TableCell>
                <TableCell className="tabular-nums">{w.amount}</TableCell>
                <TableCell className="font-mono text-xs truncate max-w-[180px]">{w.toAddress}</TableCell>
                <TableCell className="font-mono text-xs truncate max-w-[180px]">{w.txHash || "—"}</TableCell>
                <TableCell><Badge variant={w.status === "completed" ? "default" : w.status === "rejected" ? "destructive" : "secondary"}>{w.status}</Badge></TableCell>
                <TableCell className="text-xs">{new Date(w.createdAt).toLocaleString("en-IN")}</TableCell>
                <TableCell className="space-x-1">
                  {isAdmin && w.status === "pending" && (
                    <>
                      <Button size="sm" onClick={() => {
                        const tx = prompt("Tx hash (optional)?") || "";
                        update.mutate({ id: w.id, body: { status: "completed", txHash: tx } });
                      }}>Mark Sent</Button>
                      <Button size="sm" variant="destructive" onClick={() => {
                        const reason = prompt("Reject reason?");
                        if (reason) update.mutate({ id: w.id, body: { status: "rejected", rejectReason: reason } });
                      }}>Reject</Button>
                    </>
                  )}
                </TableCell>
              </TableRow>
            ))}
            {data.length === 0 && <TableRow><TableCell colSpan={8} className="text-center py-6 text-muted-foreground">No withdrawals</TableCell></TableRow>}
          </TableBody>
        </Table>
      </div>
    </Card>
  );
}
