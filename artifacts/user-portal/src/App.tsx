import { Switch, Route, Router as WouterRouter } from "wouter";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { AuthProvider, RequireAuth } from "@/lib/auth";
import { AppShell } from "@/components/layout/AppShell";

import Home from "@/pages/Home";
import Markets from "@/pages/Markets";
import Trade from "@/pages/Trade";
import Futures from "@/pages/Futures";
import Wallet from "@/pages/Wallet";
import Orders from "@/pages/Orders";
import Portfolio from "@/pages/Portfolio";
import Login from "@/pages/Login";
import Signup from "@/pages/Signup";
import Profile from "@/pages/Profile";
import Kyc from "@/pages/Kyc";
import Banks from "@/pages/Banks";
import Settings from "@/pages/Settings";
import Earn from "@/pages/Earn";
import NotFound from "@/pages/not-found";

const queryClient = new QueryClient();

function App() {
  return (
    <AuthProvider>
      <QueryClientProvider client={queryClient}>
        <TooltipProvider>
          <WouterRouter base={import.meta.env.BASE_URL.replace(/\/$/, "")}>
            <AppShell>
              <Switch>
                <Route path="/" component={Home} />
                <Route path="/markets" component={Markets} />
                <Route path="/trade/:symbol?" component={Trade} />
                <Route path="/futures/:symbol?" component={Futures} />
                
                <Route path="/wallet">
                  {() => <RequireAuth><Wallet /></RequireAuth>}
                </Route>
                <Route path="/orders">
                  {() => <RequireAuth><Orders /></RequireAuth>}
                </Route>
                <Route path="/portfolio">
                  {() => <RequireAuth><Portfolio /></RequireAuth>}
                </Route>
                <Route path="/profile">
                  {() => <RequireAuth><Profile /></RequireAuth>}
                </Route>
                <Route path="/kyc">
                  {() => <RequireAuth><Kyc /></RequireAuth>}
                </Route>
                <Route path="/banks">
                  {() => <RequireAuth><Banks /></RequireAuth>}
                </Route>
                <Route path="/settings">
                  {() => <RequireAuth><Settings /></RequireAuth>}
                </Route>
                <Route path="/earn">
                  {() => <Earn />}
                </Route>

                <Route path="/login" component={Login} />
                <Route path="/signup" component={Signup} />
                
                <Route component={NotFound} />
              </Switch>
            </AppShell>
            <Toaster />
          </WouterRouter>
        </TooltipProvider>
      </QueryClientProvider>
    </AuthProvider>
  );
}

export default App;
