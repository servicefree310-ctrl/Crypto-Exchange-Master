import { useForm } from "react-hook-form";
import { useAuth } from "@/lib/auth";
import { useLocation } from "wouter";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

export default function Signup() {
  const { signup } = useAuth();
  const [, setLocation] = useLocation();
  const form = useForm({ defaultValues: { email: "", password: "", fullName: "" } });

  const onSubmit = async (data: any) => {
    try {
      await signup(data);
      setLocation("/");
    } catch (e) {
      console.error(e);
    }
  };

  return (
    <div className="flex min-h-screen">
      <div className="flex-1 flex flex-col justify-center px-8 md:px-24">
        <h1 className="text-3xl font-bold mb-8">Sign up for CryptoX</h1>
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
          <Button type="submit" className="w-full">Sign Up</Button>
        </form>
      </div>
      <div className="hidden md:block flex-1 bg-card border-l border-border" />
    </div>
  );
}
