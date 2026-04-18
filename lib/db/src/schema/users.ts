import { pgTable, text, serial, timestamp, integer, boolean } from "drizzle-orm/pg-core";
import { createInsertSchema } from "drizzle-zod";
import { z } from "zod/v4";

export const usersTable = pgTable("users", {
  id: serial("id").primaryKey(),
  email: text("email").notNull().unique(),
  phone: text("phone").unique(),
  passwordHash: text("password_hash").notNull(),
  name: text("name").notNull().default(""),
  role: text("role").notNull().default("user"),
  kycLevel: integer("kyc_level").notNull().default(0),
  vipTier: integer("vip_tier").notNull().default(0),
  referralCode: text("referral_code").notNull().unique(),
  referredBy: integer("referred_by"),
  status: text("status").notNull().default("active"),
  twoFaEnabled: boolean("two_fa_enabled").notNull().default(false),
  uid: text("uid").notNull().unique(),
  avatarUrl: text("avatar_url"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow().$onUpdate(() => new Date()),
});

export const insertUserSchema = createInsertSchema(usersTable).omit({ id: true, createdAt: true, updatedAt: true });
export type InsertUser = z.infer<typeof insertUserSchema>;
export type User = typeof usersTable.$inferSelect;
