import { pgTable, serial, integer, text, timestamp, uniqueIndex } from "drizzle-orm/pg-core";

export const walletAddressesTable = pgTable("wallet_addresses", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  networkId: integer("network_id").notNull(),
  address: text("address").notNull(),
  memo: text("memo"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
}, (t) => ({
  uniq: uniqueIndex("wallet_addresses_user_network_uniq").on(t.userId, t.networkId),
}));

export type WalletAddress = typeof walletAddressesTable.$inferSelect;
