# Overview

This project is a pnpm workspace monorepo using TypeScript, designed to build a professional-grade crypto exchange platform for the Indian market, named CryptoX. It includes a mobile application, a comprehensive administration panel, and a robust Express-based API server. The platform aims to support spot and future trading (planned), multi-wallet functionality, KYC verification (L0-3), VIP tiers, Earn programs, and INR/crypto deposits and withdrawals, adhering to Indian tax regulations (1% TDS).

The business vision is to capture a significant share of the Indian crypto exchange market by offering a feature-rich, secure, and user-friendly platform comparable to global leaders like Binance. The project's ambition is to provide a complete ecosystem for crypto trading, from basic transactions to advanced financial products, ensuring compliance with local regulations and providing a superior user experience.

# User Preferences

I want iterative development.
Ask before making major changes.
I prefer detailed explanations.

# System Architecture

The project is structured as a pnpm workspace monorepo utilizing Node.js 24 and TypeScript 5.9.

**UI/UX Decisions:**
- **Mobile App (crypto-exchange):** Designed with an Expo framework, inspired by Binance/CoinDCX, featuring mobile authentication, multi-wallet views, and KYC flows. It includes a sophisticated theme system supporting `auto`, `light`, and `dark` modes, with persistent settings and a carefully crafted Binance-style light palette that complements the existing dark theme. Animated elements, such as spring-animated segment toggles and price flash effects, enhance user engagement.
- **Admin Panel (admin):** A full web application with 17 pages, adopting a dark navy and yellow Binance-inspired theme. It provides comprehensive tools for managing users, KYC reviews, banking approvals, crypto assets (coins, networks, pairs, gateways), deposits/withdrawals, earn products, legal content (Markdown), settings, OTP providers, login logs, and live chat.
- **Live Price Feed:** Implemented with real-time price updates (using CoinGecko as the authoritative source) and a visual `LivePriceRow` component that shows price changes with animated background flashes and direction arrows. A micro-jitter mechanism is applied only at the WebSocket boundary for display purposes, ensuring authoritative prices used for trading and backend logic remain un-jittered.

**Technical Implementations:**
- **API Server (api-server):** Built with Express 5, it handles authentication via cookie sessions (`cx_session`) and bcryptjs, implements role-based access control (`requireRole`), and serves public, authenticated, and administrative endpoints.
- **Database:** PostgreSQL is used with Drizzle ORM for schema management. A comprehensive Drizzle schema covers users, KYC, banks, wallets, coins/networks/pairs, orders, trades, deposits, withdrawals, gateways, earn products, legal content, settings, OTP providers, chat, login logs, and deterministic deposit addresses.
- **Validation:** Zod (`zod/v4`) is used for schema validation, integrated with `drizzle-zod`.
- **API Codegen:** Orval generates API hooks and Zod schemas from OpenAPI specifications.
- **Build System:** esbuild is used for CJS bundle generation.
- **Authentication & Authorization:** Implements JWT for the Bicrypto adapter, HMAC-SHA256 for signing, and cookie-based sessions for legacy flows. Role-based middleware enforces access control.
- **OTP System:** A 6-digit OTP system with 5-minute TTL and max 5 attempts, with codes hashed at rest using SHA-256 and generated with `crypto.randomInt`. `consumeVerifiedOtp` is an atomic, single-use helper.
- **Money Flow & Wallets:** Utilizes atomic database transactions (`db.transaction` with `SELECT FOR UPDATE`) for critical money movements like withdrawals, deposits, and fund management, ensuring data integrity and race-safety. Wallet credit uses `onConflictDoUpdate` for race-safe upserts.
- **Go Service:** A skeleton Go service is included for future performance-critical components like the matching engine, WebSocket gateway, and futures.
- **Flutter Web Compatibility:** Specific adaptations for Flutter web, including using `SharedPreferences` for token persistence instead of `flutter_secure_storage` due to Web Crypto API limitations, and disabling service worker registration to prevent caching issues.
- **Admin Backend Status Page:** A dynamic admin UI that lists and inspects API endpoints, allowing for live JSON fetching, `curl` command generation, and manual triggering of non-GET requests with sample body suggestions.

# External Dependencies

- **Monorepo Tool:** pnpm workspaces
- **Node.js:** v24
- **TypeScript:** v5.9
- **API Framework:** Express v5
- **Database:** PostgreSQL
- **ORM:** Drizzle ORM
- **Validation Library:** Zod (`zod/v4`), `drizzle-zod`
- **API Codegen:** Orval
- **Build Tool:** esbuild
- **Mobile App Framework:** Expo
- **Hashing Library:** bcryptjs (for authentication)
- **Random Number Generation:** Node.js `crypto` module (`crypto.randomInt`)
- **Price Data Source:** CoinGecko API (for live crypto prices)
- **Storage (Mobile):** AsyncStorage (for theme mode persistence), `SharedPreferences` (for token persistence on web), `flutter_secure_storage` (for token persistence on native)