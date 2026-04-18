import { pgTable, text, serial, timestamp, integer, numeric } from "drizzle-orm/pg-core";

export const ordersTable = pgTable("orders", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  pairId: integer("pair_id").notNull(),
  side: text("side").notNull(),
  type: text("type").notNull().default("limit"),
  price: numeric("price", { precision: 28, scale: 8 }).notNull().default("0"),
  qty: numeric("qty", { precision: 28, scale: 8 }).notNull(),
  filledQty: numeric("filled_qty", { precision: 28, scale: 8 }).notNull().default("0"),
  avgPrice: numeric("avg_price", { precision: 28, scale: 8 }).notNull().default("0"),
  fee: numeric("fee", { precision: 28, scale: 8 }).notNull().default("0"),
  tds: numeric("tds", { precision: 28, scale: 8 }).notNull().default("0"),
  status: text("status").notNull().default("open"),
  isBot: integer("is_bot").notNull().default(0),
  botId: integer("bot_id"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow().$onUpdate(() => new Date()),
});

export type Order = typeof ordersTable.$inferSelect;

export const tradesTable = pgTable("trades", {
  id: serial("id").primaryKey(),
  orderId: integer("order_id").notNull(),
  userId: integer("user_id").notNull(),
  pairId: integer("pair_id").notNull(),
  side: text("side").notNull(),
  price: numeric("price", { precision: 28, scale: 8 }).notNull(),
  qty: numeric("qty", { precision: 28, scale: 8 }).notNull(),
  fee: numeric("fee", { precision: 28, scale: 8 }).notNull().default("0"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export type Trade = typeof tradesTable.$inferSelect;
