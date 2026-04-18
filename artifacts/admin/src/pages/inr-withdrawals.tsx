import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useAuth } from "@/lib/auth";

type W = {
  id: number; userId: number; bankId: number; amount: string; fee: string;
  refId: string; status: string; rejectReason: string | null; createdAt: string;
};

export default function InrWithdrawalsPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data = [] } = useQuery<W[]>({ queryKey: ["/admin/inr-withdrawals"], queryFn: () => get<W[]>("/admin/inr-withdrawals") });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Record<string, unknown> }) => patch(`/admin/inr-withdrawals/${id}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/inr-withdrawals"] }) });

  return (
    <Card>
      <div className="overflow-x-auto">
        <Table>
          <TableHeader><TableRow>
            <TableHead>Ref ID</TableHead><TableHead>User</TableHead><TableHead>Bank</TableHead>
            <TableHead>Amount</TableHead><TableHead>Fee</TableHead><TableHead>Status</TableHead>
            <TableHead>Date</TableHead><TableHead>Actions</TableHead>
          </TableRow></TableHeader>
          <TableBody>
            {data.map((d) => (
              <TableRow key={d.id}>
                <TableCell className="font-mono text-xs">{d.refId}</TableCell>
                <TableCell>#{d.userId}</TableCell>
                <TableCell>#{d.bankId}</TableCell>
                <TableCell className="tabular-nums font-medium">₹{Number(d.amount).toLocaleString("en-IN")}</TableCell>
                <TableCell className="tabular-nums">₹{d.fee}</TableCell>
                <TableCell><Badge variant={d.status === "completed" ? "default" : d.status === "rejected" ? "destructive" : "secondary"}>{d.status}</Badge></TableCell>
                <TableCell className="text-xs">{new Date(d.createdAt).toLocaleString("en-IN")}</TableCell>
                <TableCell className="space-x-1">
                  {isAdmin && d.status === "pending" && (
                    <>
                      <Button size="sm" onClick={() => update.mutate({ id: d.id, body: { status: "completed" } })}>Mark Paid</Button>
                      <Button size="sm" variant="destructive" onClick={() => {
                        const reason = prompt("Reject reason?");
                        if (reason) update.mutate({ id: d.id, body: { status: "rejected", rejectReason: reason } });
                      }}>Reject</Button>
                    </>
                  )}
                  {d.rejectReason && <div className="text-xs text-destructive mt-1">{d.rejectReason}</div>}
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
