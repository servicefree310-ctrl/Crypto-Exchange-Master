import { createContext, useContext, useEffect, useState } from "react";
import { get, post } from "./api";

type User = {
  id: number;
  email: string;
  fullName: string;
  name?: string;
  phone?: string | null;
  role: string;
  kycLevel?: number;
  vipTier?: number;
  referralCode?: string;
  referredBy?: number | null;
  status?: string;
  twoFaEnabled?: boolean;
  uid?: string;
  avatarUrl?: string | null;
  emailVerified?: boolean;
  phoneVerified?: boolean;
  lastLoginAt?: string | null;
  createdAt?: string;
};

type AuthContextType = {
  user: User | null;
  loading: boolean;
  login: (data: any) => Promise<void>;
  signup: (data: any) => Promise<void>;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextType>({} as AuthContextType);

// Roles that belong to the admin panel — they MUST NOT be allowed to use
// the user-portal. If such a session is detected we silently log them out.
const STAFF_ROLES = new Set(["admin", "superadmin", "support"]);
const isStaff = (u: { role?: string } | null | undefined) =>
  !!u?.role && STAFF_ROLES.has(String(u.role).toLowerCase());

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    get("/auth/me")
      .then(async (data: any) => {
        if (isStaff(data?.user)) {
          // Admin/staff session leaked into the user-portal tab. Kill it.
          try { await post("/auth/logout"); } catch { /* noop */ }
          setUser(null);
          return;
        }
        setUser(data.user);
      })
      .catch(() => {
        setUser(null);
      })
      .finally(() => {
        setLoading(false);
      });
  }, []);

  const login = async (data: any) => {
    const res: any = await post("/auth/login", data);
    if (isStaff(res?.user)) {
      // Don't keep the staff session alive in the user-portal cookie jar.
      try { await post("/auth/logout"); } catch { /* noop */ }
      setUser(null);
      throw new Error("Admin accounts cannot sign in here. Please use the admin panel.");
    }
    setUser(res.user);
  };

  const signup = async (data: any) => {
    const res: any = await post("/auth/register", data);
    setUser(res.user);
  };

  const logout = async () => {
    try { await post("/auth/logout"); } catch { /* noop */ }
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, loading, login, signup, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);

import { useLocation } from "wouter";

export function RequireAuth({ children }: { children: React.ReactNode }) {
  const { user, loading } = useAuth();
  const [, setLocation] = useLocation();

  useEffect(() => {
    if (!loading && !user) {
      setLocation("/login");
    }
  }, [user, loading, setLocation]);

  if (loading) return null;
  if (!user) return null;

  return <>{children}</>;
}
