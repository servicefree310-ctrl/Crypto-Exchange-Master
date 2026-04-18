import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { useAuth } from "@/lib/auth";

type Dep = {
  id: number; userId: number; gatewayId: number; amount: string; fee: string;
  refId: string; utr: string | null; status: string; notes: string | null; createdAt: string;
};

export default function InrDepositsPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data = [] } = useQuery<Dep[]>({ queryKey: ["/admin/inr-deposits"], queryFn: () => get<Dep[]>("/admin/inr-deposits") });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Record<string, unknown> }) => patch(`/admin/inr-deposits/${id}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/inr-deposits"] }) });

  return (
    <Card>
      <div className="overflow-x-auto">
        <Table>
          <TableHeader><TableRow>
            <TableHead>Ref ID</TableHead><TableHead>User</TableHead><TableHead>Amount</TableHead>
            <TableHead>UTR</TableHead><TableHead>Status</TableHead><TableHead>Date</TableHead><TableHead>Actions</TableHead>
          </TableRow></TableHeader>
          <TableBody>
            {data.map((d) => (
              <TableRow key={d.id}>
                <TableCell className="font-mono text-xs">{d.refId}</TableCell>
                <TableCell>#{d.userId}</TableCell>
                <TableCell className="tabular-nums font-medium">₹{Number(d.amount).toLocaleString("en-IN")}</TableCell>
                <TableCell className="font-mono text-xs">{d.utr || "—"}</TableCell>
                <TableCell><Badge variant={d.status === "completed" ? "default" : d.status === "rejected" ? "destructive" : "secondary"}>{d.status}</Badge></TableCell>
                <TableCell className="text-xs">{new Date(d.createdAt).toLocaleString("en-IN")}</TableCell>
                <TableCell className="space-x-1">
                  {isAdmin && d.status === "pending" && (
                    <>
                      <Button size="sm" onClick={() => update.mutate({ id: d.id, body: { status: "completed" } })}>Approve</Button>
                      <Button size="sm" variant="destructive" onClick={() => {
                        const notes = prompt("Reject reason?");
                        if (notes) update.mutate({ id: d.id, body: { status: "rejected", notes } });
                      }}>Reject</Button>
                    </>
                  )}
                </TableCell>
              </TableRow>
            ))}
            {data.length === 0 && <TableRow><TableCell colSpan={7} className="text-center py-6 text-muted-foreground">No deposits</TableCell></TableRow>}
          </TableBody>
        </Table>
      </div>
    </Card>
  );
}
