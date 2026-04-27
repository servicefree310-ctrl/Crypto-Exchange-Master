import { Users, Bell } from "lucide-react";
import { Button } from "@/components/ui/button";
import { PageHeader } from "@/components/premium/PageHeader";
import { SectionCard } from "@/components/premium/SectionCard";
import { EmptyState } from "@/components/premium/EmptyState";
import { StatusPill } from "@/components/premium/StatusPill";
import { Link } from "wouter";

/**
 * P2P trading desk — coming-soon stub.
 *
 * This route is referenced from the main header (`/p2p`) so it must always
 * resolve. Until the matching engine + escrow flow ships, we render a
 * branded waiting room with a clear CTA back to the spot exchange so users
 * aren't dead-ended on a 404.
 */
export default function P2P() {
  return (
    <div className="container mx-auto px-4 py-8 max-w-6xl">
      <PageHeader
        eyebrow="Coming Soon"
        title="P2P Marketplace"
        description="Direct buyer ↔ seller trades with INR/UPI escrow. Launch ke liye ready ho rahe hain."
        actions={
          <StatusPill status="pending" variant="gold">
            Beta Soon
          </StatusPill>
        }
      />

      <SectionCard>
        <EmptyState
          icon={Users}
          title="P2P abhi launch nahi hua"
          description="Hum ek secure escrow-backed peer-to-peer marketplace bana rahe hain — UPI, IMPS, NEFT support ke saath. Tab tak aap spot exchange use kar sakte hain."
          action={
            <div className="flex items-center gap-2">
              <Link href="/markets">
                <Button data-testid="p2p-go-spot">Spot pe Trade Karein</Button>
              </Link>
              <Button variant="outline" disabled data-testid="p2p-notify-me">
                <Bell className="w-4 h-4 mr-2" />
                Notify Me
              </Button>
            </div>
          }
        />
      </SectionCard>
    </div>
  );
}
