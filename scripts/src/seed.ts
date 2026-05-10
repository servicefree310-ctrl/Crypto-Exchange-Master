import { db, usersTable, coinsTable, networksTable, pairsTable, gatewaysTable, kycSettingsTable, legalPagesTable, settingsTable, earnProductsTable } from "@workspace/db";
import bcrypt from "bcryptjs";
import { randomBytes } from "node:crypto";
import { eq, and } from "drizzle-orm";

function ref() { return randomBytes(4).toString("hex").toUpperCase(); }
function uid() { return "CX" + Date.now().toString(36).toUpperCase() + randomBytes(3).toString("hex").toUpperCase(); }

async function main() {
  console.log("Seeding database...");

  // Admin user
  const existingAdmin = await db.select().from(usersTable).where(eq(usersTable.email, "admin@cryptox.in")).limit(1);
  if (existingAdmin.length === 0) {
    const passwordHash = await bcrypt.hash("Admin@123", 10);
    await db.insert(usersTable).values({
      email: "admin@cryptox.in",
      phone: "9999999999",
      passwordHash,
      name: "Super Admin",
      role: "superadmin",
      kycLevel: 3,
      vipTier: 5,
      referralCode: ref(),
      uid: uid(),
      status: "active",
    });
    console.log("Created admin user: admin@cryptox.in / Admin@123");
  }

  // Demo user
  const existingDemo = await db.select().from(usersTable).where(eq(usersTable.email, "demo@cryptox.in")).limit(1);
  if (existingDemo.length === 0) {
    const passwordHash = await bcrypt.hash("Demo@123", 10);
    await db.insert(usersTable).values({
      email: "demo@cryptox.in",
      phone: "9000000001",
      passwordHash,
      name: "Demo User",
      role: "user",
      kycLevel: 2,
      vipTier: 1,
      referralCode: ref(),
      uid: uid(),
      status: "active",
    });
    console.log("Created demo user: demo@cryptox.in / Demo@123");
  }

  // Coins
  const coinsSeed = [
    { symbol: "INR", name: "Indian Rupee", type: "fiat", decimals: 2, currentPrice: "1", logoUrl: null },
    { symbol: "USDT", name: "Tether", type: "crypto", decimals: 6, currentPrice: "85.00", logoUrl: null },
    { symbol: "BTC", name: "Bitcoin", type: "crypto", decimals: 8, currentPrice: "8500000", change24h: "2.5", logoUrl: null },
    { symbol: "ETH", name: "Ethereum", type: "crypto", decimals: 8, currentPrice: "320000", change24h: "1.8", logoUrl: null },
    { symbol: "SOL", name: "Solana", type: "crypto", decimals: 8, currentPrice: "16500", change24h: "4.2", logoUrl: null },
    { symbol: "BNB", name: "BNB", type: "crypto", decimals: 8, currentPrice: "62000", change24h: "0.6", logoUrl: null },
    { symbol: "XRP", name: "XRP", type: "crypto", decimals: 6, currentPrice: "210", change24h: "-1.1", logoUrl: null },
    { symbol: "ADA", name: "Cardano", type: "crypto", decimals: 6, currentPrice: "75", change24h: "0.4", logoUrl: null },
    { symbol: "DOGE", name: "Dogecoin", type: "crypto", decimals: 8, currentPrice: "12", change24h: "5.0", logoUrl: null },
    { symbol: "MATIC", name: "Polygon", type: "crypto", decimals: 8, currentPrice: "85", change24h: "1.2", logoUrl: null },
  ];
  for (const c of coinsSeed) {
    const existing = await db.select().from(coinsTable).where(eq(coinsTable.symbol, c.symbol)).limit(1);
    if (existing.length === 0) {
      await db.insert(coinsTable).values(c as any);
    }
  }
  console.log("Coins seeded");

  // Networks
  const allCoins = await db.select().from(coinsTable);
  const networksSeed: { sym: string; name: string; chain: string; minDeposit: string; minWithdraw: string; withdrawFee: string; confirmations: number }[] = [
    { sym: "USDT", name: "TRC20", chain: "TRX", minDeposit: "1", minWithdraw: "10", withdrawFee: "1", confirmations: 19 },
    { sym: "USDT", name: "ERC20", chain: "ETH", minDeposit: "1", minWithdraw: "20", withdrawFee: "5", confirmations: 12 },
    { sym: "USDT", name: "BEP20", chain: "BNB", minDeposit: "1", minWithdraw: "10", withdrawFee: "1", confirmations: 15 },
    { sym: "BTC", name: "BTC", chain: "BTC", minDeposit: "0.0001", minWithdraw: "0.001", withdrawFee: "0.0005", confirmations: 3 },
    { sym: "ETH", name: "ERC20", chain: "ETH", minDeposit: "0.001", minWithdraw: "0.01", withdrawFee: "0.005", confirmations: 12 },
    { sym: "BNB", name: "BEP20", chain: "BNB", minDeposit: "0.01", minWithdraw: "0.05", withdrawFee: "0.001", confirmations: 15 },
    { sym: "SOL", name: "SOL", chain: "SOL", minDeposit: "0.01", minWithdraw: "0.1", withdrawFee: "0.01", confirmations: 32 },
    { sym: "XRP", name: "XRP", chain: "XRP", minDeposit: "1", minWithdraw: "20", withdrawFee: "0.25", confirmations: 5 },
  ];
  for (const n of networksSeed) {
    const coin = allCoins.find((c) => c.symbol === n.sym);
    if (!coin) continue;
    const existing = await db.select().from(networksTable).where(and(eq(networksTable.coinId, coin.id), eq(networksTable.name, n.name))).limit(1);
    if (existing.length === 0) {
      await db.insert(networksTable).values({
        coinId: coin.id, name: n.name, chain: n.chain,
        minDeposit: n.minDeposit, minWithdraw: n.minWithdraw,
        withdrawFee: n.withdrawFee, confirmations: n.confirmations,
      });
    }
  }
  console.log("Networks seeded");

  // Pairs
  const inr = allCoins.find((c) => c.symbol === "INR")!;
  const usdt = allCoins.find((c) => c.symbol === "USDT")!;
  const pairsSeed = [
    { base: "BTC", quote: "INR", pp: 0, qp: 6 },
    { base: "ETH", quote: "INR", pp: 0, qp: 5 },
    { base: "SOL", quote: "INR", pp: 1, qp: 4 },
    { base: "BNB", quote: "INR", pp: 0, qp: 4 },
    { base: "XRP", quote: "INR", pp: 2, qp: 2 },
    { base: "DOGE", quote: "INR", pp: 3, qp: 0 },
    { base: "MATIC", quote: "INR", pp: 2, qp: 2 },
    { base: "USDT", quote: "INR", pp: 2, qp: 2 },
    { base: "BTC", quote: "USDT", pp: 1, qp: 6 },
    { base: "ETH", quote: "USDT", pp: 2, qp: 5 },
    { base: "SOL", quote: "USDT", pp: 3, qp: 4 },
  ];
  for (const p of pairsSeed) {
    const baseCoin = allCoins.find((c) => c.symbol === p.base);
    const quoteCoin = p.quote === "INR" ? inr : usdt;
    if (!baseCoin) continue;
    const symbol = `${p.base}${p.quote}`;
    const existing = await db.select().from(pairsTable).where(eq(pairsTable.symbol, symbol)).limit(1);
    if (existing.length === 0) {
      await db.insert(pairsTable).values({
        symbol,
        baseCoinId: baseCoin.id,
        quoteCoinId: quoteCoin.id,
        pricePrecision: p.pp,
        qtyPrecision: p.qp,
        takerFee: "0.001",
        makerFee: "0.001",
      });
    }
  }
  console.log("Pairs seeded");

  // Gateways
  const gws = [
    { code: "upi", name: "UPI", type: "upi", direction: "deposit", minAmount: "100", maxAmount: "200000", feeFlat: "0", feePercent: "0", processingTime: "Instant", isAuto: true },
    { code: "imps", name: "IMPS", type: "imps", direction: "deposit", minAmount: "1000", maxAmount: "500000", feeFlat: "5", feePercent: "0", processingTime: "5-30 mins", isAuto: false },
    { code: "neft", name: "NEFT", type: "neft", direction: "deposit", minAmount: "1000", maxAmount: "1000000", feeFlat: "0", feePercent: "0", processingTime: "2-4 hours", isAuto: false },
    { code: "rtgs", name: "RTGS", type: "rtgs", direction: "deposit", minAmount: "200000", maxAmount: "10000000", feeFlat: "0", feePercent: "0", processingTime: "30 mins", isAuto: false },
    { code: "imps_w", name: "IMPS Withdrawal", type: "imps", direction: "withdraw", minAmount: "100", maxAmount: "500000", feeFlat: "5", feePercent: "0", processingTime: "30 mins", isAuto: false },
  ];
  for (const g of gws) {
    const existing = await db.select().from(gatewaysTable).where(eq(gatewaysTable.code, g.code)).limit(1);
    if (existing.length === 0) {
      await db.insert(gatewaysTable).values({ ...g, config: "{}" } as any);
    }
  }
  console.log("Gateways seeded");

  // KYC settings
  const kycLevels = [
    { level: 0, depositLimit: "0", withdrawLimit: "0", tradeLimit: "0", features: '["browse"]' },
    { level: 1, depositLimit: "100000", withdrawLimit: "50000", tradeLimit: "100000", features: '["deposit","trade","earn_simple"]' },
    { level: 2, depositLimit: "1000000", withdrawLimit: "500000", tradeLimit: "1000000", features: '["deposit","trade","withdraw","earn_simple","earn_advanced"]' },
    { level: 3, depositLimit: "100000000", withdrawLimit: "10000000", tradeLimit: "100000000", features: '["deposit","trade","withdraw","earn_simple","earn_advanced","futures","margin"]' },
  ];
  for (const k of kycLevels) {
    const existing = await db.select().from(kycSettingsTable).where(eq(kycSettingsTable.level, k.level)).limit(1);
    if (existing.length === 0) {
      await db.insert(kycSettingsTable).values(k);
    }
  }
  console.log("KYC settings seeded");

  // Legal pages
  const pages = [
    { slug: "privacy", title: "Privacy Policy", content: "# Privacy Policy\n\nLast updated: " + new Date().toISOString().slice(0,10) + "\n\nWe respect your privacy. This document explains what data we collect and how we use it.\n\n## Data we collect\n- Account info\n- KYC documents\n- Transaction logs" },
    { slug: "terms", title: "Terms & Conditions", content: "# Terms & Conditions\n\nBy using CryptoX, you agree to comply with applicable Indian regulations including 1% TDS on crypto sells, GST on fees, and KYC obligations." },
    { slug: "aml", title: "AML / CFT Policy", content: "# AML & CFT Policy\n\nCryptoX follows PMLA 2002 and FIU-IND guidelines. Suspicious activity is reported to authorities." },
    { slug: "contact", title: "Contact & Office", content: "# Contact\n\n**Office Address**\nCryptoX Exchange Pvt Ltd\n2nd Floor, Tech Park, Mumbai, Maharashtra 400001\n\n**Registration**\nCIN: U67100MH2024PTC123456\nGST: 27ABCDE1234F1Z5\nFIU-IND Registration: REPE12345\n\n**Email**: support@cryptox.in\n**Phone**: +91 80-4567-8901" },
  ];
  for (const p of pages) {
    const existing = await db.select().from(legalPagesTable).where(eq(legalPagesTable.slug, p.slug)).limit(1);
    if (existing.length === 0) {
      await db.insert(legalPagesTable).values(p);
    }
  }
  console.log("Legal pages seeded");

  // App settings
  const appSettings = [
    { key: "site.name", value: "CryptoX Exchange" },
    { key: "site.tagline", value: "India's Pro Crypto Exchange" },
    { key: "tds.percent", value: "1" },
    { key: "referral.commission", value: "20" },
    { key: "listing.countdown", value: "[]" },
  ];
  for (const s of appSettings) {
    const existing = await db.select().from(settingsTable).where(eq(settingsTable.key, s.key)).limit(1);
    if (existing.length === 0) {
      await db.insert(settingsTable).values(s);
    }
  }
  console.log("Settings seeded");

  // Earn products (6 plans: USDT x3, BTC x2, ETH x1)
  const btc = allCoins.find((c) => c.symbol === "BTC");
  const eth = allCoins.find((c) => c.symbol === "ETH");
  if (usdt) {
    const products = [
      { coinId: usdt.id, type: "simple",   durationDays: 0,  apy: "5.00",  minAmount: "10",    maxAmount: "100000", name: "USDT Flexible Savings",  description: "Earn daily interest on idle USDT. No lock-up, withdraw anytime.",                               featured: false, displayOrder: 1 },
      { coinId: usdt.id, type: "advanced", durationDays: 30, apy: "8.50",  minAmount: "100",   maxAmount: "100000", name: "USDT 30-Day Locked",     description: "30-day USDT locked plan at enhanced APY. Auto-maturity available.",                            featured: false, displayOrder: 2 },
      { coinId: usdt.id, type: "advanced", durationDays: 90, apy: "11.00", minAmount: "100",   maxAmount: "100000", name: "USDT 90-Day Premium",    description: "Best USDT APY. 90-day lock with daily accrual and optional auto-renew.",                       featured: true,  displayOrder: 3 },
    ];
    if (btc) {
      products.push({ coinId: btc.id, type: "simple",   durationDays: 0,  apy: "2.50", minAmount: "0.001", maxAmount: "10", name: "BTC Flexible Savings",    description: "Stack more BTC on idle holdings. No lock-up, flexible exit anytime.",                              featured: false, displayOrder: 4 } as any);
      products.push({ coinId: btc.id, type: "advanced", durationDays: 90, apy: "7.50", minAmount: "0.001", maxAmount: "5",  name: "BTC 90-Day Premium",     description: "High-yield 90-day BTC locked vault. Premium returns for long-term holders. Auto-maturity & daily accrual.", featured: true, displayOrder: 6 } as any);
    }
    if (eth) products.push({ coinId: eth.id, type: "advanced", durationDays: 60, apy: "4.50", minAmount: "0.05", maxAmount: "100", name: "ETH 60-Day Locked", description: "60-day ETH locked staking with competitive APY and auto-maturity support.", featured: false, displayOrder: 5 } as any);
    for (const p of products) {
      const existing = await db.select().from(earnProductsTable).where(and(eq(earnProductsTable.coinId, p.coinId), eq(earnProductsTable.type, p.type), eq(earnProductsTable.durationDays, p.durationDays))).limit(1);
      if (existing.length === 0) {
        await db.insert(earnProductsTable).values(p as any);
      }
    }
  }
  console.log("Earn products seeded (6 plans)");

  console.log("Seed complete.");
  process.exit(0);
}

main().catch((e) => { console.error(e); process.exit(1); });
