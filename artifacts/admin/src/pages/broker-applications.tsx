import { useState } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { CheckCircle, XCircle, Clock, Eye, User, FileText, ChevronDown, ChevronUp, AlertCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";

const API = "/api";

const STATUS_COLORS: Record<string, string> = {
  draft: "bg-gray-700 text-gray-300",
  submitted: "bg-blue-900/60 text-blue-300",
  under_review: "bg-yellow-900/60 text-yellow-300",
  approved: "bg-green-900/60 text-green-300",
  active: "bg-green-900/60 text-green-300",
  rejected: "bg-red-900/60 text-red-300",
};

const DOC_LABELS: Record<string, string> = {
  pan_card: "PAN Card",
  aadhar_front: "Aadhaar Front",
  aadhar_back: "Aadhaar Back",
  photo: "Photo",
  signature: "Signature",
  cancelled_cheque: "Cancelled Cheque",
  bank_proof: "Bank Statement",
  income_proof: "Income Proof",
};

function StatusBadge({ status }: { status: string }) {
  return <span className={`text-xs font-bold px-2 py-0.5 rounded-full ${STATUS_COLORS[status] ?? "bg-gray-700 text-gray-300"}`}>{status.replace("_"," ").toUpperCase()}</span>;
}

export default function BrokerApplicationsPage() {
  const qc = useQueryClient();
  const [selected, setSelected] = useState<any>(null);
  const [showDetail, setShowDetail] = useState(false);
  const [rejectReason, setRejectReason] = useState("");
  const [angelClientId, setAngelClientId] = useState("");
  const [angelDemat, setAngelDemat] = useState("");
  const [search, setSearch] = useState("");
  const [filter, setFilter] = useState("all");

  const { data, isLoading } = useQuery({
    queryKey: ["admin-broker-applications"],
    queryFn: async () => {
      const r = await fetch(`${API}/admin/broker-applications`, { credentials: "include" });
      if (!r.ok) throw new Error("Unauthorized");
      return r.json();
    },
    refetchInterval: 10000,
  });

  const { data: detailData } = useQuery({
    queryKey: ["admin-broker-application", selected?.id],
    enabled: !!selected?.id,
    queryFn: async () => {
      const r = await fetch(`${API}/admin/broker-applications/${selected.id}`, { credentials: "include" });
      if (!r.ok) throw new Error("Failed");
      return r.json();
    },
  });

  const approveMutation = useMutation({
    mutationFn: async (id: number) => {
      const r = await fetch(`${API}/admin/broker-applications/${id}/approve`, {
        method: "PATCH", credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ angelClientId: angelClientId || undefined, angelDemat: angelDemat || undefined }),
      });
      if (!r.ok) throw new Error("Failed");
      return r.json();
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["admin-broker-applications"] });
      qc.invalidateQueries({ queryKey: ["admin-broker-application", selected?.id] });
      setShowDetail(false);
    },
  });

  const rejectMutation = useMutation({
    mutationFn: async (id: number) => {
      const r = await fetch(`${API}/admin/broker-applications/${id}/reject`, {
        method: "PATCH", credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ reason: rejectReason }),
      });
      if (!r.ok) throw new Error("Failed");
      return r.json();
    },
    onSuccess: () => {
      qc.invalidateQueries({ queryKey: ["admin-broker-applications"] });
      qc.invalidateQueries({ queryKey: ["admin-broker-application", selected?.id] });
      setShowDetail(false);
      setRejectReason("");
    },
  });

  const kycMutation = useMutation({
    mutationFn: async ({ docId, status, rejectionNote }: { docId: number; status: string; rejectionNote?: string }) => {
      const r = await fetch(`${API}/admin/broker-applications/${selected?.id}/kyc/${docId}`, {
        method: "PATCH", credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ status, rejectionNote }),
      });
      if (!r.ok) throw new Error("Failed");
      return r.json();
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["admin-broker-application", selected?.id] }),
  });

  const apps: any[] = data?.applications ?? [];
  const filtered = apps.filter(a => {
    const matchSearch = !search || a.fullName?.toLowerCase().includes(search.toLowerCase()) || a.panNumber?.includes(search) || a.email?.toLowerCase().includes(search.toLowerCase());
    const matchFilter = filter === "all" || a.status === filter;
    return matchSearch && matchFilter;
  });

  const counts = apps.reduce((acc: Record<string, number>, a) => { acc[a.status] = (acc[a.status] ?? 0) + 1; return acc; }, {});

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-amber-400">Broker Applications</h1>
          <p className="text-sm text-gray-400 mt-1">Angel One sub-broker account applications from users</p>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
        {[
          { key: "all", label: "Total", count: apps.length, color: "text-white" },
          { key: "submitted", label: "Submitted", count: counts.submitted ?? 0, color: "text-blue-400" },
          { key: "under_review", label: "Under Review", count: counts.under_review ?? 0, color: "text-yellow-400" },
          { key: "active", label: "Active", count: (counts.approved ?? 0) + (counts.active ?? 0), color: "text-green-400" },
          { key: "rejected", label: "Rejected", count: counts.rejected ?? 0, color: "text-red-400" },
        ].map(stat => (
          <button key={stat.key} onClick={() => setFilter(stat.key)}
            className={`bg-[#0d1526] border rounded-xl p-3 text-left transition-all ${filter === stat.key ? "border-amber-500/50" : "border-gray-800/50 hover:border-gray-700"}`}>
            <div className={`text-2xl font-bold ${stat.color}`}>{stat.count}</div>
            <div className="text-xs text-gray-400 mt-0.5">{stat.label}</div>
          </button>
        ))}
      </div>

      {/* Filters */}
      <div className="flex gap-3">
        <Input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by name, PAN, email..."
          className="bg-[#0d1526] border-gray-800 text-white max-w-xs" />
      </div>

      {/* Table */}
      <div className="bg-[#0d1526] border border-gray-800/50 rounded-xl overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-gray-800/50">
              {["Name / Email", "PAN", "Mobile", "Segments", "Status", "Submitted", "Action"].map(h => (
                <th key={h} className="text-left text-xs font-semibold text-gray-400 px-4 py-3 uppercase tracking-wider">{h}</th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-800/30">
            {isLoading ? (
              <tr><td colSpan={7} className="text-center py-12 text-gray-500 text-sm">Loading...</td></tr>
            ) : filtered.length === 0 ? (
              <tr><td colSpan={7} className="text-center py-12 text-gray-500 text-sm">No applications found</td></tr>
            ) : filtered.map((app: any) => (
              <tr key={app.id} className="hover:bg-[#111c30] transition-all">
                <td className="px-4 py-3">
                  <div className="font-semibold text-white text-sm">{app.fullName ?? "—"}</div>
                  <div className="text-xs text-gray-400">{app.email ?? "No email"}</div>
                  {app.angelClientId && <div className="text-xs text-amber-400">ID: {app.angelClientId}</div>}
                </td>
                <td className="px-4 py-3 text-sm font-mono text-gray-300">{app.panNumber ?? "—"}</td>
                <td className="px-4 py-3 text-sm text-gray-300">{app.mobile ?? "—"}</td>
                <td className="px-4 py-3">
                  <div className="flex gap-1 flex-wrap">
                    {app.segmentEquity && <span className="text-xs bg-green-900/30 text-green-400 px-1.5 py-0.5 rounded">EQ</span>}
                    {app.segmentFno && <span className="text-xs bg-blue-900/30 text-blue-400 px-1.5 py-0.5 rounded">F&O</span>}
                    {app.segmentCommodity && <span className="text-xs bg-yellow-900/30 text-yellow-400 px-1.5 py-0.5 rounded">MCX</span>}
                    {app.segmentCurrency && <span className="text-xs bg-purple-900/30 text-purple-400 px-1.5 py-0.5 rounded">FX</span>}
                  </div>
                </td>
                <td className="px-4 py-3"><StatusBadge status={app.status} /></td>
                <td className="px-4 py-3 text-xs text-gray-400">
                  {app.submittedAt ? new Date(app.submittedAt).toLocaleDateString("en-IN") : "Not submitted"}
                </td>
                <td className="px-4 py-3">
                  <Button variant="ghost" size="sm" onClick={() => { setSelected(app); setShowDetail(true); }}
                    className="text-amber-400 hover:text-amber-300 hover:bg-amber-900/20">
                    <Eye size={14} className="mr-1" /> Review
                  </Button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Detail Dialog */}
      <Dialog open={showDetail} onOpenChange={setShowDetail}>
        <DialogContent className="max-w-4xl bg-[#0d1526] border-gray-800 text-white max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="text-amber-400 flex items-center gap-2">
              <User size={18} /> {selected?.fullName ?? "Application"} — <StatusBadge status={selected?.status ?? "draft"} />
            </DialogTitle>
          </DialogHeader>

          {detailData && (
            <div className="space-y-5 mt-2">
              {/* Personal Info */}
              <div className="bg-[#111c30] rounded-xl p-4">
                <div className="text-sm font-semibold text-gray-300 mb-3 flex items-center gap-2"><User size={14} /> Personal Details</div>
                <div className="grid grid-cols-2 md:grid-cols-3 gap-3 text-sm">
                  {[
                    ["Full Name", selected?.fullName],
                    ["DOB", selected?.dob],
                    ["Gender", selected?.gender],
                    ["Father", selected?.fatherName],
                    ["PAN", selected?.panNumber],
                    ["Aadhaar", selected?.aadharNumber ? `••••${selected.aadharNumber.slice(-4)}` : "—"],
                    ["Mobile", selected?.mobile],
                    ["Email", selected?.email],
                    ["City", selected?.city],
                    ["State", selected?.state],
                    ["PIN", selected?.pincode],
                    ["Occupation", selected?.occupation],
                    ["Annual Income", selected?.annualIncome],
                    ["Bank A/C", selected?.bankAccountNo],
                    ["IFSC", selected?.bankIfsc],
                  ].map(([label, val]) => (
                    <div key={label as string}>
                      <div className="text-xs text-gray-500">{label}</div>
                      <div className="text-white font-medium">{val ?? "—"}</div>
                    </div>
                  ))}
                </div>
                {selected?.rejectionReason && (
                  <div className="mt-3 bg-red-900/20 border border-red-800/40 rounded-lg p-3 flex items-start gap-2">
                    <AlertCircle size={14} className="text-red-400 flex-shrink-0 mt-0.5" />
                    <div className="text-red-300 text-sm">{selected.rejectionReason}</div>
                  </div>
                )}
              </div>

              {/* KYC Documents */}
              <div className="bg-[#111c30] rounded-xl p-4">
                <div className="text-sm font-semibold text-gray-300 mb-3 flex items-center gap-2"><FileText size={14} /> KYC Documents</div>
                {detailData.docs?.length === 0 ? (
                  <div className="text-gray-500 text-sm">No documents uploaded yet</div>
                ) : (
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                    {detailData.docs?.map((doc: any) => (
                      <div key={doc.id} className={`border rounded-xl p-3 ${doc.status === "verified" ? "border-green-700/50 bg-green-900/10" : doc.status === "rejected" ? "border-red-700/50 bg-red-900/10" : "border-gray-700/50"}`}>
                        <div className="flex items-start justify-between mb-2">
                          <div>
                            <div className="text-sm font-semibold text-white">{DOC_LABELS[doc.docType] ?? doc.docType}</div>
                            <div className="text-xs text-gray-400">{new Date(doc.uploadedAt).toLocaleDateString("en-IN")}</div>
                          </div>
                          <div className="flex items-center gap-1">
                            {doc.status === "verified" && <CheckCircle size={14} className="text-green-400" />}
                            {doc.status === "rejected" && <XCircle size={14} className="text-red-400" />}
                            {doc.status === "pending" && <Clock size={14} className="text-yellow-400" />}
                            <span className={`text-xs font-bold ${doc.status === "verified" ? "text-green-400" : doc.status === "rejected" ? "text-red-400" : "text-yellow-400"}`}>
                              {doc.status.toUpperCase()}
                            </span>
                          </div>
                        </div>
                        {doc.fileUrl && (
                          <a href={doc.fileUrl} target="_blank" rel="noreferrer"
                            className="text-xs text-amber-400 hover:underline block mb-2">View Document ↗</a>
                        )}
                        {doc.rejectionNote && <div className="text-xs text-red-400 mb-2">{doc.rejectionNote}</div>}
                        <div className="flex gap-2">
                          <Button size="sm" variant="ghost"
                            className="text-xs text-green-400 hover:bg-green-900/20 h-7"
                            onClick={() => kycMutation.mutate({ docId: doc.id, status: "verified" })}
                            disabled={doc.status === "verified" || kycMutation.isPending}>
                            <CheckCircle size={10} className="mr-1" /> Verify
                          </Button>
                          <Button size="sm" variant="ghost"
                            className="text-xs text-red-400 hover:bg-red-900/20 h-7"
                            onClick={() => kycMutation.mutate({ docId: doc.id, status: "rejected", rejectionNote: "Document unclear or invalid" })}
                            disabled={doc.status === "rejected" || kycMutation.isPending}>
                            <XCircle size={10} className="mr-1" /> Reject
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              {/* Approve / Reject Actions */}
              {["submitted","under_review","draft"].includes(selected?.status) && (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {/* Approve */}
                  <div className="bg-green-900/10 border border-green-800/40 rounded-xl p-4">
                    <div className="text-sm font-semibold text-green-400 mb-3 flex items-center gap-2"><CheckCircle size={14} /> Approve Account</div>
                    <div className="space-y-2 mb-3">
                      <Input value={angelClientId} onChange={e => setAngelClientId(e.target.value)}
                        placeholder="Angel One Client ID (auto-generated if blank)"
                        className="bg-[#0d1526] border-gray-700 text-white text-sm h-8" />
                      <Input value={angelDemat} onChange={e => setAngelDemat(e.target.value)}
                        placeholder="Demat A/C No. (auto-generated if blank)"
                        className="bg-[#0d1526] border-gray-700 text-white text-sm h-8" />
                    </div>
                    <Button onClick={() => approveMutation.mutate(selected.id)}
                      disabled={approveMutation.isPending}
                      className="w-full bg-green-700 hover:bg-green-600 text-white">
                      {approveMutation.isPending ? "Approving..." : "Approve & Activate"}
                    </Button>
                  </div>

                  {/* Reject */}
                  <div className="bg-red-900/10 border border-red-800/40 rounded-xl p-4">
                    <div className="text-sm font-semibold text-red-400 mb-3 flex items-center gap-2"><XCircle size={14} /> Reject Application</div>
                    <Textarea value={rejectReason} onChange={e => setRejectReason(e.target.value)}
                      placeholder="Reason for rejection (shown to user)..."
                      className="bg-[#0d1526] border-gray-700 text-white text-sm resize-none h-16 mb-3" />
                    <Button onClick={() => rejectMutation.mutate(selected.id)}
                      disabled={rejectMutation.isPending || !rejectReason}
                      className="w-full bg-red-700 hover:bg-red-600 text-white">
                      {rejectMutation.isPending ? "Rejecting..." : "Reject Application"}
                    </Button>
                  </div>
                </div>
              )}

              {/* Active account info */}
              {(selected?.status === "active" || selected?.status === "approved") && (
                <div className="bg-green-900/10 border border-green-800/40 rounded-xl p-4">
                  <div className="text-sm font-semibold text-green-400 mb-2 flex items-center gap-2"><CheckCircle size={14} /> Account Active</div>
                  <div className="grid grid-cols-3 gap-3 text-sm">
                    <div><div className="text-xs text-gray-400">Client ID</div><div className="text-amber-400 font-mono">{selected.angelClientId}</div></div>
                    <div><div className="text-xs text-gray-400">Demat</div><div className="text-white font-mono">{selected.angelDemat}</div></div>
                    <div><div className="text-xs text-gray-400">Trading ID</div><div className="text-white font-mono">{selected.angelTradingId}</div></div>
                  </div>
                </div>
              )}

              {/* Orders */}
              {detailData.orders?.length > 0 && (
                <div className="bg-[#111c30] rounded-xl p-4">
                  <div className="text-sm font-semibold text-gray-300 mb-3">Recent Orders ({detailData.orders.length})</div>
                  <div className="divide-y divide-gray-800/30 max-h-48 overflow-y-auto">
                    {detailData.orders.map((order: any) => (
                      <div key={order.id} className="py-2 flex items-center justify-between text-sm">
                        <div>
                          <span className={`font-bold uppercase mr-2 ${order.side === "buy" ? "text-green-400" : "text-red-400"}`}>{order.side}</span>
                          <span className="text-white">{order.symbol}</span>
                          <span className="text-gray-400 ml-2 text-xs">{Number(order.qty)} @ {order.executedPrice ?? "—"}</span>
                        </div>
                        <span className={`text-xs ${order.status === "complete" ? "text-green-400" : "text-gray-400"}`}>{order.status}</span>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
