# Overview

This project is a pnpm workspace monorepo using TypeScript, designed to build a professional-grade crypto exchange platform primarily targeting the Indian market. It includes a mobile application, a comprehensive admin web panel, and a desktop web user portal. The platform aims to offer spot and future trading, multi-wallet support, KYC verification (L0-3), VIP tiers, Earn programs, and facilitate INR and crypto deposits/withdrawals, adhering to Indian tax regulations (1% TDS).

The business vision is to capture a significant share of the Indian crypto exchange market by providing a feature-rich, user-friendly, and compliant platform. The project ambitions include high scalability, robust security, and a seamless user experience across all interfaces.

# User Preferences

I prefer iterative development and want to be asked before major changes are made.

# System Architecture

The project is structured as a pnpm workspace monorepo, leveraging Node.js 24 and TypeScript 5.9.

**UI/UX Decisions:**
- **Mobile App:** Designed for a Binance/CoinDCX style experience with a dynamic theme system and consistent branding.
- **Admin Panel:** Premium Zebvix Admin Console with a dark navy + gold/amber Binance-style theme across 28 pages, featuring a branded sidebar, sticky header with command palette, and role-gated access. Includes a premium dashboard with KPI cards, pending approvals breakdown, system health monitoring, and user/withdrawal teasers. Reusable premium components and custom CSS utilities are implemented.
- **User Portal:** Utilizes a dark gold/amber theme (Binance-style) for Home, Markets, Trade, and Futures terminals with `lightweight-charts` for data visualization and live price feeds.
  - **Account Pages:** Comprehensive profile management (KYC, bank accounts, settings with 2FA, sessions), Earn programs with KYC gating, and an Invite & Earn system with referral tracking and commission tiers. All pages use `react-query` and a consistent amber/orange brand gradient.
  - **Production Hardening:** Includes stub pages for future features (`/p2p`, `/convert`), rewritten Orders and Portfolio sections using shared premium primitives, and a robust `ErrorBoundary` for improved user experience.
  - **Order Contracts:** Standardized API endpoints for Spot (`/exchange/order`) and Futures (`/futures/order`, `/futures/position`) trading, with wallet balance (`/finance/wallet`) available for derived `available` balances.
  - **Shared Auth:** `bicryptoAuth` middleware accepts both `cx_session` cookie and Bearer JWT for unified authentication across web and Flutter clients.
  - **WS Trades Stream:** Symbol-scoped `trades:<symbol>` WebSocket stream for real-time market data.

**Technical Implementations:**
- **API Framework:** Express 5 with cookie sessions, `bcryptjs` for authentication, and role-based access control.
- **Database:** PostgreSQL with Drizzle ORM, featuring a comprehensive schema across 12 modules.
- **Validation:** Zod (`zod/v4`) with `drizzle-zod` for robust data validation.
- **API Codegen:** Orval generates API hooks and Zod schemas from an OpenAPI specification.
- **Build System:** esbuild for CJS bundle generation.
- **Authentication:** HMAC-SHA256 JWTs with platform-specific token persistence (SharedPreferences for web, `flutter_secure_storage` for native). OTP codes are hashed and generated cryptographically.
- **Real-time Data:** Custom `marketSocket.ts` normalizes Bicrypto-style WebSocket frames.
- **Monetary Transactions:** Atomic database transactions with `SELECT FOR UPDATE` and `onConflictDoUpdate` for data integrity in all sensitive financial operations.
- **Security Hardening:** OTP codes are cryptographically generated, hashed at rest, and consumed atomically. KYC approval is monotonic to prevent level downgrades.
- **Request Correlation:** `X-Request-Id` header (or UUID fallback) is used for request tracing and logging across services.
- **Liveness vs Readiness Probes:** Separate endpoints (`/api/healthz` and `/api/readyz`) for cheap liveness checks and deep dependency checks (Postgres, Redis).
- **Zod Request Validation:** Middleware for API request body validation with detailed error responses.
- **Admin Hardening:** Global `ErrorBoundary` for admin UI, automatic redirection to login on 401, and replacement of native dialogs with `shadcn` components.
- **Multi-server / Horizontal Scaling:**
    - **Leader Election:** Redis-based leader election using `SET key NX EX` with atomic heartbeats to ensure a single leader for critical tasks.
    - **Leader-gated Workers:** Recurring tasks (price-service, sweepers, bot-service, futures engine ticks) are executed only by the elected leader.
    - **WS Fanout:** Leader publishes price ticks to Redis pub/sub, and followers subscribe to fan out to their connected WebSocket clients.
    - **Distributed Rate Limits:** `express-rate-limit` configured with `rate-limit-redis` for shared, distributed rate limiting across all replicas.
    - **Bootstrap Order:** Strict initialization sequence ensuring Redis connection and leader election before app import and server start.
    - **Single-instance Fallback:** Graceful degradation to single-instance operation if Redis is unavailable.
    - **Environment Variables:** Configurable Redis settings for multi-server deployments.

**Feature Specifications:**
- **Auth System:** Comprehensive authentication with `/auth`, `/admin`, `/public` routers, supporting both mobile and web clients.
- **KYC System:** Multi-level verification with admin approval workflow.
- **Wallets and Banking:** Multi-wallet support, INR/crypto deposits/withdrawals, and single-verified-bank rule with IFSC validation.
- **Trading Features:** Spot and Futures trading terminals, order placement, and real-time market data.
- **Admin Fund Endpoint:** `adminOnly` API for atomically funding user wallets with audit trails.
- **Bicrypto v5 Adapter:** Provides Flutter-shaped endpoints for various functionalities, including auth with Proof-of-Work.
- **Go Service Skeleton:** Established for performance-critical services like the matching engine.
- **In-Memory Matching Engine:** A pure-TypeScript, single-threaded, low-latency matching engine lives at `artifacts/api-server/src/lib/inmem-engine/` (orderbook.ts / pricelevel.ts / engine.ts / wal.ts / snapshot.ts). Uses sorted price arrays + per-level doubly-linked FIFO queues for O(log n) cross + O(1) maker pop; supports limit orders (buy/sell), partial fills, price-time priority, single-threaded event-queue processing, append-only JSONL WAL + atomic snapshot/recovery. Benchmarked at ~263k orders/sec, p99 latency 11µs (well under the 1ms target). Exposed via admin-only HTTP at `/api/admin/inmem-engine/{orders,orderbook/:symbol,metrics,snapshot}`. Runs in PARALLEL to the existing Redis+Postgres engine in `lib/matching-engine.ts` — no production wallet impact yet; settlement-layer cutover is a separate planned migration.
- **User-portal "More" Mega-Menu:** Header dropdown groups three discovery sections — Tools (Calculator, Currency Converter, Crypto Compare, Price Predictions), Promotion (Announcements), and Explore (Trading Leagues). Same grouping rendered in the mobile drawer. All six pages are public and use the premium pattern (`PageHeader`, `SectionCard`, `PremiumStatCard`, `StatusPill`); Predictions clamps projected prices to a sane band and explicitly carries a "NOT financial advice" disclaimer.

# External Dependencies

- **pnpm workspaces:** Monorepo management.
- **TypeScript:** Primary programming language.
- **Express 5:** API framework.
- **PostgreSQL:** Primary database.
- **Drizzle ORM:** Object-relational mapper.
- **Zod (`zod/v4`), `drizzle-zod`:** Schema validation.
- **Orval:** API client and schema generation.
- **esbuild:** JavaScript bundler.
- **Expo:** Mobile application framework.
- **lightweight-charts v5:** Charting library.
- **bcryptjs:** Password hashing.
- **Coingecko:** External API for live price data.
- **AsyncStorage:** Mobile data persistence.
- **SharedPreferences:** Web data persistence (for Flutter).
- **flutter_secure_storage:** Native mobile data persistence (for Flutter).
- **Stripe:** Payment processing (conditional for web).