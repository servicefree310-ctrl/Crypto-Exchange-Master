import { Platform } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

const TOKEN_KEY = 'cx_session_token';

function apiBase(): string {
  if (Platform.OS === 'web') return '/api';
  const dom = process.env.EXPO_PUBLIC_DOMAIN;
  return dom ? `https://${dom}/api` : 'http://localhost:8080/api';
}

async function authHeaders(): Promise<Record<string, string>> {
  if (Platform.OS === 'web') return {};
  const token = await AsyncStorage.getItem(TOKEN_KEY);
  return token ? { Cookie: `cx_session=${token}` } : {};
}

async function rememberToken(headers: Headers) {
  if (Platform.OS === 'web') return;
  const setCookie = headers.get('set-cookie') || headers.get('Set-Cookie');
  if (!setCookie) return;
  const m = /cx_session=([^;]+)/.exec(setCookie);
  if (m) await AsyncStorage.setItem(TOKEN_KEY, m[1]);
}

export class ApiError extends Error {
  constructor(public status: number, message: string) { super(message); }
}

async function request<T>(method: string, path: string, body?: unknown): Promise<T> {
  const headers: Record<string, string> = { 'content-type': 'application/json', ...(await authHeaders()) };
  const res = await fetch(`${apiBase()}${path}`, {
    method,
    credentials: Platform.OS === 'web' ? 'include' : 'omit',
    headers,
    body: body !== undefined ? JSON.stringify(body) : undefined,
  });
  await rememberToken(res.headers);
  const text = await res.text();
  const data = text ? JSON.parse(text) : null;
  if (!res.ok) throw new ApiError(res.status, data?.error || `HTTP ${res.status}`);
  return data as T;
}

export const api = {
  get:    <T>(p: string) => request<T>('GET', p),
  post:   <T>(p: string, b?: unknown) => request<T>('POST', p, b),
  patch:  <T>(p: string, b?: unknown) => request<T>('PATCH', p, b),
  delete: <T>(p: string) => request<T>('DELETE', p),
  clearToken: () => AsyncStorage.removeItem(TOKEN_KEY),
};

export type ApiUser = {
  id: number;
  uid: string;
  email: string;
  phone: string | null;
  name: string;
  role: string;
  kycLevel: number;
  kycStatus?: string;
  vipTier: number;
  referralCode: string;
  status: string;
};

export type ApiWallet = {
  id: number;
  walletType: 'spot' | 'inr' | 'earn' | 'futures' | string;
  coinId: number;
  balance: string;
  locked: string;
  coinSymbol: string;
  coinName: string;
  coinPrice: string;
};

export type ApiBank = {
  id: number;
  bankName: string;
  accountNumber: string;
  ifsc: string;
  holderName: string;
  status: 'under_review' | 'verified' | 'rejected' | string;
  rejectReason: string | null;
  createdAt: string;
};

export type ApiCoin = {
  id: number;
  symbol: string;
  name: string;
  status: string;
  currentPrice: string;
};

export type ApiKycRecord = {
  id: number; userId: number; level: number; status: 'pending' | 'approved' | 'rejected' | string;
  fullName: string | null; dob: string | null; address: string | null;
  panNumber: string | null; aadhaarNumber: string | null;
  panDocUrl: string | null; aadhaarDocUrl: string | null; selfieUrl: string | null;
  rejectReason: string | null; reviewedAt: string | null; createdAt: string;
};

export type ApiReferStats = {
  referralCode: string | null;
  referredCount: number;
  referredKycCount: number;
  estimatedEarnings: number;
  recent: { id: number; name: string; kycLevel: number | null; createdAt: string }[];
};

export type ApiOtpSendRes = {
  otpId: number; expiresInSec: number; delivered: boolean; devCode?: string; message: string;
};

export type ApiNetwork = {
  id: number;
  coinId: number;
  name: string;
  symbol: string;
  minWithdraw: string;
  withdrawFee: string;
  memoRequired?: boolean;
  status: string;
};
