import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, patch, post, del } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Badge } from "@/components/ui/badge";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Database, RefreshCw, Trash2, Search, Activity, HardDrive, Server, Zap } from "lucide-react";
import { useState } from "react";
import { useToast } from "@/hooks/use-toast";

type Status = {
  ready: boolean; version?: string; uptimeSec?: number; memoryUsed?: string;
  memoryPeak?: string; maxMemory?: string; maxMemoryPolicy?: string;
  connectedClients?: number; totalCommands?: number; opsPerSec?: number;
  hits?: number; misses?: number; hitRate?: number; keysCount?: number;
};
type Cfg = {
  cacheKey: string; label: string; description: string; category: string;
  ttlSec: number; enabled: boolean; cacheOnServer: boolean;
  cacheOnMobile: boolean; cacheOnWeb: boolean; pattern: string;
};
type KeyRow = { key: string; type: string; ttl: number; preview: any };

function fmtSec(s?: number) {
  if (!s) return "—";
  const d = Math.floor(s / 86400), h = Math.floor((s % 86400) / 3600), m = Math.floor((s % 3600) / 60);
  return `${d}d ${h}h ${m}m`;
}

export default function RedisPage() {
  const qc = useQueryClient();
  const { toast } = useToast();
  const { data: status, refetch: refetchStatus } = useQuery<Status>({
    queryKey: ["redis-status"],
    queryFn: () => get("/admin/redis/status"),
    refetchInterval: 3000,
  });
  const { data: configs = [] } = useQuery<Cfg[]>({
    queryKey: ["redis-configs"],
    queryFn: () => get("/admin/redis/configs"),
  });

  const [pattern, setPattern] = useState("*");
  const { data: keysData, refetch: refetchKeys, isFetching: keysLoading } = useQuery<{ keys: KeyRow[]; total: number }>({
    queryKey: ["redis-keys", pattern],
    queryFn: () => get(`/admin/redis/keys?pattern=${encodeURIComponent(pattern)}&limit=200`),
    enabled: false,
  });

  const updateCfg = useMutation({
    mutationFn: (c: Partial<Cfg> & { cacheKey: string }) => patch(`/admin/redis/configs/${c.cacheKey}`, c),
    onSuccess: () => { qc.invalidateQueries({ queryKey: ["redis-configs"] }); toast({ title: "Saved" }); },
  });

  const flushPattern = useMutation({
    mutationFn: (p: string) => post("/admin/redis/flush-pattern", { pattern: p }),
    onSuccess: (r: any) => toast({ title: `Flushed ${r.deleted} keys` }),
  });
  const flushAll = useMutation({
    mutationFn: () => post("/admin/redis/flush-all", {}),
    onSuccess: () => toast({ title: "All cache flushed" }),
  });
  const delKey = useMutation({
    mutationFn: (k: string) => del(`/admin/redis/key?key=${encodeURIComponent(k)}`),
    onSuccess: () => { refetchKeys(); toast({ title: "Key deleted" }); },
  });
  const reseed = useMutation({
    mutationFn: () => post("/admin/redis/configs/reseed", {}),
    onSuccess: () => qc.invalidateQueries({ queryKey: ["redis-configs"] }),
  });

  const grouped = configs.reduce<Record<string, Cfg[]>>((acc, c) => {
    (acc[c.category] ||= []).push(c); return acc;
  }, {});

  return (
    <div className="space-y-4">
      <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
        <Card className="p-4">
          <div className="flex items-center gap-2 text-xs text-muted-foreground mb-1"><Server className="w-3 h-3" /> Status</div>
          <div className="flex items-center gap-2">
            <div className={`w-2 h-2 rounded-full ${status?.ready ? "bg-green-500" : "bg-red-500"}`} />
            <span className="font-bold">{status?.ready ? "Connected" : "Offline"}</span>
          </div>
          <div className="text-xs text-muted-foreground mt-1">v{status?.version || "—"} · uptime {fmtSec(status?.uptimeSec)}</div>
        </Card>
        <Card className="p-4">
          <div className="flex items-center gap-2 text-xs text-muted-foreground mb-1"><HardDrive className="w-3 h-3" /> Memory</div>
          <div className="font-bold">{status?.memoryUsed || "—"}</div>
          <div className="text-xs text-muted-foreground mt-1">peak {status?.memoryPeak || "—"} / max {status?.maxMemory || "—"}</div>
        </Card>
        <Card className="p-4">
          <div className="flex items-center gap-2 text-xs text-muted-foreground mb-1"><Database className="w-3 h-3" /> Keys</div>
          <div className="font-bold">{status?.keysCount?.toLocaleString() || 0}</div>
          <div className="text-xs text-muted-foreground mt-1">{status?.connectedClients || 0} clients · {status?.opsPerSec || 0} ops/s</div>
        </Card>
        <Card className="p-4">
          <div className="flex items-center gap-2 text-xs text-muted-foreground mb-1"><Zap className="w-3 h-3" /> Hit Rate</div>
          <div className="font-bold text-green-500">{status?.hitRate?.toFixed(1) || "0.0"}%</div>
          <div className="text-xs text-muted-foreground mt-1">{status?.hits?.toLocaleString() || 0} hits / {status?.misses?.toLocaleString() || 0} misses</div>
        </Card>
      </div>

      <div className="flex gap-2">
        <Button size="sm" variant="outline" onClick={() => refetchStatus()}><RefreshCw className="w-3 h-3 mr-1" /> Refresh</Button>
        <Button size="sm" variant="outline" onClick={() => reseed.mutate()}>Re-seed default configs</Button>
        <Button size="sm" variant="destructive" onClick={() => { if (confirm("Flush ALL Redis cache? This cannot be undone.")) flushAll.mutate(); }}>
          <Trash2 className="w-3 h-3 mr-1" /> Flush All Cache
        </Button>
      </div>

      <Tabs defaultValue="configs">
        <TabsList>
          <TabsTrigger value="configs">Cache Configs ({configs.length})</TabsTrigger>
          <TabsTrigger value="explorer">Key Explorer</TabsTrigger>
          <TabsTrigger value="info">Server Info</TabsTrigger>
        </TabsList>

        <TabsContent value="configs">
          {Object.entries(grouped).sort(([a],[b]) => a.localeCompare(b)).map(([cat, items]) => (
            <Card key={cat} className="mb-3">
              <div className="px-4 py-2 border-b font-semibold text-sm uppercase text-muted-foreground tracking-wide">{cat}</div>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Cache</TableHead>
                    <TableHead className="w-24">TTL (sec)</TableHead>
                    <TableHead className="w-20 text-center">Server</TableHead>
                    <TableHead className="w-20 text-center">Mobile</TableHead>
                    <TableHead className="w-20 text-center">Web</TableHead>
                    <TableHead className="w-20 text-center">Active</TableHead>
                    <TableHead className="w-32">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {items.map((c) => (
                    <TableRow key={c.cacheKey}>
                      <TableCell>
                        <div className="font-medium text-sm">{c.label}</div>
                        <div className="text-xs text-muted-foreground">{c.description}</div>
                        <div className="text-[10px] font-mono text-muted-foreground mt-0.5">{c.pattern || c.cacheKey}</div>
                      </TableCell>
                      <TableCell>
                        <Input type="number" defaultValue={c.ttlSec} className="h-8 w-20"
                          onBlur={(e) => { const v = Number(e.target.value); if (v !== c.ttlSec) updateCfg.mutate({ cacheKey: c.cacheKey, ttlSec: v }); }} />
                      </TableCell>
                      <TableCell className="text-center"><Switch checked={c.cacheOnServer} onCheckedChange={(v) => updateCfg.mutate({ cacheKey: c.cacheKey, cacheOnServer: v })} /></TableCell>
                      <TableCell className="text-center"><Switch checked={c.cacheOnMobile} onCheckedChange={(v) => updateCfg.mutate({ cacheKey: c.cacheKey, cacheOnMobile: v })} /></TableCell>
                      <TableCell className="text-center"><Switch checked={c.cacheOnWeb} onCheckedChange={(v) => updateCfg.mutate({ cacheKey: c.cacheKey, cacheOnWeb: v })} /></TableCell>
                      <TableCell className="text-center"><Switch checked={c.enabled} onCheckedChange={(v) => updateCfg.mutate({ cacheKey: c.cacheKey, enabled: v })} /></TableCell>
                      <TableCell>
                        <Button size="sm" variant="outline" onClick={() => { const p = c.pattern || c.cacheKey; if (confirm(`Flush keys matching "${p}"?`)) flushPattern.mutate(p); }}>
                          <Trash2 className="w-3 h-3 mr-1" /> Flush
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </Card>
          ))}
        </TabsContent>

        <TabsContent value="explorer">
          <Card className="p-4">
            <div className="flex gap-2 mb-3">
              <Input placeholder="Pattern (e.g. price:*, orderbook:BTCINR:*)" value={pattern} onChange={(e) => setPattern(e.target.value)} className="flex-1" />
              <Button onClick={() => refetchKeys()} disabled={keysLoading}><Search className="w-3 h-3 mr-1" /> Scan</Button>
              <Button variant="destructive" onClick={() => { if (confirm(`Flush all keys matching "${pattern}"?`)) flushPattern.mutate(pattern); }}>Flush Match</Button>
            </div>
            {keysData && (
              <>
                <div className="text-xs text-muted-foreground mb-2">Found {keysData.total} keys (showing first {keysData.keys.length})</div>
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Key</TableHead>
                      <TableHead className="w-20">Type</TableHead>
                      <TableHead className="w-20">TTL</TableHead>
                      <TableHead>Preview</TableHead>
                      <TableHead className="w-20"></TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {keysData.keys.map((k) => (
                      <TableRow key={k.key}>
                        <TableCell className="font-mono text-xs">{k.key}</TableCell>
                        <TableCell><Badge variant="secondary" className="text-[10px]">{k.type}</Badge></TableCell>
                        <TableCell className="text-xs">{k.ttl < 0 ? "∞" : `${k.ttl}s`}</TableCell>
                        <TableCell className="font-mono text-[10px] max-w-md truncate">{typeof k.preview === "string" ? k.preview : JSON.stringify(k.preview)}</TableCell>
                        <TableCell><Button size="sm" variant="ghost" onClick={() => delKey.mutate(k.key)}><Trash2 className="w-3 h-3" /></Button></TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </>
            )}
          </Card>
        </TabsContent>

        <TabsContent value="info">
          <Card className="p-4 space-y-2 text-sm">
            <div className="grid grid-cols-2 gap-2">
              <div><Label className="text-xs text-muted-foreground">Version</Label><div>{status?.version}</div></div>
              <div><Label className="text-xs text-muted-foreground">Uptime</Label><div>{fmtSec(status?.uptimeSec)}</div></div>
              <div><Label className="text-xs text-muted-foreground">Memory Used</Label><div>{status?.memoryUsed}</div></div>
              <div><Label className="text-xs text-muted-foreground">Memory Peak</Label><div>{status?.memoryPeak}</div></div>
              <div><Label className="text-xs text-muted-foreground">Max Memory</Label><div>{status?.maxMemory}</div></div>
              <div><Label className="text-xs text-muted-foreground">Eviction Policy</Label><div>{status?.maxMemoryPolicy}</div></div>
              <div><Label className="text-xs text-muted-foreground">Connected Clients</Label><div>{status?.connectedClients}</div></div>
              <div><Label className="text-xs text-muted-foreground">Total Commands</Label><div>{status?.totalCommands?.toLocaleString()}</div></div>
              <div><Label className="text-xs text-muted-foreground">Ops / Second</Label><div>{status?.opsPerSec}</div></div>
              <div><Label className="text-xs text-muted-foreground">Total Keys</Label><div>{status?.keysCount?.toLocaleString()}</div></div>
            </div>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
