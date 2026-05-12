import { pgTable, serial, integer, text, boolean, timestamp, numeric } from "drizzle-orm/pg-core";
import { usersTable } from "./users";

export const brokerAccountsTable = pgTable("broker_accounts", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull().references(() => usersTable.id, { onDelete: "cascade" }),
  // Angel One account details
  angelClientId: text("angel_client_id"),          // Angel One client ID after account creation
  angelDemat: text("angel_demat"),                 // DP / demat account number
  angelTradingId: text("angel_trading_id"),        // Trading account ID
  // Application status
  status: text("status").notNull().default("draft"), // draft | submitted | under_review | approved | rejected | active
  rejectionReason: text("rejection_reason"),
  // Personal details
  fullName: text("full_name"),
  dob: text("dob"),                                // YYYY-MM-DD
  gender: text("gender"),                          // male | female | other
  fatherName: text("father_name"),
  motherName: text("mother_name"),
  maritalStatus: text("marital_status"),
  annualIncome: text("annual_income"),
  occupation: text("occupation"),
  // Contact
  mobile: text("mobile"),
  email: text("email"),
  address: text("address"),
  city: text("city"),
  state: text("state"),
  pincode: text("pincode"),
  // Identity
  panNumber: text("pan_number"),
  aadharNumber: text("aadhar_number"),
  // Bank details
  bankAccountNo: text("bank_account_no"),
  bankIfsc: text("bank_ifsc"),
  bankName: text("bank_name"),
  bankAccountType: text("bank_account_type"),     // savings | current
  // Trading preferences
  segmentEquity: boolean("segment_equity").default(true),
  segmentFno: boolean("segment_fno").default(false),
  segmentCommodity: boolean("segment_commodity").default(false),
  segmentCurrency: boolean("segment_currency").default(false),
  // Nominee
  nomineeName: text("nominee_name"),
  nomineeRelation: text("nominee_relation"),
  nomineeDob: text("nominee_dob"),
  // Angel One API tokens (after account activation)
  jwtToken: text("jwt_token"),
  jwtExpiresAt: timestamp("jwt_expires_at"),
  refreshToken: text("refresh_token"),
  feedToken: text("feed_token"),
  // Timestamps
  submittedAt: timestamp("submitted_at"),
  approvedAt: timestamp("approved_at"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});

export const brokerKycDocsTable = pgTable("broker_kyc_docs", {
  id: serial("id").primaryKey(),
  brokerAccountId: integer("broker_account_id").notNull().references(() => brokerAccountsTable.id, { onDelete: "cascade" }),
  docType: text("doc_type").notNull(), // pan_card | aadhar_front | aadhar_back | photo | signature | bank_proof | income_proof | cancelled_cheque
  fileUrl: text("file_url"),           // stored URL
  fileKey: text("file_key"),           // storage key
  status: text("status").notNull().default("pending"), // pending | verified | rejected
  rejectionNote: text("rejection_note"),
  uploadedAt: timestamp("uploaded_at").notNull().defaultNow(),
  verifiedAt: timestamp("verified_at"),
});

export const brokerOrdersTable = pgTable("broker_orders", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull().references(() => usersTable.id, { onDelete: "cascade" }),
  brokerAccountId: integer("broker_account_id").references(() => brokerAccountsTable.id),
  // Instrument
  symbol: text("symbol").notNull(),
  exchange: text("exchange").notNull(),
  assetClass: text("asset_class").notNull(),        // forex | stock | commodity
  // Order details
  orderType: text("order_type").notNull(),          // market | limit | sl | sl-m
  side: text("side").notNull(),                      // buy | sell
  qty: numeric("qty", { precision: 18, scale: 4 }).notNull(),
  price: numeric("price", { precision: 18, scale: 6 }),
  triggerPrice: numeric("trigger_price", { precision: 18, scale: 6 }),
  // Execution
  status: text("status").notNull().default("pending"), // pending | open | complete | cancelled | rejected
  angelOrderId: text("angel_order_id"),
  executedQty: numeric("executed_qty", { precision: 18, scale: 4 }).default("0"),
  executedPrice: numeric("executed_price", { precision: 18, scale: 6 }),
  pnl: numeric("pnl", { precision: 18, scale: 6 }),
  brokerage: numeric("brokerage", { precision: 18, scale: 6 }),
  // Meta
  simulated: boolean("simulated").notNull().default(true),
  errorMsg: text("error_msg"),
  placedAt: timestamp("placed_at"),
  executedAt: timestamp("executed_at"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
});

export const brokerPortfolioTable = pgTable("broker_portfolio", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull().references(() => usersTable.id, { onDelete: "cascade" }),
  brokerAccountId: integer("broker_account_id").references(() => brokerAccountsTable.id),
  symbol: text("symbol").notNull(),
  exchange: text("exchange").notNull(),
  assetClass: text("asset_class").notNull(),
  holdingQty: numeric("holding_qty", { precision: 18, scale: 4 }).notNull().default("0"),
  avgBuyPrice: numeric("avg_buy_price", { precision: 18, scale: 6 }).notNull().default("0"),
  currentPrice: numeric("current_price", { precision: 18, scale: 6 }),
  unrealizedPnl: numeric("unrealized_pnl", { precision: 18, scale: 6 }),
  realizedPnl: numeric("realized_pnl", { precision: 18, scale: 6 }).default("0"),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
});
