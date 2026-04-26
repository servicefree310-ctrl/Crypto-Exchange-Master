import { Link } from "wouter";
import {
  Twitter,
  Send,
  Github,
  Youtube,
  Instagram,
  Mail,
  Shield,
  Lock,
  Award,
  Globe2,
} from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

type LinkItem = { label: string; href: string; external?: boolean };

const COLUMNS: { title: string; links: LinkItem[] }[] = [
  {
    title: "Products",
    links: [
      { label: "Spot trading", href: "/trade" },
      { label: "Perpetual futures", href: "/futures" },
      { label: "Markets", href: "/markets" },
      { label: "Wallet", href: "/wallet" },
      { label: "Portfolio", href: "/portfolio" },
    ],
  },
  {
    title: "Company",
    links: [
      { label: "About Zebvix", href: "/about" },
      { label: "Careers", href: "/careers" },
      { label: "Blog", href: "/blog" },
      { label: "Press", href: "/press" },
      { label: "Contact", href: "/contact" },
    ],
  },
  {
    title: "Support",
    links: [
      { label: "Help center", href: "/help" },
      { label: "Submit a request", href: "/support" },
      { label: "API documentation", href: "/docs/api" },
      { label: "Fee schedule", href: "/fees" },
      { label: "System status", href: "/status" },
    ],
  },
  {
    title: "Legal",
    links: [
      { label: "Terms of service", href: "/legal/terms" },
      { label: "Privacy policy", href: "/legal/privacy" },
      { label: "Risk disclosure", href: "/legal/risk" },
      { label: "AML / KYC policy", href: "/legal/aml" },
      { label: "Cookies", href: "/legal/cookies" },
    ],
  },
];

const SOCIALS: { label: string; href: string; icon: React.ReactNode }[] = [
  { label: "Twitter", href: "https://twitter.com/", icon: <Twitter className="h-4 w-4" /> },
  { label: "Telegram", href: "https://telegram.org/", icon: <Send className="h-4 w-4" /> },
  { label: "Instagram", href: "https://instagram.com/", icon: <Instagram className="h-4 w-4" /> },
  { label: "YouTube", href: "https://youtube.com/", icon: <Youtube className="h-4 w-4" /> },
  { label: "GitHub", href: "https://github.com/", icon: <Github className="h-4 w-4" /> },
];

export function AppFooter() {
  return (
    <footer className="mt-auto border-t border-border bg-gradient-to-b from-card/40 to-card/80">
      {/* ── Top: Newsletter strip ─────────────────────────────── */}
      <div className="border-b border-border/60">
        <div className="container mx-auto px-4 py-8 flex flex-col md:flex-row items-start md:items-center gap-6 justify-between">
          <div>
            <h3 className="text-lg font-bold">Stay in the market</h3>
            <p className="text-sm text-muted-foreground mt-1">
              Get weekly market briefings, new listings and product updates — straight to your inbox.
            </p>
          </div>
          <form
            className="flex w-full md:w-auto md:min-w-[420px] gap-2"
            onSubmit={(e) => e.preventDefault()}
          >
            <div className="relative flex-1">
              <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                type="email"
                placeholder="you@example.com"
                className="pl-9 bg-background border-border"
                aria-label="Email address"
              />
            </div>
            <Button type="submit" className="bg-primary text-primary-foreground hover:bg-primary/90 px-6">
              Subscribe
            </Button>
          </form>
        </div>
      </div>

      {/* ── Middle: Brand + columns ───────────────────────────── */}
      <div className="container mx-auto px-4 py-12 grid gap-10 md:grid-cols-12">
        {/* Brand block */}
        <div className="md:col-span-4 lg:col-span-4 space-y-4">
          <Link href="/" className="inline-flex items-center gap-2">
            <span className="h-9 w-9 rounded-xl bg-gradient-to-br from-amber-400 to-orange-600 text-black font-extrabold text-lg flex items-center justify-center shadow-lg">
              Z
            </span>
            <span className="text-xl font-extrabold tracking-tight">
              Zebvix<span className="text-primary">.</span>
            </span>
          </Link>
          <p className="text-sm text-muted-foreground max-w-sm leading-relaxed">
            India's pro-grade crypto exchange — built on its own L1 chain. Spot &amp; perpetual futures,
            ZBX-20 smart contracts, native DEX &amp; bridge, all powered by Zebvix L1
            <span className="text-foreground/80"> (chain 7878)</span>.
          </p>

          {/* Trust badges */}
          <div className="flex flex-wrap gap-2 pt-2">
            <TrustBadge icon={<Shield className="h-3 w-3" />} text="ISO 27001" />
            <TrustBadge icon={<Lock className="h-3 w-3" />} text="SOC 2 Type II" />
            <TrustBadge icon={<Award className="h-3 w-3" />} text="FIU-IND registered" />
          </div>

          {/* Socials */}
          <div className="flex gap-2 pt-3">
            {SOCIALS.map((s) => (
              <a
                key={s.label}
                href={s.href}
                target="_blank"
                rel="noreferrer noopener"
                aria-label={s.label}
                className="h-9 w-9 rounded-lg border border-border bg-background/60 text-muted-foreground hover:text-primary hover:border-primary/50 flex items-center justify-center transition-colors"
              >
                {s.icon}
              </a>
            ))}
          </div>
        </div>

        {/* Link columns */}
        <div className="md:col-span-8 lg:col-span-8 grid grid-cols-2 sm:grid-cols-4 gap-6">
          {COLUMNS.map((col) => (
            <div key={col.title}>
              <h4 className="text-xs font-bold uppercase tracking-wider text-foreground/90 mb-3">
                {col.title}
              </h4>
              <ul className="space-y-2.5">
                {col.links.map((l) => (
                  <li key={l.label}>
                    <Link
                      href={l.href}
                      className="text-sm text-muted-foreground hover:text-primary transition-colors"
                    >
                      {l.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </div>

      {/* ── Risk disclaimer ───────────────────────────────────── */}
      <div className="border-t border-border/60">
        <div className="container mx-auto px-4 py-5 text-[11px] leading-relaxed text-muted-foreground">
          <strong className="text-foreground/90">Risk warning:</strong> Crypto-asset trading is subject to
          high market risk and price volatility. The value of your investment can go down as well as up,
          and you may not get back the amount you invested. Trading derivatives such as perpetual futures
          carries additional risk and can result in the loss of all of your collateral. You are solely
          responsible for your trading decisions and Zebvix is not liable for any losses you may incur.
        </div>
      </div>

      {/* ── Bottom strip ──────────────────────────────────────── */}
      <div className="border-t border-border bg-background/60">
        <div className="container mx-auto px-4 py-4 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-muted-foreground">
          <div>© {new Date().getFullYear()} Zebvix Technologies Pvt Ltd. All rights reserved.</div>
          <div className="flex items-center gap-4">
            <span className="inline-flex items-center gap-1.5">
              <span className="h-1.5 w-1.5 rounded-full bg-success animate-pulse" />
              All systems operational
            </span>
            <span className="inline-flex items-center gap-1.5">
              <Globe2 className="h-3 w-3" />
              English (IN)
            </span>
          </div>
        </div>
      </div>
    </footer>
  );
}

function TrustBadge({ icon, text }: { icon: React.ReactNode; text: string }) {
  return (
    <span className="inline-flex items-center gap-1.5 px-2 py-1 rounded-md border border-border bg-background/40 text-[11px] text-muted-foreground">
      <span className="text-primary">{icon}</span>
      {text}
    </span>
  );
}
