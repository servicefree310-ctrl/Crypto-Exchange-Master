import { pgTable, text, serial, timestamp, integer } from "drizzle-orm/pg-core";

export const kycRecordsTable = pgTable("kyc_records", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  level: integer("level").notNull(),
  status: text("status").notNull().default("pending"),
  fullName: text("full_name"),
  dob: text("dob"),
  address: text("address"),
  panNumber: text("pan_number"),
  aadhaarNumber: text("aadhaar_number"),
  panDocUrl: text("pan_doc_url"),
  aadhaarDocUrl: text("aadhaar_doc_url"),
  selfieUrl: text("selfie_url"),
  rejectReason: text("reject_reason"),
  reviewedBy: integer("reviewed_by"),
  reviewedAt: timestamp("reviewed_at", { withTimezone: true }),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow().$onUpdate(() => new Date()),
});

export type KycRecord = typeof kycRecordsTable.$inferSelect;

export const kycSettingsTable = pgTable("kyc_settings", {
  level: integer("level").primaryKey(),
  depositLimit: text("deposit_limit").notNull(),
  withdrawLimit: text("withdraw_limit").notNull(),
  tradeLimit: text("trade_limit").notNull(),
  features: text("features").notNull().default("[]"),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow().$onUpdate(() => new Date()),
});

export type KycSetting = typeof kycSettingsTable.$inferSelect;
