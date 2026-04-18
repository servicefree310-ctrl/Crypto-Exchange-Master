import { pgTable, text, serial, timestamp, integer } from "drizzle-orm/pg-core";

export const legalPagesTable = pgTable("legal_pages", {
  slug: text("slug").primaryKey(),
  title: text("title").notNull(),
  content: text("content").notNull().default(""),
  updatedBy: integer("updated_by"),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow().$onUpdate(() => new Date()),
});

export type LegalPage = typeof legalPagesTable.$inferSelect;

export const settingsTable = pgTable("app_settings", {
  key: text("key").primaryKey(),
  value: text("value").notNull(),
  updatedAt: timestamp("updated_at", { withTimezone: true }).notNull().defaultNow().$onUpdate(() => new Date()),
});

export type AppSetting = typeof settingsTable.$inferSelect;

export const referralsTable = pgTable("referrals", {
  id: serial("id").primaryKey(),
  referrerId: integer("referrer_id").notNull(),
  referredId: integer("referred_id").notNull().unique(),
  commissionRate: text("commission_rate").notNull().default("20"),
  totalEarned: text("total_earned").notNull().default("0"),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export type Referral = typeof referralsTable.$inferSelect;

export const chatThreadsTable = pgTable("chat_threads", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
  subject: text("subject").notNull().default("Support"),
  status: text("status").notNull().default("open"),
  assigneeId: integer("assignee_id"),
  lastMessageAt: timestamp("last_message_at", { withTimezone: true }).notNull().defaultNow(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export type ChatThread = typeof chatThreadsTable.$inferSelect;

export const chatMessagesTable = pgTable("chat_messages", {
  id: serial("id").primaryKey(),
  threadId: integer("thread_id").notNull(),
  senderId: integer("sender_id").notNull(),
  senderRole: text("sender_role").notNull(),
  message: text("message").notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).notNull().defaultNow(),
});

export type ChatMessage = typeof chatMessagesTable.$inferSelect;
