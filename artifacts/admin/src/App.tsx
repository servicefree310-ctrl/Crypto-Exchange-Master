import { Switch, Route, Router as WouterRouter, Redirect } from "wouter";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { Toaster } from "@/components/ui/toaster";
import { TooltipProvider } from "@/components/ui/tooltip";
import { AuthProvider, useAuth } from "@/lib/auth";
import { AdminLayout } from "@/components/admin-layout";
import LoginPage from "@/pages/login";
import DashboardPage from "@/pages/dashboard";
import UsersPage from "@/pages/users";
import KycPage from "@/pages/kyc";
import KycTemplatesPage from "@/pages/kyc-templates";
import BanksPage from "@/pages/banks";
import CoinsPage from "@/pages/coins";
import NetworksPage from "@/pages/networks";
import PairsPage from "@/pages/pairs";
import GatewaysPage from "@/pages/gateways";
import InrDepositsPage from "@/pages/inr-deposits";
import InrWithdrawalsPage from "@/pages/inr-withdrawals";
import CryptoDepositsPage from "@/pages/crypto-deposits";
import CryptoWithdrawalsPage from "@/pages/crypto-withdrawals";
import EarnPage from "@/pages/earn";
import LegalPage from "@/pages/legal";
import SettingsPage from "@/pages/settings";
import LoginLogsPage from "@/pages/login-logs";
import OtpProvidersPage from "@/pages/otp-providers";
import ChatPage from "@/pages/chat";
import FundingRatesPage from "@/pages/funding-rates";
import FuturesPositionsPage from "@/pages/futures-positions";
import ApiKeysPage from "@/pages/api-keys";
import BotsPage from "@/pages/bots";
import OrdersPage from "@/pages/orders";
import UserAddressesPage from "@/pages/user-addresses";
import BannersPage from "@/pages/banners";
import PromotionsPage from "@/pages/promotions";
import RedisPage from "@/pages/redis";
import BackendStatusPage from "@/pages/backend-status";
import NotFound from "@/pages/not-found";
import { Loader2 } from "lucide-react";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: { staleTime: 5_000, refetchOnWindowFocus: false, retry: 1 },
  },
});

const ADMIN_ROLES = ["support", "admin", "superadmin"];

function Protected() {
  const { user, loading, logout } = useAuth();
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Loader2 className="w-6 h-6 animate-spin text-primary" />
      </div>
    );
  }
  if (!user) return <Redirect to="/login" />;
  if (!ADMIN_ROLES.includes(user.role)) {
    void logout();
    return <Redirect to="/login" />;
  }

  return (
    <AdminLayout>
      <Switch>
        <Route path="/" component={() => <Redirect to="/dashboard" />} />
        <Route path="/dashboard" component={DashboardPage} />
        <Route path="/users" component={UsersPage} />
        <Route path="/kyc" component={KycPage} />
        <Route path="/kyc-templates" component={KycTemplatesPage} />
        <Route path="/banks" component={BanksPage} />
        <Route path="/coins" component={CoinsPage} />
        <Route path="/networks" component={NetworksPage} />
        <Route path="/pairs" component={PairsPage} />
        <Route path="/funding-rates" component={FundingRatesPage} />
        <Route path="/futures-positions" component={FuturesPositionsPage} />
        <Route path="/api-keys" component={ApiKeysPage} />
        <Route path="/bots" component={BotsPage} />
        <Route path="/orders" component={OrdersPage} />
        <Route path="/gateways" component={GatewaysPage} />
        <Route path="/inr-deposits" component={InrDepositsPage} />
        <Route path="/inr-withdrawals" component={InrWithdrawalsPage} />
        <Route path="/crypto-deposits" component={CryptoDepositsPage} />
        <Route path="/user-addresses" component={UserAddressesPage} />
        <Route path="/crypto-withdrawals" component={CryptoWithdrawalsPage} />
        <Route path="/earn" component={EarnPage} />
        <Route path="/banners" component={BannersPage} />
        <Route path="/promotions" component={PromotionsPage} />
        <Route path="/redis" component={RedisPage} />
        <Route path="/legal" component={LegalPage} />
        <Route path="/chat" component={ChatPage} />
        <Route path="/login-logs" component={LoginLogsPage} />
        <Route path="/otp-providers" component={OtpProvidersPage} />
        <Route path="/settings" component={SettingsPage} />
        <Route path="/backend-status" component={BackendStatusPage} />
        <Route component={NotFound} />
      </Switch>
    </AdminLayout>
  );
}

function Router() {
  const { user, loading } = useAuth();
  return (
    <Switch>
      <Route path="/login">{loading ? null : user ? <Redirect to="/dashboard" /> : <LoginPage />}</Route>
      <Route><Protected /></Route>
    </Switch>
  );
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <TooltipProvider>
          <WouterRouter base={import.meta.env.BASE_URL.replace(/\/$/, "")}>
            <Router />
          </WouterRouter>
          <Toaster />
        </TooltipProvider>
      </AuthProvider>
    </QueryClientProvider>
  );
}

export default App;
