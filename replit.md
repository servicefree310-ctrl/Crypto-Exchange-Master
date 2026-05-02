# Overview

This project is a pnpm workspace monorepo using TypeScript, designed to build a professional-grade crypto exchange platform primarily targeting the Indian market. It includes a mobile application, a comprehensive admin web panel, and a desktop web user portal. The platform aims to offer spot and future trading, multi-wallet support, KYC verification (L0-3), VIP tiers, Earn programs, and facilitate INR and crypto deposits/withdrawals, adhering to Indian tax regulations (1% TDS).

The business vision is to capture a significant share of the Indian crypto exchange market by providing a feature-rich, user-friendly, and compliant platform. The project ambitions include high scalability, robust security, and a seamless user experience across all interfaces.

# User Preferences

I prefer iterative development and want to be asked before major changes are made.

# System Architecture

The project is structured as a pnpm workspace monorepo, leveraging Node.js 24 and TypeScript 5.9.

**UI/UX Decisions:**
- **Mobile App:** Designed for a Binance/CoinDCX style experience with a dynamic theme system and consistent branding.
- **Admin Panel:** Premium Zebvix Admin Console with a dark navy + gold/amber Binance-style theme across 28 pages, featuring a branded sidebar, sticky header with command palette, and role-gated access. Includes a premium dashboard with KPI cards, pending approvals breakdown, system health monitoring, and user/withdrawal teasers.
- **User Portal:** Utilizes a dark gold/amber theme (Binance-style) for Home, Markets, Trade, and Futures terminals with `lightweight-charts` for data visualization and live price feeds. Account pages offer comprehensive profile management, Earn programs, and an Invite & Earn system. Production hardening includes stub pages, rewritten sections, and robust `ErrorBoundary`.
- **Shared Authentication:** `bicryptoAuth` middleware accepts both `cx_session` cookie and Bearer JWT for unified authentication across web and Flutter clients.
- **Real-time Data:** Symbol-scoped `trades:<symbol>` WebSocket stream for real-time market data.

**Technical Implementations:**
- **API Framework:** Express 5 with cookie sessions, `bcryptjs` for authentication, and role-based access control.
- **Database:** PostgreSQL with Drizzle ORM.
- **Validation:** Zod (`zod/v4`) with `drizzle-zod` for robust data validation.
- **API Codegen:** Orval generates API hooks and Zod schemas from an OpenAPI specification.
- **Build System:** esbuild for CJS bundle generation.
- **Authentication:** HMAC-SHA256 JWTs with platform-specific token persistence. OTP codes are hashed and cryptographically generated.
- **Monetary Transactions:** Atomic database transactions with `SELECT FOR UPDATE` and `onConflictDoUpdate` for data integrity.
- **Security Hardening:** OTP codes are cryptographically generated, hashed at rest, and consumed atomically. KYC approval is monotonic.
- **Request Correlation:** `X-Request-Id` header for tracing and logging.
- **Liveness vs Readiness Probes:** Separate endpoints (`/api/healthz`, `/api/readyz`) for system health.
- **Zod Request Validation:** Middleware for API request body validation.
- **Admin Hardening:** Global `ErrorBoundary`, automatic 401 redirection, and `shadcn` components.
- **Multi-server / Horizontal Scaling:** Redis-based leader election for critical tasks, leader-gated workers, WS fanout via Redis pub/sub, distributed rate limits with `express-rate-limit` and `rate-limit-redis`. Strict bootstrap order and graceful degradation if Redis is unavailable.
- **In-Memory Matching Engine:** Pure-TypeScript, single-threaded, low-latency engine for Spot and Futures trading, supporting various order types and self-trade prevention. Benchmarked at ~232–263k orders/sec. Exposed via admin-only HTTP endpoints.
- **Production Engine (in-memory + DB-settled):** Orchestrates the raw in-memory engine with features like Symbol Registry, Risk Guard (per-user rate limits, max open orders), and an Async Settler for event-driven trade and autocancel processing with atomic Postgres transactions for wallet and order updates. Includes admin HTTP routes and a dedicated "Trading Engine" console for operators.
- **Admin Control & Audit:** Per-session order rate limits, `blockIfNotActive` middleware for user suspension, user freeze/unfreeze endpoints, force cancel order functionality, and a comprehensive audit log infrastructure and viewer.
- **DexScreener-style Auto-Listing System:** Automated token discovery and listing pipeline using admin-configurable rules, risk scoring, and auto-listing paths for spot and Web3 tokens. Includes admin and user interfaces for managing and discovering listings.
- **User API Keys (HMAC-signed REST):** Users can mint personal HMAC-signed API keys with configurable permissions and IP whitelists for programmatic account access. Crypto helpers ensure secure key management and signature verification.
- **Options Trading (Black-Scholes derivatives):** Implements a full-featured options product with new database tables for contracts, orders, positions, and settlements. Includes a Black-Scholes pricing engine with greeks and a leader-gated settlement engine. User and admin UIs are provided for managing and trading options.
- **Web3 Multi-Chain Trading (Simulated On-Ledger):** Provides a synthetic exchange-side product for multi-chain swaps and bridges across 8 simulated networks. Moves balances between existing spot wallets, generates fake transaction hashes for UX, and uses atomic database transactions. User and admin UIs are available for Web3 functionalities.

**Feature Specifications:**
- **Auth System:** Comprehensive authentication with `/auth`, `/admin`, `/public` routers.
- **KYC System:** Multi-level verification with admin approval workflow.
- **Wallets and Banking:** Multi-wallet support, INR/crypto deposits/withdrawals, and single-verified-bank rule.
- **Trading Features:** Spot and Futures trading terminals, order placement, and real-time market data.
- **Admin Fund Endpoint:** `adminOnly` API for atomically funding user wallets with audit trails.
- **Bicrypto v5 Adapter:** Provides Flutter-shaped endpoints.
- **Go Service Skeleton:** Established for performance-critical services.
- **User-portal "More" Mega-Menu:** Header dropdown for Tools, Promotion, and Explore sections.

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
- **SharedPreferences:** Web data persistence (for Flutter).
- **flutter_secure_storage:** Native mobile data persistence (for Flutter).