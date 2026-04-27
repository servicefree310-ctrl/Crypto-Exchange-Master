# Overview

This project is a pnpm workspace monorepo using TypeScript, designed to build a professional-grade crypto exchange platform primarily targeting the Indian market. It includes a mobile application, a comprehensive admin web panel, and a desktop web user portal. The platform aims to offer spot and future trading, multi-wallet support, KYC verification (L0-3), VIP tiers, Earn programs, and facilitate INR and crypto deposits/withdrawals, adhering to Indian tax regulations (1% TDS).

The business vision is to capture a significant share of the Indian crypto exchange market by providing a feature-rich, user-friendly, and compliant platform. The project ambitions include high scalability, robust security, and a seamless user experience across all interfaces.

# User Preferences

I prefer iterative development and want to be asked before major changes are made.

# System Architecture

The project is structured as a pnpm workspace monorepo, leveraging Node.js 24 and TypeScript 5.9.

**UI/UX Decisions:**
- **Mobile App (artifacts/crypto-exchange):** Designed for a Binance/CoinDCX style experience, featuring a dynamic theme system (Auto/Light/Dark) with persisted preferences and adaptive icons. Brand accents (yellow, red, green) are consistent for trading context recognition.
- **Admin Panel (artifacts/admin):** Premium **Zebvix Admin Console** with dark navy + gold/amber Binance-style theme across 28 pages. Layout: Zebvix-branded sidebar with grouped nav (Overview / Users & Compliance / Markets & Trading / Treasury / Earn & CMS / System) and gold left-bar active indicator; sticky header with breadcrumbs, Cmd+K command palette (jump-to-page), notifications icon, and avatar dropdown (role-gated — Settings is admin/superadmin only). **Premium dashboard** rewritten with greeting hero + system-status pill, 4 hero KPI cards (Users, 24h Futures Volume, Open Positions, Pending Approvals), Pending Approvals breakdown (6 quick-link cards), System Health row (Futures Engine, Deposit Sweeper, HD Vault, API Server) wired to existing `/admin/futures-engine/status`, `/admin/sweeper/status`, `/admin/vault/status` endpoints, and Recent Users / Pending INR Withdrawals teasers. **Reusable premium components** in `src/components/premium/`: `PageHeader`, `PremiumStatCard` (gradient orb + delta chip + loading skeleton), `StatusPill` (status-string → variant map), `EmptyState`, `SectionCard`. Premium login screen with Zebvix logo, ambient gold glow, and `premium-card-hero` shell. CSS utilities (`gold-text`, `gold-bg`, `premium-card`, `premium-card-hero`, `gold-glow`, `stat-orb`, `nav-active-bar`, `scroll-fade`) added to `src/index.css`.
- **User Portal (artifacts/user-portal):** Utilizes a dark gold/amber theme (Binance-style), providing Home, Markets, Trade, and Futures terminals with `lightweight-charts` for candlesticks, depth-bar orderbook, and live price feeds. Live price updates incorporate micro-jittering for display without affecting authoritative pricing.
  - **Account pages:** Profile (hero with name/UID/KYC badge, stats strip, action grid, referral panel, KYC level overview), KYC (3 level cards, per-level submit dialogs with PAN/Aadhaar regex + file upload, current achieved level), Bank Accounts (list/add/delete with IFSC validation + single-verified-bank rule), Settings (4 tabs — Account / Security / Notifications / Preferences; 2FA enable/disable via OTP, change-password, sessions list with revoke-others), Earn (hero with totals, product grid with KYC L1/L2 gating + filter/sort, subscribe with projected-earn breakdown + auto-renew, redeem with early-penalty math), Invite & Earn (gradient hero with code + invite link + QR dialog, share buttons for WhatsApp/Telegram/X/Email + Web Share API, stats strip, 3-step "How it works", commission tier breakdown Bronze/Silver/Gold, invitee table, FAQ accordion). All pages use react-query, amber/orange brand gradient, and shared dialog patterns. Routes wired in `App.tsx`; AppHeader user dropdown surfaces KYC / Banks / Earn / Invite & Earn / Settings & 2FA. Signup page reads `?ref=CODE` query param to auto-attribute referrals.
  - **Earn data contract:** Backend `/api/earn/positions` exposes both legacy DB names (`maturedAt`, `autoMaturity`) and frontend-canonical aliases (`maturityAt`, `autoRenew`). `POST /api/earn/subscribe` accepts both `autoRenew` and `autoMaturity` keys. Server enforces KYC Level 1 for any subscribe and Level 2 for locked products (durationDays > 0), matching the UI gates so direct API calls cannot bypass.
  - **Production hardening (Apr 2026):** User portal now exposes `/p2p` and `/convert` stub pages (premium "Coming Soon" cards) so header links never 404. Orders and Portfolio rewritten with shared premium primitives (`PageHeader`, `PremiumStatCard`, `SectionCard`, `EmptyState`, `StatusPill`) — the same set ported from admin into `src/components/premium/` plus the gold-themed CSS tokens (`gold-text`, `premium-card`, `premium-card-hero`, `stat-orb`, `gold-bg`, `gold-bg-soft`, `gold-glow`) appended to `src/index.css`. App-root `ErrorBoundary` (Hinglish recovery card) wraps the user portal *inside* a `QueryErrorResetBoundary` so "Try Again" reliably clears React Query error state instead of re-throwing on remount.
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

**Production Observability & Validation (api-server, Apr 2026):**
- **Request correlation:** `src/middleware/requestId.ts` honors inbound `X-Request-Id` (regex `^[a-zA-Z0-9_-]{1,64}$`, log-injection-safe) or generates a `crypto.randomUUID()` fallback, sets it on `req.id` (reused by pino-http's existing `IncomingMessage.id` slot) and echoes it in the response header. Wired before pinoHttp in `app.ts` via `genReqId`, so every log line is tagged with `reqId=…` for cross-service tracing. `bicrypto.ts` and `otp.ts` migrated from `console.log/warn` to `req.log` / structured logger.
- **Liveness vs readiness:** `/api/healthz` is a cheap liveness probe (200 + `{status:"ok",ts}`). `/api/readyz` is a deep dependency check — runs `sql\`select 1\`` against Postgres and `redis.ping()` in parallel, both wrapped in a 1500ms timeout, returns 503 if either fails. Includes `ms` timing per check for SLO dashboards.
- **Zod request validation:** `RegisterBody`/`LoginBody` zod schemas in `routes/auth.ts` and `PlaceOrderBody` (`.strict()` + `superRefine` enforcing limit-needs-price / market-forbids-price) in `routes/orders.ts`, applied via a small `validate()` middleware that returns `{error, field, issues}` 400 on failure. `zod` added as a direct dep via `catalog:`.

**Admin hardening (Apr 2026):**
- **Global ErrorBoundary** (`src/components/ErrorBoundary.tsx`) wraps the admin tree inside a `QueryErrorResetBoundary` so the retry button clears React Query error state.
- **401 auto-redirect:** `src/lib/api.ts` redirects to `/admin/login` on any 401 response, with an *exact-match* silent-list (`/auth/me`, `/auth/login`, `/auth/logout`) — querystrings are stripped before matching so `/auth/me?force=1` is still silenced; future routes like `/auth/logout-all` won't accidentally inherit silent behavior.
- **Native dialog removal:** `users.tsx` (Disable 2FA, Force Logout) and `kyc-templates.tsx` (custom field add) now use shadcn `AlertDialog`/`Dialog` with validated `Input` instead of `window.confirm`/`prompt`/`alert`.

**Multi-server / Horizontal Scaling (api-server):**
- **Leader Election:** `src/lib/leader.ts` uses Redis `SET key NX EX 15` to elect a single leader across all replicas. Each instance has a `crypto.randomUUID()` `INSTANCE_ID`. A 5s heartbeat extends the TTL via an atomic Lua script (compare-and-extend on the stored UUID), so a crashed leader's lock auto-expires within 15s and any replica can take over.
- **Leader-gated Workers:** All recurring tick bodies are guarded by `isLeader()` so they only run on the leader: `price-service` (external feed fetch + DB writes), `withdrawal-watcher`, `deposit-sweeper`, `bot-service`, `pair-stats`, `cache-warmup` refresh, and the 3 `futures-engine` ticks (auto-funding 60s, settle 30s, risk 5s). Boot-time `warmAllCaches()` and `restoreBooksOnBoot()` (Go matching engine reseed) also gated. Externally-callable functions (e.g. admin manual triggers) remain unrestricted.
- **WS Fanout:** `src/lib/ws-fanout.ts` lets followers serve real-time price WebSocket clients. The leader publishes price ticks tagged with its `INSTANCE_ID` to Redis pub/sub channel `prices.tick`; followers subscribe and call `injectExternalTick()` on their local `price-service`, which fans out to their connected WS subscribers. The leader skips its own published ticks (by `INSTANCE_ID` match) to avoid double-broadcast.
- **Distributed Rate Limits:** All 3 `express-rate-limit` instances (global / auth / OTP) use `rate-limit-redis` v4 with a shared Redis backend (key prefix `cryptox:rl:{global,auth,otp}:`). Without this, an attacker could spread requests across N replicas to hit N×limit. The `sendCommand` callback fetches the live ioredis client at command-time so it survives restarts.
- **Bootstrap Order:** `src/index.ts` `bootstrap()` runs `initRedis()` → `startLeaderElection()` (awaits first heartbeat) → `startWsFanout()` → dynamic `import("./app")` → `http.createServer` → `server.listen` → workers. App must be imported AFTER Redis is connected because `RedisStore`'s constructor calls `SCRIPT LOAD` on the Redis client.
- **Single-instance Fallback:** When Redis is unavailable, `leader.ts` returns `isLeader() === true` so the lone instance still does all work. Rate-limit `sendCommand` throws and `express-rate-limit` fails open (logs + allows) during the boot window.
- **Env Vars:** `LEADER_LOCK_KEY` (default `cryptox:leader:global`), `LEADER_TTL_SEC` (default 15), `LEADER_HEARTBEAT_MS` (default 5000). Multi-server deployment requires all replicas to share the same Redis (the embedded redis-server is replaced by an external one in production via `REDIS_URL`).

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