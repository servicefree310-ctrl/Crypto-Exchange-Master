import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsList, TabsTrigger } from "@/components/ui/tabs";
import { useState } from "react";
import { useAuth } from "@/lib/auth";

type Bank = {
  id: number; userId: number; bankName: string; accountNumber: string; ifsc: string;
  holderName: string; status: string; rejectReason: string | null; createdAt: string;
};

export default function BanksPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const [tab, setTab] = useState("under_review");
  const { data = [] } = useQuery<Bank[]>({ queryKey: ["/admin/banks", tab], queryFn: () => get<Bank[]>(`/admin/banks?status=${tab}`) });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: Record<string, unknown> }) => patch(`/admin/banks/${id}`, body), onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/banks"] }) });

  return (
    <div className="space-y-4">
      <Tabs value={tab} onValueChange={setTab}>
        <TabsList>
          <TabsTrigger value="under_review">Pending</TabsTrigger>
          <TabsTrigger value="verified">Verified</TabsTrigger>
          <TabsTrigger value="rejected">Rejected</TabsTrigger>
        </TabsList>
      </Tabs>
      <Card>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader><TableRow>
              <TableHead>User ID</TableHead><TableHead>Holder Name</TableHead>
              <TableHead>Bank</TableHead><TableHead>Account #</TableHead>
              <TableHead>IFSC</TableHead><TableHead>Status</TableHead>
              <TableHead>Submitted</TableHead><TableHead>Actions</TableHead>
            </TableRow></TableHeader>
            <TableBody>
              {data.map((b) => (
                <TableRow key={b.id}>
                  <TableCell>#{b.userId}</TableCell>
                  <TableCell className="font-medium">{b.holderName}</TableCell>
                  <TableCell>{b.bankName}</TableCell>
                  <TableCell className="font-mono text-xs">{b.accountNumber}</TableCell>
                  <TableCell className="font-mono text-xs">{b.ifsc}</TableCell>
                  <TableCell><Badge variant={b.status === "verified" ? "default" : b.status === "rejected" ? "destructive" : "secondary"}>{b.status}</Badge></TableCell>
                  <TableCell className="text-xs">{new Date(b.createdAt).toLocaleDateString("en-IN")}</TableCell>
                  <TableCell className="space-x-1">
                    {isAdmin && b.status === "under_review" && (
                      <>
                        <Button size="sm" onClick={() => update.mutate({ id: b.id, body: { status: "verified" } })}>Verify</Button>
                        <Button size="sm" variant="destructive" onClick={() => {
                          const reason = prompt("Reject reason?");
                          if (reason) update.mutate({ id: b.id, body: { status: "rejected", rejectReason: reason } });
                        }}>Reject</Button>
                      </>
                    )}
                    {b.rejectReason && <div className="text-xs text-destructive mt-1">{b.rejectReason}</div>}
                  </TableCell>
                </TableRow>
              ))}
              {data.length === 0 && <TableRow><TableCell colSpan={8} className="text-center py-6 text-muted-foreground">No bank accounts</TableCell></TableRow>}
            </TableBody>
          </Table>
        </div>
      </Card>
    </div>
  );
}
