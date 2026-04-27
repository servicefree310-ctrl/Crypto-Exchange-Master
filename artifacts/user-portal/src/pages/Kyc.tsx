import { useState, useMemo, useRef } from "react";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";
import {
  Shield, BadgeCheck, Lock, Clock, CheckCircle2, XCircle, AlertCircle,
  Loader2, Upload, FileText, User as UserIcon, Camera, MapPin, Calendar,
  Hash, ArrowRight, Info, IdCard, Mail, Phone, Crown, Gift, KeyRound,
  Copy, Check, Fingerprint, ShieldCheck, ShieldOff, TrendingUp,
} from "lucide-react";
import { get, post, ApiError } from "@/lib/api";
import { Card } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Separator } from "@/components/ui/separator";
import {
  Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter,
} from "@/components/ui/dialog";
import { useAuth } from "@/lib/auth";
import { toast } from "@/hooks/use-toast";
import { PageHeader } from "@/components/premium/PageHeader";
import { PremiumStatCard } from "@/components/premium/PremiumStatCard";
import { SectionCard } from "@/components/premium/SectionCard";
import { StatusPill } from "@/components/premium/StatusPill";
import { Link } from "wouter";

type KycSetting = {
  level: number;
  depositLimit: string | number;
  withdrawLimit: string | number;
  tradeLimit: string | number;
  features: string[] | string;
};

function parseFeatures(f: string[] | string | null | undefined): string[] {
  if (!f) return [];
  if (Array.isArray(f)) return f;
  try {
    const parsed = JSON.parse(f);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

type KycRecord = {
  id: number;
  level: number;
  status: "pending" | "approved" | "rejected";
  fullName: string | null;
  dob: string | null;
  panNumber: string | null;
  aadhaarNumber: string | null;
  rejectReason: string | null;
  createdAt: string;
  reviewedAt: string | null;
};

const LEVEL_META: Record<number, { name: string; tagline: string; color: string; icon: any }> = {
  1: { name: "Basic", tagline: "PAN + Personal Info", color: "sky", icon: IdCard },
  2: { name: "Intermediate", tagline: "Aadhaar + Documents", color: "amber", icon: FileText },
  3: { name: "Advanced", tagline: "Selfie + Address", color: "emerald", icon: Camera },
};

const FEATURE_LABELS: Record<string, string> = {
  browse: "Browse markets",
  deposit: "Deposit funds",
  trade: "Spot trading",
  withdraw: "Withdrawals",
  earn_simple: "Flexible Earn",
  earn_advanced: "Locked Earn",
  futures: "Futures trading",
  margin: "Margin trading",
};

function fmtINR(n: number) {
  if (!Number.isFinite(n)) return "—";
  if (n >= 10000000) return `₹${(n / 10000000).toFixed(1)} Cr`;
  if (n >= 100000) return `₹${(n / 100000).toFixed(1)} L`;
  if (n >= 1000) return `₹${(n / 1000).toFixed(0)}k`;
  return `₹${n}`;
}

function fmtDate(s: string | null | undefined): string {
  if (!s) return "—";
  try {
    return new Date(s).toLocaleDateString("en-IN", {
      day: "2-digit", month: "short", year: "numeric",
    });
  } catch {
    return "—";
  }
}

function fmtDateTime(s: string | null | undefined): string {
  if (!s) return "—";
  try {
    const d = new Date(s);
    return d.toLocaleString("en-IN", {
      day: "2-digit", month: "short", year: "numeric",
      hour: "2-digit", minute: "2-digit",
    });
  } catch {
    return "—";
  }
}

function maskPhone(p: string | null | undefined): string {
  if (!p) return "—";
  if (p.length < 6) return p;
  return p.slice(0, 3) + "•••••" + p.slice(-2);
}

function maskEmail(e: string | null | undefined): string {
  if (!e) return "—";
  const [u, d] = e.split("@");
  if (!u || !d) return e;
  if (u.length <= 2) return e;
  return u.slice(0, 2) + "•••" + "@" + d;
}

export default function Kyc() {
  const { user } = useAuth();
  const qc = useQueryClient();

  const settingsQ = useQuery<KycSetting[]>({
    queryKey: ["/kyc/settings"],
    queryFn: () => get<KycSetting[]>("/kyc/settings"),
  });

  const myKycQ = useQuery<KycRecord[]>({
    queryKey: ["/kyc/my"],
    queryFn: () => get<KycRecord[]>("/kyc/my"),
  });

  const [submitFor, setSubmitFor] = useState<number | null>(null);

  const currentLevel = user?.kycLevel ?? 0;

  // Latest record per level (sorted desc by createdAt — first occurrence is latest)
  const latestByLevel = useMemo(() => {
    const map = new Map<number, KycRecord>();
    const records = myKycQ.data ?? [];
    for (const r of records) {
      if (!map.has(r.level)) map.set(r.level, r);
    }
    return map;
  }, [myKycQ.data]);

  const settings = settingsQ.data ?? [];
  const sorted = [...settings].sort((a, b) => a.level - b.level);

  // Limits unlocked at the user's *current* level (used for KPI tiles).
  const currentSettings = useMemo(
    () => sorted.find((s) => s.level === currentLevel),
    [sorted, currentLevel],
  );

  // Verification roll-up — what counts as "fully verified" for the badge
  // and for the Status KPI tile. We treat L1+ + email-verified as the
  // baseline; full = L3 + email + phone + 2FA.
  const verification = useMemo(() => {
    const emailOk = !!user?.emailVerified;
    const phoneOk = !!user?.phoneVerified;
    const twoFaOk = !!user?.twoFaEnabled;
    const kycFull = currentLevel >= 3;
    if (kycFull && emailOk && phoneOk && twoFaOk) return { label: "Fully Verified", variant: "success" as const };
    if (currentLevel >= 1 && emailOk) return { label: "Verified", variant: "success" as const };
    if (currentLevel >= 1) return { label: "Partial", variant: "warning" as const };
    return { label: "Unverified", variant: "danger" as const };
  }, [currentLevel, user?.emailVerified, user?.phoneVerified, user?.twoFaEnabled]);

  return (
    <div className="container mx-auto max-w-6xl p-4 sm:p-6 space-y-5">
      <PageHeader
        eyebrow="Compliance"
        title="KYC Verification"
        description="Apni identity verify karke higher limits aur extra features unlock karein."
        actions={
          <StatusPill variant={currentLevel >= 3 ? "gold" : currentLevel >= 1 ? "success" : "warning"}>
            <BadgeCheck className="h-3 w-3 mr-0.5" /> Level {currentLevel} / 3
          </StatusPill>
        }
      />

      {/* KPI tiles */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3" data-testid="kyc-kpis">
        <PremiumStatCard
          title="Verification"
          value={verification.label}
          icon={verification.variant === "success" ? ShieldCheck : ShieldOff}
          accent={verification.variant === "success"}
          hint={`${currentLevel}/3 levels`}
        />
        <PremiumStatCard
          title="Daily Withdraw"
          value={currentSettings ? fmtINR(Number(currentSettings.withdrawLimit)) : "—"}
          icon={TrendingUp}
          hint={currentLevel === 0 ? "Submit L1 to unlock" : `Level ${currentLevel} limit`}
        />
        <PremiumStatCard
          title="Daily Trade"
          value={currentSettings ? fmtINR(Number(currentSettings.tradeLimit)) : "—"}
          icon={TrendingUp}
          hint={currentLevel === 0 ? "Submit L1 to unlock" : `Level ${currentLevel} limit`}
        />
        <PremiumStatCard
          title="VIP Tier"
          value={user?.vipTier ? `VIP ${user.vipTier}` : "Standard"}
          icon={Crown}
          accent={!!user?.vipTier}
          hint={user?.vipTier ? "Premium fee tier" : "Trade more to upgrade"}
        />
      </div>

      {/* Account Details — show user info from /auth/me */}
      <SectionCard
        title="Account Details"
        description="Aapki current account information aur verification status."
        icon={UserIcon}
      >
        <div className="flex flex-col sm:flex-row gap-5">
          {/* Avatar + identity */}
          <div className="flex items-center gap-4 sm:w-72 shrink-0">
            <Avatar user={user} />
            <div className="min-w-0">
              <div className="font-semibold text-base truncate" data-testid="account-name">
                {user?.name || user?.fullName || "—"}
              </div>
              <div className="text-xs text-muted-foreground truncate">
                UID: <span className="font-mono">{user?.uid ?? user?.id ?? "—"}</span>
              </div>
              <div className="mt-1.5 flex items-center gap-1.5 flex-wrap">
                <StatusPill status={user?.status || "active"} />
                {user?.role && user.role !== "user" && (
                  <StatusPill variant="gold">{user.role.toUpperCase()}</StatusPill>
                )}
              </div>
            </div>
          </div>

          <Separator orientation="vertical" className="hidden sm:block h-auto" />
          <Separator className="sm:hidden" />

          {/* Field grid */}
          <div className="flex-1 grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-3 text-sm">
            <DetailField
              icon={Mail}
              label="Email"
              value={maskEmail(user?.email)}
              testId="account-email"
              trailing={
                user?.emailVerified
                  ? <StatusPill variant="success">Verified</StatusPill>
                  : <StatusPill variant="warning">Unverified</StatusPill>
              }
            />
            <DetailField
              icon={Phone}
              label="Phone"
              value={user?.phone ? maskPhone(user.phone) : "Not added"}
              testId="account-phone"
              trailing={
                user?.phoneVerified
                  ? <StatusPill variant="success">Verified</StatusPill>
                  : user?.phone
                    ? <StatusPill variant="warning">Unverified</StatusPill>
                    : null
              }
            />
            <DetailField
              icon={KeyRound}
              label="Two-Factor Auth"
              value={user?.twoFaEnabled ? "Enabled" : "Disabled"}
              testId="account-2fa"
              trailing={
                user?.twoFaEnabled
                  ? <StatusPill variant="success">Active</StatusPill>
                  : (
                    <Link href="/settings">
                      <Button size="sm" variant="ghost" className="h-6 px-2 text-[11px] text-amber-400 hover:text-amber-300">
                        Enable
                      </Button>
                    </Link>
                  )
              }
            />
            <DetailField
              icon={Fingerprint}
              label="KYC Level"
              value={`Level ${currentLevel}${currentLevel ? ` · ${LEVEL_META[currentLevel]?.name ?? ""}` : " · Unverified"}`}
              testId="account-kyc"
              trailing={
                currentLevel >= 3
                  ? <StatusPill variant="gold">Full</StatusPill>
                  : currentLevel >= 1
                    ? <StatusPill variant="success">L{currentLevel}</StatusPill>
                    : <StatusPill variant="warning">L0</StatusPill>
              }
            />
            <DetailField
              icon={Calendar}
              label="Member Since"
              value={fmtDate(user?.createdAt)}
              testId="account-created"
            />
            <DetailField
              icon={Clock}
              label="Last Login"
              value={fmtDateTime(user?.lastLoginAt)}
              testId="account-last-login"
            />
            <DetailField
              icon={Gift}
              label="Referral Code"
              value={user?.referralCode || "—"}
              mono
              testId="account-ref"
              trailing={
                user?.referralCode
                  ? <CopyButton value={user.referralCode} />
                  : null
              }
            />
            <DetailField
              icon={Crown}
              label="VIP Tier"
              value={user?.vipTier ? `VIP ${user.vipTier}` : "Standard"}
              testId="account-vip"
            />
          </div>
        </div>
      </SectionCard>

      {/* Progress bar */}
      <Card className="p-5" data-testid="kyc-progress">
        <div className="flex items-center justify-between mb-3">
          <span className="text-xs font-semibold uppercase text-muted-foreground tracking-wider">Verification progress</span>
          <span className="text-xs text-muted-foreground tabular-nums">{currentLevel} / 3 levels</span>
        </div>
        <div className="relative h-2 bg-muted rounded-full overflow-hidden">
          <div
            className="absolute inset-y-0 left-0 bg-gradient-to-r from-emerald-500 via-amber-500 to-orange-500 rounded-full transition-all duration-700"
            style={{ width: `${(currentLevel / 3) * 100}%` }}
          />
        </div>
        <div className="grid grid-cols-4 mt-2 text-[10px] text-muted-foreground uppercase tracking-wider">
          <span>L0 · Unverified</span>
          <span className="text-center">L1 · Basic</span>
          <span className="text-center">L2 · Intermediate</span>
          <span className="text-right">L3 · Advanced</span>
        </div>
      </Card>

      {/* Levels grid */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
        {sorted.filter((s) => s.level >= 1).map((s) => {
          const meta = LEVEL_META[s.level];
          const latest = latestByLevel.get(s.level);
          const achieved = currentLevel >= s.level;
          const isPrevReq = s.level > 1 && currentLevel < s.level - 1;
          const Icon = meta.icon;

          let status: "achieved" | "pending" | "rejected" | "available" | "locked" = "available";
          if (achieved) status = "achieved";
          else if (latest?.status === "pending") status = "pending";
          else if (latest?.status === "rejected") status = "rejected";
          else if (isPrevReq) status = "locked";

          const tones: Record<string, string> = {
            sky: "from-sky-500/10 border-sky-500/30 text-sky-400",
            amber: "from-amber-500/10 border-amber-500/30 text-amber-400",
            emerald: "from-emerald-500/10 border-emerald-500/30 text-emerald-400",
          };

          return (
            <Card key={s.level} className={`p-5 border bg-gradient-to-br ${tones[meta.color]} to-card flex flex-col`} data-testid={`level-card-${s.level}`}>
              {/* Top */}
              <div className="flex items-start justify-between mb-3">
                <div className={`h-10 w-10 rounded-lg bg-card/60 flex items-center justify-center`}>
                  <Icon className="h-5 w-5" />
                </div>
                <LevelStatusBadge status={status} />
              </div>

              <h3 className="font-bold text-lg">Level {s.level} · {meta.name}</h3>
              <p className="text-xs text-muted-foreground mb-3">{meta.tagline}</p>

              <Separator className="my-2" />

              {/* Limits */}
              <div className="grid grid-cols-2 gap-2 text-xs my-3">
                <div>
                  <div className="text-[10px] text-muted-foreground uppercase tracking-wider">Daily withdraw</div>
                  <div className="font-bold tabular-nums">{fmtINR(Number(s.withdrawLimit))}</div>
                </div>
                <div>
                  <div className="text-[10px] text-muted-foreground uppercase tracking-wider">Daily trade</div>
                  <div className="font-bold tabular-nums">{fmtINR(Number(s.tradeLimit))}</div>
                </div>
              </div>

              {/* Features */}
              <div className="my-2 flex flex-wrap gap-1">
                {parseFeatures(s.features).map((f) => (
                  <Badge key={f} variant="outline" className="text-[9px] font-normal">
                    {FEATURE_LABELS[f] ?? f}
                  </Badge>
                ))}
              </div>

              {latest?.status === "rejected" && latest.rejectReason && (
                <div className="mt-2 text-xs text-rose-400 rounded-md bg-rose-500/10 border border-rose-500/30 p-2 flex items-start gap-1.5">
                  <XCircle className="h-3.5 w-3.5 mt-0.5 flex-shrink-0" />
                  <span><span className="font-semibold">Rejected:</span> {latest.rejectReason}</span>
                </div>
              )}

              <div className="mt-auto pt-3">
                {status === "achieved" && (
                  <Button variant="outline" disabled className="w-full">
                    <CheckCircle2 className="h-4 w-4 mr-1.5" /> Approved
                  </Button>
                )}
                {status === "pending" && (
                  <Button variant="outline" disabled className="w-full">
                    <Clock className="h-4 w-4 mr-1.5" /> Under Review
                  </Button>
                )}
                {status === "locked" && (
                  <Button variant="outline" disabled className="w-full">
                    <Lock className="h-4 w-4 mr-1.5" /> Complete L{s.level - 1} first
                  </Button>
                )}
                {(status === "available" || status === "rejected") && (
                  <Button
                    onClick={() => setSubmitFor(s.level)}
                    className="w-full bg-gradient-to-r from-amber-500 to-orange-500 text-black hover:from-amber-400 hover:to-orange-400 font-semibold"
                    data-testid={`button-submit-l${s.level}`}
                  >
                    {status === "rejected" ? "Re-submit" : "Submit"} <ArrowRight className="h-4 w-4 ml-1.5" />
                  </Button>
                )}
              </div>
            </Card>
          );
        })}
      </div>

      {/* Submission history */}
      {(myKycQ.data?.length ?? 0) > 0 && (
        <SectionCard title="Submission history" icon={FileText}>
          <div className="space-y-2">
            {(myKycQ.data ?? []).map((r) => (
              <div key={r.id} className="flex items-center justify-between gap-3 p-3 rounded-lg bg-muted/30 border border-border/40 text-sm" data-testid={`record-${r.id}`}>
                <div className="flex items-center gap-3 min-w-0">
                  <Badge variant="outline" className="text-[10px]">L{r.level}</Badge>
                  <div className="min-w-0">
                    <div className="font-medium truncate">{r.fullName || "—"}</div>
                    <div className="text-xs text-muted-foreground">
                      Submitted {new Date(r.createdAt).toLocaleString()}
                      {r.reviewedAt && ` · Reviewed ${new Date(r.reviewedAt).toLocaleDateString()}`}
                    </div>
                  </div>
                </div>
                <StatusPill status={r.status} />
              </div>
            ))}
          </div>
        </SectionCard>
      )}

      {/* Helper */}
      <Card className="p-4 border-border/60 bg-muted/20">
        <div className="flex items-start gap-3">
          <Info className="h-4 w-4 text-muted-foreground mt-0.5 flex-shrink-0" />
          <div className="text-xs text-muted-foreground leading-relaxed">
            <p className="font-medium text-foreground mb-1">Kaise kaam karta hai</p>
            <ul className="space-y-0.5 list-disc list-inside marker:text-muted-foreground/40">
              <li>Submission usually <span className="text-foreground">24 hours</span> mein review ho jaati hai.</li>
              <li>Original documents ki clear, well-lit photo upload karein — screenshots na lein.</li>
              <li>Information aapke bank account name se match honi chahiye taaki withdrawals chal sakein.</li>
              <li>Reject hone par hum reason batayenge aur aap dobara submit kar sakte hain.</li>
            </ul>
          </div>
        </div>
      </Card>

      <KycSubmitDialog
        level={submitFor}
        onOpenChange={(v) => { if (!v) setSubmitFor(null); }}
        onSuccess={() => {
          qc.invalidateQueries({ queryKey: ["/kyc/my"] });
          setSubmitFor(null);
        }}
      />
    </div>
  );
}

// ───────────────── Account-detail field row ─────────────────
function DetailField({
  icon: Icon, label, value, trailing, mono, testId,
}: {
  icon: any; label: string; value: string; trailing?: React.ReactNode; mono?: boolean; testId?: string;
}) {
  return (
    <div className="flex items-start gap-2 min-w-0" data-testid={testId}>
      <Icon className="h-4 w-4 text-muted-foreground mt-0.5 flex-shrink-0" />
      <div className="min-w-0 flex-1">
        <div className="text-[10px] uppercase tracking-wider text-muted-foreground">{label}</div>
        <div className={`text-sm truncate ${mono ? "font-mono" : ""}`}>{value}</div>
      </div>
      {trailing && <div className="flex-shrink-0">{trailing}</div>}
    </div>
  );
}

// ───────────────── Avatar (initials fallback) ─────────────────
function Avatar({ user }: { user: ReturnType<typeof useAuth>["user"] }) {
  if (user?.avatarUrl) {
    return (
      <img
        src={user.avatarUrl}
        alt={user.name || user.email}
        className="h-14 w-14 rounded-full object-cover border border-border/60"
      />
    );
  }
  const seed = (user?.name || user?.fullName || user?.email || "?").trim();
  const initials = seed
    .split(/\s+/)
    .map((w) => w[0])
    .filter(Boolean)
    .slice(0, 2)
    .join("")
    .toUpperCase() || "?";
  return (
    <div className="h-14 w-14 rounded-full bg-gradient-to-br from-amber-500/30 to-orange-500/20 border border-amber-500/30 flex items-center justify-center text-amber-300 font-bold text-lg">
      {initials}
    </div>
  );
}

// ───────────────── Copy-to-clipboard button ─────────────────
function CopyButton({ value }: { value: string }) {
  const [copied, setCopied] = useState(false);
  const onCopy = async () => {
    try {
      await navigator.clipboard.writeText(value);
      setCopied(true);
      toast({ title: "Copied to clipboard" });
      setTimeout(() => setCopied(false), 1500);
    } catch {
      toast({ title: "Copy failed", variant: "destructive" });
    }
  };
  return (
    <Button
      type="button"
      size="sm"
      variant="ghost"
      onClick={onCopy}
      className="h-6 px-2 text-[11px]"
      data-testid="copy-referral"
    >
      {copied ? <Check className="h-3 w-3 mr-1 text-emerald-400" /> : <Copy className="h-3 w-3 mr-1" />}
      {copied ? "Copied" : "Copy"}
    </Button>
  );
}

// ───────────────── Level status badge ─────────────────
function LevelStatusBadge({ status }: { status: "achieved" | "pending" | "rejected" | "available" | "locked" }) {
  const map: Record<string, { label: string; cls: string; Icon: any }> = {
    achieved: { label: "Approved", cls: "bg-emerald-500/15 text-emerald-400 border-emerald-500/30", Icon: CheckCircle2 },
    pending: { label: "Pending", cls: "bg-amber-500/15 text-amber-400 border-amber-500/30", Icon: Clock },
    rejected: { label: "Rejected", cls: "bg-rose-500/15 text-rose-400 border-rose-500/30", Icon: XCircle },
    available: { label: "Available", cls: "bg-sky-500/15 text-sky-400 border-sky-500/30", Icon: ArrowRight },
    locked: { label: "Locked", cls: "bg-zinc-500/15 text-zinc-400 border-zinc-500/30", Icon: Lock },
  };
  const m = map[status];
  const Icon = m.Icon;
  return (
    <Badge className={`${m.cls} border text-[10px] font-bold uppercase`}>
      <Icon className="h-2.5 w-2.5 mr-0.5" /> {m.label}
    </Badge>
  );
}

// ───────────────── Submit dialog ─────────────────
function KycSubmitDialog({
  level, onOpenChange, onSuccess,
}: { level: number | null; onOpenChange: (v: boolean) => void; onSuccess: () => void }) {
  const [fullName, setFullName] = useState("");
  const [dob, setDob] = useState("");
  const [pan, setPan] = useState("");
  const [aadhaar, setAadhaar] = useState("");
  const [address, setAddress] = useState("");
  const [panDocUrl, setPanDocUrl] = useState("");
  const [aadhaarDocUrl, setAadhaarDocUrl] = useState("");
  const [selfieUrl, setSelfieUrl] = useState("");
  const [submitting, setSubmitting] = useState(false);

  const reset = () => {
    setFullName(""); setDob(""); setPan(""); setAadhaar(""); setAddress("");
    setPanDocUrl(""); setAadhaarDocUrl(""); setSelfieUrl(""); setSubmitting(false);
  };

  const lvl = level ?? 0;

  const panOk = /^[A-Z]{5}[0-9]{4}[A-Z]$/.test(pan.toUpperCase());
  const aadhaarOk = /^\d{12}$/.test(aadhaar.replace(/\s+/g, ""));

  const validation =
    !fullName.trim() ? "Full name required"
    : !dob ? "Date of birth required"
    : !panOk ? "Valid PAN required (format: AAAAA1111A)"
    : (lvl >= 2 && !aadhaarOk) ? "Valid 12-digit Aadhaar required"
    : (lvl >= 2 && !panDocUrl) ? "Upload your PAN card image"
    : (lvl >= 2 && !aadhaarDocUrl) ? "Upload your Aadhaar card image"
    : (lvl >= 3 && !selfieUrl) ? "Upload a clear selfie"
    : (lvl >= 3 && !address.trim()) ? "Address required"
    : null;

  const submit = async () => {
    if (validation || !level) return;
    setSubmitting(true);
    try {
      await post("/kyc/submit", {
        level,
        fullName: fullName.trim(),
        dob,
        panNumber: pan.toUpperCase(),
        aadhaarNumber: lvl >= 2 ? aadhaar.replace(/\s+/g, "") : undefined,
        panDocUrl: lvl >= 2 ? panDocUrl : undefined,
        aadhaarDocUrl: lvl >= 2 ? aadhaarDocUrl : undefined,
        selfieUrl: lvl >= 3 ? selfieUrl : undefined,
        address: lvl >= 3 ? address.trim() : undefined,
      });
      toast({ title: "Submission received", description: "We'll review and get back to you within 24 hours." });
      reset();
      onSuccess();
    } catch (e: any) {
      const msg = e instanceof ApiError ? (e.data?.error || e.message) : e?.message;
      toast({ title: "Submission failed", description: msg, variant: "destructive" });
      setSubmitting(false);
    }
  };

  return (
    <Dialog open={level !== null} onOpenChange={(v) => { if (!v) reset(); onOpenChange(v); }}>
      <DialogContent className="sm:max-w-lg max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <Shield className="h-5 w-5 text-amber-400" /> Submit Level {level} verification
          </DialogTitle>
          <DialogDescription>
            {lvl === 1 && "Provide your name, date of birth, and PAN number."}
            {lvl === 2 && "Add your Aadhaar and upload images of both PAN and Aadhaar cards."}
            {lvl === 3 && "Final step — provide your address and upload a clear selfie holding your PAN card."}
          </DialogDescription>
        </DialogHeader>

        <div className="space-y-3">
          <div>
            <Label htmlFor="fn"><UserIcon className="h-3 w-3 inline mr-1" /> Full Name (as on PAN)</Label>
            <Input id="fn" value={fullName} onChange={(e) => setFullName(e.target.value)} data-testid="input-kyc-name" />
          </div>
          <div>
            <Label htmlFor="dob"><Calendar className="h-3 w-3 inline mr-1" /> Date of Birth</Label>
            <Input id="dob" type="date" value={dob} onChange={(e) => setDob(e.target.value)} data-testid="input-kyc-dob" />
          </div>
          <div>
            <Label htmlFor="pan"><Hash className="h-3 w-3 inline mr-1" /> PAN Number</Label>
            <Input
              id="pan"
              value={pan}
              onChange={(e) => setPan(e.target.value.toUpperCase().slice(0, 10))}
              placeholder="AAAAA1111A"
              maxLength={10}
              className="font-mono uppercase"
              data-testid="input-kyc-pan"
            />
          </div>

          {lvl >= 2 && (
            <>
              <Separator />
              <div>
                <Label htmlFor="aad"><IdCard className="h-3 w-3 inline mr-1" /> Aadhaar Number</Label>
                <Input
                  id="aad"
                  value={aadhaar}
                  onChange={(e) => setAadhaar(e.target.value.replace(/\D/g, "").slice(0, 12))}
                  placeholder="12 digits"
                  maxLength={12}
                  className="font-mono"
                  data-testid="input-kyc-aadhaar"
                />
              </div>
              <FileUploadField label="PAN card image" testId="upload-pan" url={panDocUrl} setUrl={setPanDocUrl} />
              <FileUploadField label="Aadhaar card image" testId="upload-aadhaar" url={aadhaarDocUrl} setUrl={setAadhaarDocUrl} />
            </>
          )}

          {lvl >= 3 && (
            <>
              <Separator />
              <FileUploadField label="Selfie holding PAN card" testId="upload-selfie" url={selfieUrl} setUrl={setSelfieUrl} />
              <div>
                <Label htmlFor="addr"><MapPin className="h-3 w-3 inline mr-1" /> Full Address</Label>
                <Textarea
                  id="addr"
                  value={address}
                  onChange={(e) => setAddress(e.target.value)}
                  placeholder="Door no., street, city, state, pincode"
                  rows={3}
                  data-testid="input-kyc-address"
                />
              </div>
            </>
          )}

          {validation && (
            <p className="text-xs text-rose-400 flex items-center gap-1.5"><AlertCircle className="h-3.5 w-3.5" /> {validation}</p>
          )}
        </div>

        <DialogFooter>
          <Button variant="ghost" onClick={() => onOpenChange(false)}>Cancel</Button>
          <Button onClick={submit} disabled={!!validation || submitting} data-testid="button-submit-kyc">
            {submitting ? <Loader2 className="h-4 w-4 mr-1.5 animate-spin" /> : <CheckCircle2 className="h-4 w-4 mr-1.5" />}
            Submit for review
          </Button>
        </DialogFooter>
      </DialogContent>
    </Dialog>
  );
}

// ───────────────── File upload field ─────────────────
function FileUploadField({
  label, testId, url, setUrl,
}: { label: string; testId: string; url: string; setUrl: (u: string) => void }) {
  const inputRef = useRef<HTMLInputElement>(null);
  const [uploading, setUploading] = useState(false);

  const onFile = async (file: File) => {
    if (file.size > 5 * 1024 * 1024) {
      toast({ title: "File too large", description: "Maximum 5 MB", variant: "destructive" });
      return;
    }
    setUploading(true);
    try {
      const form = new FormData();
      form.append("file", file);
      const res = await fetch("/api/upload/kyc-document", {
        method: "POST",
        credentials: "include",
        body: form,
      });
      if (!res.ok) throw new Error("Upload failed");
      const data = await res.json();
      setUrl(data.url);
      toast({ title: `${label} uploaded` });
    } catch (e: any) {
      toast({ title: "Upload failed", description: e?.message || "Try again", variant: "destructive" });
    } finally {
      setUploading(false);
    }
  };

  return (
    <div>
      <Label>{label}</Label>
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        className="hidden"
        onChange={(e) => { const f = e.target.files?.[0]; if (f) onFile(f); }}
        data-testid={`${testId}-input`}
      />
      <div className="flex items-center gap-2 mt-1">
        <Button
          type="button"
          variant={url ? "outline" : "default"}
          onClick={() => inputRef.current?.click()}
          disabled={uploading}
          data-testid={`${testId}-button`}
          className="flex-shrink-0"
        >
          {uploading ? <Loader2 className="h-4 w-4 mr-1.5 animate-spin" /> : <Upload className="h-4 w-4 mr-1.5" />}
          {url ? "Replace" : "Upload"}
        </Button>
        {url && (
          <span className="text-xs text-emerald-400 flex items-center gap-1 truncate" data-testid={`${testId}-status`}>
            <CheckCircle2 className="h-3.5 w-3.5" /> Uploaded
          </span>
        )}
      </div>
    </div>
  );
}
