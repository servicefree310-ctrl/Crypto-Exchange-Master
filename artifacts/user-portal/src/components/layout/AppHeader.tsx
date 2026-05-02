import { useState, useEffect } from "react";
import { Link, useLocation } from "wouter";
import {
  BarChart3,
  TrendingUp,
  Zap,
  Wallet as WalletIcon,
  ListOrdered,
  PieChart,
  Search,
  Bell,
  BellRing,
  Menu,
  X,
  User as UserIcon,
  LogOut,
  Settings,
  Shield,
  Gift,
  LifeBuoy,
  Sparkles,
  Layers,
  Construction,
  Coins,
  Users,
  ArrowLeftRight,
  Globe,
  Check,
  ChevronDown,
  Calculator as CalculatorIcon,
  GitCompare,
  LineChart,
  Repeat,
  Megaphone,
  Trophy,
  Wrench,
  Compass,
  Sigma,
  Globe2,
  Radar,
  Bot as BotIcon,
  Star,
  LayoutDashboard,
  AlertTriangle,
  CheckCircle2,
  XCircle,
  Info,
  CheckCheck,
  MoreHorizontal,
  type LucideIcon,
} from "lucide-react";
import { useAuth } from "@/lib/auth";
import { useFeatures } from "@/lib/siteConfig";
import { useQuery } from "@tanstack/react-query";
import { get } from "@/lib/api";
import { Button } from "@/components/ui/button";
import { Badge } from "@/components/ui/badge";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import {
  Sheet,
  SheetContent,
  SheetTrigger,
} from "@/components/ui/sheet";
import { toast } from "@/hooks/use-toast";

type Mode = "exchange" | "dex";

type Language = {
  code: string;
  label: string;
  native: string;
  flag: string;
};

const LANGUAGES: Language[] = [
  { code: "en", label: "English", native: "English", flag: "🇬🇧" },
  { code: "hi", label: "Hindi", native: "हिन्दी", flag: "🇮🇳" },
  { code: "bn", label: "Bengali", native: "বাংলা", flag: "🇮🇳" },
  { code: "ta", label: "Tamil", native: "தமிழ்", flag: "🇮🇳" },
  { code: "te", label: "Telugu", native: "తెలుగు", flag: "🇮🇳" },
  { code: "mr", label: "Marathi", native: "मराठी", flag: "🇮🇳" },
  { code: "gu", label: "Gujarati", native: "ગુજરાતી", flag: "🇮🇳" },
  { code: "es", label: "Spanish", native: "Español", flag: "🇪🇸" },
  { code: "zh", label: "Chinese", native: "中文", flag: "🇨🇳" },
  { code: "ar", label: "Arabic", native: "العربية", flag: "🇸🇦" },
];

const LANG_STORAGE_KEY = "zebvix:lang";

type NavItem = {
  href: string;
  label: string;
  icon: typeof BarChart3;
  match: (l: string) => boolean;
  badge?: string;
  badgeTone?: "hot" | "new";
  priority: number;
};

const navItems: NavItem[] = [
  { href: "/markets", label: "Markets", icon: BarChart3, match: (l) => l === "/markets" || l.startsWith("/markets/"), priority: 1 },
  { href: "/trade", label: "Trade", icon: TrendingUp, match: (l) => l.startsWith("/trade"), priority: 1 },
  { href: "/futures", label: "Futures", icon: Zap, match: (l) => l.startsWith("/futures"), badge: "100×", badgeTone: "hot", priority: 1 },
  { href: "/options", label: "Options", icon: Sigma, match: (l) => l.startsWith("/options"), badge: "NEW", badgeTone: "new", priority: 1 },
  { href: "/web3", label: "Web3", icon: Globe2, match: (l) => l.startsWith("/web3"), badge: "NEW", badgeTone: "new", priority: 2 },
  { href: "/discover", label: "Discover", icon: Radar, match: (l) => l.startsWith("/discover"), badge: "HOT", badgeTone: "hot", priority: 2 },
  { href: "/earn", label: "Earn", icon: Coins, match: (l) => l.startsWith("/earn"), badge: "NEW", badgeTone: "new", priority: 2 },
];

const userNavItems: NavItem[] = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard, match: (l) => l === "/dashboard", badge: "PRO", badgeTone: "new", priority: 2 },
  { href: "/wallet", label: "Wallet", icon: WalletIcon, match: (l) => l === "/wallet", priority: 2 },
  { href: "/bots", label: "Bots", icon: BotIcon, match: (l) => l.startsWith("/bots"), badge: "NEW", badgeTone: "new", priority: 2 },
  { href: "/copy-trading", label: "Copy", icon: Star, match: (l) => l.startsWith("/copy-trading"), priority: 2 },
];

type MoreItem = {
  href: string;
  label: string;
  desc: string;
  icon: LucideIcon;
  badge?: string;
};
type MoreSection = { id: string; label: string; icon: LucideIcon; items: MoreItem[] };

type FeatureGate = (f: ReturnType<typeof useFeatures>) => boolean;
type MoreSectionDef = MoreSection & { gate?: FeatureGate; itemGates?: Record<string, FeatureGate> };

const MORE_MENU: MoreSectionDef[] = [
  {
    id: "trade-extras",
    label: "Trade",
    icon: TrendingUp,
    items: [
      { href: "/p2p",     label: "P2P Trading",     desc: "Buy and sell crypto directly with other users",       icon: Users },
      { href: "/convert", label: "Instant Convert", desc: "One-click swap between any two supported assets",     icon: ArrowLeftRight },
    ],
    itemGates: {
      "/p2p": (f) => f.showP2P,
      "/convert": (f) => f.showConvert,
    },
  },
  {
    id: "tools",
    label: "Tools",
    icon: Wrench,
    gate: (f) => f.showTools,
    items: [
      { href: "/tools/calculator",  label: "Calculator",         desc: "Quickly calculate crypto values and returns", icon: CalculatorIcon },
      { href: "/tools/compare",     label: "Crypto Compare",     desc: "Compare cryptos across prices and metrics",   icon: GitCompare },
      { href: "/tools/predictions", label: "Price Predictions",  desc: "Explore potential future crypto price trends", icon: LineChart },
      { href: "/tools/converter",   label: "Currency Converter", desc: "Convert values between crypto and fiat",      icon: Repeat },
    ],
  },
  {
    id: "promotion",
    label: "Promotion",
    icon: Gift,
    items: [
      { href: "/announcements", label: "Announcements", desc: "Stay updated with the latest news and updates", icon: Megaphone },
      { href: "/news",          label: "News & Insights", desc: "Market analysis, product launches and tutorials", icon: Sparkles },
    ],
    itemGates: {
      "/announcements": (f) => f.showAnnouncements,
      "/news": (f) => f.showNews,
    },
  },
  {
    id: "explore",
    label: "Explore",
    icon: Compass,
    items: [
      { href: "/leagues", label: "Leagues", desc: "Compete and earn rewards in crypto trading contests", icon: Trophy, badge: "NEW" },
    ],
    itemGates: {
      "/leagues": (f) => f.showLeagues,
    },
  },
];

function isMoreActive(loc: string, sections: { items: { href: string }[] }[]): boolean {
  return sections.some((s) => s.items.some((it) => loc.startsWith(it.href)));
}

const NOTIF_KIND_TONE: Record<string, string> = {
  info:    "text-sky-400",
  success: "text-emerald-400",
  warning: "text-amber-400",
  danger:  "text-rose-400",
  promo:   "text-amber-400",
};

function relativeTime(iso: string): string {
  try {
    const ms = Date.now() - new Date(iso).getTime();
    if (ms < 60_000) return "just now";
    if (ms < 3_600_000) return `${Math.floor(ms / 60_000)}m ago`;
    if (ms < 86_400_000) return `${Math.floor(ms / 3_600_000)}h ago`;
    return `${Math.floor(ms / 86_400_000)}d ago`;
  } catch { return ""; }
}

type BroadcastNotif = {
  id: number; title: string; body: string; kind: string;
  ctaLabel: string; ctaUrl: string; createdAt: string;
};

type UserNotif = {
  id: number; title: string; body: string; kind: string; category: string;
  ctaLabel: string | null; ctaUrl: string | null;
  readAt: string | null; createdAt: string;
};

export function AppHeader() {
  const { user, logout } = useAuth();
  const features = useFeatures();
  const [location] = useLocation();
  const [mode, setMode] = useState<Mode>("exchange");
  const [mobileOpen, setMobileOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);
  const [langCode, setLangCode] = useState<string>("en");

  // Public broadcast notifications (visible to guests too)
  const { data: notifs = [] } = useQuery<BroadcastNotif[]>({
    queryKey: ["/content/notifications"],
    queryFn: () => get<BroadcastNotif[]>("/content/notifications"),
    staleTime: 20_000,
    refetchOnWindowFocus: false,
    retry: 1,
  });

  // User-specific inbox: unread count + most recent few (auth users only)
  const { data: unreadCount } = useQuery<{ count: number }>({
    queryKey: ["/notifications/me/unread-count"],
    queryFn: () => get<{ count: number }>("/notifications/me/unread-count"),
    enabled: !!user,
    refetchInterval: 30_000,
    retry: false,
  });
  const { data: userInbox } = useQuery<{ items: UserNotif[] }>({
    queryKey: ["/notifications/me?limit=8"],
    queryFn: () => get<{ items: UserNotif[] }>("/notifications/me?limit=8"),
    enabled: !!user,
    refetchInterval: 30_000,
    retry: false,
  });

  useEffect(() => {
    // Edge-trigger only: avoid setting state on every scroll pixel, which
    // otherwise causes the sticky header to re-render constantly and feel
    // like it's "jumping" as transitions retrigger near the threshold.
    let isScrolled = window.scrollY > 8;
    setScrolled(isScrolled);
    const onScroll = () => {
      const next = window.scrollY > 8;
      if (next !== isScrolled) {
        isScrolled = next;
        setScrolled(next);
      }
    };
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => {
    try {
      const saved = window.localStorage.getItem(LANG_STORAGE_KEY);
      if (saved && LANGUAGES.some((l) => l.code === saved)) setLangCode(saved);
    } catch {
      /* ignore storage errors */
    }
  }, []);

  const currentLang = LANGUAGES.find((l) => l.code === langCode) ?? LANGUAGES[0];

  const handleLanguageChange = (code: string) => {
    const next = LANGUAGES.find((l) => l.code === code);
    if (!next) return;
    setLangCode(code);
    try {
      window.localStorage.setItem(LANG_STORAGE_KEY, code);
    } catch {
      /* ignore storage errors */
    }
    if (code === "en") {
      toast({
        title: `Display language set to ${next.label}`,
        description: "Your preference has been saved.",
      });
    } else {
      toast({
        title: `${next.flag} ${next.native} selected`,
        description: "Full localization is coming soon — your preference is saved.",
      });
    }
  };

  const handleModeChange = (next: Mode) => {
    if (next === "dex") {
      toast({
        title: "Zebvix DEX is under development",
        description:
          "On-chain swaps and AMM liquidity pools on Zebvix Blockchain are coming soon. You'll be the first to know.",
      });
      return;
    }
    setMode(next);
  };

  // Apply feature-flag gating to nav items
  const featureGate: Record<string, boolean> = {
    "/futures": features.showFutures,
    "/earn":    features.showEarn,
  };
  const baseItems = navItems.filter((it) => featureGate[it.href] !== false);
  const items = user ? [...baseItems, ...userNavItems] : baseItems;
  const moreSections = MORE_MENU
    .filter((s) => !s.gate || s.gate(features))
    .map((s) => ({ ...s, items: s.items.filter((it) => !s.itemGates?.[it.href] || s.itemGates[it.href](features)) }))
    .filter((s) => s.items.length > 0);

  return (
    <header
      className={`sticky top-0 left-0 right-0 z-40 border-b backdrop-blur-xl transform-gpu will-change-[background-color,box-shadow] transition-[background-color,box-shadow,border-color] duration-200 ${
        scrolled
          ? "border-border bg-card/85 shadow-sm"
          : "border-border/60 bg-card/70 shadow-none"
      }`}
    >
      <div className="container mx-auto px-3 sm:px-4 h-16 flex items-center justify-between gap-3 sm:gap-4 lg:gap-6 xl:gap-8">
        {/* ── Left: logo + mode switcher + nav ─────────────── */}
        <div className="flex items-center gap-3 sm:gap-5 min-w-0 flex-shrink">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2 font-bold text-xl flex-shrink-0">
            <span className="relative h-8 w-8 rounded-lg bg-gradient-to-br from-amber-400 via-amber-500 to-orange-600 text-black font-extrabold text-sm flex items-center justify-center shadow-lg shadow-amber-500/30">
              Z
              <span className="absolute -bottom-0.5 -right-0.5 h-2 w-2 rounded-full bg-emerald-400 ring-2 ring-card" />
            </span>
            <span className="tracking-tight hidden xs:inline sm:inline">
              Zebvix<span className="text-primary">.</span>
            </span>
          </Link>

          {/* Mode switcher: Exchange / DEX */}
          <div className="hidden md:flex items-center rounded-full bg-muted/60 border border-border p-0.5 flex-shrink-0">
            <button
              type="button"
              onClick={() => handleModeChange("exchange")}
              className={`relative inline-flex items-center gap-1.5 px-3 h-7 rounded-full text-xs font-semibold transition-all ${
                mode === "exchange"
                  ? "bg-gradient-to-r from-amber-500 to-orange-500 text-black shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              }`}
            >
              <BarChart3 className="h-3.5 w-3.5" />
              Exchange
            </button>
            <button
              type="button"
              onClick={() => handleModeChange("dex")}
              className={`relative inline-flex items-center gap-1.5 px-3 h-7 rounded-full text-xs font-semibold transition-all ${
                mode === "dex"
                  ? "bg-gradient-to-r from-violet-500 to-fuchsia-500 text-white shadow-sm"
                  : "text-muted-foreground hover:text-foreground"
              }`}
              aria-label="Switch to DEX (under development)"
            >
              <Layers className="h-3.5 w-3.5" />
              DEX
              <span className="ml-0.5 inline-flex items-center px-1.5 h-4 rounded-full bg-amber-500/20 text-amber-500 text-[9px] font-bold uppercase tracking-wider">
                Soon
              </span>
            </button>
          </div>

          {/* Desktop nav — auto-fits via priority-based progressive disclosure */}
          <nav className="hidden xl:flex items-center gap-0.5 xl:gap-1 text-sm min-w-0">
            {items.map((item) => {
              const Icon = item.icon;
              const active = item.match(location);
              // Nav itself is hidden < xl. priority 1 always shows when the
              // nav is visible; priority 2 only at 2xl+ where there's room.
              // Keeps xl widths (1280–1535) compact: 4–5 items + More button.
              const visibility =
                item.priority === 1
                  ? "inline-flex"
                  : "hidden 2xl:inline-flex";
              const badgeClass =
                item.badgeTone === "new"
                  ? "bg-emerald-500/15 text-emerald-400 border-emerald-500/30 hover:bg-emerald-500/20"
                  : "bg-rose-500/15 text-rose-400 border-rose-500/30 hover:bg-rose-500/20";
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`relative ${visibility} items-center gap-1.5 px-2 xl:px-3 h-9 rounded-md font-medium whitespace-nowrap transition-colors ${
                    active
                      ? "text-primary bg-primary/10"
                      : "text-muted-foreground hover:text-foreground hover:bg-muted/50"
                  }`}
                >
                  <Icon className="h-4 w-4 flex-shrink-0" />
                  {item.label}
                  {item.badge && (
                    <Badge className={`ml-0.5 h-4 px-1.5 text-[9px] font-bold ${badgeClass}`}>
                      {item.badge}
                    </Badge>
                  )}
                  {active && (
                    <span className="absolute bottom-0 left-1/2 -translate-x-1/2 h-0.5 w-6 rounded-full bg-primary" />
                  )}
                </Link>
              );
            })}

            {/* "More" mega menu — Tools / Promotion / Explore */}
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <button
                  type="button"
                  className={`relative inline-flex items-center gap-1 px-2 xl:px-3 h-9 rounded-md font-medium whitespace-nowrap transition-colors ${
                    isMoreActive(location, moreSections)
                      ? "text-primary bg-primary/10"
                      : "text-muted-foreground hover:text-foreground hover:bg-muted/50"
                  }`}
                  aria-label="More menu"
                >
                  More
                  <ChevronDown className="h-3.5 w-3.5" />
                  {isMoreActive(location, moreSections) && (
                    <span className="absolute bottom-0 left-1/2 -translate-x-1/2 h-0.5 w-6 rounded-full bg-primary" />
                  )}
                </button>
              </DropdownMenuTrigger>
              <DropdownMenuContent align="start" className="w-[420px] p-0">
                <div className="grid grid-cols-1 divide-y divide-border">
                  {moreSections.map((section) => {
                    const SectionIcon = section.icon;
                    return (
                      <div key={section.id} className="p-2">
                        <div className="flex items-center gap-1.5 px-2 py-1.5 text-[10px] font-bold uppercase tracking-[0.18em] text-amber-400">
                          <SectionIcon className="h-3 w-3" />
                          {section.label}
                        </div>
                        <div className="space-y-0.5">
                          {section.items.map((item) => {
                            const ItemIcon = item.icon;
                            const active = location.startsWith(item.href);
                            return (
                              <DropdownMenuItem key={item.href} asChild>
                                <Link
                                  href={item.href}
                                  className={`flex items-start gap-3 px-2 py-2 rounded-md cursor-pointer ${
                                    active ? "bg-primary/10" : ""
                                  }`}
                                >
                                  <div className="h-9 w-9 rounded-lg bg-muted/60 border border-border flex items-center justify-center flex-shrink-0">
                                    <ItemIcon className="h-4 w-4 text-amber-400" />
                                  </div>
                                  <div className="flex-1 min-w-0">
                                    <div className="flex items-center gap-1.5">
                                      <span className="text-sm font-semibold text-foreground">{item.label}</span>
                                      {item.badge && (
                                        <Badge className="h-4 px-1.5 text-[9px] font-bold bg-emerald-500/15 text-emerald-400 border-emerald-500/30">
                                          {item.badge}
                                        </Badge>
                                      )}
                                    </div>
                                    <p className="text-[11px] text-muted-foreground leading-snug mt-0.5">
                                      {item.desc}
                                    </p>
                                  </div>
                                </Link>
                              </DropdownMenuItem>
                            );
                          })}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </DropdownMenuContent>
            </DropdownMenu>
          </nav>
        </div>

        {/* ── Right: search + actions ─────────────── */}
        <div className="flex items-center gap-1.5 sm:gap-2">
          {/* Search icon — shown at xl+ (where the full desktop nav is also
              visible). Below xl the Quick Actions dropdown absorbs it. */}
          <Button asChild variant="ghost" size="icon" className="hidden xl:inline-flex h-9 w-9 flex-shrink-0">
            <Link href="/markets" aria-label="Search markets">
              <Search className="h-4 w-4" />
            </Link>
          </Button>

          {/* Quick Actions dropdown — consolidates Search + Language on
              sm → lg widths so the user-panel area never overflows. Hidden
              at xl+ where Search and Language each get their own icon. */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="hidden sm:inline-flex xl:hidden relative h-9 w-9 flex-shrink-0"
                aria-label="Quick actions"
              >
                <MoreHorizontal className="h-4 w-4" />
                <span className="absolute -bottom-0.5 -right-0.5 inline-flex items-center justify-center h-3.5 min-w-[1.05rem] px-1 rounded-full bg-primary text-[8px] font-bold text-primary-foreground uppercase tracking-tight ring-2 ring-card">
                  {currentLang.code}
                </span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-64 p-0">
              <div className="p-1">
                <DropdownMenuItem asChild>
                  <Link href="/markets" className="cursor-pointer">
                    <Search className="h-4 w-4 mr-2 text-muted-foreground" />
                    <span className="flex-1">Search markets</span>
                    <kbd className="inline-flex h-4 items-center rounded border border-border bg-muted/40 px-1 font-mono text-[9px] font-medium text-muted-foreground">
                      ⌘K
                    </kbd>
                  </Link>
                </DropdownMenuItem>
              </div>
              <DropdownMenuSeparator className="my-0" />
              <DropdownMenuLabel className="flex items-center gap-2 px-3 pt-2 pb-1 text-[10px] font-bold uppercase tracking-[0.18em] text-amber-400">
                <Globe className="h-3 w-3" />
                <span>Language · {currentLang.native}</span>
              </DropdownMenuLabel>
              <div className="max-h-64 overflow-y-auto p-1">
                {LANGUAGES.map((lang) => {
                  const active = lang.code === langCode;
                  return (
                    <DropdownMenuItem
                      key={lang.code}
                      onClick={() => handleLanguageChange(lang.code)}
                      className="cursor-pointer flex items-center gap-2"
                    >
                      <span className="text-base leading-none">{lang.flag}</span>
                      <span className="flex-1 flex items-center gap-1.5">
                        <span className="text-sm font-medium">{lang.native}</span>
                        {lang.native !== lang.label && (
                          <span className="text-[10px] text-muted-foreground">({lang.label})</span>
                        )}
                      </span>
                      {active && <Check className="h-4 w-4 text-primary" />}
                    </DropdownMenuItem>
                  );
                })}
              </div>
            </DropdownMenuContent>
          </DropdownMenu>

          {/* Standalone Language switcher — only at xl+ where there's room. */}
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <Button
                variant="ghost"
                size="icon"
                className="hidden xl:inline-flex relative h-9 w-9 flex-shrink-0"
                aria-label={`Language: ${currentLang.label}`}
              >
                <Globe className="h-4 w-4" />
                <span className="absolute -bottom-0.5 -right-0.5 inline-flex items-center justify-center h-3.5 min-w-[1.05rem] px-1 rounded-full bg-primary text-[8px] font-bold text-primary-foreground uppercase tracking-tight ring-2 ring-card">
                  {currentLang.code}
                </span>
              </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" className="w-56">
              <DropdownMenuLabel className="flex items-center gap-2">
                <Globe className="h-4 w-4 text-muted-foreground" />
                <span>Language</span>
              </DropdownMenuLabel>
              <DropdownMenuSeparator />
              <div className="max-h-72 overflow-y-auto">
                {LANGUAGES.map((lang) => {
                  const active = lang.code === langCode;
                  return (
                    <DropdownMenuItem
                      key={lang.code}
                      onClick={() => handleLanguageChange(lang.code)}
                      className="cursor-pointer flex items-center gap-2"
                    >
                      <span className="text-base leading-none">{lang.flag}</span>
                      <span className="flex-1 flex items-center gap-1.5">
                        <span className="text-sm font-medium">{lang.native}</span>
                        {lang.native !== lang.label && (
                          <span className="text-[10px] text-muted-foreground">({lang.label})</span>
                        )}
                      </span>
                      {active && <Check className="h-4 w-4 text-primary" />}
                    </DropdownMenuItem>
                  );
                })}
              </div>
            </DropdownMenuContent>
          </DropdownMenu>

          {/* Notifications — user inbox (auth) + broadcast (everyone) */}
          <NotificationsBell
            broadcasts={notifs}
            inbox={userInbox?.items ?? []}
            unreadCount={unreadCount?.count ?? 0}
            isAuthed={!!user}
          />

          {user ? (
            <>
              {/* User menu — icon-only avatar */}
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button
                    variant="ghost"
                    size="icon"
                    className="hidden sm:inline-flex h-9 w-9 p-0 rounded-full overflow-hidden ring-2 ring-transparent hover:ring-primary/30 focus-visible:ring-primary/40 transition flex-shrink-0"
                    aria-label={`Account: ${user.fullName || user.email}`}
                  >
                    <span className="h-9 w-9 rounded-full bg-gradient-to-br from-amber-500 to-orange-600 text-white text-sm font-extrabold flex items-center justify-center">
                      {(user.fullName || user.email || "U").charAt(0).toUpperCase()}
                    </span>
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-60">
                  <DropdownMenuLabel className="font-normal">
                    <div className="flex flex-col gap-0.5">
                      <span className="text-sm font-semibold truncate">{user.fullName || "Trader"}</span>
                      <span className="text-xs text-muted-foreground truncate">{user.email}</span>
                    </div>
                  </DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem asChild>
                    <Link href="/profile" className="cursor-pointer">
                      <UserIcon className="h-4 w-4 mr-2" /> Profile
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem asChild>
                    <Link href="/wallet" className="cursor-pointer">
                      <WalletIcon className="h-4 w-4 mr-2" /> Wallet
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem asChild>
                    <Link href="/orders" className="cursor-pointer">
                      <ListOrdered className="h-4 w-4 mr-2" /> Orders
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem asChild>
                    <Link href="/portfolio" className="cursor-pointer">
                      <PieChart className="h-4 w-4 mr-2" /> Portfolio
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem asChild>
                    <Link href="/kyc" className="cursor-pointer">
                      <Shield className="h-4 w-4 mr-2" /> KYC Verification
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem asChild>
                    <Link href="/banks" className="cursor-pointer">
                      <Construction className="h-4 w-4 mr-2" /> Bank Accounts
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem asChild>
                    <Link href="/earn" className="cursor-pointer">
                      <Coins className="h-4 w-4 mr-2" /> Earn
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem asChild>
                    <Link href="/invite" className="cursor-pointer">
                      <Gift className="h-4 w-4 mr-2" /> Invite & Earn
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem asChild>
                    <Link href="/support" className="cursor-pointer">
                      <LifeBuoy className="h-4 w-4 mr-2" /> Support & AI Chat
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem asChild>
                    <Link href="/settings" className="cursor-pointer">
                      <Settings className="h-4 w-4 mr-2" /> Settings & 2FA
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem onClick={logout} className="cursor-pointer text-rose-500 focus:text-rose-500">
                    <LogOut className="h-4 w-4 mr-2" /> Log out
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </>
          ) : (features.showLogin || features.showSignup) ? (
            <div className="hidden sm:flex items-center gap-1.5">
              {features.showLogin && (
                <Button variant="ghost" size="sm" asChild>
                  <Link href="/login">Log In</Link>
                </Button>
              )}
              {features.showSignup && (
                <Button
                  size="sm"
                  className="bg-gradient-to-r from-amber-500 to-orange-500 text-black hover:from-amber-400 hover:to-orange-400 font-semibold shadow-md shadow-amber-500/20"
                  asChild
                >
                  <Link href="/signup">
                    <Sparkles className="h-3.5 w-3.5 mr-1" /> Sign Up
                  </Link>
                </Button>
              )}
            </div>
          ) : null}

          {/* Mobile menu trigger */}
          <Sheet open={mobileOpen} onOpenChange={setMobileOpen}>
            <SheetTrigger asChild>
              <Button variant="ghost" size="icon" className="xl:hidden h-9 w-9">
                {mobileOpen ? <X className="h-5 w-5" /> : <Menu className="h-5 w-5" />}
              </Button>
            </SheetTrigger>
            <SheetContent side="right" className="w-[85vw] max-w-sm p-0 flex flex-col bg-card border-border">
              {/* Header inside drawer */}
              <div className="px-4 py-4 border-b border-border flex items-center gap-2">
                <span className="h-8 w-8 rounded-lg bg-gradient-to-br from-amber-400 to-orange-600 text-black font-extrabold text-sm flex items-center justify-center">
                  Z
                </span>
                <span className="font-bold text-lg">Zebvix<span className="text-primary">.</span></span>
              </div>

              {/* Mobile mode switcher */}
              <div className="px-4 pt-4">
                <div className="grid grid-cols-2 gap-2 rounded-xl bg-muted/40 border border-border p-1">
                  <button
                    type="button"
                    onClick={() => handleModeChange("exchange")}
                    className={`inline-flex items-center justify-center gap-1.5 h-9 rounded-lg text-xs font-semibold transition ${
                      mode === "exchange"
                        ? "bg-gradient-to-r from-amber-500 to-orange-500 text-black shadow"
                        : "text-muted-foreground"
                    }`}
                  >
                    <BarChart3 className="h-3.5 w-3.5" /> Exchange
                  </button>
                  <button
                    type="button"
                    onClick={() => {
                      handleModeChange("dex");
                    }}
                    className="relative inline-flex items-center justify-center gap-1.5 h-9 rounded-lg text-xs font-semibold text-muted-foreground"
                  >
                    <Layers className="h-3.5 w-3.5" /> DEX
                    <span className="absolute top-0.5 right-1 inline-flex items-center px-1 h-3.5 rounded-full bg-amber-500/20 text-amber-500 text-[8px] font-bold uppercase">
                      Soon
                    </span>
                  </button>
                </div>
                <p className="mt-2 inline-flex items-center gap-1 text-[10px] text-muted-foreground">
                  <Construction className="h-3 w-3" /> DEX swaps coming soon on Zebvix Blockchain
                </p>
              </div>

              {/* Mobile nav */}
              <nav className="flex-1 overflow-y-auto px-2 py-4 space-y-0.5">
                {items.map((item) => {
                  const Icon = item.icon;
                  const active = item.match(location);
                  return (
                    <Link
                      key={item.href}
                      href={item.href}
                      onClick={() => setMobileOpen(false)}
                      className={`flex items-center gap-3 px-3 h-11 rounded-lg text-sm font-medium transition-colors ${
                        active ? "bg-primary/15 text-primary" : "text-foreground hover:bg-muted/50"
                      }`}
                    >
                      <Icon className="h-4 w-4" />
                      <span className="flex-1">{item.label}</span>
                      {item.badge && (
                        <Badge
                          className={`h-4 px-1.5 text-[9px] font-bold ${
                            item.badgeTone === "new"
                              ? "bg-emerald-500/15 text-emerald-400 border-emerald-500/30"
                              : "bg-rose-500/15 text-rose-400 border-rose-500/30"
                          }`}
                        >
                          {item.badge}
                        </Badge>
                      )}
                    </Link>
                  );
                })}

                {/* Tools / Promotion / Explore sections */}
                {moreSections.map((section) => {
                  const SectionIcon = section.icon;
                  return (
                    <div key={section.id} className="pt-4">
                      <div className="px-3 pb-1.5 flex items-center gap-1.5 text-[10px] font-bold uppercase tracking-[0.18em] text-amber-400">
                        <SectionIcon className="h-3 w-3" />
                        {section.label}
                      </div>
                      {section.items.map((item) => {
                        const ItemIcon = item.icon;
                        const active = location.startsWith(item.href);
                        return (
                          <Link
                            key={item.href}
                            href={item.href}
                            onClick={() => setMobileOpen(false)}
                            className={`flex items-center gap-3 px-3 h-11 rounded-lg text-sm font-medium transition-colors ${
                              active ? "bg-primary/15 text-primary" : "text-foreground hover:bg-muted/50"
                            }`}
                          >
                            <ItemIcon className="h-4 w-4" />
                            <span className="flex-1 truncate">{item.label}</span>
                            {item.badge && (
                              <Badge className="h-4 px-1.5 text-[9px] font-bold bg-emerald-500/15 text-emerald-400 border-emerald-500/30">
                                {item.badge}
                              </Badge>
                            )}
                          </Link>
                        );
                      })}
                    </div>
                  );
                })}
              </nav>

              {/* Drawer footer auth */}
              <div className="border-t border-border p-4 space-y-2">
                {user ? (
                  <>
                    <Link
                      href="/profile"
                      onClick={() => setMobileOpen(false)}
                      className="flex items-center gap-3 p-2 rounded-lg hover:bg-muted/50"
                    >
                      <span className="h-9 w-9 rounded-full bg-gradient-to-br from-amber-500 to-orange-600 text-white text-sm font-extrabold flex items-center justify-center">
                        {(user.fullName || user.email || "U").charAt(0).toUpperCase()}
                      </span>
                      <div className="flex-1 min-w-0">
                        <div className="text-sm font-semibold truncate">{user.fullName || "Trader"}</div>
                        <div className="text-xs text-muted-foreground truncate">{user.email}</div>
                      </div>
                    </Link>
                    <Button variant="outline" className="w-full" onClick={() => { logout(); setMobileOpen(false); }}>
                      <LogOut className="h-4 w-4 mr-2" /> Log out
                    </Button>
                  </>
                ) : (features.showLogin || features.showSignup) ? (
                  <>
                    {features.showLogin && (
                      <Button variant="outline" className="w-full" asChild>
                        <Link href="/login" onClick={() => setMobileOpen(false)}>Log In</Link>
                      </Button>
                    )}
                    {features.showSignup && (
                      <Button
                        className="w-full bg-gradient-to-r from-amber-500 to-orange-500 text-black hover:from-amber-400 hover:to-orange-400 font-semibold"
                        asChild
                      >
                        <Link href="/signup" onClick={() => setMobileOpen(false)}>
                          <Sparkles className="h-3.5 w-3.5 mr-1" /> Sign Up
                        </Link>
                      </Button>
                    )}
                  </>
                ) : null}
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </header>
  );
}

const INBOX_KIND_ICON: Record<string, LucideIcon> = {
  info: Info, success: CheckCircle2, warning: AlertTriangle, danger: XCircle, promo: Gift,
};
const INBOX_KIND_TONE: Record<string, string> = {
  info: "text-sky-400", success: "text-emerald-400", warning: "text-amber-400", danger: "text-rose-400", promo: "text-fuchsia-400",
};

function NotificationsBell({
  broadcasts,
  inbox,
  unreadCount,
  isAuthed,
}: {
  broadcasts: BroadcastNotif[];
  inbox: UserNotif[];
  unreadCount: number;
  isAuthed: boolean;
}) {
  const totalDot = unreadCount > 0 || broadcasts.length > 0;
  return (
    <DropdownMenu>
      <DropdownMenuTrigger asChild>
        <Button variant="ghost" size="icon" className="relative h-9 w-9" aria-label="Notifications">
          {unreadCount > 0 ? <BellRing className="h-4 w-4 text-amber-400" /> : <Bell className="h-4 w-4" />}
          {unreadCount > 0 ? (
            <span className="absolute -top-0.5 -right-0.5 min-w-[16px] h-4 px-1 rounded-full bg-rose-500 text-[9px] font-bold text-white flex items-center justify-center ring-2 ring-card">
              {unreadCount > 99 ? "99+" : unreadCount}
            </span>
          ) : totalDot ? (
            <span className="absolute top-1.5 right-1.5 h-2 w-2 rounded-full bg-rose-500 ring-2 ring-card" />
          ) : null}
        </Button>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-80 p-0">
        <DropdownMenuLabel className="flex items-center justify-between px-3 py-2">
          <span className="text-sm font-bold">Notifications</span>
          {unreadCount > 0 && (
            <Badge variant="outline" className="text-[9px] h-4">
              <CheckCheck className="h-2.5 w-2.5 mr-0.5" /> {unreadCount} unread
            </Badge>
          )}
        </DropdownMenuLabel>
        <DropdownMenuSeparator className="m-0" />

        <div className="max-h-96 overflow-y-auto">
          {/* Personal inbox first */}
          {isAuthed && inbox.length > 0 && (
            <>
              <div className="px-3 pt-2 pb-1 text-[10px] uppercase tracking-wider text-muted-foreground font-bold">Inbox</div>
              {inbox.slice(0, 5).map((n) => {
                const Icon = INBOX_KIND_ICON[n.kind] ?? Bell;
                const tone = INBOX_KIND_TONE[n.kind] ?? "text-amber-400";
                const isUnread = !n.readAt;
                return (
                  <div key={`u${n.id}`} className={isUnread ? "border-l-2 border-primary/50" : ""}>
                    <NotificationItem
                      icon={<Icon className={`h-4 w-4 ${tone}`} />}
                      title={n.title}
                      desc={n.body || ""}
                      time={relativeTime(n.createdAt)}
                      href={n.ctaUrl || "/notifications"}
                    />
                  </div>
                );
              })}
            </>
          )}

          {/* Public broadcasts */}
          {broadcasts.length > 0 && (
            <>
              <div className="px-3 pt-2 pb-1 text-[10px] uppercase tracking-wider text-muted-foreground font-bold">Announcements</div>
              {broadcasts.slice(0, 5).map((n) => {
                const tone = NOTIF_KIND_TONE[n.kind] ?? "text-amber-400";
                const Icon = n.kind === "success" ? Gift : n.kind === "warning" || n.kind === "danger" ? Shield : Bell;
                return (
                  <NotificationItem
                    key={`b${n.id}`}
                    icon={<Icon className={`h-4 w-4 ${tone}`} />}
                    title={n.title}
                    desc={n.body || (n.ctaLabel ? n.ctaLabel : "")}
                    time={relativeTime(n.createdAt)}
                    href={n.ctaUrl || undefined}
                  />
                );
              })}
            </>
          )}

          {(!isAuthed || inbox.length === 0) && broadcasts.length === 0 && (
            <div className="px-4 py-8 text-center text-xs text-muted-foreground">
              <Bell className="h-6 w-6 mx-auto mb-2 opacity-40" />
              Aap up to date hain. Naya kuch nahi.
            </div>
          )}
        </div>

        <DropdownMenuSeparator className="m-0" />
        <DropdownMenuItem asChild className="justify-center text-xs text-primary font-medium py-2">
          <Link href={isAuthed ? "/notifications" : "/announcements"}>
            View all{isAuthed ? "" : " updates"} →
          </Link>
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}

function NotificationItem({
  icon,
  title,
  desc,
  time,
  href,
}: {
  icon: React.ReactNode;
  title: string;
  desc: string;
  time: string;
  href?: string;
}) {
  const inner = (
    <div className="flex items-start gap-2.5">
      <div className="h-8 w-8 rounded-lg bg-muted flex items-center justify-center flex-shrink-0">{icon}</div>
      <div className="flex-1 min-w-0">
        <div className="text-sm font-semibold truncate">{title}</div>
        <div className="text-xs text-muted-foreground line-clamp-2 leading-snug">{desc}</div>
        <div className="text-[10px] text-muted-foreground mt-0.5">{time}</div>
      </div>
    </div>
  );
  if (href) {
    return /^https?:\/\//.test(href) ? (
      <a href={href} target="_blank" rel="noreferrer noopener" className="block px-3 py-2.5 hover:bg-muted/50 cursor-pointer">{inner}</a>
    ) : (
      <Link href={href} className="block px-3 py-2.5 hover:bg-muted/50 cursor-pointer">{inner}</Link>
    );
  }
  return <div className="px-3 py-2.5 hover:bg-muted/50 cursor-pointer">{inner}</div>;
}
