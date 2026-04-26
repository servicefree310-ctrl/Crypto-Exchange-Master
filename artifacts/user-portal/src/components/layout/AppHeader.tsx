import { Link, useLocation } from "wouter";
import { useAuth } from "@/lib/auth";
import { Button } from "@/components/ui/button";

export function AppHeader() {
  const { user, logout } = useAuth();
  const [location] = useLocation();

  return (
    <header className="border-b border-border bg-card">
      <div className="container mx-auto px-4 h-14 flex items-center justify-between">
        <div className="flex items-center gap-6">
          <Link href="/" className="flex items-center gap-2 font-bold text-xl">
            <span className="h-7 w-7 rounded-lg bg-gradient-to-br from-amber-400 to-orange-600 text-black font-extrabold text-sm flex items-center justify-center shadow-md">
              Z
            </span>
            <span className="tracking-tight">
              Zebvix<span className="text-primary">.</span>
            </span>
          </Link>
          <nav className="hidden md:flex items-center gap-4 text-sm">
            <Link href="/markets" className={location === "/markets" ? "text-primary" : "text-muted-foreground hover:text-foreground"}>Markets</Link>
            <Link href="/trade" className={location.startsWith("/trade") ? "text-primary" : "text-muted-foreground hover:text-foreground"}>Trade</Link>
            <Link href="/futures" className={location.startsWith("/futures") ? "text-primary" : "text-muted-foreground hover:text-foreground"}>Futures</Link>
            {user && (
              <>
                <Link href="/wallet" className={location === "/wallet" ? "text-primary" : "text-muted-foreground hover:text-foreground"}>Wallet</Link>
                <Link href="/orders" className={location === "/orders" ? "text-primary" : "text-muted-foreground hover:text-foreground"}>Orders</Link>
                <Link href="/portfolio" className={location === "/portfolio" ? "text-primary" : "text-muted-foreground hover:text-foreground"}>Portfolio</Link>
              </>
            )}
          </nav>
        </div>
        <div className="flex items-center gap-4">
          {user ? (
            <div className="flex items-center gap-4">
              <Link href="/profile" className="text-sm hover:text-primary">{user.fullName}</Link>
              <Button variant="ghost" size="sm" onClick={logout}>Logout</Button>
            </div>
          ) : (
            <div className="flex items-center gap-2">
              <Button variant="ghost" size="sm" asChild>
                <Link href="/login">Log In</Link>
              </Button>
              <Button size="sm" className="bg-primary text-primary-foreground hover:bg-primary/90" asChild>
                <Link href="/signup">Sign Up</Link>
              </Button>
            </div>
          )}
        </div>
      </div>
    </header>
  );
}
