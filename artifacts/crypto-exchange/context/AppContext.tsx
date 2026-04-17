import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useColorScheme } from 'react-native';

export type Theme = 'dark' | 'light' | 'system';
export type Language = 'en' | 'hi';

export interface User {
  uid: string;
  name: string;
  email: string;
  phone: string;
  kycStatus: 'pending' | 'under_review' | 'verified' | 'rejected';
  subscriptionLevel: 0 | 1 | 2 | 3;
  referralCode: string;
  referralEarnings: number;
  totalTdsPaid: number;
  totalTdsUnpaid: number;
  withdrawLimit: number;
  tradingFeeDiscount: number;
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
  logo: string;
}

export interface WalletBalance {
  symbol: string;
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
}

export interface Transaction {
  id: string;
  type: 'deposit' | 'withdraw' | 'transfer' | 'trade';
  symbol: string;
  amount: number;
  status: 'pending' | 'completed' | 'failed';
  timestamp: number;
  txHash?: string;
  network?: string;
  fee: number;
  address?: string;
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

interface AppContextType {
  theme: Theme;
  setTheme: (t: Theme) => void;
  effectiveTheme: 'dark' | 'light';
  language: Language;
  setLanguage: (l: Language) => void;
  user: User;
  setUser: (u: Partial<User>) => void;
  coins: Coin[];
  walletBalances: WalletBalance[];
  orders: Order[];
  addOrder: (o: Order) => void;
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
  totalPortfolioValue: number;
  todayPnl: number;
  todayPnlPercent: number;
}

const generateUID = () => 'CX' + Math.random().toString(36).substr(2, 8).toUpperCase();

export const MOCK_COINS: Coin[] = [
  { symbol: 'BTC', name: 'Bitcoin', price: 6750000, change24h: 2.34, volume24h: 2100000000, high24h: 6820000, low24h: 6580000, marketCap: 132000000000000, logo: 'btc' },
  { symbol: 'ETH', name: 'Ethereum', price: 355000, change24h: -1.23, volume24h: 980000000, high24h: 362000, low24h: 347000, marketCap: 42000000000000, logo: 'eth' },
  { symbol: 'BNB', name: 'BNB', price: 62000, change24h: 0.87, volume24h: 450000000, high24h: 63500, low24h: 61000, marketCap: 9500000000000, logo: 'bnb' },
  { symbol: 'SOL', name: 'Solana', price: 18500, change24h: 4.56, volume24h: 320000000, high24h: 19200, low24h: 17600, marketCap: 8200000000000, logo: 'sol' },
  { symbol: 'XRP', name: 'XRP', price: 580, change24h: -0.45, volume24h: 280000000, high24h: 598, low24h: 568, marketCap: 3200000000000, logo: 'xrp' },
  { symbol: 'ADA', name: 'Cardano', price: 82, change24h: 1.23, volume24h: 180000000, high24h: 86, low24h: 79, marketCap: 2900000000000, logo: 'ada' },
  { symbol: 'DOGE', name: 'Dogecoin', price: 18.5, change24h: 3.78, volume24h: 250000000, high24h: 19.2, low24h: 17.8, marketCap: 2600000000000, logo: 'doge' },
  { symbol: 'MATIC', name: 'Polygon', price: 95, change24h: -2.1, volume24h: 160000000, high24h: 98, low24h: 92, marketCap: 900000000000, logo: 'matic' },
  { symbol: 'AVAX', name: 'Avalanche', price: 4200, change24h: 5.67, volume24h: 140000000, high24h: 4350, low24h: 3980, marketCap: 1750000000000, logo: 'avax' },
  { symbol: 'DOT', name: 'Polkadot', price: 980, change24h: -1.89, volume24h: 120000000, high24h: 1020, low24h: 960, marketCap: 1300000000000, logo: 'dot' },
  { symbol: 'LINK', name: 'Chainlink', price: 1450, change24h: 2.11, volume24h: 95000000, high24h: 1490, low24h: 1410, marketCap: 850000000000, logo: 'link' },
  { symbol: 'UNI', name: 'Uniswap', price: 1050, change24h: -0.78, volume24h: 78000000, high24h: 1080, low24h: 1020, marketCap: 620000000000, logo: 'uni' },
  { symbol: 'SHIB', name: 'Shiba Inu', price: 0.00185, change24h: 6.45, volume24h: 220000000, high24h: 0.00195, low24h: 0.00174, marketCap: 1090000000000, logo: 'shib' },
  { symbol: 'LTC', name: 'Litecoin', price: 7200, change24h: 1.56, volume24h: 88000000, high24h: 7380, low24h: 7080, marketCap: 540000000000, logo: 'ltc' },
  { symbol: 'ATOM', name: 'Cosmos', price: 1020, change24h: -3.21, volume24h: 65000000, high24h: 1060, low24h: 985, marketCap: 400000000000, logo: 'atom' },
];

const MOCK_WALLET: WalletBalance[] = [
  { symbol: 'INR', available: 50000, locked: 5000, inrValue: 55000 },
  { symbol: 'BTC', available: 0.025, locked: 0.002, inrValue: 182250 },
  { symbol: 'ETH', available: 0.8, locked: 0.1, inrValue: 319500 },
  { symbol: 'BNB', available: 2.5, locked: 0, inrValue: 155000 },
  { symbol: 'USDT', available: 10000, locked: 1000, inrValue: 924000 },
];

const MOCK_ORDERS: Order[] = [
  { id: 'ORD001', symbol: 'BTC/INR', type: 'limit', side: 'buy', price: 6700000, quantity: 0.001, filled: 0.001, status: 'filled', timestamp: Date.now() - 3600000, fee: 67, tds: 0, total: 6700.067 },
  { id: 'ORD002', symbol: 'ETH/INR', type: 'market', side: 'sell', price: 358000, quantity: 0.5, filled: 0.5, status: 'filled', timestamp: Date.now() - 7200000, fee: 89.5, tds: 1790, total: 178910.5 },
  { id: 'ORD003', symbol: 'SOL/INR', type: 'limit', side: 'buy', price: 18200, quantity: 5, filled: 2.5, status: 'partial', timestamp: Date.now() - 1800000, fee: 22.75, tds: 0, total: 45522.75 },
];

const MOCK_POSITIONS: Position[] = [
  { symbol: 'BTC/USDT', side: 'long', size: 0.01, entryPrice: 65000, markPrice: 67500, pnl: 25, pnlPercent: 3.84, leverage: 10, liquidationPrice: 58500 },
  { symbol: 'ETH/USDT', side: 'short', size: 0.5, entryPrice: 3600, markPrice: 3550, pnl: 25, pnlPercent: 1.38, leverage: 5, liquidationPrice: 3960 },
];

const MOCK_TRANSACTIONS: Transaction[] = [
  { id: 'TXN001', type: 'deposit', symbol: 'INR', amount: 50000, status: 'completed', timestamp: Date.now() - 86400000, fee: 0, address: 'Bank Transfer' },
  { id: 'TXN002', type: 'withdraw', symbol: 'BTC', amount: 0.01, status: 'completed', timestamp: Date.now() - 172800000, fee: 0.0001, txHash: '0xabc...', network: 'Bitcoin', address: '1A2B3C...' },
  { id: 'TXN003', type: 'deposit', symbol: 'USDT', amount: 5000, status: 'pending', timestamp: Date.now() - 3600000, fee: 1, network: 'TRC20' },
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

const defaultUser: User = {
  uid: 'CXABCD1234',
  name: 'Rahul Sharma',
  email: 'rahul@example.com',
  phone: '+91 98765 43210',
  kycStatus: 'verified',
  subscriptionLevel: 1,
  referralCode: 'RAHUL100',
  referralEarnings: 2500,
  totalTdsPaid: 3580,
  totalTdsUnpaid: 1200,
  withdrawLimit: 500000,
  tradingFeeDiscount: 25,
  isLoggedIn: false,
};

export const AppContext = createContext<AppContextType | null>(null);

export function AppProvider({ children }: { children: ReactNode }) {
  const systemScheme = useColorScheme();
  const [theme, setThemeState] = useState<Theme>('dark');
  const [language, setLanguageState] = useState<Language>('en');
  const [user, setUserState] = useState<User>(defaultUser);
  const [coins, setCoins] = useState<Coin[]>(MOCK_COINS);
  const [walletBalances] = useState<WalletBalance[]>(MOCK_WALLET);
  const [orders, setOrders] = useState<Order[]>(MOCK_ORDERS);
  const [positions] = useState<Position[]>(MOCK_POSITIONS);
  const [transactions, setTransactions] = useState<Transaction[]>(MOCK_TRANSACTIONS);
  const [banks, setBanks] = useState<Bank[]>([
    { id: 'B1', accountHolder: 'Rahul Sharma', accountNumber: '1234567890', ifsc: 'HDFC0001234', bankName: 'HDFC Bank', status: 'verified', addedAt: Date.now() - 604800000 },
  ]);
  const [loginLogs] = useState<LoginLog[]>(MOCK_LOGIN_LOGS);
  const [activeSessions] = useState<ActiveSession[]>(MOCK_SESSIONS);
  const [botEnabled, setBotEnabled] = useState(true);

  const effectiveTheme: 'dark' | 'light' = theme === 'system' ? (systemScheme ?? 'dark') : theme;

  useEffect(() => {
    loadSettings();
    const interval = setInterval(() => {
      setCoins(prev => prev.map(c => ({
        ...c,
        price: c.price * (1 + (Math.random() - 0.498) * 0.002),
        change24h: parseFloat((c.change24h + (Math.random() - 0.5) * 0.1).toFixed(2)),
      })));
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  const loadSettings = async () => {
    try {
      const savedTheme = await AsyncStorage.getItem('theme');
      const savedLang = await AsyncStorage.getItem('language');
      const savedUser = await AsyncStorage.getItem('user');
      if (savedTheme) setThemeState(savedTheme as Theme);
      if (savedLang) setLanguageState(savedLang as Language);
      if (savedUser) setUserState(JSON.parse(savedUser));
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

  const addOrder = (o: Order) => setOrders(prev => [o, ...prev]);
  const addTransaction = (t: Transaction) => setTransactions(prev => [t, ...prev]);
  const addBank = (b: Bank) => setBanks(prev => [...prev, b]);
  const updateBankStatus = (id: string, status: Bank['status']) => {
    setBanks(prev => prev.map(b => b.id === id ? { ...b, status } : b));
  };

  const totalPortfolioValue = walletBalances.reduce((s, b) => s + b.inrValue, 0);
  const todayPnl = 8750;
  const todayPnlPercent = 2.34;

  return (
    <AppContext.Provider value={{
      theme, setTheme, effectiveTheme,
      language, setLanguage,
      user, setUser,
      coins, walletBalances, orders, addOrder,
      positions, transactions, addTransaction,
      banks, addBank, updateBankStatus,
      loginLogs, activeSessions,
      botEnabled, setBotEnabled,
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
