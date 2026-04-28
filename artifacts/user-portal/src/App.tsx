import { Switch, Route, Router as WouterRouter } from "wouter";
import { QueryClient, QueryClientProvider, QueryErrorResetBoundary } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { AuthProvider, RequireAuth } from "@/lib/auth";
import { AppShell } from "@/components/layout/AppShell";
import { ErrorBoundary } from "@/components/ErrorBoundary";

import Home from "@/pages/Home";
import Markets from "@/pages/Markets";
import Trade from "@/pages/Trade";
import Futures from "@/pages/Futures";
import Wallet from "@/pages/Wallet";
import Orders from "@/pages/Orders";
import Invoice from "@/pages/Invoice";
import Portfolio from "@/pages/Portfolio";
import Login from "@/pages/Login";
import Signup from "@/pages/Signup";
import Profile from "@/pages/Profile";
import Kyc from "@/pages/Kyc";
import Banks from "@/pages/Banks";
import Settings from "@/pages/Settings";
import Earn from "@/pages/Earn";
import Invite from "@/pages/Invite";
import Support from "@/pages/Support";
import About from "@/pages/About";
import Terms from "@/pages/Terms";
import Privacy from "@/pages/Privacy";
import Aml from "@/pages/Aml";
import Cookies from "@/pages/Cookies";
import Risk from "@/pages/Risk";
import Fees from "@/pages/Fees";
import ApiDocs from "@/pages/ApiDocs";
import Careers from "@/pages/Careers";
import Blog from "@/pages/Blog";
import Press from "@/pages/Press";
import Contact from "@/pages/Contact";
import Help from "@/pages/Help";
import Status from "@/pages/Status";
import P2P from "@/pages/P2P";
import Convert from "@/pages/Convert";
import Calculator from "@/pages/tools/Calculator";
import Converter from "@/pages/tools/Converter";
import Compare from "@/pages/tools/Compare";
import Predictions from "@/pages/tools/Predictions";
import Announcements from "@/pages/Announcements";
import News from "@/pages/News";
import Leagues from "@/pages/Leagues";
import SupportChatWidget from "@/components/SupportChatWidget";
import NotFound from "@/pages/not-found";

const queryClient = new QueryClient();

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <QueryErrorResetBoundary>
        {({ reset }) => (
          <ErrorBoundary onReset={reset}>
            <AuthProvider>
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
                <Route path="/orders/:id/invoice">
                  {() => <RequireAuth><Invoice /></RequireAuth>}
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
                <Route path="/invite">
                  {() => <RequireAuth><Invite /></RequireAuth>}
                </Route>
                <Route path="/support">
                  {() => <RequireAuth><Support /></RequireAuth>}
                </Route>

                <Route path="/about" component={About} />
                <Route path="/legal/terms" component={Terms} />
                <Route path="/legal/privacy" component={Privacy} />
                <Route path="/legal/aml" component={Aml} />
                <Route path="/legal/cookies" component={Cookies} />
                <Route path="/legal/risk" component={Risk} />
                <Route path="/fees" component={Fees} />
                <Route path="/docs/api" component={ApiDocs} />
                <Route path="/careers" component={Careers} />
                <Route path="/blog" component={Blog} />
                <Route path="/press" component={Press} />
                <Route path="/contact" component={Contact} />
                <Route path="/help" component={Help} />
                <Route path="/status" component={Status} />
                <Route path="/p2p" component={P2P} />
                <Route path="/convert" component={Convert} />

                <Route path="/tools/calculator" component={Calculator} />
                <Route path="/tools/converter" component={Converter} />
                <Route path="/tools/compare" component={Compare} />
                <Route path="/tools/predictions" component={Predictions} />
                <Route path="/announcements" component={Announcements} />
                <Route path="/news" component={News} />
                <Route path="/leagues" component={Leagues} />

                <Route path="/login" component={Login} />
                <Route path="/signup" component={Signup} />
                
                <Route component={NotFound} />
              </Switch>
            </AppShell>
            <SupportChatWidget />
            <Toaster />
          </WouterRouter>
              </TooltipProvider>
            </AuthProvider>
          </ErrorBoundary>
        )}
      </QueryErrorResetBoundary>
    </QueryClientProvider>
  );
}

export default App;
