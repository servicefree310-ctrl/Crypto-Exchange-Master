import { createContext, useContext, useEffect, useState } from "react";
import { get, post } from "./api";

type User = {
  id: number;
  email: string;
  fullName: string;
  name?: string;
  phone?: string;
  role: string;
  kycLevel?: number;
  vipTier?: number;
  referralCode?: string;
  status?: string;
  twoFaEnabled?: boolean;
};

type AuthContextType = {
  user: User | null;
  loading: boolean;
  login: (data: any) => Promise<void>;
  signup: (data: any) => Promise<void>;
  logout: () => Promise<void>;
};

const AuthContext = createContext<AuthContextType>({} as AuthContextType);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    get("/auth/me")
      .then((data: any) => {
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
    setUser(res.user);
  };

  const signup = async (data: any) => {
    const res: any = await post("/auth/register", data);
    setUser(res.user);
  };

  const logout = async () => {
    await post("/auth/logout");
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
