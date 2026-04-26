# Overview

This project is a pnpm workspace monorepo using TypeScript, designed to build a professional-grade crypto exchange platform primarily targeting the Indian market. It includes a mobile application, a comprehensive admin web panel, and a desktop web user portal. The platform aims to offer spot and future trading, multi-wallet support, KYC verification (L0-3), VIP tiers, Earn programs, and facilitate INR and crypto deposits/withdrawals, adhering to Indian tax regulations (1% TDS).

The business vision is to capture a significant share of the Indian crypto exchange market by providing a feature-rich, user-friendly, and compliant platform. The project ambitions include high scalability, robust security, and a seamless user experience across all interfaces.

# User Preferences

I prefer iterative development and want to be asked before major changes are made.

# System Architecture

The project is structured as a pnpm workspace monorepo, leveraging Node.js 24 and TypeScript 5.9.

**UI/UX Decisions:**
- **Mobile App (artifacts/crypto-exchange):** Designed for a Binance/CoinDCX style experience, featuring a dynamic theme system (Auto/Light/Dark) with persisted preferences and adaptive icons. Brand accents (yellow, red, green) are consistent for trading context recognition.
- **Admin Panel (artifacts/admin):** Features a dark navy and yellow Binance-themed interface across 17 pages for comprehensive platform management. Includes a live backend status page to inspect API endpoints.
- **User Portal (artifacts/user-portal):** Utilizes a dark gold/amber theme (Binance-style), providing Home, Markets, Trade, and Futures terminals with `lightweight-charts` for candlesticks, depth-bar orderbook, and live price feeds. Live price updates incorporate micro-jittering for display without affecting authoritative pricing.
  - **Account pages:** Profile (hero with name/UID/KYC badge, stats strip, action grid, referral panel, KYC level overview), KYC (3 level cards, per-level submit dialogs with PAN/Aadhaar regex + file upload, current achieved level), Bank Accounts (list/add/delete with IFSC validation + single-verified-bank rule), Settings (4 tabs — Account / Security / Notifications / Preferences; 2FA enable/disable via OTP, change-password, sessions list with revoke-others), Earn (hero with totals, product grid with KYC L1/L2 gating + filter/sort, subscribe with projected-earn breakdown + auto-renew, redeem with early-penalty math), Invite & Earn (gradient hero with code + invite link + QR dialog, share buttons for WhatsApp/Telegram/X/Email + Web Share API, stats strip, 3-step "How it works", commission tier breakdown Bronze/Silver/Gold, invitee table, FAQ accordion). All pages use react-query, amber/orange brand gradient, and shared dialog patterns. Routes wired in `App.tsx`; AppHeader user dropdown surfaces KYC / Banks / Earn / Invite & Earn / Settings & 2FA. Signup page reads `?ref=CODE` query param to auto-attribute referrals.
  - **Earn data contract:** Backend `/api/earn/positions` exposes both legacy DB names (`maturedAt`, `autoMaturity`) and frontend-canonical aliases (`maturityAt`, `autoRenew`). `POST /api/earn/subscribe` accepts both `autoRenew` and `autoMaturity` keys. Server enforces KYC Level 1 for any subscribe and Level 2 for locked products (durationDays > 0), matching the UI gates so direct API calls cannot bypass.
  - **Order contracts (Bicrypto-style):** Spot uses `POST /exchange/order`, `GET /exchange/order?status=OPEN&currency=&pair=`, and `DELETE /exchange/order/:id` with `{currency, pair, side: buy|sell, type, amount, price?}`. Futures uses `POST /futures/order`, `GET /futures/position`, and `DELETE /futures/position` (body `{currency, pair, side: long|short}`); UI long/short maps to buy/sell when placing orders. Wallet read via `GET /finance/wallet` returning `{items:[{currency, balance, inOrder, ...}], pagination}` — `available` is derived as `balance - inOrder` when not present.
  - **Shared auth:** `bicryptoAuth` in both `routes/bicrypto.ts` and `routes/futures.ts` accepts the `cx_session` cookie (used by the React user-portal) in addition to Bearer JWT (used by Flutter). Single auth flow across both clients.
  - **WS trades stream:** symbol-scoped `trades:<symbol>` (with backward-compat for legacy `trades` frames). PriceChart resets per-symbol live state on switch and tolerates REST seed failures.

**Technical Implementations:**
- **API Framework:** Express 5 handles API requests, managing cookie sessions, bcryptjs for authentication, and role-based middleware (`requireRole`) for access control.
- **Database:** PostgreSQL with Drizzle ORM is used for data persistence. The Drizzle schema consists of 12 modules covering users, KYC, wallets, orders, deposits/withdrawals, etc.
- **Validation:** Zod (`zod/v4`) with `drizzle-zod` ensures robust data validation.
- **API Codegen:** Orval generates API hooks and Zod schemas from an OpenAPI specification.
- **Build System:** esbuild is used for CJS bundle generation.
- **Authentication:** HMAC-SHA256 JWTs are used for secure authentication, with separate handling for web (SharedPreferences) and native (flutter_secure_storage) token persistence. OTP codes are hashed at rest and generated using `crypto.randomInt` for enhanced security.
- **Real-time Data:** A custom `marketSocket.ts` normalizes Bicrypto-style WebSocket frames into a Binance-like format for simplified component consumption.
- **Monetary Transactions:** All sensitive monetary operations (deposits, withdrawals, admin funding) are implemented using atomic database transactions with `SELECT FOR UPDATE` to ensure data integrity and prevent race conditions. `onConflictDoUpdate` is used for race-safe upserts during wallet crediting.
- **Security Hardening:** OTP codes are hashed and generated cryptographically. `consumeVerifiedOtp()` is designed as an atomic, single-use operation for race-safe OTP consumption within transactions. KYC approval is monotonic, ensuring `kycLevel` never downgrades.

**Feature Specifications:**
- **Auth System:** Includes `/auth`, `/admin`, `/public` routers, mobile auth with `AsyncStorage` and web auth with cookies.
- **KYC System:** Multi-level KYC verification with specific requirements and an admin approval workflow that atomically updates user KYC levels.
- **Wallets and Banking:** Supports multiple wallets per user, INR and crypto deposits/withdrawals, and a single-verified-bank rule with IFSC validation.
- **Trading Features:** Spot and Futures trading terminals, order placement, and real-time market data display.
- **Admin Fund Endpoint:** An `adminOnly` API (`POST /api/admin/users/:id/fund`) allows administrators to fund user wallets atomically, with ledger entries for audit.
- **Bicrypto v5 Adapter:** An adapter is implemented to provide Flutter-shaped endpoints for various functionalities, including authentication with Proof-of-Work, user profiles, finance/wallet, exchange, and futures.
- **Go Service Skeleton:** A Go service skeleton is established for performance-critical tasks like the matching engine, WS gateway, and futures.

# External Dependencies

- **pnpm workspaces:** Monorepo management.
- **TypeScript:** Primary programming language.
- **Express 5:** API framework.
- **PostgreSQL:** Primary database.
- **Drizzle ORM:** Object-relational mapper for PostgreSQL.
- **Zod (`zod/v4`), `drizzle-zod`:** Schema validation.
- **Orval:** API client and schema generation from OpenAPI.
- **esbuild:** JavaScript bundler.
- **Expo:** Mobile application framework.
- **lightweight-charts v5:** Charting library for trading terminals.
- **bcryptjs:** Password hashing.
- **Coingecko:** External API for live price data.
- **AsyncStorage:** Mobile data persistence.
- **SharedPreferences:** Web data persistence for Flutter.
- **flutter_secure_storage:** Native mobile data persistence for Flutter.
- **Stripe:** Payment processing (with conditional initialization for web).