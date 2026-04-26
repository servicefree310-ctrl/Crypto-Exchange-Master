import { useAuth } from "@/lib/auth";

export default function Profile() {
  const { user } = useAuth();

  return (
    <div className="p-8 container mx-auto max-w-3xl">
      <h1 className="text-3xl font-bold mb-8">Profile</h1>
      
      <div className="bg-card border border-border p-8 rounded-lg space-y-6">
        <div>
          <div className="text-sm text-muted-foreground mb-1">Full Name</div>
          <div className="text-xl font-bold">{user?.fullName}</div>
        </div>
        
        <div>
          <div className="text-sm text-muted-foreground mb-1">Email</div>
          <div>{user?.email}</div>
        </div>

        <div>
          <div className="text-sm text-muted-foreground mb-1">Account Status</div>
          <div className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-success/20 text-success">
            Active
          </div>
        </div>
      </div>
    </div>
  );
}
