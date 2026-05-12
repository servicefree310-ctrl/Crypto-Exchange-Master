import { useState, useEffect } from "react";
import { Link } from "wouter";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import { CheckCircle, Circle, ChevronRight, ChevronLeft, Upload, AlertCircle, Clock, XCircle, User, Building2, CreditCard, FileText, Shield } from "lucide-react";

const API = "/api";
const STATES = ["Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chhattisgarh","Goa","Gujarat","Haryana","Himachal Pradesh","Jharkhand","Karnataka","Kerala","Madhya Pradesh","Maharashtra","Manipur","Meghalaya","Mizoram","Nagaland","Odisha","Punjab","Rajasthan","Sikkim","Tamil Nadu","Telangana","Tripura","Uttar Pradesh","Uttarakhand","West Bengal","Delhi","Jammu and Kashmir","Ladakh"];
const OCCUPATIONS = ["Salaried","Self Employed","Business","Professional","Retired","Student","Housewife","Other"];
const INCOME_RANGES = ["Below 1 Lakh","1-5 Lakh","5-10 Lakh","10-25 Lakh","25-50 Lakh","50 Lakh - 1 Crore","Above 1 Crore"];

const STEPS = [
  { id: 1, label: "Personal Info", icon: User },
  { id: 2, label: "Contact & Address", icon: Building2 },
  { id: 3, label: "Bank Details", icon: CreditCard },
  { id: 4, label: "KYC Documents", icon: FileText },
  { id: 5, label: "Segments & Nominee", icon: Shield },
];

const KYC_DOCS = [
  { type: "pan_card", label: "PAN Card", required: true, hint: "Clear photo of PAN card" },
  { type: "aadhar_front", label: "Aadhaar Front", required: true, hint: "Front side of Aadhaar card" },
  { type: "aadhar_back", label: "Aadhaar Back", required: true, hint: "Back side of Aadhaar card" },
  { type: "photo", label: "Passport Photo", required: true, hint: "Recent passport size photo" },
  { type: "signature", label: "Signature", required: true, hint: "Signature on white paper" },
  { type: "cancelled_cheque", label: "Cancelled Cheque", required: true, hint: "Cancelled cheque of your bank account" },
  { type: "bank_proof", label: "Bank Statement", required: false, hint: "Last 3 months bank statement (optional)" },
  { type: "income_proof", label: "Income Proof", required: false, hint: "Salary slip / ITR (optional, required for F&O)" },
];

function StatusBadge({ status }: { status: string }) {
  const map: Record<string, { color: string; label: string; icon: any }> = {
    draft: { color: "text-gray-400 bg-gray-800", label: "Draft", icon: Circle },
    submitted: { color: "text-blue-400 bg-blue-900/30", label: "Under Review", icon: Clock },
    under_review: { color: "text-yellow-400 bg-yellow-900/30", label: "Under Review", icon: Clock },
    approved: { color: "text-green-400 bg-green-900/30", label: "Approved", icon: CheckCircle },
    active: { color: "text-green-400 bg-green-900/30", label: "Active", icon: CheckCircle },
    rejected: { color: "text-red-400 bg-red-900/30", label: "Rejected", icon: XCircle },
  };
  const s = map[status] ?? map.draft;
  const Icon = s.icon;
  return (
    <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold ${s.color}`}>
      <Icon size={12} /> {s.label}
    </span>
  );
}

export default function BrokerOnboarding() {
  const qc = useQueryClient();
  const [step, setStep] = useState(1);
  const [form, setForm] = useState<Record<string, any>>({
    segmentEquity: true, segmentFno: false, segmentCommodity: true, segmentCurrency: false,
  });
  const [uploadStatus, setUploadStatus] = useState<Record<string, string>>({});

  const { data, isLoading } = useQuery({
    queryKey: ["broker-account"],
    queryFn: async () => {
      const r = await fetch(`${API}/broker/account`, { credentials: "include" });
      if (!r.ok) throw new Error("Unauthorized");
      return r.json();
    },
  });

  useEffect(() => {
    if (data?.account) {
      const a = data.account;
      setForm(f => ({ ...f, ...Object.fromEntries(Object.entries(a).filter(([, v]) => v !== null)) }));
    }
    if (data?.kyc) {
      const status: Record<string, string> = {};
      for (const doc of data.kyc) status[doc.docType] = doc.status;
      setUploadStatus(status);
    }
  }, [data]);

  const saveMutation = useMutation({
    mutationFn: async (payload: Record<string, any>) => {
      const r = await fetch(`${API}/broker/account`, {
        method: "POST", credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      });
      if (!r.ok) throw new Error((await r.json()).error);
      return r.json();
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["broker-account"] }),
  });

  const submitMutation = useMutation({
    mutationFn: async () => {
      const r = await fetch(`${API}/broker/account/submit`, {
        method: "POST", credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({}),
      });
      if (!r.ok) throw new Error((await r.json()).error ?? "Submit failed");
      return r.json();
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["broker-account"] }),
  });

  const kycMutation = useMutation({
    mutationFn: async ({ docType, fileUrl }: { docType: string; fileUrl: string }) => {
      const r = await fetch(`${API}/broker/account/kyc`, {
        method: "POST", credentials: "include",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ docType, fileUrl }),
      });
      if (!r.ok) throw new Error((await r.json()).error);
      return r.json();
    },
    onSuccess: (_, { docType }) => {
      setUploadStatus(s => ({ ...s, [docType]: "pending" }));
      qc.invalidateQueries({ queryKey: ["broker-account"] });
    },
  });

  function set(key: string, val: any) { setForm(f => ({ ...f, [key]: val })); }
  function inp(key: string, placeholder?: string, type = "text") {
    return (
      <input type={type} value={form[key] ?? ""} onChange={e => set(key, e.target.value)}
        placeholder={placeholder}
        className="w-full bg-[#111] border border-[#2a2a2a] rounded-lg px-3 py-2.5 text-white text-sm focus:border-[#d4a017] focus:outline-none" />
    );
  }
  function sel(key: string, opts: string[], placeholder = "Select") {
    return (
      <select value={form[key] ?? ""} onChange={e => set(key, e.target.value)}
        className="w-full bg-[#111] border border-[#2a2a2a] rounded-lg px-3 py-2.5 text-white text-sm focus:border-[#d4a017] focus:outline-none">
        <option value="">{placeholder}</option>
        {opts.map(o => <option key={o} value={o}>{o}</option>)}
      </select>
    );
  }
  function lbl(text: string, required = false) {
    return <label className="block text-xs text-gray-400 mb-1">{text}{required && <span className="text-red-400 ml-1">*</span>}</label>;
  }

  async function handleFileUpload(docType: string, file: File) {
    setUploadStatus(s => ({ ...s, [docType]: "uploading" }));
    const reader = new FileReader();
    reader.onloadend = () => {
      const fileUrl = reader.result as string;
      kycMutation.mutate({ docType, fileUrl });
    };
    reader.readAsDataURL(file);
  }

  async function handleNext() {
    await saveMutation.mutateAsync(form);
    setStep(s => Math.min(s + 1, STEPS.length));
  }

  const account = data?.account;
  const isReadonly = account?.status && !["draft", "rejected"].includes(account.status);
  const isActive = account?.status === "active";

  if (isLoading) return (
    <div className="min-h-screen bg-[#0a0a0a] flex items-center justify-center">
      <div className="text-gray-400 text-sm">Loading...</div>
    </div>
  );

  return (
    <div className="min-h-screen bg-[#0a0a0a] text-white">
      {/* Header */}
      <div className="border-b border-[#1a1a1a] bg-[#0d0d0d] px-4 py-3 flex items-center gap-3">
        <Link href="/forex" className="text-gray-400 hover:text-white text-sm">← Trading</Link>
        <span className="text-gray-600">/</span>
        <span className="text-sm font-semibold text-[#d4a017]">Angel One Sub-broker Account</span>
        {account && <StatusBadge status={account.status} />}
      </div>

      {/* Active Account Banner */}
      {isActive && (
        <div className="bg-green-900/20 border-b border-green-800/40 px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <CheckCircle className="text-green-400" size={20} />
            <div>
              <div className="text-green-400 font-semibold text-sm">Your Angel One account is active!</div>
              <div className="text-gray-400 text-xs">Client ID: {account.angelClientId} · Demat: {account.angelDemat}</div>
            </div>
          </div>
          <Link href="/forex" className="bg-[#d4a017] text-black px-4 py-2 rounded-lg text-sm font-bold hover:bg-[#b8860b]">
            Start Trading →
          </Link>
        </div>
      )}

      {/* Rejected Banner */}
      {account?.status === "rejected" && account.rejectionReason && (
        <div className="bg-red-900/20 border-b border-red-800/40 px-6 py-3 flex items-center gap-3">
          <XCircle className="text-red-400" size={16} />
          <div className="text-red-300 text-sm"><b>Rejected:</b> {account.rejectionReason}</div>
        </div>
      )}

      <div className="max-w-4xl mx-auto px-4 py-6">
        {/* Progress Steps */}
        <div className="flex items-center gap-1 mb-8 overflow-x-auto pb-2">
          {STEPS.map((s, i) => {
            const Icon = s.icon;
            const done = step > s.id || isReadonly;
            const active = step === s.id;
            return (
              <div key={s.id} className="flex items-center gap-1 flex-shrink-0">
                <button onClick={() => !isReadonly && setStep(s.id)}
                  className={`flex items-center gap-2 px-3 py-2 rounded-lg text-xs font-semibold transition-all ${active ? "bg-[#d4a017] text-black" : done ? "bg-green-900/30 text-green-400" : "bg-[#1a1a1a] text-gray-500"}`}>
                  <Icon size={12} />
                  {s.label}
                  {done && !active && <CheckCircle size={10} />}
                </button>
                {i < STEPS.length - 1 && <ChevronRight size={14} className="text-gray-700 flex-shrink-0" />}
              </div>
            );
          })}
        </div>

        <div className="bg-[#0d0d0d] border border-[#1a1a1a] rounded-2xl p-6">
          {/* STEP 1: Personal Info */}
          {step === 1 && (
            <div>
              <h2 className="text-lg font-bold mb-6 flex items-center gap-2"><User size={18} className="text-[#d4a017]" /> Personal Information</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="md:col-span-2">
                  {lbl("Full Name (as per PAN)", true)}
                  {inp("fullName", "e.g. Rahul Kumar")}
                </div>
                <div>
                  {lbl("Date of Birth", true)}
                  {inp("dob", "YYYY-MM-DD", "date")}
                </div>
                <div>
                  {lbl("Gender", true)}
                  {sel("gender", ["male","female","other"], "Select Gender")}
                </div>
                <div>
                  {lbl("Father's Name", true)}
                  {inp("fatherName", "Father's full name")}
                </div>
                <div>
                  {lbl("Mother's Name")}
                  {inp("motherName", "Mother's full name")}
                </div>
                <div>
                  {lbl("Marital Status")}
                  {sel("maritalStatus", ["single","married","divorced","widowed"], "Select")}
                </div>
                <div>
                  {lbl("Occupation", true)}
                  {sel("occupation", OCCUPATIONS, "Select Occupation")}
                </div>
                <div>
                  {lbl("Annual Income")}
                  {sel("annualIncome", INCOME_RANGES, "Select Range")}
                </div>
                <div>
                  {lbl("PAN Number", true)}
                  {inp("panNumber", "e.g. ABCDE1234F")}
                </div>
                <div>
                  {lbl("Aadhaar Number", true)}
                  {inp("aadharNumber", "12-digit Aadhaar number")}
                </div>
              </div>
            </div>
          )}

          {/* STEP 2: Contact & Address */}
          {step === 2 && (
            <div>
              <h2 className="text-lg font-bold mb-6 flex items-center gap-2"><Building2 size={18} className="text-[#d4a017]" /> Contact & Address</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  {lbl("Mobile Number", true)}
                  {inp("mobile", "10-digit mobile number")}
                </div>
                <div>
                  {lbl("Email Address", true)}
                  {inp("email", "your@email.com", "email")}
                </div>
                <div className="md:col-span-2">
                  {lbl("Residential Address", true)}
                  <textarea value={form.address ?? ""} onChange={e => set("address", e.target.value)}
                    placeholder="Full address"
                    className="w-full bg-[#111] border border-[#2a2a2a] rounded-lg px-3 py-2.5 text-white text-sm focus:border-[#d4a017] focus:outline-none resize-none h-20" />
                </div>
                <div>
                  {lbl("City", true)}
                  {inp("city", "e.g. Mumbai")}
                </div>
                <div>
                  {lbl("State", true)}
                  {sel("state", STATES, "Select State")}
                </div>
                <div>
                  {lbl("PIN Code", true)}
                  {inp("pincode", "6-digit PIN")}
                </div>
              </div>
            </div>
          )}

          {/* STEP 3: Bank Details */}
          {step === 3 && (
            <div>
              <h2 className="text-lg font-bold mb-6 flex items-center gap-2"><CreditCard size={18} className="text-[#d4a017]" /> Bank Account Details</h2>
              <div className="bg-blue-900/20 border border-blue-800/40 rounded-lg p-3 mb-5 flex items-center gap-2">
                <AlertCircle size={14} className="text-blue-400 flex-shrink-0" />
                <p className="text-blue-300 text-xs">Your bank account must be in your name and match your KYC documents. Funds will be settled to this account.</p>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  {lbl("Account Number", true)}
                  {inp("bankAccountNo", "Bank account number")}
                </div>
                <div>
                  {lbl("IFSC Code", true)}
                  {inp("bankIfsc", "e.g. HDFC0001234")}
                </div>
                <div>
                  {lbl("Bank Name", true)}
                  {inp("bankName", "e.g. HDFC Bank")}
                </div>
                <div>
                  {lbl("Account Type")}
                  {sel("bankAccountType", ["savings","current"], "Select")}
                </div>
              </div>
            </div>
          )}

          {/* STEP 4: KYC Documents */}
          {step === 4 && (
            <div>
              <h2 className="text-lg font-bold mb-2 flex items-center gap-2"><FileText size={18} className="text-[#d4a017]" /> KYC Documents</h2>
              <p className="text-gray-400 text-xs mb-6">Upload clear photos or scanned copies. Max 5MB per file. Accepted: JPG, PNG, PDF.</p>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {KYC_DOCS.map(doc => {
                  const st = uploadStatus[doc.type];
                  const existingDoc = data?.kyc?.find((d: any) => d.docType === doc.type);
                  return (
                    <div key={doc.type} className={`border rounded-xl p-4 ${st === "verified" ? "border-green-700 bg-green-900/10" : st === "rejected" ? "border-red-700 bg-red-900/10" : st === "pending" || existingDoc ? "border-[#d4a017]/50 bg-[#d4a017]/5" : "border-[#2a2a2a]"}`}>
                      <div className="flex items-start justify-between mb-2">
                        <div>
                          <div className="text-sm font-semibold text-white">{doc.label} {doc.required && <span className="text-red-400">*</span>}</div>
                          <div className="text-xs text-gray-500">{doc.hint}</div>
                        </div>
                        {st === "verified" && <CheckCircle size={14} className="text-green-400 flex-shrink-0" />}
                        {st === "rejected" && <XCircle size={14} className="text-red-400 flex-shrink-0" />}
                        {(st === "pending" || (existingDoc && !st)) && <Clock size={14} className="text-yellow-400 flex-shrink-0" />}
                      </div>
                      {existingDoc?.rejectionNote && (
                        <div className="text-red-400 text-xs mb-2">Rejected: {existingDoc.rejectionNote}</div>
                      )}
                      {!isReadonly && (
                        <label className="cursor-pointer">
                          <div className={`flex items-center gap-2 px-3 py-2 rounded-lg text-xs font-semibold transition-all ${st === "uploading" ? "bg-gray-700 text-gray-400" : "bg-[#1a1a1a] hover:bg-[#222] text-gray-300"}`}>
                            <Upload size={12} />
                            {st === "uploading" ? "Uploading..." : existingDoc ? "Re-upload" : "Upload File"}
                          </div>
                          <input type="file" className="hidden" accept="image/*,.pdf"
                            onChange={e => { const f = e.target.files?.[0]; if (f) handleFileUpload(doc.type, f); }} />
                        </label>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* STEP 5: Segments & Nominee */}
          {step === 5 && (
            <div>
              <h2 className="text-lg font-bold mb-6 flex items-center gap-2"><Shield size={18} className="text-[#d4a017]" /> Trading Segments & Nominee</h2>
              <div className="mb-6">
                <div className="text-sm font-semibold text-white mb-3">Select Trading Segments</div>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                  {[
                    { key: "segmentEquity", label: "Equity (Stocks)", desc: "NSE/BSE cash", color: "green" },
                    { key: "segmentFno", label: "F&O", desc: "Futures & Options", color: "blue" },
                    { key: "segmentCommodity", label: "Commodity", desc: "MCX Gold/Silver/Oil", color: "yellow" },
                    { key: "segmentCurrency", label: "Currency", desc: "Forex USD/INR etc.", color: "purple" },
                  ].map(seg => (
                    <button key={seg.key} onClick={() => !isReadonly && set(seg.key, !form[seg.key])}
                      className={`p-3 rounded-xl border text-left transition-all ${form[seg.key] ? "border-[#d4a017] bg-[#d4a017]/10" : "border-[#2a2a2a] bg-[#111]"}`}>
                      <div className={`w-4 h-4 rounded border mb-2 flex items-center justify-center ${form[seg.key] ? "bg-[#d4a017] border-[#d4a017]" : "border-gray-600"}`}>
                        {form[seg.key] && <span className="text-black text-xs">✓</span>}
                      </div>
                      <div className="text-xs font-semibold text-white">{seg.label}</div>
                      <div className="text-xs text-gray-500">{seg.desc}</div>
                    </button>
                  ))}
                </div>
              </div>

              <div className="border-t border-[#1a1a1a] pt-5">
                <div className="text-sm font-semibold text-white mb-3">Nominee Details (Optional)</div>
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div>
                    {lbl("Nominee Name")}
                    {inp("nomineeName", "Full name")}
                  </div>
                  <div>
                    {lbl("Relationship")}
                    {sel("nomineeRelation", ["Spouse","Father","Mother","Son","Daughter","Brother","Sister","Other"], "Select")}
                  </div>
                  <div>
                    {lbl("Nominee DOB")}
                    {inp("nomineeDob", "YYYY-MM-DD", "date")}
                  </div>
                </div>
              </div>

              {!isReadonly && (
                <div className="mt-6 bg-[#1a1a1a] rounded-xl p-4">
                  <div className="text-xs text-gray-400 mb-3">By submitting this application, you agree to Angel One's terms and conditions and authorize us to act as your Authorized Person (AP) for trading services.</div>
                  {submitMutation.isSuccess ? (
                    <div className="flex items-center gap-2 text-green-400 text-sm font-semibold">
                      <CheckCircle size={16} /> Application submitted successfully! We'll review within 2-3 business days.
                    </div>
                  ) : (
                    <button onClick={() => submitMutation.mutate()}
                      disabled={submitMutation.isPending}
                      className="w-full bg-[#d4a017] text-black py-3 rounded-xl font-bold text-sm hover:bg-[#b8860b] disabled:opacity-50 transition-all">
                      {submitMutation.isPending ? "Submitting..." : "Submit Application for Review"}
                    </button>
                  )}
                  {submitMutation.isError && (
                    <div className="mt-2 text-red-400 text-xs">{(submitMutation.error as Error).message}</div>
                  )}
                </div>
              )}

              {account?.status === "submitted" && (
                <div className="mt-4 bg-blue-900/20 border border-blue-800/40 rounded-xl p-4 flex items-center gap-3">
                  <Clock size={20} className="text-blue-400 flex-shrink-0" />
                  <div>
                    <div className="text-blue-300 font-semibold text-sm">Application Under Review</div>
                    <div className="text-gray-400 text-xs">We're verifying your documents. This typically takes 2-3 business days. You'll be notified via email once approved.</div>
                  </div>
                </div>
              )}
            </div>
          )}

          {/* Navigation */}
          <div className="flex items-center justify-between mt-8 pt-4 border-t border-[#1a1a1a]">
            <button onClick={() => setStep(s => Math.max(1, s - 1))} disabled={step === 1}
              className="flex items-center gap-2 px-4 py-2 rounded-lg bg-[#1a1a1a] text-gray-300 text-sm font-semibold disabled:opacity-30 hover:bg-[#222]">
              <ChevronLeft size={14} /> Previous
            </button>
            {step < STEPS.length ? (
              <button onClick={handleNext} disabled={saveMutation.isPending || isReadonly}
                className="flex items-center gap-2 px-5 py-2 rounded-lg bg-[#d4a017] text-black text-sm font-bold hover:bg-[#b8860b] disabled:opacity-50">
                {saveMutation.isPending ? "Saving..." : "Save & Continue"} <ChevronRight size={14} />
              </button>
            ) : (
              <Link href="/forex" className="px-5 py-2 rounded-lg bg-[#1a1a1a] text-gray-300 text-sm font-semibold hover:bg-[#222]">
                Go to Trading →
              </Link>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
