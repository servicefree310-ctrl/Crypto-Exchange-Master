/**
 * P2P engine — periodic background tick that auto-cancels stale orders.
 *
 * Runs once per minute. For every `pending` order whose `expiresAt` has
 * elapsed, we refund the seller's locked escrow back to spendable balance,
 * restore the offer's available liquidity, and flip the order to `expired`.
 * Each transition is recorded in `p2p_messages` so the chat audit shows it.
 *
 * Multi-replica safety: only the elected leader executes the work. The
 * timer fires on every replica but the body is leader-gated, matching the
 * `futures-engine` and `deposit-sweeper` patterns.
 */

import { and, eq, lte, sql } from "drizzle-orm";
import {
  db,
  p2pOrdersTable,
  p2pOffersTable,
  p2pMessagesTable,
} from "@workspace/db";
import { logger } from "./logger";
import { isLeader } from "./leader";
import { refundEscrow, quantizeQty } from "./p2p-escrow";

const TICK_MS = 60_000;
let timer: ReturnType<typeof setInterval> | null = null;
let busy = false;

const stats = {
  ticks: 0,
  expired: 0,
  lastTickAt: 0 as number,
  lastError: "" as string,
};

async function tickExpireOrders(): Promise<{ checked: number; expired: number }> {
  if (busy) return { checked: 0, expired: 0 };
  busy = true;
  let checked = 0, expired = 0;
  try {
    const now = new Date();
    // Batch: pull a chunk of overdue pending orders. Each one is processed
    // in its own transaction so a single bad row doesn't poison the rest.
    const overdue = await db.select({ id: p2pOrdersTable.id })
      .from(p2pOrdersTable)
      .where(and(eq(p2pOrdersTable.status, "pending"), lte(p2pOrdersTable.expiresAt, now)))
      .limit(50);
    checked = overdue.length;

    for (const { id } of overdue) {
      try {
        await db.transaction(async (tx) => {
          // Re-read with FOR UPDATE to guard against races with mark-paid /
          // manual cancel / dispute that may have flipped the row already.
          const [o] = await tx.select().from(p2pOrdersTable)
            .where(eq(p2pOrdersTable.id, id))
            .for("update").limit(1);
          if (!o || o.status !== "pending") return;
          if (!o.expiresAt || o.expiresAt.getTime() > Date.now()) return;

          const qtyStr = quantizeQty(o.qty);
          await refundEscrow(tx, o.sellerId, o.coinId, qtyStr);

          await tx.update(p2pOffersTable).set({
            availableQty: sql`${p2pOffersTable.availableQty} + ${qtyStr}::numeric`,
            updatedAt: new Date(),
          }).where(eq(p2pOffersTable.id, o.offerId));

          await tx.update(p2pOrdersTable).set({
            status: "expired",
            cancelledAt: new Date(),
            updatedAt: new Date(),
          }).where(eq(p2pOrdersTable.id, id));

          await tx.insert(p2pMessagesTable).values({
            orderId: id, senderId: o.sellerId, senderRole: "system",
            body: "Pay window expired — order auto-cancelled and escrow refunded to seller.",
          });
        });
        expired++;
      } catch (e) {
        logger.warn({ err: (e as Error).message, orderId: id }, "p2p auto-expire failed for order");
      }
    }
    if (expired > 0) {
      logger.info({ expired, checked }, "p2p-engine expired stale orders");
    }
  } catch (e) {
    stats.lastError = (e as Error).message;
    logger.error({ err: (e as Error).message }, "p2p-engine tick failed");
  } finally {
    busy = false;
    stats.ticks++;
    stats.expired += expired;
    stats.lastTickAt = Date.now();
  }
  return { checked, expired };
}

export function startP2PEngine(intervalMs: number = TICK_MS): void {
  if (timer) return;
  logger.info({ intervalMs }, "p2p-engine starting (auto-expire pending orders, leader-gated)");
  const guard = async () => {
    try {
      if (isLeader()) await tickExpireOrders();
    } catch (e) {
      logger.error({ err: (e as Error).message }, "p2p-engine guard error");
    }
  };
  timer = setInterval(() => { void guard(); }, intervalMs);
  // Initial best-effort tick on boot (still leader-gated).
  void guard();
}

export function stopP2PEngine(): void {
  if (timer) clearInterval(timer);
  timer = null;
}

export function getP2PEngineStatus() {
  return { ...stats, intervalMs: TICK_MS };
}

/** Exposed for tests + admin "force run" buttons. */
export const _internal = { tickExpireOrders };
