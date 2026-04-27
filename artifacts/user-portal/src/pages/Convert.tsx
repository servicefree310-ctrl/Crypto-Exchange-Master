import { ArrowLeftRight, Bell } from "lucide-react";
import { Button } from "@/components/ui/button";
import { PageHeader } from "@/components/premium/PageHeader";
import { SectionCard } from "@/components/premium/SectionCard";
import { EmptyState } from "@/components/premium/EmptyState";
import { StatusPill } from "@/components/premium/StatusPill";
import { Link } from "wouter";

/**
 * Quick Convert — coming-soon stub.
 *
 * Prevents the `/convert` header link from 404'ing while the one-click
 * convert flow (no orderbook, fixed quote, instant settle) is being wired
 * up against the spot router.
 */
export default function Convert() {
  return (
    <div className="container mx-auto px-4 py-8 max-w-6xl">
      <PageHeader
        eyebrow="Coming Soon"
        title="Quick Convert"
        description="Ek click mein crypto-to-crypto ya INR-to-crypto swap. Zero orderbook hassle."
        actions={
          <StatusPill status="pending" variant="gold">
            Beta Soon
          </StatusPill>
        }
      />

      <SectionCard>
        <EmptyState
          icon={ArrowLeftRight}
          title="Convert abhi available nahi hai"
          description="Hum quote-based instant conversion la rahe hain — kuch hi din mein. Tab tak Spot ya Futures pe trade karein."
          action={
            <div className="flex items-center gap-2">
              <Link href="/trade">
                <Button data-testid="convert-go-trade">Trade Open Karein</Button>
              </Link>
              <Button variant="outline" disabled data-testid="convert-notify-me">
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
