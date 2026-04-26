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
  Menu,
  X,
  ChevronDown,
  User as UserIcon,
  LogOut,
  Settings,
  Shield,
  Gift,
  Sparkles,
  Layers,
  Construction,
  Coins,
  Users,
  ArrowLeftRight,
} from "lucide-react";
import { useAuth } from "@/lib/auth";
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
  { href: "/earn", label: "Earn", icon: Coins, match: (l) => l.startsWith("/earn"), badge: "NEW", badgeTone: "new", priority: 1 },
  { href: "/p2p", label: "P2P", icon: Users, match: (l) => l.startsWith("/p2p"), priority: 2 },
  { href: "/convert", label: "Convert", icon: ArrowLeftRight, match: (l) => l.startsWith("/convert"), priority: 2 },
];

const userNavItems: NavItem[] = [
  { href: "/wallet", label: "Wallet", icon: WalletIcon, match: (l) => l === "/wallet", priority: 2 },
  { href: "/portfolio", label: "Portfolio", icon: PieChart, match: (l) => l === "/portfolio", priority: 3 },
];

export function AppHeader() {
  const { user, logout } = useAuth();
  const [location] = useLocation();
  const [mode, setMode] = useState<Mode>("exchange");
  const [mobileOpen, setMobileOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 8);
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

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

  const items = user ? [...navItems, ...userNavItems] : navItems;

  return (
    <header
      className={`sticky top-0 z-40 transition-all duration-300 ${
        scrolled
          ? "border-b border-border bg-card/80 backdrop-blur-xl shadow-sm"
          : "border-b border-border/50 bg-card/60 backdrop-blur-md"
      }`}
    >
      <div className="container mx-auto px-3 sm:px-4 h-16 flex items-center justify-between gap-2 sm:gap-4">
        {/* ── Left: logo + mode switcher + nav ─────────────── */}
        <div className="flex items-center gap-3 sm:gap-5 min-w-0">
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
          <nav className="hidden lg:flex items-center gap-0.5 xl:gap-1 text-sm min-w-0">
            {items.map((item) => {
              const Icon = item.icon;
              const active = item.match(location);
              const visibility =
                item.priority === 1
                  ? "inline-flex"
                  : item.priority === 2
                  ? "hidden xl:inline-flex"
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
                    <span className="absolute -bottom-[5px] left-1/2 -translate-x-1/2 h-0.5 w-6 rounded-full bg-primary" />
                  )}
                </Link>
              );
            })}
          </nav>
        </div>

        {/* ── Right: search + actions ─────────────── */}
        <div className="flex items-center gap-1.5 sm:gap-2">
          {/* Quick search — full box only at 2xl+ (avoids cramping the 6-item nav at xl) */}
          <Link
            href="/markets"
            className="hidden 2xl:flex items-center gap-2 h-9 px-3 rounded-md bg-muted/50 border border-border text-xs text-muted-foreground hover:bg-muted hover:text-foreground transition-colors w-56 flex-shrink min-w-0"
          >
            <Search className="h-3.5 w-3.5 flex-shrink-0" />
            <span className="flex-1 text-left truncate">Search markets…</span>
            <kbd className="inline-flex h-5 items-center gap-0.5 rounded border border-border bg-background px-1.5 font-mono text-[10px] font-medium text-muted-foreground">
              ⌘K
            </kbd>
          </Link>

          {/* Search icon — shown whenever the full box is hidden */}
          <Button asChild variant="ghost" size="icon" className="2xl:hidden h-9 w-9 flex-shrink-0">
            <Link href="/markets" aria-label="Search markets">
              <Search className="h-4 w-4" />
            </Link>
          </Button>

          {user ? (
            <>
              {/* Notifications */}
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" size="icon" className="relative h-9 w-9">
                    <Bell className="h-4 w-4" />
                    <span className="absolute top-1.5 right-1.5 h-2 w-2 rounded-full bg-rose-500 ring-2 ring-card" />
                  </Button>
                </DropdownMenuTrigger>
                <DropdownMenuContent align="end" className="w-80">
                  <DropdownMenuLabel className="flex items-center justify-between">
                    <span>Notifications</span>
                    <Badge variant="outline" className="text-[9px] h-4">3 new</Badge>
                  </DropdownMenuLabel>
                  <DropdownMenuSeparator />
                  <div className="max-h-80 overflow-y-auto">
                    <NotificationItem
                      icon={<TrendingUp className="h-4 w-4 text-emerald-400" />}
                      title="ZBX/USDT order filled"
                      desc="Your buy order for 1,200 ZBX at $1.348 was filled."
                      time="2m ago"
                    />
                    <NotificationItem
                      icon={<Gift className="h-4 w-4 text-amber-400" />}
                      title="Welcome bonus credited"
                      desc="You received 50 ZBX as part of your welcome bonus."
                      time="1h ago"
                    />
                    <NotificationItem
                      icon={<Shield className="h-4 w-4 text-sky-400" />}
                      title="New device login"
                      desc="A login from Mumbai, IN was approved on your account."
                      time="3h ago"
                    />
                  </div>
                  <DropdownMenuSeparator />
                  <DropdownMenuItem asChild className="justify-center text-xs text-primary font-medium">
                    <Link href="/profile">View all notifications</Link>
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>

              {/* User menu */}
              <DropdownMenu>
                <DropdownMenuTrigger asChild>
                  <Button variant="ghost" className="h-9 px-2 gap-2 hidden sm:inline-flex">
                    <span className="h-7 w-7 rounded-full bg-gradient-to-br from-amber-500 to-orange-600 text-white text-xs font-extrabold flex items-center justify-center">
                      {(user.fullName || user.email || "U").charAt(0).toUpperCase()}
                    </span>
                    <span className="text-sm font-medium max-w-[7rem] truncate">{user.fullName || user.email}</span>
                    <ChevronDown className="h-3.5 w-3.5 text-muted-foreground" />
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
                    <Link href="/profile" className="cursor-pointer">
                      <Settings className="h-4 w-4 mr-2" /> Settings
                    </Link>
                  </DropdownMenuItem>
                  <DropdownMenuItem onClick={logout} className="cursor-pointer text-rose-500 focus:text-rose-500">
                    <LogOut className="h-4 w-4 mr-2" /> Log out
                  </DropdownMenuItem>
                </DropdownMenuContent>
              </DropdownMenu>
            </>
          ) : (
            <div className="hidden sm:flex items-center gap-1.5">
              <Button variant="ghost" size="sm" asChild>
                <Link href="/login">Log In</Link>
              </Button>
              <Button
                size="sm"
                className="bg-gradient-to-r from-amber-500 to-orange-500 text-black hover:from-amber-400 hover:to-orange-400 font-semibold shadow-md shadow-amber-500/20"
                asChild
              >
                <Link href="/signup">
                  <Sparkles className="h-3.5 w-3.5 mr-1" /> Sign Up
                </Link>
              </Button>
            </div>
          )}

          {/* Mobile menu trigger */}
          <Sheet open={mobileOpen} onOpenChange={setMobileOpen}>
            <SheetTrigger asChild>
              <Button variant="ghost" size="icon" className="lg:hidden h-9 w-9">
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
                ) : (
                  <>
                    <Button variant="outline" className="w-full" asChild>
                      <Link href="/login" onClick={() => setMobileOpen(false)}>Log In</Link>
                    </Button>
                    <Button
                      className="w-full bg-gradient-to-r from-amber-500 to-orange-500 text-black hover:from-amber-400 hover:to-orange-400 font-semibold"
                      asChild
                    >
                      <Link href="/signup" onClick={() => setMobileOpen(false)}>
                        <Sparkles className="h-3.5 w-3.5 mr-1" /> Sign Up
                      </Link>
                    </Button>
                  </>
                )}
              </div>
            </SheetContent>
          </Sheet>
        </div>
      </div>
    </header>
  );
}

function NotificationItem({
  icon,
  title,
  desc,
  time,
}: {
  icon: React.ReactNode;
  title: string;
  desc: string;
  time: string;
}) {
  return (
    <div className="px-3 py-2.5 hover:bg-muted/50 cursor-pointer">
      <div className="flex items-start gap-2.5">
        <div className="h-8 w-8 rounded-lg bg-muted flex items-center justify-center flex-shrink-0">{icon}</div>
        <div className="flex-1 min-w-0">
          <div className="text-sm font-semibold truncate">{title}</div>
          <div className="text-xs text-muted-foreground line-clamp-2 leading-snug">{desc}</div>
          <div className="text-[10px] text-muted-foreground mt-0.5">{time}</div>
        </div>
      </div>
    </div>
  );
}
