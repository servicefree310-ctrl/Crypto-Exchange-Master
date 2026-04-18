import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { get, post, patch, del } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { Plus, Trash2, Pencil, Wifi, Wallet, KeyRound, ExternalLink, RefreshCw, AlertTriangle } from "lucide-react";
import { useState } from "react";
import { useAuth } from "@/lib/auth";

type Coin = { id: number; symbol: string };
type Network = {
  id: number; coinId: number; name: string; chain: string; contractAddress: string | null;
  minDeposit: string; minWithdraw: string; withdrawFee: string; confirmations: number;
  depositEnabled: boolean; withdrawEnabled: boolean; memoRequired: boolean; status: string;
  nodeAddress: string | null; nodeStatus: string; lastNodeCheckAt: string | null;
  providerType: string;
  rpcApiKey: string | null; rpcApiKeySet?: boolean;
  hotWalletAddress: string | null; hotWalletKeySet?: boolean;
  explorerUrl: string | null;
  lastBlockHeight: number | null; blockHeightCheckedAt: string | null;
};

const PROVIDERS: Record<string, { label: string; placeholder: string; chains: string[]; signupUrl: string }> = {
  alchemy:    { label: "Alchemy (EVM)",      placeholder: "https://bnb-mainnet.g.alchemy.com/v2/YOUR_KEY", chains: ["BNB","ETH","POLYGON","ARBITRUM"], signupUrl: "https://alchemy.com" },
  infura:     { label: "Infura (EVM)",       placeholder: "https://mainnet.infura.io/v3/YOUR_KEY",        chains: ["ETH","POLYGON","ARBITRUM"],       signupUrl: "https://infura.io" },
  trongrid:   { label: "TronGrid (TRC-20)",  placeholder: "https://api.trongrid.io",                      chains: ["TRX"],                            signupUrl: "https://trongrid.io" },
  blockcypher:{ label: "BlockCypher (BTC)",  placeholder: "https://api.blockcypher.com/v1/btc/main",      chains: ["BTC"],                            signupUrl: "https://blockcypher.com" },
  helius:     { label: "Helius (Solana)",    placeholder: "https://mainnet.helius-rpc.com/?api-key=KEY",  chains: ["SOL"],                            signupUrl: "https://helius.xyz" },
  quicknode:  { label: "QuickNode",          placeholder: "https://your-endpoint.quiknode.pro/TOKEN/",    chains: ["BTC","SOL","ETH","BNB"],          signupUrl: "https://quicknode.com" },
  custom:     { label: "Custom RPC",         placeholder: "https://your-rpc-url",                         chains: [],                                 signupUrl: "" },
};

const STATUS_COLOR: Record<string, string> = {
  online: "bg-green-500/15 text-green-600 border-green-500/30",
  offline: "bg-red-500/15 text-red-600 border-red-500/30",
  syncing: "bg-amber-500/15 text-amber-600 border-amber-500/30",
  unknown: "bg-muted text-muted-foreground",
};

function NetworkForm({ initial, coins, onSubmit, onTest, testResult }: { initial?: Partial<Network>; coins: Coin[]; onSubmit: (v: any) => void; onTest?: () => void; testResult?: any }) {
  const [v, setV] = useState<any>(initial || {
    confirmations: 12, depositEnabled: true, withdrawEnabled: true, memoRequired: false,
    status: "active", nodeStatus: "unknown", providerType: "custom",
  });
  const [showRpcKey, setShowRpcKey] = useState(false);
  const [showHotKey, setShowHotKey] = useState(false);
  const provider = PROVIDERS[v.providerType] || PROVIDERS.custom;

  return (
    <div className="space-y-3 max-h-[75vh] overflow-y-auto pr-2">
      <div className="grid grid-cols-2 gap-3">
        <div><Label>Coin</Label>
          <Select value={v.coinId ? String(v.coinId) : ""} onValueChange={(c) => setV({ ...v, coinId: Number(c) })}>
            <SelectTrigger><SelectValue placeholder="Select" /></SelectTrigger>
            <SelectContent>{coins.map((c) => <SelectItem key={c.id} value={String(c.id)}>{c.symbol}</SelectItem>)}</SelectContent>
          </Select>
        </div>
        <div><Label>Network Name (e.g. BEP20, TRC20)</Label><Input value={v.name || ""} onChange={(e) => setV({ ...v, name: e.target.value })} /></div>
        <div><Label>Chain (BNB, ETH, TRX, BTC, SOL)</Label><Input value={v.chain || ""} onChange={(e) => setV({ ...v, chain: e.target.value })} /></div>
        <div><Label>Token Contract Address (blank for native)</Label><Input value={v.contractAddress || ""} onChange={(e) => setV({ ...v, contractAddress: e.target.value })} placeholder="0x55d398326f99059..." /></div>
      </div>

      {/* RPC NODE SECTION */}
      <div className="border rounded-lg p-3 space-y-3 bg-muted/30">
        <div className="flex items-center gap-2 font-semibold"><Wifi className="size-4" /> RPC Node</div>
        <div className="grid grid-cols-2 gap-3">
          <div><Label>Provider</Label>
            <Select value={v.providerType || "custom"} onValueChange={(p) => setV({ ...v, providerType: p })}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                {Object.entries(PROVIDERS).map(([k, p]) => <SelectItem key={k} value={k}>{p.label}</SelectItem>)}
              </SelectContent>
            </Select>
            {provider.signupUrl && <a href={provider.signupUrl} target="_blank" rel="noopener" className="text-xs text-blue-500 inline-flex items-center gap-1 mt-1">Get free API key <ExternalLink className="size-3" /></a>}
          </div>
          <div><Label>Min Confirmations</Label>
            <Input type="number" value={v.confirmations ?? 12} onChange={(e) => setV({ ...v, confirmations: Number(e.target.value) })} />
          </div>
          <div className="col-span-2"><Label>RPC URL</Label>
            <Input value={v.nodeAddress || ""} onChange={(e) => setV({ ...v, nodeAddress: e.target.value })} placeholder={provider.placeholder} />
          </div>
          <div className="col-span-2"><Label>RPC API Key (optional, encrypted)</Label>
            <div className="flex gap-2">
              <Input type={showRpcKey ? "text" : "password"} value={v.rpcApiKey ?? ""} onChange={(e) => setV({ ...v, rpcApiKey: e.target.value })} placeholder={initial?.rpcApiKeySet ? "•••• (set, leave blank to keep)" : "Paste API key"} />
              <Button type="button" variant="outline" size="sm" onClick={() => setShowRpcKey(!showRpcKey)}>{showRpcKey ? "Hide" : "Show"}</Button>
            </div>
            <p className="text-xs text-muted-foreground mt-1">Used for providers like TronGrid that need separate API key. Encrypted at rest.</p>
          </div>
          <div className="col-span-2"><Label>Block Explorer URL (for users)</Label>
            <Input value={v.explorerUrl || ""} onChange={(e) => setV({ ...v, explorerUrl: e.target.value })} placeholder="https://bscscan.com" />
          </div>
        </div>
        {onTest && (
          <div className="flex items-center gap-2">
            <Button type="button" size="sm" variant="secondary" onClick={onTest}><RefreshCw className="size-3 mr-1" /> Test Connection</Button>
            {testResult && (
              testResult.ok
                ? <span className="text-xs text-emerald-500">✓ Online · block #{testResult.blockHeight} · {testResult.latencyMs}ms</span>
                : <span className="text-xs text-red-500">✗ {testResult.error}</span>
            )}
          </div>
        )}
      </div>

      {/* HOT WALLET SECTION */}
      <div className="border rounded-lg p-3 space-y-3 bg-muted/30">
        <div className="flex items-center gap-2 font-semibold"><Wallet className="size-4" /> Hot Wallet (for withdrawals & deposit sweeps)</div>
        <div className="grid grid-cols-1 gap-3">
          <div><Label>Hot Wallet Address (public)</Label>
            <Input value={v.hotWalletAddress || ""} onChange={(e) => setV({ ...v, hotWalletAddress: e.target.value })} placeholder="0x... (deposit destination + withdrawal source)" />
          </div>
          <div><Label className="flex items-center gap-2"><KeyRound className="size-3" /> Hot Wallet Private Key (encrypted)</Label>
            <div className="flex gap-2">
              <Input type={showHotKey ? "text" : "password"} value={v.hotWalletPrivateKey ?? ""} onChange={(e) => setV({ ...v, hotWalletPrivateKey: e.target.value })} placeholder={initial?.hotWalletKeySet ? "•••• (set, leave blank to keep)" : "Private key / mnemonic"} />
              <Button type="button" variant="outline" size="sm" onClick={() => setShowHotKey(!showHotKey)}>{showHotKey ? "Hide" : "Show"}</Button>
            </div>
            <p className="text-xs text-amber-600 mt-1 flex items-start gap-1"><AlertTriangle className="size-3 mt-0.5 shrink-0" /> Encrypted at rest. Only used server-side to sign withdrawal txs. Never exposed via API.</p>
          </div>
        </div>
      </div>

      {/* LIMITS */}
      <div className="grid grid-cols-3 gap-3">
        <div><Label>Min Deposit</Label><Input value={v.minDeposit || "0"} onChange={(e) => setV({ ...v, minDeposit: e.target.value })} /></div>
        <div><Label>Min Withdraw</Label><Input value={v.minWithdraw || "0"} onChange={(e) => setV({ ...v, minWithdraw: e.target.value })} /></div>
        <div><Label>Withdraw Fee</Label><Input value={v.withdrawFee || "0"} onChange={(e) => setV({ ...v, withdrawFee: e.target.value })} /></div>
      </div>

      {/* TOGGLES */}
      <div className="flex gap-4 flex-wrap pt-2 border-t">
        <label className="flex items-center gap-2"><Switch checked={v.depositEnabled} onCheckedChange={(c) => setV({ ...v, depositEnabled: c })} /> Deposits Enabled</label>
        <label className="flex items-center gap-2"><Switch checked={v.withdrawEnabled} onCheckedChange={(c) => setV({ ...v, withdrawEnabled: c })} /> Withdrawals Enabled</label>
        <label className="flex items-center gap-2"><Switch checked={v.memoRequired} onCheckedChange={(c) => setV({ ...v, memoRequired: c })} /> Memo Required</label>
        <div className="ml-auto"><Label className="text-xs">Status</Label>
          <Select value={v.status || "active"} onValueChange={(s) => setV({ ...v, status: s })}>
            <SelectTrigger className="w-32"><SelectValue /></SelectTrigger>
            <SelectContent>
              <SelectItem value="active">Active</SelectItem>
              <SelectItem value="paused">Paused</SelectItem>
            </SelectContent>
          </Select>
        </div>
      </div>

      <Button className="w-full" onClick={() => {
        const payload = { ...v };
        // Don't send empty password fields (preserves existing encrypted values)
        if (!payload.rpcApiKey) delete payload.rpcApiKey;
        if (!payload.hotWalletPrivateKey) delete payload.hotWalletPrivateKey;
        onSubmit(payload);
      }}>Save</Button>
    </div>
  );
}

export default function NetworksPage() {
  const { user: me } = useAuth();
  const qc = useQueryClient();
  const isAdmin = me?.role === "admin" || me?.role === "superadmin";
  const { data: coins = [] } = useQuery<Coin[]>({ queryKey: ["/admin/coins"], queryFn: () => get<Coin[]>("/admin/coins") });
  const { data = [] } = useQuery<Network[]>({ queryKey: ["/admin/networks"], queryFn: () => get<Network[]>("/admin/networks") });
  const [open, setOpen] = useState(false);
  const [edit, setEdit] = useState<Network | null>(null);
  const [testResults, setTestResults] = useState<Record<number, any>>({});
  const inv = () => qc.invalidateQueries({ queryKey: ["/admin/networks"] });
  const create = useMutation({ mutationFn: (v: Partial<Network>) => post("/admin/networks", v), onSuccess: () => { inv(); setOpen(false); } });
  const update = useMutation({ mutationFn: ({ id, body }: { id: number; body: any }) => patch(`/admin/networks/${id}`, body), onSuccess: () => { inv(); setEdit(null); } });
  const remove = useMutation({ mutationFn: (id: number) => del(`/admin/networks/${id}`), onSuccess: inv });
  const test = useMutation({
    mutationFn: (id: number) => post<any>(`/admin/networks/${id}/test`, {}),
    onSuccess: (r, id) => { setTestResults((prev) => ({ ...prev, [id]: r })); inv(); },
  });
  const sym = (id: number) => coins.find((c) => c.id === id)?.symbol || `#${id}`;

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-2xl font-bold">Networks & Nodes</h1>
        <p className="text-sm text-muted-foreground">Configure blockchain RPC nodes, hot wallets, and per-network deposit/withdrawal toggles. Only one network per coin should be active at a time for clarity.</p>
      </div>
      <div className="flex justify-between items-center">
        <div className="text-sm text-muted-foreground">{data.length} networks · {data.filter(n => n.depositEnabled).length} deposit-enabled · {data.filter(n => n.nodeStatus === "online").length} nodes online</div>
        {isAdmin && (
          <Dialog open={open} onOpenChange={setOpen}>
            <DialogTrigger asChild><Button><Plus className="w-4 h-4 mr-1" /> Add Network</Button></DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader><DialogTitle>Add network</DialogTitle></DialogHeader>
              <NetworkForm coins={coins} onSubmit={(v) => create.mutate(v)} />
            </DialogContent>
          </Dialog>
        )}
      </div>
      <Card>
        <div className="overflow-x-auto">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Coin</TableHead><TableHead>Network</TableHead>
                <TableHead>Provider</TableHead><TableHead>Node</TableHead><TableHead>Hot Wallet</TableHead>
                <TableHead>Min Dep</TableHead><TableHead>Fee</TableHead>
                <TableHead>Dep</TableHead><TableHead>W/d</TableHead>
                {isAdmin && <TableHead></TableHead>}
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.map((n) => (
                <TableRow key={n.id}>
                  <TableCell className="font-bold">{sym(n.coinId)}</TableCell>
                  <TableCell><div className="font-mono">{n.name}</div><div className="text-xs text-muted-foreground">{n.chain}</div></TableCell>
                  <TableCell><Badge variant="outline">{PROVIDERS[n.providerType]?.label || n.providerType}</Badge></TableCell>
                  <TableCell>
                    <div className="space-y-1">
                      <span className={`px-2 py-0.5 text-xs rounded-md border ${STATUS_COLOR[n.nodeStatus] || STATUS_COLOR.unknown}`}>
                        <Wifi className="size-3 inline mr-1" />{n.nodeStatus}
                      </span>
                      {n.lastBlockHeight && <div className="text-xs text-muted-foreground">block #{n.lastBlockHeight.toLocaleString()}</div>}
                      {isAdmin && n.nodeAddress && <Button size="sm" variant="ghost" className="h-6 text-xs" onClick={() => test.mutate(n.id)}>{test.isPending && test.variables === n.id ? "Testing..." : "Test"}</Button>}
                      {testResults[n.id] && !testResults[n.id].ok && <div className="text-xs text-red-500 max-w-[160px] truncate" title={testResults[n.id].error}>{testResults[n.id].error}</div>}
                    </div>
                  </TableCell>
                  <TableCell>
                    {n.hotWalletAddress
                      ? <div className="space-y-0.5">
                          <div className="font-mono text-xs">{n.hotWalletAddress.slice(0, 8)}…{n.hotWalletAddress.slice(-6)}</div>
                          {n.hotWalletKeySet ? <Badge className="bg-emerald-600 text-xs">Key set</Badge> : <Badge variant="destructive" className="text-xs">No key</Badge>}
                        </div>
                      : <span className="text-xs text-muted-foreground">—</span>}
                  </TableCell>
                  <TableCell className="tabular-nums">{n.minDeposit}</TableCell>
                  <TableCell className="tabular-nums">{n.withdrawFee}</TableCell>
                  <TableCell>
                    {isAdmin
                      ? <Switch checked={n.depositEnabled} onCheckedChange={(c) => update.mutate({ id: n.id, body: { depositEnabled: c } })} />
                      : <Badge variant={n.depositEnabled ? "default" : "secondary"}>{n.depositEnabled ? "On" : "Off"}</Badge>}
                  </TableCell>
                  <TableCell>
                    {isAdmin
                      ? <Switch checked={n.withdrawEnabled} onCheckedChange={(c) => update.mutate({ id: n.id, body: { withdrawEnabled: c } })} />
                      : <Badge variant={n.withdrawEnabled ? "default" : "secondary"}>{n.withdrawEnabled ? "On" : "Off"}</Badge>}
                  </TableCell>
                  {isAdmin && (
                    <TableCell className="text-right space-x-1">
                      <Button size="icon" variant="ghost" onClick={() => setEdit(n)}><Pencil className="w-4 h-4" /></Button>
                      <Button size="icon" variant="ghost" onClick={() => { if (confirm(`Delete ${sym(n.coinId)}/${n.name}?`)) remove.mutate(n.id); }}><Trash2 className="w-4 h-4 text-destructive" /></Button>
                    </TableCell>
                  )}
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </div>
      </Card>
      {edit && (
        <Dialog open={!!edit} onOpenChange={(o) => !o && setEdit(null)}>
          <DialogContent className="max-w-2xl">
            <DialogHeader><DialogTitle>Edit {sym(edit.coinId)} / {edit.name}</DialogTitle></DialogHeader>
            <NetworkForm
              initial={edit}
              coins={coins}
              testResult={testResults[edit.id]}
              onTest={() => test.mutate(edit.id)}
              onSubmit={(v) => update.mutate({ id: edit.id, body: v })}
            />
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
