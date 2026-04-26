import { useLocation } from "wouter";
import { AppHeader } from "./AppHeader";
import { AppFooter } from "./AppFooter";

export function AppShell({ children }: { children: React.ReactNode }) {
  const [location] = useLocation();
  const isAuthPage = location === "/login" || location === "/signup";

  if (isAuthPage) {
    return <main className="min-h-screen bg-background">{children}</main>;
  }

  return (
    <div className="min-h-screen flex flex-col bg-background text-foreground">
      <AppHeader />
      <main className="flex-1 flex flex-col">{children}</main>
      <AppFooter />
    </div>
  );
}
