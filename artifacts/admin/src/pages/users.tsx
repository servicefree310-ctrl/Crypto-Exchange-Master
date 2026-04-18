import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { useAuth } from "@/lib/auth";
import { useState } from "react";
import { Input } from "@/components/ui/input";

type User = {
  id: number; email: string; name: string; phone: string | null;
  role: string; status: string; kycLevel: number; vipTier: number;
  uid: string; referralCode: string; createdAt: string;
};

const ROLES = ["user", "support", "admin", "superadmin"];
const STATUSES = ["active", "suspended", "banned"];

export default function UsersPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const [search, setSearch] = useState("");
  const { data = [], isLoading } = useQuery<User[]>({
    queryKey: ["/admin/users"],
    queryFn: () => get<User[]>("/admin/users"),
  });

  const update = useMutation({
    mutationFn: ({ id, body }: { id: number; body: Partial<User> }) => patch(`/admin/users/${id}`, body),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["/admin/users"] }),
  });

  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const filtered = data.filter((u) =>
    !search || u.email.toLowerCase().includes(search.toLowerCase()) ||
    (u.name || "").toLowerCase().includes(search.toLowerCase()) ||
    (u.phone || "").includes(search) || u.uid.includes(search)
  );

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between gap-3">
        <Input
          placeholder="Search by email, name, phone, UID…"
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="max-w-sm"
        />
        <div className="text-sm text-muted-foreground">{filtered.length} users</div>
      </div>

      <Card className="overflow-hidden">
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>UID</TableHead>
                <TableHead>Email / Name</TableHead>
                <TableHead>Phone</TableHead>
                <TableHead>Role</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>KYC</TableHead>
                <TableHead>VIP</TableHead>
                <TableHead>Created</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {isLoading && (
                <TableRow><TableCell colSpan={8} className="text-center text-muted-foreground py-6">Loading…</TableCell></TableRow>
              )}
              {filtered.map((u) => (
                <TableRow key={u.id}>
                  <TableCell className="font-mono text-xs">{u.uid}</TableCell>
                  <TableCell>
                    <div className="font-medium">{u.email}</div>
                    {u.name && <div className="text-xs text-muted-foreground">{u.name}</div>}
                  </TableCell>
                  <TableCell>{u.phone || "—"}</TableCell>
                  <TableCell>
                    {isAdmin ? (
                      <Select value={u.role} onValueChange={(v) => update.mutate({ id: u.id, body: { role: v } })}>
                        <SelectTrigger className="h-8 w-32"><SelectValue /></SelectTrigger>
                        <SelectContent>{ROLES.map((r) => <SelectItem key={r} value={r}>{r}</SelectItem>)}</SelectContent>
                      </Select>
                    ) : <Badge variant="outline">{u.role}</Badge>}
                  </TableCell>
                  <TableCell>
                    {isAdmin ? (
                      <Select value={u.status} onValueChange={(v) => update.mutate({ id: u.id, body: { status: v } })}>
                        <SelectTrigger className="h-8 w-32"><SelectValue /></SelectTrigger>
                        <SelectContent>{STATUSES.map((r) => <SelectItem key={r} value={r}>{r}</SelectItem>)}</SelectContent>
                      </Select>
                    ) : (
                      <Badge variant={u.status === "active" ? "default" : "destructive"}>{u.status}</Badge>
                    )}
                  </TableCell>
                  <TableCell>
                    {isAdmin ? (
                      <Select value={String(u.kycLevel)} onValueChange={(v) => update.mutate({ id: u.id, body: { kycLevel: Number(v) } })}>
                        <SelectTrigger className="h-8 w-20"><SelectValue /></SelectTrigger>
                        <SelectContent>{[0,1,2,3].map((r) => <SelectItem key={r} value={String(r)}>L{r}</SelectItem>)}</SelectContent>
                      </Select>
                    ) : <Badge>L{u.kycLevel}</Badge>}
                  </TableCell>
                  <TableCell>
                    {isAdmin ? (
                      <Select value={String(u.vipTier)} onValueChange={(v) => update.mutate({ id: u.id, body: { vipTier: Number(v) } })}>
                        <SelectTrigger className="h-8 w-20"><SelectValue /></SelectTrigger>
                        <SelectContent>{[0,1,2,3,4,5].map((r) => <SelectItem key={r} value={String(r)}>V{r}</SelectItem>)}</SelectContent>
                      </Select>
                    ) : <Badge variant="outline">V{u.vipTier}</Badge>}
                  </TableCell>
                  <TableCell className="text-xs text-muted-foreground">
                    {new Date(u.createdAt).toLocaleDateString("en-IN")}
                  </TableCell>
                </TableRow>
              ))}
              {!isLoading && filtered.length === 0 && (
                <TableRow><TableCell colSpan={8} className="text-center text-muted-foreground py-6">No users</TableCell></TableRow>
              )}
            </TableBody>
          </Table>
        </div>
      </Card>
      {update.isPending && <div className="text-xs text-muted-foreground">Saving…</div>}
      <Button variant="outline" size="sm" onClick={() => qc.invalidateQueries({ queryKey: ["/admin/users"] })}>Refresh</Button>
    </div>
  );
}
