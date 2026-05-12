import { useState } from "react";
import { Link } from "wouter";
import { useQuery } from "@tanstack/react-query";
import { TrendingUp, TrendingDown, Wallet, BarChart2, List, PlusCircle, Clock, CheckCircle, XCircle, ArrowUpRight } from "lucide-react";

const API = "/api";
const fmtPrice = (v: any, currency = "₹") => v == null ? "—" : `${currency}${Number(v).toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
const fmtPnl = (v: any) => {
  const n = Number(v ?? 0);
  const s = n >= 0 ? "+" : "";
  return `${s}${n.toLocaleString("en-IN", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
};

export default function BrokerDashboard() {
  const [activeTab, setActiveTab] = useState<"portfolio" | "orders">("portfolio");

  const { data: accountData } = useQuery({
    queryKey: ["broker-account"],
    queryFn: async () => {
      const r = await fetch(`${API}/broker/account`, { credentials: "include" });
      if (!r.ok) throw new Error("Unauthorized");
      return r.json();
    },
  });

  const { data: portfolioData, isLoading: loadingPortfolio } = useQuery({
    queryKey: ["broker-portfolio"],
    queryFn: async () => {
      const r = await fetch(`${API}/broker/portfolio`, { credentials: "include" });
      if (!r.ok) throw new Error("Unauthorized");
      return r.json();
    },
    refetchInterval: 10000,
  });

  const { data: ordersData, isLoading: loadingOrders } = useQuery({
    queryKey: ["broker-orders"],
    queryFn: async () => {
      const r = await fetch(`${API}/broker/orders`, { credentials: "include" });
      if (!r.ok) throw new Error("Unauthorized");
      return r.json();
    },
    refetchInterval: 5000,
  });

  const account = accountData?.account;
  const portfolio: any[] = portfolioData?.portfolio ?? [];
  const orders: any[] = ordersData?.orders ?? [];

  const totalInvested = portfolio.reduce((s, p) => s + Number(p.holdingQty) * Number(p.avgBuyPrice), 0);
  const totalCurrent = portfolio.reduce((s, p) => s + Number(p.holdingQty) * Number(p.currentPrice ?? p.avgBuyPrice), 0);
  const totalPnl = totalCurrent - totalInvested;
  const totalPnlPct = totalInvested > 0 ? (totalPnl / totalInvested) * 100 : 0;

  const statusIcon = (s: string) => {
    if (s === "complete") return <CheckCircle size={12} className="text-green-400" />;
    if (s === "rejected" || s === "cancelled") return <XCircle size={12} className="text-red-400" />;
    return <Clock size={12} className="text-yellow-400" />;
  };
  const statusColor = (s: string) => {
    if (s === "complete") return "text-green-400";
    if (s === "rejected" || s === "cancelled") return "text-red-400";
    return "text-yellow-400";
  };
  const sideColor = (side: string) => side === "buy" ? "text-green-400" : "text-red-400";

  const assetGroups = portfolio.reduce((acc: Record<string, any[]>, p) => {
    const g = p.assetClass ?? "other";
    if (!acc[g]) acc[g] = [];
    acc[g].push(p);
    return acc;
  }, {});

  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white">
      {/* Header */}
      <div className="border-b border-[#1a1a1a] bg-[#0d0d0d] px-4 py-3 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <Link href="/forex" className="text-gray-400 hover:text-white text-sm">← Trading</Link>
          <span className="text-gray-600">/</span>
          <span className="text-sm font-semibold text-white">My Broker Account</span>
        </div>
        <Link href="/broker/onboarding" className="text-xs text-[#d4a017] hover:underline">Edit Application</Link>
      </div>

      <div className="max-w-5xl mx-auto px-4 py-5">
        {/* Account Card */}
        {account && (
          <div className="bg-gradient-to-r from-[#1a1200] to-[#0d0d0d] border border-[#d4a017]/30 rounded-2xl p-5 mb-5">
            <div className="flex items-start justify-between flex-wrap gap-4">
              <div>
                <div className="text-xs text-gray-400 mb-1">Angel One Sub-broker Account</div>
                <div className="text-xl font-bold text-white">{account.fullName ?? "Your Account"}</div>
                {account.angelClientId && (
                  <div className="text-xs text-gray-400 mt-1">
                    Client ID: <span className="text-[#d4a017]">{account.angelClientId}</span>
                    {account.angelDemat && <> · Demat: <span className="text-[#d4a017]">{account.angelDemat}</span></>}
                  </div>
                )}
                <div className="mt-2 flex gap-2 flex-wrap">
                  {account.segmentEquity && <span className="bg-green-900/30 text-green-400 text-xs px-2 py-0.5 rounded-full">Equity</span>}
                  {account.segmentFno && <span className="bg-blue-900/30 text-blue-400 text-xs px-2 py-0.5 rounded-full">F&O</span>}
                  {account.segmentCommodity && <span className="bg-yellow-900/30 text-yellow-400 text-xs px-2 py-0.5 rounded-full">Commodity</span>}
                  {account.segmentCurrency && <span className="bg-purple-900/30 text-purple-400 text-xs px-2 py-0.5 rounded-full">Currency</span>}
                </div>
              </div>
              <div className="text-right">
                <div className="text-xs text-gray-400 mb-1">Account Status</div>
                <div className={`text-sm font-bold ${account.status === "active" ? "text-green-400" : account.status === "submitted" ? "text-blue-400" : "text-yellow-400"}`}>
                  {account.status.toUpperCase()}
                </div>
              </div>
            </div>
          </div>
        )}

        {/* P&L Summary */}
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-5">
          {[
            { label: "Total Invested", value: fmtPrice(totalInvested), icon: Wallet, color: "text-white" },
            { label: "Current Value", value: fmtPrice(totalCurrent), icon: BarChart2, color: "text-white" },
            { label: "Total P&L", value: fmtPnl(totalPnl), icon: totalPnl >= 0 ? TrendingUp : TrendingDown, color: totalPnl >= 0 ? "text-green-400" : "text-red-400" },
            { label: "P&L %", value: `${fmtPnl(totalPnlPct)}%`, icon: ArrowUpRight, color: totalPnlPct >= 0 ? "text-green-400" : "text-red-400" },
          ].map(card => {
            const Icon = card.icon;
            return (
              <div key={card.label} className="bg-[#0d0d0d] border border-[#1a1a1a] rounded-xl p-4">
                <div className="flex items-center gap-2 mb-2">
                  <Icon size={14} className="text-gray-500" />
                  <span className="text-xs text-gray-400">{card.label}</span>
                </div>
                <div className={`text-lg font-bold ${card.color}`}>{card.value}</div>
              </div>
            );
          })}
        </div>

        {/* Quick Trade Links */}
        <div className="grid grid-cols-3 gap-3 mb-5">
          {[
            { label: "Trade Forex", href: "/forex", color: "bg-blue-900/20 border-blue-800/40 text-blue-400" },
            { label: "Trade Stocks", href: "/stocks", color: "bg-green-900/20 border-green-800/40 text-green-400" },
            { label: "Trade Commodities", href: "/commodities", color: "bg-yellow-900/20 border-yellow-800/40 text-yellow-400" },
          ].map(link => (
            <Link key={link.href} href={link.href}
              className={`flex items-center justify-center gap-2 border rounded-xl py-3 text-sm font-semibold hover:opacity-80 transition-all ${link.color}`}>
              <PlusCircle size={14} /> {link.label}
            </Link>
          ))}
        </div>

        {/* Portfolio / Orders Tabs */}
        <div className="bg-[#0d0d0d] border border-[#1a1a1a] rounded-2xl overflow-hidden">
          <div className="flex border-b border-[#1a1a1a]">
            {(["portfolio","orders"] as const).map(tab => (
              <button key={tab} onClick={() => setActiveTab(tab)}
                className={`flex-1 py-3 text-sm font-semibold capitalize transition-all ${activeTab === tab ? "text-[#d4a017] border-b-2 border-[#d4a017]" : "text-gray-400 hover:text-white"}`}>
                {tab === "portfolio" ? <><List size={12} className="inline mr-1.5" />Portfolio ({portfolio.length})</>
                  : <><Clock size={12} className="inline mr-1.5" />Orders ({orders.length})</>}
              </button>
            ))}
          </div>

          {/* Portfolio Tab */}
          {activeTab === "portfolio" && (
            <div>
              {loadingPortfolio ? (
                <div className="py-12 text-center text-gray-500 text-sm">Loading portfolio...</div>
              ) : portfolio.length === 0 ? (
                <div className="py-12 text-center">
                  <BarChart2 size={40} className="mx-auto text-gray-700 mb-3" />
                  <div className="text-gray-400 text-sm">No holdings yet</div>
                  <div className="text-gray-600 text-xs mt-1">Start trading to see your portfolio here</div>
                </div>
              ) : (
                <div>
                  {Object.entries(assetGroups).map(([group, items]) => (
                    <div key={group}>
                      <div className="px-4 py-2 bg-[#111] text-xs font-bold text-gray-400 uppercase tracking-wider">{group}</div>
                      <div className="divide-y divide-[#1a1a1a]">
                        {items.map((pos: any) => {
                          const invested = Number(pos.holdingQty) * Number(pos.avgBuyPrice);
                          const current = Number(pos.holdingQty) * Number(pos.currentPrice ?? pos.avgBuyPrice);
                          const pnl = current - invested;
                          const pnlPct = invested > 0 ? (pnl / invested) * 100 : 0;
                          return (
                            <div key={pos.id} className="px-4 py-3 hover:bg-[#111] transition-all">
                              <div className="flex items-start justify-between">
                                <div>
                                  <div className="text-sm font-bold text-white">{pos.symbol}</div>
                                  <div className="text-xs text-gray-400">{pos.exchange} · {Number(pos.holdingQty)} units</div>
                                  <div className="text-xs text-gray-500 mt-0.5">Avg: {fmtPrice(pos.avgBuyPrice)}</div>
                                </div>
                                <div className="text-right">
                                  <div className="text-sm font-semibold text-white">{fmtPrice(current)}</div>
                                  <div className={`text-xs font-semibold ${pnl >= 0 ? "text-green-400" : "text-red-400"}`}>
                                    {pnl >= 0 ? "+" : ""}{fmtPnl(pnl)} ({fmtPnl(pnlPct)}%)
                                  </div>
                                </div>
                              </div>
                            </div>
                          );
                        })}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* Orders Tab */}
          {activeTab === "orders" && (
            <div>
              {loadingOrders ? (
                <div className="py-12 text-center text-gray-500 text-sm">Loading orders...</div>
              ) : orders.length === 0 ? (
                <div className="py-12 text-center">
                  <List size={40} className="mx-auto text-gray-700 mb-3" />
                  <div className="text-gray-400 text-sm">No orders yet</div>
                  <div className="text-gray-600 text-xs mt-1">Place your first trade from the trading pages</div>
                </div>
              ) : (
                <div className="divide-y divide-[#1a1a1a]">
                  {orders.map((order: any) => (
                    <div key={order.id} className="px-4 py-3 hover:bg-[#111]">
                      <div className="flex items-start justify-between">
                        <div>
                          <div className="flex items-center gap-2">
                            <span className={`text-xs font-bold uppercase px-2 py-0.5 rounded ${order.side === "buy" ? "bg-green-900/30 text-green-400" : "bg-red-900/30 text-red-400"}`}>
                              {order.side}
                            </span>
                            <span className="text-sm font-bold text-white">{order.symbol}</span>
                            <span className="text-xs text-gray-500">{order.exchange}</span>
                            {order.simulated && <span className="text-xs text-gray-600 bg-gray-800 px-1.5 py-0.5 rounded">SIM</span>}
                          </div>
                          <div className="text-xs text-gray-400 mt-1">
                            Qty: {Number(order.qty)} · Type: {order.orderType.toUpperCase()}
                            {order.executedPrice && <> · Exec: {fmtPrice(order.executedPrice)}</>}
                          </div>
                          <div className="text-xs text-gray-500 mt-0.5">
                            {new Date(order.createdAt).toLocaleString("en-IN")}
                          </div>
                        </div>
                        <div className="text-right">
                          <div className={`flex items-center gap-1 text-xs font-semibold ${statusColor(order.status)}`}>
                            {statusIcon(order.status)} {order.status}
                          </div>
                          {order.pnl != null && (
                            <div className={`text-xs font-semibold mt-1 ${Number(order.pnl) >= 0 ? "text-green-400" : "text-red-400"}`}>
                              P&L: {fmtPnl(order.pnl)}
                            </div>
                          )}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
