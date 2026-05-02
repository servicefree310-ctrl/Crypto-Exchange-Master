// P2P escrow helpers — all reads/writes of wallets.{balance,p2pLocked}
// for P2P trades must go through these to keep accounting consistent.
// Amounts are strings to align with numeric(28,8) and avoid float drift.

import { and, eq, sql } from "drizzle-orm";
import { db, walletsTable } from "@workspace/db";

type Tx = Parameters<Parameters<typeof db.transaction>[0]>[0];

class EscrowError extends Error {
  constructor(public readonly httpStatus: number, message: string) {
    super(message);
    this.name = "EscrowError";
  }
}

export function quantizeQty(qty: string | number): string {
  const n = typeof qty === "string" ? Number(qty) : qty;
  if (!Number.isFinite(n) || n <= 0) {
    throw new EscrowError(400, "Invalid escrow quantity");
  }
  return n.toFixed(8);
}

export async function ensureSpotWalletForUpdate(tx: Tx, userId: number, coinId: number) {
  const [w] = await tx.select().from(walletsTable)
    .where(and(eq(walletsTable.userId, userId), eq(walletsTable.coinId, coinId), eq(walletsTable.walletType, "spot")))
    .for("update").limit(1);
  if (w) return w;
  const [created] = await tx.insert(walletsTable).values({
    userId, coinId, walletType: "spot", balance: "0", locked: "0", p2pLocked: "0",
  }).returning();
  const [locked] = await tx.select().from(walletsTable).where(eq(walletsTable.id, created.id)).for("update").limit(1);
  return locked;
}

export async function lockEscrow(tx: Tx, sellerId: number, coinId: number, qty: string | number): Promise<void> {
  const q = quantizeQty(qty);
  const wallet = await ensureSpotWalletForUpdate(tx, sellerId, coinId);
  if (Number(wallet.balance) < Number(q)) {
    throw new EscrowError(400, "Seller has insufficient balance — try a smaller order");
  }
  await tx.update(walletsTable).set({
    balance: sql`${walletsTable.balance} - ${q}::numeric`,
    p2pLocked: sql`${walletsTable.p2pLocked} + ${q}::numeric`,
    updatedAt: new Date(),
  }).where(eq(walletsTable.id, wallet.id));
}

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
  if (Number(sellerWallet.p2pLocked) + 1e-8 < Number(q)) {
    throw new EscrowError(500, "Escrow accounting error — p2p_locked < qty");
  }
  await tx.update(walletsTable).set({
    p2pLocked: sql`${walletsTable.p2pLocked} - ${q}::numeric`,
    updatedAt: new Date(),
  }).where(eq(walletsTable.id, sellerWallet.id));
  await tx.update(walletsTable).set({
    balance: sql`${walletsTable.balance} + ${q}::numeric`,
    updatedAt: new Date(),
  }).where(eq(walletsTable.id, buyerWallet.id));
}

export async function refundEscrow(tx: Tx, sellerId: number, coinId: number, qty: string | number): Promise<void> {
  const q = quantizeQty(qty);
  const wallet = await ensureSpotWalletForUpdate(tx, sellerId, coinId);
  if (Number(wallet.p2pLocked) + 1e-8 < Number(q)) {
    throw new EscrowError(500, "Escrow accounting error — p2p_locked < refund qty");
  }
  await tx.update(walletsTable).set({
    balance: sql`${walletsTable.balance} + ${q}::numeric`,
    p2pLocked: sql`${walletsTable.p2pLocked} - ${q}::numeric`,
    updatedAt: new Date(),
  }).where(eq(walletsTable.id, wallet.id));
}
