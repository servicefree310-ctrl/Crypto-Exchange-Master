import { pgTable, serial, integer, text, timestamp, numeric, varchar, uniqueIndex } from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";
import { ulid } from "ulid";

export const futuresPositionsTable = pgTable("futures_positions", {
  id: serial("id").primaryKey(),
  uid: varchar("uid", { length: 32 }).notNull().unique().$defaultFn(() => ulid()).default(sql`replace(gen_random_uuid()::text, '-', '')`),
  userId: integer("user_id").notNull(),
  pairId: integer("pair_id").notNull(),
  side: text("side").notNull(),
  leverage: integer("leverage").notNull().default(10),
  qty: numeric("qty", { precision: 28, scale: 8 }).notNull(),
  entryPrice: numeric("entry_price", { precision: 28, scale: 8 }).notNull(),
  markPrice: numeric("mark_price", { precision: 28, scale: 8 }).notNull().default("0"),
  marginAmount: numeric("margin_amount", { precision: 28, scale: 8 }).notNull(),
  marginType: text("margin_type").notNull().default("isolated"),
  unrealizedPnl: numeric("unrealized_pnl", { precision: 28, scale: 8 }).notNull().default("0"),
  liquidationPrice: numeric("liquidation_price", { precision: 28, scale: 8 }).notNull().default("0"),
  status: text("status").notNull().default("open"),
  openedAt: timestamp("opened_at", { withTimezone: true }).notNull().defaultNow(),
  closedAt: timestamp("closed_at", { withTimezone: true }),
  closeReason: text("close_reason"),
  realizedPnl: numeric("realized_pnl", { precision: 28, scale: 8 }).notNull().default("0"),
});

export type FuturesPosition = typeof futuresPositionsTable.$inferSelect;

export const fundingPaymentsTable = pgTable("funding_payments", {
  id: serial("id").primaryKey(),
  positionId: integer("position_id").notNull(),
  userId: integer("user_id").notNull(),
  pairId: integer("pair_id").notNull(),
  fundingRateId: integer("funding_rate_id").notNull(),
  rate: numeric("rate", { precision: 10, scale: 6 }).notNull(),
  positionValue: numeric("position_value", { precision: 28, scale: 8 }).notNull(),
  payment: numeric("payment", { precision: 28, scale: 8 }).notNull(),
  paidAt: timestamp("paid_at", { withTimezone: true }).notNull().defaultNow(),
}, (t) => ({
  uniqRatePos: uniqueIndex("funding_payments_rate_pos_idx").on(t.fundingRateId, t.positionId),
}));

export type FundingPayment = typeof fundingPaymentsTable.$inferSelect;
