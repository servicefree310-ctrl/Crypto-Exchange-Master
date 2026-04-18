import { pgTable, serial, integer, boolean, numeric, text, timestamp, uniqueIndex } from "drizzle-orm/pg-core";

export const marketBotsTable = pgTable("market_bots", {
  id: serial("id").primaryKey(),
  pairId: integer("pair_id").notNull(),
  enabled: boolean("enabled").notNull().default(false),
  spreadBps: integer("spread_bps").notNull().default(20),
  levels: integer("levels").notNull().default(5),
  priceStepBps: integer("price_step_bps").notNull().default(10),
  orderSize: numeric("order_size", { precision: 28, scale: 8 }).notNull().default("0.01"),
  refreshSec: integer("refresh_sec").notNull().default(8),
  maxOrderAgeSec: integer("max_order_age_sec").notNull().default(60),
  fillOnCross: boolean("fill_on_cross").notNull().default(true),
  status: text("status").notNull().default("idle"),
  lastRunAt: timestamp("last_run_at", { withTimezone: true }),
  lastError: text("last_error"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow().$onUpdate(() => new Date()),
}, (t) => ({
  pairUnique: uniqueIndex("market_bots_pair_unique").on(t.pairId),
}));

export type MarketBot = typeof marketBotsTable.$inferSelect;
