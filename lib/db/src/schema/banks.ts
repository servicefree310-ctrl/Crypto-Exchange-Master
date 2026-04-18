import { pgTable, text, serial, timestamp, integer, boolean } from "drizzle-orm/pg-core";

export const bankAccountsTable = pgTable("bank_accounts", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  bankName: text("bank_name").notNull(),
  accountNumber: text("account_number").notNull(),
  ifsc: text("ifsc").notNull(),
  holderName: text("holder_name").notNull(),
  status: text("status").notNull().default("under_review"),
  isPrimary: boolean("is_primary").notNull().default(true),
  rejectReason: text("reject_reason"),
  verifiedAt: timestamp("verified_at", { withTimezone: true }),
  reviewedBy: integer("reviewed_by"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export type BankAccount = typeof bankAccountsTable.$inferSelect;
