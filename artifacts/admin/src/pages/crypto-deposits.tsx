import { useQuery } from "@tanstack/react-query";
import { get } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";

type D = {
  id: number; userId: number; coinId: number; networkId: number; amount: string;
  address: string; txHash: string | null; confirmations: number; status: string; createdAt: string;
};

export default function CryptoDepositsPage() {
  const { data = [] } = useQuery<D[]>({ queryKey: ["/admin/crypto-deposits"], queryFn: () => get<D[]>("/admin/crypto-deposits") });
  return (
    <Card>
      <div className="overflow-x-auto">
        <Table>
          <TableHeader><TableRow>
            <TableHead>User</TableHead><TableHead>Coin</TableHead><TableHead>Network</TableHead>
            <TableHead>Amount</TableHead><TableHead>Address</TableHead><TableHead>Tx Hash</TableHead>
            <TableHead>Confirms</TableHead><TableHead>Status</TableHead><TableHead>Date</TableHead>
          </TableRow></TableHeader>
          <TableBody>
            {data.map((d) => (
              <TableRow key={d.id}>
                <TableCell>#{d.userId}</TableCell>
                <TableCell>#{d.coinId}</TableCell>
                <TableCell>#{d.networkId}</TableCell>
                <TableCell className="tabular-nums">{d.amount}</TableCell>
                <TableCell className="font-mono text-xs truncate max-w-[180px]">{d.address}</TableCell>
                <TableCell className="font-mono text-xs truncate max-w-[180px]">{d.txHash || "—"}</TableCell>
                <TableCell>{d.confirmations}</TableCell>
                <TableCell><Badge variant={d.status === "completed" ? "default" : "secondary"}>{d.status}</Badge></TableCell>
                <TableCell className="text-xs">{new Date(d.createdAt).toLocaleString("en-IN")}</TableCell>
              </TableRow>
            ))}
            {data.length === 0 && <TableRow><TableCell colSpan={9} className="text-center py-6 text-muted-foreground">No deposits</TableCell></TableRow>}
          </TableBody>
        </Table>
      </div>
    </Card>
  );
}
