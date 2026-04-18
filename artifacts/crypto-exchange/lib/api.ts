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
