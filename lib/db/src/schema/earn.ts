import { pgTable, text, serial, timestamp, integer, numeric, boolean } from "drizzle-orm/pg-core";

export const earnProductsTable = pgTable("earn_products", {
  id: serial("id").primaryKey(),
  coinId: integer("coin_id").notNull(),
  type: text("type").notNull(),
  durationDays: integer("duration_days").notNull().default(0),
  apy: numeric("apy", { precision: 6, scale: 2 }).notNull(),
  minAmount: numeric("min_amount", { precision: 28, scale: 8 }).notNull().default("0"),
  maxAmount: numeric("max_amount", { precision: 28, scale: 8 }).notNull().default("0"),
  status: text("status").notNull().default("active"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export type EarnProduct = typeof earnProductsTable.$inferSelect;

export const earnPositionsTable = pgTable("earn_positions", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  productId: integer("product_id").notNull(),
  amount: numeric("amount", { precision: 28, scale: 8 }).notNull(),
  totalEarned: numeric("total_earned", { precision: 28, scale: 8 }).notNull().default("0"),
  autoMaturity: boolean("auto_maturity").notNull().default(false),
  status: text("status").notNull().default("active"),
  startedAt: timestamp("started_at", { withTimezone: true }).notNull().defaultNow(),
  maturedAt: timestamp("matured_at", { withTimezone: true }),
  closedAt: timestamp("closed_at", { withTimezone: true }),
});

export type EarnPosition = typeof earnPositionsTable.$inferSelect;
