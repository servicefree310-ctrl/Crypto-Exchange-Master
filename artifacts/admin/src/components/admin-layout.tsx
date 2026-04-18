import { type ReactNode } from "react";
import { Link, useLocation } from "wouter";
import {
  LayoutDashboard, Users, Coins as CoinsIcon, Network, ArrowLeftRight, Wallet, ShieldCheck,
  Banknote, ArrowDownToLine, ArrowUpFromLine, Bitcoin, Landmark, PiggyBank,
  FileText, Settings as SettingsIcon, Activity, MessageSquare, KeyRound, LogOut, Menu
} from "lucide-react";
import { useAuth } from "@/lib/auth";
import { Button } from "@/components/ui/button";
import { Avatar, AvatarFallback } from "@/components/ui/avatar";
import { useState } from "react";
import { cn } from "@/lib/utils";

const NAV = [
  { href: "/dashboard", label: "Dashboard", icon: LayoutDashboard, roles: ["support", "admin", "superadmin"] },
  { href: "/users", label: "Users", icon: Users, roles: ["support", "admin", "superadmin"] },
  { href: "/kyc", label: "KYC Reviews", icon: ShieldCheck, roles: ["support", "admin", "superadmin"] },
  { href: "/banks", label: "Bank Approvals", icon: Landmark, roles: ["support", "admin", "superadmin"] },
  { href: "/coins", label: "Coins", icon: CoinsIcon, roles: ["support", "admin", "superadmin"] },
  { href: "/networks", label: "Networks", icon: Network, roles: ["support", "admin", "superadmin"] },
  { href: "/pairs", label: "Trading Pairs", icon: ArrowLeftRight, roles: ["support", "admin", "superadmin"] },
  { href: "/gateways", label: "Payment Gateways", icon: Wallet, roles: ["support", "admin", "superadmin"] },
  { href: "/inr-deposits", label: "INR Deposits", icon: ArrowDownToLine, roles: ["support", "admin", "superadmin"] },
  { href: "/inr-withdrawals", label: "INR Withdrawals", icon: ArrowUpFromLine, roles: ["support", "admin", "superadmin"] },
  { href: "/crypto-deposits", label: "Crypto Deposits", icon: Bitcoin, roles: ["support", "admin", "superadmin"] },
  { href: "/crypto-withdrawals", label: "Crypto Withdrawals", icon: Banknote, roles: ["support", "admin", "superadmin"] },
  { href: "/earn", label: "Earn Products", icon: PiggyBank, roles: ["support", "admin", "superadmin"] },
  { href: "/legal", label: "Legal CMS", icon: FileText, roles: ["support", "admin", "superadmin"] },
  { href: "/chat", label: "Live Chat", icon: MessageSquare, roles: ["support", "admin", "superadmin"] },
  { href: "/login-logs", label: "Login Logs", icon: Activity, roles: ["support", "admin", "superadmin"] },
  { href: "/otp-providers", label: "OTP Providers", icon: KeyRound, roles: ["admin", "superadmin"] },
  { href: "/settings", label: "Settings", icon: SettingsIcon, roles: ["admin", "superadmin"] },
];

export function AdminLayout({ children }: { children: ReactNode }) {
  const { user, logout } = useAuth();
  const [location] = useLocation();
  const [open, setOpen] = useState(false);

  const items = NAV.filter((n) => !user || n.roles.includes(user.role));

  return (
    <div className="min-h-screen flex bg-background text-foreground">
      <aside className={cn(
        "fixed lg:static inset-y-0 left-0 z-40 w-64 bg-sidebar border-r border-sidebar-border flex flex-col transition-transform",
        open ? "translate-x-0" : "-translate-x-full lg:translate-x-0"
      )}>
        <div className="px-5 py-4 border-b border-sidebar-border">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-md bg-primary flex items-center justify-center">
              <span className="text-primary-foreground font-bold text-lg">X</span>
            </div>
            <div>
              <div className="font-bold text-sidebar-foreground leading-tight">CryptoX</div>
              <div className="text-xs text-muted-foreground leading-tight">Admin Panel</div>
            </div>
          </div>
        </div>
        <nav className="flex-1 overflow-y-auto py-3 px-2 space-y-0.5">
          {items.map((it) => {
            const active = location === it.href;
            const Icon = it.icon;
            return (
              <Link key={it.href} href={it.href} onClick={() => setOpen(false)}>
                <a className={cn(
                  "flex items-center gap-3 px-3 py-2 rounded-md text-sm hover-elevate transition-colors",
                  active
                    ? "bg-sidebar-accent text-sidebar-accent-foreground font-medium"
                    : "text-sidebar-foreground"
                )}>
                  <Icon className="w-4 h-4 shrink-0" />
                  <span className="truncate">{it.label}</span>
                </a>
              </Link>
            );
          })}
        </nav>
        <div className="px-3 py-3 border-t border-sidebar-border">
          <div className="flex items-center gap-2 mb-2">
            <Avatar className="w-8 h-8">
              <AvatarFallback>{(user?.name || user?.email || "?").slice(0,2).toUpperCase()}</AvatarFallback>
            </Avatar>
            <div className="flex-1 min-w-0">
              <div className="text-sm font-medium truncate text-sidebar-foreground">{user?.name || user?.email}</div>
              <div className="text-xs text-muted-foreground capitalize">{user?.role}</div>
            </div>
          </div>
          <Button variant="ghost" size="sm" className="w-full justify-start" onClick={logout}>
            <LogOut className="w-4 h-4 mr-2" /> Logout
          </Button>
        </div>
      </aside>

      <div className="flex-1 flex flex-col min-w-0">
        <header className="h-14 border-b border-border flex items-center px-4 lg:px-6 gap-3 bg-card">
          <Button variant="ghost" size="icon" className="lg:hidden" onClick={() => setOpen(!open)}>
            <Menu className="w-5 h-5" />
          </Button>
          <h1 className="text-base font-semibold">{items.find((i) => i.href === location)?.label || "Admin"}</h1>
        </header>
        <main className="flex-1 overflow-y-auto p-4 lg:p-6">
          {children}
        </main>
      </div>
    </div>
  );
}
