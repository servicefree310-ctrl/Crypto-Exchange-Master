import { useEffect, useMemo } from "react";
import { useForm } from "react-hook-form";
import { useAuth } from "@/lib/auth";
import { useLocation } from "wouter";
import { Gift } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Badge } from "@/components/ui/badge";

export default function Signup() {
  const { signup } = useAuth();
  const [, setLocation] = useLocation();

  // Pull ?ref=CODE from the URL so referral attribution Just Works™ when a
  // friend opens the invite link from the Invite page.
  const refFromUrl = useMemo(() => {
    if (typeof window === "undefined") return "";
    return new URLSearchParams(window.location.search).get("ref")?.trim().toUpperCase() ?? "";
  }, []);

  const form = useForm({
    defaultValues: { email: "", password: "", fullName: "", referralCode: refFromUrl },
  });

  useEffect(() => {
    if (refFromUrl) form.setValue("referralCode", refFromUrl);
  }, [refFromUrl, form]);

  const onSubmit = async (data: any) => {
    try {
      const payload: any = {
        email: data.email,
        password: data.password,
        fullName: data.fullName,
      };
      if (data.referralCode) payload.referralCode = data.referralCode;
      await signup(payload);
      setLocation("/");
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <div className="flex min-h-screen">
      <div className="flex-1 flex flex-col justify-center px-8 md:px-24">
        <h1 className="text-3xl font-bold mb-2">Sign up for CryptoX</h1>
        {refFromUrl && (
          <Badge className="self-start mb-6 bg-amber-500/15 text-amber-300 border-amber-500/40" data-testid="badge-referral-applied">
            <Gift className="h-3 w-3 mr-1" /> Invited by code {refFromUrl}
          </Badge>
        )}
        {!refFromUrl && <div className="mb-6" />}
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4 max-w-sm">
          <div>
            <Input placeholder="Full Name" {...form.register("fullName")} />
          </div>
          <div>
            <Input placeholder="Email" {...form.register("email")} />
          </div>
          <div>
            <Input type="password" placeholder="Password" {...form.register("password")} />
          </div>
          <div>
            <Input
              placeholder="Referral code (optional)"
              {...form.register("referralCode")}
              data-testid="input-signup-referral"
              className="font-mono"
            />
          </div>
          <Button type="submit" className="w-full">Sign Up</Button>
        </form>
      </div>
      <div className="hidden md:block flex-1 bg-card border-l border-border" />
    </div>
  );
}
