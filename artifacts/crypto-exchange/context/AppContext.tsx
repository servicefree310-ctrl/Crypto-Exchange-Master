import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useColorScheme } from 'react-native';
import { api, type ApiUser, type ApiWallet, type ApiBank, type ApiCoin, type ApiNetwork } from '@/lib/api';

export type Theme = 'dark' | 'light' | 'system';
export type Language = 'en' | 'hi';
export type KycLevel = 0 | 1 | 2 | 3;
export type WalletType = 'spot' | 'inr' | 'earn' | 'futures';

export interface User {
  uid: string;
  name: string;
  email: string;
  phone: string;
  kycLevel: KycLevel;
  kycStatus: 'pending' | 'under_review' | 'verified' | 'rejected';
  subscriptionLevel: 0 | 1 | 2 | 3;
  monthlyVolume: number;
  referralCode: string;
  referralEarnings: number;
  totalTdsPaid: number;
  totalTdsUnpaid: number;
  totalFeesPaid: number;
  totalEarned: number;
  isLoggedIn: boolean;
}

export interface Coin {
  symbol: string;
  name: string;
  price: number;
  change24h: number;
  volume24h: number;
  high24h: number;
  low24h: number;
  marketCap: number;
}

export interface WalletBalance {
  symbol: string;
  walletType: WalletType;
  available: number;
  locked: number;
  inrValue: number;
}

export interface Order {
  id: string;
  symbol: string;
  type: 'market' | 'limit' | 'stop';
  side: 'buy' | 'sell';
  price: number;
  quantity: number;
  filled: number;
  status: 'open' | 'filled' | 'cancelled' | 'partial';
  timestamp: number;
  fee: number;
  tds: number;
  total: number;
  invoiceId: string;
}

export interface Position {
  symbol: string;
  side: 'long' | 'short';
  size: number;
  entryPrice: number;
  markPrice: number;
  pnl: number;
  pnlPercent: number;
  leverage: number;
  liquidationPrice: number;
  margin: number;
}

export interface Transaction {
  id: string;
  type: 'deposit' | 'withdraw' | 'transfer' | 'trade' | 'earn' | 'refer';
  symbol: string;
  amount: number;
  status: 'pending' | 'completed' | 'failed';
  timestamp: number;
  txHash?: string;
  network?: string;
  fee: number;
  address?: string;
  bankRef?: string;
  walletType?: WalletType;
}

export interface Bank {
  id: string;
  accountHolder: string;
  accountNumber: string;
  ifsc: string;
  bankName: string;
  status: 'under_review' | 'verified' | 'rejected';
  addedAt: number;
}

export interface LoginLog {
  id: string;
  device: string;
  location: string;
  ip: string;
  timestamp: number;
  status: 'success' | 'failed';
}

export interface ActiveSession {
  id: string;
  device: string;
  location: string;
  lastActive: number;
  isCurrent: boolean;
}

export interface EarnProduct {
  id: string;
  symbol: string;
  type: 'simple' | 'advanced';
  apy: number;
  minAmount: number;
  duration?: number; // days for advanced
  totalLocked: number;
  available: boolean;
}

export interface EarnPosition {
  id: string;
  productId: string;
  symbol: string;
  type: 'simple' | 'advanced';
  amount: number;
  apy: number;
  startDate: number;
  endDate?: number;
  earned: number;
  status: 'active' | 'matured' | 'redeemed';
  autoMaturity: boolean;
}

export interface FeeTier {
  level: number;
  name: string;
  minVolume: number;
  spotMaker: number;
  spotTaker: number;
  futuresMaker: number;
  futuresTaker: number;
  withdrawDiscount: number;
}

export interface KycLevelInfo {
  level: KycLevel;
  name: string;
  withdrawLimitDaily: number;
  withdrawLimitMonthly: number;
  depositLimit: number;
  features: string[];
  required: string[];
}

interface AppContextType {
  theme: Theme;
  setTheme: (t: Theme) => void;
  effectiveTheme: 'dark' | 'light';
  language: Language;
  setLanguage: (l: Language) => void;
  user: User;
  setUser: (u: Partial<User>) => void;
  authBootstrapped: boolean;
  loginWithApi: (email: string, password: string) => Promise<void>;
  signupWithApi: (data: { name: string; email: string; phone: string; password: string; referralCode?: string }) => Promise<void>;
  logout: () => Promise<void>;
  apiWallets: ApiWallet[];
  apiBanks: ApiBank[];
  apiCoins: ApiCoin[];
  refreshWallets: () => Promise<void>;
  refreshBanks: () => Promise<void>;
  refreshCoins: () => Promise<void>;
  fetchNetworks: (coinId: number) => Promise<ApiNetwork[]>;
  addBankApi: (data: { bankName: string; accountNumber: string; ifsc: string; holderName: string }) => Promise<ApiBank>;
  removeBankApi: (id: number) => Promise<void>;
  withdrawInrApi: (bankId: number, amount: number) => Promise<any>;
  withdrawCryptoApi: (data: { coinId: number; networkId: number; amount: number; toAddress: string; memo?: string }) => Promise<any>;
  coins: Coin[];
  walletBalances: WalletBalance[];
  updateBalance: (symbol: string, walletType: WalletType, delta: number) => void;
  orders: Order[];
  addOrder: (o: Order) => void;
  cancelOrder: (id: string) => void;
  updateOrderFill: (id: string, filled: number) => void;
  positions: Position[];
  transactions: Transaction[];
  addTransaction: (t: Transaction) => void;
  banks: Bank[];
  addBank: (b: Bank) => void;
  updateBankStatus: (id: string, status: Bank['status']) => void;
  loginLogs: LoginLog[];
  activeSessions: ActiveSession[];
  botEnabled: boolean;
  setBotEnabled: (v: boolean) => void;
  earnProducts: EarnProduct[];
  earnPositions: EarnPosition[];
  addEarnPosition: (p: EarnPosition) => void;
  feeTiers: FeeTier[];
  currentFeeTier: FeeTier;
  kycLevels: KycLevelInfo[];
  totalPortfolioValue: number;
  todayPnl: number;
  todayPnlPercent: number;
}

export const MOCK_COINS: Coin[] = [
  { symbol: 'BTC', name: 'Bitcoin', price: 6750000, change24h: 2.34, volume24h: 2100000000, high24h: 6820000, low24h: 6580000, marketCap: 132000000000000 },
  { symbol: 'ETH', name: 'Ethereum', price: 355000, change24h: -1.23, volume24h: 980000000, high24h: 362000, low24h: 347000, marketCap: 42000000000000 },
  { symbol: 'BNB', name: 'BNB', price: 62000, change24h: 0.87, volume24h: 450000000, high24h: 63500, low24h: 61000, marketCap: 9500000000000 },
  { symbol: 'SOL', name: 'Solana', price: 18500, change24h: 4.56, volume24h: 320000000, high24h: 19200, low24h: 17600, marketCap: 8200000000000 },
  { symbol: 'XRP', name: 'XRP', price: 580, change24h: -0.45, volume24h: 280000000, high24h: 598, low24h: 568, marketCap: 3200000000000 },
  { symbol: 'ADA', name: 'Cardano', price: 82, change24h: 1.23, volume24h: 180000000, high24h: 86, low24h: 79, marketCap: 2900000000000 },
  { symbol: 'DOGE', name: 'Dogecoin', price: 18.5, change24h: 3.78, volume24h: 250000000, high24h: 19.2, low24h: 17.8, marketCap: 2600000000000 },
  { symbol: 'MATIC', name: 'Polygon', price: 95, change24h: -2.1, volume24h: 160000000, high24h: 98, low24h: 92, marketCap: 900000000000 },
  { symbol: 'AVAX', name: 'Avalanche', price: 4200, change24h: 5.67, volume24h: 140000000, high24h: 4350, low24h: 3980, marketCap: 1750000000000 },
  { symbol: 'DOT', name: 'Polkadot', price: 980, change24h: -1.89, volume24h: 120000000, high24h: 1020, low24h: 960, marketCap: 1300000000000 },
  { symbol: 'LINK', name: 'Chainlink', price: 1450, change24h: 2.11, volume24h: 95000000, high24h: 1490, low24h: 1410, marketCap: 850000000000 },
  { symbol: 'UNI', name: 'Uniswap', price: 1050, change24h: -0.78, volume24h: 78000000, high24h: 1080, low24h: 1020, marketCap: 620000000000 },
  { symbol: 'SHIB', name: 'Shiba Inu', price: 0.00185, change24h: 6.45, volume24h: 220000000, high24h: 0.00195, low24h: 0.00174, marketCap: 1090000000000 },
  { symbol: 'LTC', name: 'Litecoin', price: 7200, change24h: 1.56, volume24h: 88000000, high24h: 7380, low24h: 7080, marketCap: 540000000000 },
  { symbol: 'ATOM', name: 'Cosmos', price: 1020, change24h: -3.21, volume24h: 65000000, high24h: 1060, low24h: 985, marketCap: 400000000000 },
];

const MOCK_WALLET: WalletBalance[] = [
  { symbol: 'INR', walletType: 'inr', available: 50000, locked: 5000, inrValue: 55000 },
  { symbol: 'INR', walletType: 'spot', available: 25000, locked: 0, inrValue: 25000 },
  { symbol: 'BTC', walletType: 'spot', available: 0.025, locked: 0.002, inrValue: 182250 },
  { symbol: 'ETH', walletType: 'spot', available: 0.8, locked: 0.1, inrValue: 319500 },
  { symbol: 'BNB', walletType: 'spot', available: 2.5, locked: 0, inrValue: 155000 },
  { symbol: 'USDT', walletType: 'spot', available: 10000, locked: 1000, inrValue: 924000 },
  { symbol: 'BTC', walletType: 'earn', available: 0.005, locked: 0, inrValue: 33750 },
  { symbol: 'USDT', walletType: 'earn', available: 5000, locked: 0, inrValue: 462000 },
  { symbol: 'USDT', walletType: 'futures', available: 2000, locked: 500, inrValue: 184800 },
];

const MOCK_ORDERS: Order[] = [
  { id: 'ORD001', symbol: 'BTC/INR', type: 'limit', side: 'buy', price: 6700000, quantity: 0.001, filled: 0.001, status: 'filled', timestamp: Date.now() - 3600000, fee: 67, tds: 0, total: 6700.067, invoiceId: 'INV-2026001' },
  { id: 'ORD002', symbol: 'ETH/INR', type: 'market', side: 'sell', price: 358000, quantity: 0.5, filled: 0.5, status: 'filled', timestamp: Date.now() - 7200000, fee: 89.5, tds: 1790, total: 178910.5, invoiceId: 'INV-2026002' },
  { id: 'ORD003', symbol: 'SOL/INR', type: 'limit', side: 'buy', price: 18200, quantity: 5, filled: 2.5, status: 'partial', timestamp: Date.now() - 1800000, fee: 22.75, tds: 0, total: 45522.75, invoiceId: 'INV-2026003' },
];

const MOCK_POSITIONS: Position[] = [
  { symbol: 'BTC/USDT', side: 'long', size: 0.01, entryPrice: 65000, markPrice: 67500, pnl: 25, pnlPercent: 3.84, leverage: 10, liquidationPrice: 58500, margin: 65 },
  { symbol: 'ETH/USDT', side: 'short', size: 0.5, entryPrice: 3600, markPrice: 3550, pnl: 25, pnlPercent: 1.38, leverage: 5, liquidationPrice: 3960, margin: 360 },
];

const MOCK_TRANSACTIONS: Transaction[] = [
  { id: 'TXN001', type: 'deposit', symbol: 'INR', amount: 50000, status: 'completed', timestamp: Date.now() - 86400000, fee: 0, address: 'HDFC Bank ••••4321', bankRef: 'NEFT/HDFC/123456', walletType: 'inr' },
  { id: 'TXN002', type: 'withdraw', symbol: 'BTC', amount: 0.01, status: 'completed', timestamp: Date.now() - 172800000, fee: 0.0001, txHash: '0xabc...def', network: 'Bitcoin', address: '1A2B3C...', walletType: 'spot' },
  { id: 'TXN003', type: 'deposit', symbol: 'USDT', amount: 5000, status: 'pending', timestamp: Date.now() - 3600000, fee: 1, network: 'TRC20', walletType: 'spot' },
  { id: 'TXN004', type: 'withdraw', symbol: 'INR', amount: 25000, status: 'completed', timestamp: Date.now() - 259200000, fee: 0, address: 'HDFC Bank ••••4321', bankRef: 'IMPS/HDFC/234567', walletType: 'inr' },
  { id: 'TXN005', type: 'earn', symbol: 'USDT', amount: 12.5, status: 'completed', timestamp: Date.now() - 86400000, fee: 0, walletType: 'earn' },
];

const MOCK_LOGIN_LOGS: LoginLog[] = [
  { id: 'L1', device: 'iPhone 14 Pro', location: 'Mumbai, India', ip: '103.xxx.xx.1', timestamp: Date.now() - 3600000, status: 'success' },
  { id: 'L2', device: 'Chrome / Windows', location: 'Delhi, India', ip: '103.xxx.xx.2', timestamp: Date.now() - 86400000, status: 'success' },
  { id: 'L3', device: 'Unknown Device', location: 'Unknown', ip: '185.xxx.xx.3', timestamp: Date.now() - 172800000, status: 'failed' },
];

const MOCK_SESSIONS: ActiveSession[] = [
  { id: 'S1', device: 'iPhone 14 Pro (Current)', location: 'Mumbai, India', lastActive: Date.now(), isCurrent: true },
  { id: 'S2', device: 'Chrome / Windows', location: 'Delhi, India', lastActive: Date.now() - 7200000, isCurrent: false },
];

const EARN_PRODUCTS: EarnProduct[] = [
  // Simple - flexible
  { id: 'E1', symbol: 'USDT', type: 'simple', apy: 5.5, minAmount: 10, totalLocked: 1250000, available: true },
  { id: 'E2', symbol: 'BTC', type: 'simple', apy: 2.8, minAmount: 0.0001, totalLocked: 18.5, available: true },
  { id: 'E3', symbol: 'ETH', type: 'simple', apy: 3.5, minAmount: 0.01, totalLocked: 220, available: true },
  { id: 'E4', symbol: 'BNB', type: 'simple', apy: 4.2, minAmount: 0.05, totalLocked: 850, available: true },
  // Advanced - locked
  { id: 'E5', symbol: 'USDT', type: 'advanced', apy: 8.5, minAmount: 100, duration: 30, totalLocked: 5800000, available: true },
  { id: 'E6', symbol: 'USDT', type: 'advanced', apy: 12.5, minAmount: 500, duration: 90, totalLocked: 8200000, available: true },
  { id: 'E7', symbol: 'USDT', type: 'advanced', apy: 18.5, minAmount: 1000, duration: 180, totalLocked: 12000000, available: true },
  { id: 'E8', symbol: 'BTC', type: 'advanced', apy: 6.5, minAmount: 0.01, duration: 60, totalLocked: 45, available: true },
  { id: 'E9', symbol: 'ETH', type: 'advanced', apy: 7.8, minAmount: 0.1, duration: 90, totalLocked: 580, available: true },
];

const FEE_TIERS: FeeTier[] = [
  { level: 0, name: 'Regular', minVolume: 0, spotMaker: 0.20, spotTaker: 0.25, futuresMaker: 0.05, futuresTaker: 0.07, withdrawDiscount: 0 },
  { level: 1, name: 'VIP 1', minVolume: 100000, spotMaker: 0.16, spotTaker: 0.20, futuresMaker: 0.04, futuresTaker: 0.06, withdrawDiscount: 5 },
  { level: 2, name: 'VIP 2', minVolume: 500000, spotMaker: 0.12, spotTaker: 0.15, futuresMaker: 0.03, futuresTaker: 0.05, withdrawDiscount: 10 },
  { level: 3, name: 'VIP 3', minVolume: 2500000, spotMaker: 0.08, spotTaker: 0.10, futuresMaker: 0.02, futuresTaker: 0.04, withdrawDiscount: 15 },
  { level: 4, name: 'VIP 4', minVolume: 10000000, spotMaker: 0.06, spotTaker: 0.08, futuresMaker: 0.015, futuresTaker: 0.03, withdrawDiscount: 20 },
  { level: 5, name: 'VIP 5', minVolume: 50000000, spotMaker: 0.04, spotTaker: 0.06, futuresMaker: 0.01, futuresTaker: 0.025, withdrawDiscount: 25 },
];

const KYC_LEVELS: KycLevelInfo[] = [
  {
    level: 0, name: 'Unverified',
    withdrawLimitDaily: 0, withdrawLimitMonthly: 0, depositLimit: 0,
    features: ['Browse markets', 'View prices'],
    required: [],
  },
  {
    level: 1, name: 'Basic KYC',
    withdrawLimitDaily: 50000, withdrawLimitMonthly: 500000, depositLimit: 100000,
    features: ['Spot trading', 'INR deposit/withdraw', 'Basic earn'],
    required: ['Email verification', 'Phone verification', 'PAN card'],
  },
  {
    level: 2, name: 'Intermediate KYC',
    withdrawLimitDaily: 500000, withdrawLimitMonthly: 5000000, depositLimit: 1000000,
    features: ['Futures trading', 'All earn products', 'Higher limits', 'Refer & earn'],
    required: ['Aadhaar card', 'Live selfie verification', 'Address proof'],
  },
  {
    level: 3, name: 'Advanced KYC',
    withdrawLimitDaily: 5000000, withdrawLimitMonthly: 50000000, depositLimit: 10000000,
    features: ['Unlimited limits', 'OTC trading', 'API trading', 'Priority support'],
    required: ['Income proof', 'Source of funds', 'Video KYC'],
  },
];

const defaultUser: User = {
  uid: 'CXABCD1234',
  name: 'Rahul Sharma',
  email: 'rahul@example.com',
  phone: '+91 98765 43210',
  kycLevel: 2,
  kycStatus: 'verified',
  subscriptionLevel: 1,
  monthlyVolume: 350000,
  referralCode: 'RAHUL100',
  referralEarnings: 2500,
  totalTdsPaid: 3580,
  totalTdsUnpaid: 1200,
  totalFeesPaid: 8540,
  totalEarned: 4250,
  isLoggedIn: false,
};

export const AppContext = createContext<AppContextType | null>(null);

export function AppProvider({ children }: { children: ReactNode }) {
  const systemScheme = useColorScheme();
  const [theme, setThemeState] = useState<Theme>('dark');
  const [language, setLanguageState] = useState<Language>('en');
  const [user, setUserState] = useState<User>(defaultUser);
  const [authBootstrapped, setAuthBootstrapped] = useState(false);
  const [apiWallets, setApiWallets] = useState<ApiWallet[]>([]);
  const [apiBanks, setApiBanks] = useState<ApiBank[]>([]);
  const [apiCoins, setApiCoins] = useState<ApiCoin[]>([]);

  const refreshWallets = async () => {
    try { setApiWallets(await api.get<ApiWallet[]>('/wallets')); } catch {}
  };
  const refreshBanks = async () => {
    try { setApiBanks(await api.get<ApiBank[]>('/banks')); } catch {}
  };
  const refreshCoins = async () => {
    try { setApiCoins(await api.get<ApiCoin[]>('/coins')); } catch {}
  };
  const fetchNetworks = async (coinId: number) => {
    try { return await api.get<ApiNetwork[]>(`/networks?coinId=${coinId}`); } catch { return []; }
  };
  const addBankApi = async (data: { bankName: string; accountNumber: string; ifsc: string; holderName: string }) => {
    const created = await api.post<ApiBank>('/banks', data);
    await refreshBanks();
    return created;
  };
  const removeBankApi = async (id: number) => {
    await api.delete(`/banks/${id}`);
    await refreshBanks();
  };
  const withdrawInrApi = async (bankId: number, amount: number) => {
    const wd = await api.post('/inr-withdrawals', { bankId, amount });
    await refreshWallets();
    return wd;
  };
  const withdrawCryptoApi = async (data: { coinId: number; networkId: number; amount: number; toAddress: string; memo?: string }) => {
    const wd = await api.post('/crypto-withdrawals', data);
    await refreshWallets();
    return wd;
  };

  const apiUserToUser = (u: ApiUser): User => ({
    ...defaultUser,
    uid: u.uid,
    name: u.name || u.email.split('@')[0],
    email: u.email,
    phone: u.phone || '',
    kycLevel: (u.kycLevel ?? 0) as 0 | 1 | 2 | 3,
    kycStatus: (u.kycStatus as User['kycStatus']) || 'pending',
    subscriptionLevel: (u.vipTier ?? 0) as 0 | 1 | 2 | 3,
    referralCode: u.referralCode,
    isLoggedIn: true,
  });

  const loginWithApi = async (email: string, password: string) => {
    const res = await api.post<{ user: ApiUser }>('/auth/login', { email, password });
    setUserState(apiUserToUser(res.user));
    await Promise.all([refreshWallets(), refreshBanks(), refreshCoins()]);
  };
  const signupWithApi = async (data: { name: string; email: string; phone: string; password: string; referralCode?: string }) => {
    const res = await api.post<{ user: ApiUser }>('/auth/register', data);
    setUserState(apiUserToUser(res.user));
    await Promise.all([refreshWallets(), refreshBanks(), refreshCoins()]);
  };
  const logout = async () => {
    try { await api.post('/auth/logout'); } catch {}
    await api.clearToken();
    setUserState({ ...defaultUser, isLoggedIn: false });
    setApiWallets([]); setApiBanks([]);
  };
  const [coins, setCoins] = useState<Coin[]>(MOCK_COINS);
  const [walletBalances, setWalletBalances] = useState<WalletBalance[]>(MOCK_WALLET);
  const [orders, setOrders] = useState<Order[]>(MOCK_ORDERS);
  const [positions] = useState<Position[]>(MOCK_POSITIONS);
  const [transactions, setTransactions] = useState<Transaction[]>(MOCK_TRANSACTIONS);
  const [banks, setBanks] = useState<Bank[]>([
    { id: 'B1', accountHolder: 'Rahul Sharma', accountNumber: '1234567890', ifsc: 'HDFC0001234', bankName: 'HDFC Bank', status: 'verified', addedAt: Date.now() - 604800000 },
  ]);
  const [loginLogs] = useState<LoginLog[]>(MOCK_LOGIN_LOGS);
  const [activeSessions] = useState<ActiveSession[]>(MOCK_SESSIONS);
  const [botEnabled, setBotEnabled] = useState(true);
  const [earnPositions, setEarnPositions] = useState<EarnPosition[]>([
    { id: 'EP1', productId: 'E1', symbol: 'USDT', type: 'simple', amount: 1000, apy: 5.5, startDate: Date.now() - 1209600000, earned: 4.52, status: 'active', autoMaturity: false },
    { id: 'EP2', productId: 'E5', symbol: 'USDT', type: 'advanced', amount: 500, apy: 8.5, startDate: Date.now() - 864000000, endDate: Date.now() + 1728000000, earned: 11.6, status: 'active', autoMaturity: true },
  ]);

  const effectiveTheme: 'dark' | 'light' = theme === 'system' ? (systemScheme ?? 'dark') : theme;
  const currentFeeTier = [...FEE_TIERS].reverse().find(t => user.monthlyVolume >= t.minVolume) || FEE_TIERS[0];

  useEffect(() => {
    loadSettings();
    (async () => {
      try {
        const me = await api.get<{ user: ApiUser }>('/auth/me');
        setUserState(apiUserToUser(me.user));
        await Promise.all([refreshWallets(), refreshBanks(), refreshCoins()]);
      } catch {
        // Server says not logged in — clear any stale token + reset to defaults
        await api.clearToken();
        setUserState({ ...defaultUser, isLoggedIn: false });
        setApiWallets([]); setApiBanks([]);
      } finally { setAuthBootstrapped(true); }
    })();
    const interval = setInterval(() => {
      setCoins(prev => prev.map(c => ({
        ...c,
        price: c.price * (1 + (Math.random() - 0.498) * 0.002),
        change24h: parseFloat((c.change24h + (Math.random() - 0.5) * 0.05).toFixed(2)),
      })));
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  const loadSettings = async () => {
    try {
      const savedTheme = await AsyncStorage.getItem('theme');
      const savedLang = await AsyncStorage.getItem('language');
      if (savedTheme) setThemeState(savedTheme as Theme);
      if (savedLang) setLanguageState(savedLang as Language);
      // NOTE: user state is hydrated authoritatively from /auth/me, not local cache.
    } catch {}
  };

  const setTheme = async (t: Theme) => {
    setThemeState(t);
    try { await AsyncStorage.setItem('theme', t); } catch {}
  };

  const setLanguage = async (l: Language) => {
    setLanguageState(l);
    try { await AsyncStorage.setItem('language', l); } catch {}
  };

  const setUser = async (updates: Partial<User>) => {
    const updated = { ...user, ...updates };
    setUserState(updated);
    try { await AsyncStorage.setItem('user', JSON.stringify(updated)); } catch {}
  };

  const updateBalance = (symbol: string, walletType: WalletType, delta: number) => {
    setWalletBalances(prev => {
      const existing = prev.find(b => b.symbol === symbol && b.walletType === walletType);
      const coin = MOCK_COINS.find(c => c.symbol === symbol);
      const rate = symbol === 'INR' ? 1 : symbol === 'USDT' ? 92.4 : (coin?.price || 0);
      if (existing) {
        return prev.map(b => b.symbol === symbol && b.walletType === walletType
          ? { ...b, available: Math.max(0, b.available + delta), inrValue: Math.max(0, b.available + delta) * rate }
          : b);
      }
      return [...prev, { symbol, walletType, available: Math.max(0, delta), locked: 0, inrValue: Math.max(0, delta) * rate }];
    });
  };

  const addOrder = (o: Order) => setOrders(prev => [o, ...prev]);
  const cancelOrder = (id: string) => setOrders(prev => prev.map(o => o.id === id && (o.status === 'open' || o.status === 'partial') ? { ...o, status: 'cancelled' } : o));
  const updateOrderFill = (id: string, filled: number) => setOrders(prev => prev.map(o => {
    if (o.id !== id) return o;
    const fillPct = filled / o.quantity;
    return { ...o, filled, status: fillPct >= 1 ? 'filled' : fillPct > 0 ? 'partial' : 'open' };
  }));
  const addTransaction = (t: Transaction) => setTransactions(prev => [t, ...prev]);
  const addBank = (b: Bank) => setBanks(prev => [...prev, b]);
  const updateBankStatus = (id: string, status: Bank['status']) => {
    setBanks(prev => prev.map(b => b.id === id ? { ...b, status } : b));
  };
  const addEarnPosition = (p: EarnPosition) => setEarnPositions(prev => [p, ...prev]);

  const totalPortfolioValue = walletBalances.reduce((s, b) => s + b.inrValue, 0);
  const todayPnl = 8750;
  const todayPnlPercent = 2.34;

  return (
    <AppContext.Provider value={{
      theme, setTheme, effectiveTheme,
      language, setLanguage,
      user, setUser, authBootstrapped, loginWithApi, signupWithApi, logout,
      apiWallets, apiBanks, apiCoins,
      refreshWallets, refreshBanks, refreshCoins, fetchNetworks,
      addBankApi, removeBankApi, withdrawInrApi, withdrawCryptoApi,
      coins, walletBalances, updateBalance,
      orders, addOrder, cancelOrder, updateOrderFill,
      positions, transactions, addTransaction,
      banks, addBank, updateBankStatus,
      loginLogs, activeSessions,
      botEnabled, setBotEnabled,
      earnProducts: EARN_PRODUCTS, earnPositions, addEarnPosition,
      feeTiers: FEE_TIERS, currentFeeTier,
      kycLevels: KYC_LEVELS,
      totalPortfolioValue, todayPnl, todayPnlPercent,
    }}>
      {children}
    </AppContext.Provider>
  );
}

export function useApp() {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp must be used within AppProvider');
  return ctx;
}
