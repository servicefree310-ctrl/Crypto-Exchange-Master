import { useQuery } from "@tanstack/react-query";
import { get } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";

type Log = {
  id: number; userId: number | null; email: string | null; ip: string | null;
  userAgent: string | null; success: string; reason: string | null; createdAt: string;
};

export default function LoginLogsPage() {
  const { data = [] } = useQuery<Log[]>({ queryKey: ["/admin/login-logs"], queryFn: () => get<Log[]>("/admin/login-logs") });
  return (
    <Card>
      <div className="overflow-x-auto">
        <Table>
          <TableHeader><TableRow>
            <TableHead>Time</TableHead><TableHead>Email</TableHead><TableHead>IP</TableHead>
            <TableHead>UA</TableHead><TableHead>Success</TableHead><TableHead>Reason</TableHead>
          </TableRow></TableHeader>
          <TableBody>
            {data.map((l) => (
              <TableRow key={l.id}>
                <TableCell className="text-xs">{new Date(l.createdAt).toLocaleString("en-IN")}</TableCell>
                <TableCell>{l.email}</TableCell>
                <TableCell className="font-mono text-xs">{l.ip}</TableCell>
                <TableCell className="text-xs truncate max-w-[260px]">{l.userAgent}</TableCell>
                <TableCell><Badge variant={l.success === "true" ? "default" : "destructive"}>{l.success}</Badge></TableCell>
                <TableCell className="text-xs text-muted-foreground">{l.reason || "—"}</TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>
    </Card>
  );
}
