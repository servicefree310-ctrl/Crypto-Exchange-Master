/**
 * P2P escrow — single source of truth for crypto balance moves between
 * a seller's spot wallet and the platform's "locked" pocket.
 *
 * EVERY P2P route that touches `wallets.balance` / `wallets.locked` MUST go
 * through one of `lockEscrow` / `releaseEscrow` / `refundEscrow` so the
 * escrow accounting stays in lock-step with order state. This mirrors the
 * pattern used by `routes/transfer.ts` for spot↔futures transfers.
 *
 * Numeric handling: amounts are always passed in/out as strings so we can
 * keep the values aligned with the `numeric(28,8)` columns and avoid
 * float drift over many trades. The drizzle `sql` template binds the
 * string verbatim to a numeric parameter on the postgres side.
 */

import { and, eq, sql } from "drizzle-orm";
import { db, walletsTable } from "@workspace/db";

type Tx = Parameters<Parameters<typeof db.transaction>[0]>[0];

/** Always returns a string with up to 8 decimal places — matches numeric(28,8). */
export function quantizeQty(qty: string | number): string {
  const n = typeof qty === "string" ? Number(qty) : qty;
  if (!Number.isFinite(n) || n <= 0) {
    throw Object.assign(new Error("Invalid escrow quantity"), { code: 400 });
  }
  // 8 decimal places, no trailing junk; toFixed handles the rounding deterministically.
  return n.toFixed(8);
}

/** Locate-or-create a user's spot wallet for a coin, taking row lock. */
export async function ensureSpotWalletForUpdate(tx: Tx, userId: number, coinId: number) {
  const [w] = await tx.select().from(walletsTable)
    .where(and(eq(walletsTable.userId, userId), eq(walletsTable.coinId, coinId), eq(walletsTable.walletType, "spot")))
    .for("update").limit(1);
  if (w) return w;
  const [created] = await tx.insert(walletsTable).values({
    userId, coinId, walletType: "spot", balance: "0", locked: "0",
  }).returning();
  const [locked] = await tx.select().from(walletsTable).where(eq(walletsTable.id, created.id)).for("update").limit(1);
  return locked;
}

/**
 * Move `qty` units of `coinId` from `sellerId.spot.balance` → `sellerId.spot.locked`.
 * Throws { code: 400, message } when balance is insufficient. MUST be called
 * inside an active drizzle transaction with the offer row already FOR UPDATE
 * locked by the caller.
 */
export async function lockEscrow(tx: Tx, sellerId: number, coinId: number, qty: string | number): Promise<void> {
  const q = quantizeQty(qty);
  const wallet = await ensureSpotWalletForUpdate(tx, sellerId, coinId);
  if (Number(wallet.balance) < Number(q)) {
    throw Object.assign(new Error("Seller has insufficient balance — try a smaller order"), { code: 400 });
  }
  await tx.update(walletsTable).set({
    balance: sql`${walletsTable.balance} - ${q}::numeric`,
    locked: sql`${walletsTable.locked} + ${q}::numeric`,
    updatedAt: new Date(),
  }).where(eq(walletsTable.id, wallet.id));
}

/**
 * Move `qty` units from `sellerId.spot.locked` → `buyerId.spot.balance`.
 * This is the "trade settles, buyer gets crypto" path.
 */
export async function releaseEscrow(
  tx: Tx,
  sellerId: number,
  buyerId: number,
  coinId: number,
  qty: string | number,
): Promise<void> {
  const q = quantizeQty(qty);
  const sellerWallet = await ensureSpotWalletForUpdate(tx, sellerId, coinId);
  const buyerWallet = await ensureSpotWalletForUpdate(tx, buyerId, coinId);
  // Defensive: if locked < qty we would create money out of thin air.
  // Round-trip via Number is OK here — locked is always written by us in 8dp.
  if (Number(sellerWallet.locked) + 1e-8 < Number(q)) {
    throw Object.assign(new Error("Escrow accounting error — locked < qty"), { code: 500 });
  }
  await tx.update(walletsTable).set({
    locked: sql`${walletsTable.locked} - ${q}::numeric`,
    updatedAt: new Date(),
  }).where(eq(walletsTable.id, sellerWallet.id));
  await tx.update(walletsTable).set({
    balance: sql`${walletsTable.balance} + ${q}::numeric`,
    updatedAt: new Date(),
  }).where(eq(walletsTable.id, buyerWallet.id));
}

/**
 * Refund `qty` from `sellerId.spot.locked` → `sellerId.spot.balance`.
 * Used by cancel + admin-resolve-refund paths. Inverse of lockEscrow.
 */
export async function refundEscrow(tx: Tx, sellerId: number, coinId: number, qty: string | number): Promise<void> {
  const q = quantizeQty(qty);
  const wallet = await ensureSpotWalletForUpdate(tx, sellerId, coinId);
  if (Number(wallet.locked) + 1e-8 < Number(q)) {
    throw Object.assign(new Error("Escrow accounting error — locked < refund qty"), { code: 500 });
  }
  await tx.update(walletsTable).set({
    balance: sql`${walletsTable.balance} + ${q}::numeric`,
    locked: sql`${walletsTable.locked} - ${q}::numeric`,
    updatedAt: new Date(),
  }).where(eq(walletsTable.id, wallet.id));
}
