import { pgTable, text, serial, timestamp, integer, numeric } from "drizzle-orm/pg-core";

export const inrDepositsTable = pgTable("inr_deposits", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  gatewayId: integer("gateway_id").notNull(),
  bankId: integer("bank_id"),
  amount: numeric("amount", { precision: 18, scale: 2 }).notNull(),
  fee: numeric("fee", { precision: 18, scale: 2 }).notNull().default("0"),
  refId: text("ref_id").notNull().unique(),
  utr: text("utr"),
  status: text("status").notNull().default("pending"),
  notes: text("notes"),
  reviewedBy: integer("reviewed_by"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  processedAt: timestamp("processed_at", { withTimezone: true }),
});

export type InrDeposit = typeof inrDepositsTable.$inferSelect;

export const inrWithdrawalsTable = pgTable("inr_withdrawals", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  bankId: integer("bank_id").notNull(),
  amount: numeric("amount", { precision: 18, scale: 2 }).notNull(),
  fee: numeric("fee", { precision: 18, scale: 2 }).notNull().default("0"),
  refId: text("ref_id").notNull().unique(),
  status: text("status").notNull().default("pending"),
  rejectReason: text("reject_reason"),
  reviewedBy: integer("reviewed_by"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  processedAt: timestamp("processed_at", { withTimezone: true }),
});

export type InrWithdrawal = typeof inrWithdrawalsTable.$inferSelect;

export const cryptoDepositsTable = pgTable("crypto_deposits", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  coinId: integer("coin_id").notNull(),
  networkId: integer("network_id").notNull(),
  amount: numeric("amount", { precision: 28, scale: 8 }).notNull(),
  address: text("address").notNull(),
  txHash: text("tx_hash"),
  confirmations: integer("confirmations").notNull().default(0),
  status: text("status").notNull().default("pending"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  processedAt: timestamp("processed_at", { withTimezone: true }),
});

export type CryptoDeposit = typeof cryptoDepositsTable.$inferSelect;

export const cryptoWithdrawalsTable = pgTable("crypto_withdrawals", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  coinId: integer("coin_id").notNull(),
  networkId: integer("network_id").notNull(),
  amount: numeric("amount", { precision: 28, scale: 8 }).notNull(),
  fee: numeric("fee", { precision: 28, scale: 8 }).notNull().default("0"),
  toAddress: text("to_address").notNull(),
  memo: text("memo"),
  txHash: text("tx_hash"),
  status: text("status").notNull().default("pending"),
  rejectReason: text("reject_reason"),
  reviewedBy: integer("reviewed_by"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  processedAt: timestamp("processed_at", { withTimezone: true }),
});

export type CryptoWithdrawal = typeof cryptoWithdrawalsTable.$inferSelect;

export const transfersTable = pgTable("transfers", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  fromWallet: text("from_wallet").notNull(),
  toWallet: text("to_wallet").notNull(),
  coinId: integer("coin_id").notNull(),
  amount: numeric("amount", { precision: 28, scale: 8 }).notNull(),
  status: text("status").notNull().default("completed"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export type Transfer = typeof transfersTable.$inferSelect;
