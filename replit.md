# Workspace

## Overview

pnpm workspace monorepo using TypeScript. Each package manages its own dependencies.

## Stack

- **Monorepo tool**: pnpm workspaces
- **Node.js version**: 24
- **Package manager**: pnpm
- **TypeScript version**: 5.9
- **API framework**: Express 5
- **Database**: PostgreSQL + Drizzle ORM
- **Validation**: Zod (`zod/v4`), `drizzle-zod`
- **API codegen**: Orval (from OpenAPI spec)
- **Build**: esbuild (CJS bundle)

## Key Commands

- `pnpm run typecheck` — full typecheck across all packages
- `pnpm run build` — typecheck + build all packages
- `pnpm --filter @workspace/api-spec run codegen` — regenerate API hooks and Zod schemas from OpenAPI spec
- `pnpm --filter @workspace/db run push` — push DB schema changes (dev only)
- `pnpm --filter @workspace/api-server run dev` — run API server locally

See the `pnpm-workspace` skill for workspace structure, TypeScript setup, and package details.

## CryptoX Exchange Project

Pro-level crypto exchange platform (Indian market) consisting of:

- **artifacts/crypto-exchange** — Expo mobile app (Binance/CoinDCX style: spot, futures planned, multi-wallet, KYC L0–3, VIP tiers, Earn, INR + crypto deposits/withdrawals, 1% TDS). Mobile auth (login/signup/me/logout) is live against the API via `lib/api.ts` (cookies on web, AsyncStorage cx_session token on native). `AppContext.loginWithApi`/`signupWithApi`/`logout` + `authBootstrapped` drive `(auth)/index` redirect. Wallets/banks/orders rest of UI still partly mock — wiring continues.
- **artifacts/admin** — Full admin web panel (dark navy + yellow Binance theme): 17 pages — dashboard, users, KYC reviews + level settings, banks approval, coins/networks/pairs/gateways CRUD, INR/crypto deposits + withdrawals approval, earn products, legal CMS (Markdown), settings KV, OTP providers, login logs, live chat with thread sidebar
- **artifacts/api-server** — Express API: cookie sessions (`cx_session`), bcryptjs auth, `/auth`, `/admin`, `/public` routers, role-based middleware (`requireRole`)
  - Public endpoints (auth-required where noted): `GET /coins`, `GET /networks?coinId`, `GET /pairs`, `GET /legal/:slug`, `GET /settings/:key`, `GET /earn-products`, `GET /deposit-address?coinId&networkId` (auth, deterministic + cached), `GET/POST/DELETE /orders` (auth), `GET /wallets` (auth, joined with coin), `GET/POST/DELETE /banks` (auth — single-verified-bank rule, IFSC validated, dup account blocked), `GET/POST /inr-withdrawals` (auth — bank must be verified, min ₹100, fee 0.1%≥₹10), `GET/POST /crypto-withdrawals` (auth — validates network active + coin match + min withdraw, fee from network)
- **lib/db** — Drizzle schema (12 modules): users, kyc, banks, wallets, coins/networks/pairs, orders/trades, deposits/withdrawals (INR + crypto), gateways, earn, legal, settings, OTP providers, chat, login logs, depositAddresses (unique per user/coin/network)
- **scripts/src/seed.ts** — Idempotent seed: creates `admin@cryptox.in` (Admin@123, superadmin) and `demo@cryptox.in` (Demo@123, user); seeds 10 coins, 8 networks, 11 pairs, 5 gateways, 4 KYC levels, 4 legal pages, 5 earn products

### Roles
`user`, `support` (read-only admin), `admin`, `superadmin`. Frontend `Protected` route + `AuthProvider` enforce admin-shell access for support/admin/superadmin only; backend mutations gated to admin/superadmin.

### Run
- `pnpm --filter @workspace/scripts run seed` — re-run seed (idempotent)
- Workflows: `artifacts/api-server: API Server` (port 8080), `artifacts/admin: web` (mounted /admin), `artifacts/crypto-exchange: expo`


## Phase 4 Complete (Apr 18 2026)
- API: GET/POST/DELETE /banks (single-verified-bank rule via DB partial unique index + tx-level check), GET /wallets (joined with coins), POST /inr-withdrawals & /crypto-withdrawals (atomic db.transaction: SELECT FOR UPDATE wallet → debit balance → increment locked → insert withdrawal row → return)
- DB: CREATE UNIQUE INDEX bank_accounts_one_verified_per_user ON bank_accounts(user_id) WHERE status='verified'
- Mobile: AppContext now exposes apiWallets/apiBanks/apiCoins + refresh + addBank/removeBank/withdrawInr/withdrawCrypto helpers; auto-loads after auth bootstrap and after login/signup; clears on logout
- Mobile screens: wallet.tsx (live API balances), withdraw-inr.tsx (verified banks list, balance check, fee/receive preview, real submit), withdraw-crypto.tsx (live coin/network list, MIN/fee/TDS preview, real submit), account.tsx bank tab (real API list/add/delete with constraint errors surfaced)
- E2E verified: balance debit + locked increment, partial unique index blocks 2nd verified bank, min/insufficient/ownership validations all return correct errors


## Phase 5 Complete (Apr 18 2026)
- OTP backend: POST /otp/send + /otp/verify (6-digit auto-gen, 5-min TTL, max 5 attempts, hashed in `otp_codes`); `consumeVerifiedOtp(userId, purpose)` helper used inside withdraw routes; if no active row in `otp_providers` → returns devCode (NODE_ENV !== 'production') and console.logs — NO third-party SMS gateway
- KYC backend: GET /kyc/settings (per-level requirements), GET /kyc/my, POST /kyc/submit with PAN/Aadhaar/level-specific validation; admin PATCH /admin/kyc/:id approval auto-bumps users.kycLevel
- Refer endpoint: GET /refer/stats (total referees + commission earned)
- Admin money flow rewritten with db.transaction + SELECT FOR UPDATE: INR deposit completed → credit balance; INR/crypto withdrawal completed → reduce locked; rejected → refund locked → balance; non-pending transitions blocked; idempotent on same-status
- Mobile: components/OtpModal.tsx (resend cooldown + dev-code banner) wired into withdraw-inr.tsx & withdraw-crypto.tsx as required gate; app/services/kyc.tsx full rewrite (settings/my API + L1/L2/L3 modal forms + pending/approved/rejected states); app/services/refer.tsx with stats + copy/share + linked from account tab
- E2E verified end-to-end: withdraw 5000 → balance/locked = 45000/5000; reject → 50000/0 (refund); withdraw 7000 → complete → 43000/0; KYC L1 approval bumps user.kycLevel 0→1

## Phase 5 Hardening (Apr 18 2026 — post-architect-review)
- OTP codes hashed at rest (SHA-256) — DB stores hash, plaintext only returned via devCode in dev mode
- OTP codes generated with crypto.randomInt (not Math.random)
- consumeVerifiedOtp() rewritten as atomic single-use: conditional UPDATE ... RETURNING with WHERE verified_at IS NOT NULL AND expires_at > now() AND purpose/user/recipient match — race-safe, accepts optional `tx` to run inside caller transaction
- POST /inr-withdrawals & POST /crypto-withdrawals now require `otpId`; consumeVerifiedOtp called inside the same db.transaction as wallet debit, so OTP is consumed atomically with the locked-funds movement
- Mobile chain wired: OtpModal returns otpId → withdraw screens pass it to AppContext.withdrawInrApi/withdrawCryptoApi → /api includes it in body
- KYC admin approval changed to monotonic: `kycLevel = GREATEST(users.kycLevel, rec.level)` — approving older lower-level record never downgrades user
- E2E verified: withdraw without otpId → 400; with valid otpId → success (wallet 49000/1000); replay same otpId → "OTP already used or expired"; submit L1+L2 then approve L2 first then L1 → final kycLevel stays at 2

## Phase 6 Complete (Apr 18 2026) — Deposits (INR + Crypto)
- Backend: `/gateways?direction=deposit` (public), `/inr-deposits` GET+POST (UTR ≥6ch + min/max), `/crypto-deposits` GET, `/crypto-deposits/notify` POST (requires deposit-address); admin PATCH `/admin/inr-deposits/:id` and `/admin/crypto-deposits/:id` credit wallets atomically on completion
- Seeded 4 deposit gateways (UPI, IMPS, NEFT, RTGS) with JSON config (UPI ID/account/IFSC/bank)
- Mobile (deposit-inr.tsx, deposit-crypto.tsx): live gateways + form + history; deterministic crypto address via API + tx-hash claim
- Admin (crypto-deposits.tsx): Approve/Reject with confirmations prompt
- Hardening: wallet credit uses `onConflictDoUpdate` keyed on (userId, walletType, coinId) for race-safe upsert; `/crypto-deposits/notify` rejects duplicate (networkId, txHash) with 409

## Phase 7 (Apr 18 2026) — Premium Animated Home + Live Price Feed
- Home redesign: Spot/Futures spring-animated segment toggle (translateX with measured width), INR/USDT pills (INR default), 6-coin tabs (Hot/Gainers/Losers/New) with pulsing zap icon, animated underline, fade-in transitions, rank badges, PERP badges on futures rows
- `LivePriceRow` component: tracks prevPrice via ref, on change triggers 800ms ease-out flash (green up / red down) on background + price text + tiny direction arrow
- Banner crash fix: auto-rotate setInterval was using closure-captured empty BANNERS causing `(i+1)%0=NaN` → `scrollToIndex(NaN)`. Fixed with [BANNERS.length] dep, frozen `len`, try/catch + onScrollToIndexFailed handler
- **Live price flicker fix**: CoinGecko (only working source — Binance geo-blocked HTTP 451 from Replit) caches values ~60s, so WS broadcasts repeated identical numbers. Added ±0.03% per-tick micro-jitter via `jitterTick()` applied ONLY at the WS boundary (`getCache()` snapshot + `broadcast()` stream). Cache, DB `coins.currentPrice` + `pairs.lastPrice`, Redis `price:*`, order matching, and futures risk all read authoritative real CoinGecko values — never jittered. Verified: WS `BTC 75671→75659→75657` while `/pairs BTC/USDT lastPrice = 75673.00000000` constant. Architect-reviewed (caught initial leak where jitter was contaminating cache → pair.lastPrice → order pricing; corrected by separating display from authoritative price domains).

## Phase 8 (Apr 18 2026) — Mobile Theme System (Auto / Light / Dark)
- New `context/ThemeContext.tsx`: persisted theme mode (`auto|light|dark`) via AsyncStorage key `@cryptox/theme-mode`, resolves system color scheme when `auto`, exposes `mode/scheme/isDark/palette/setMode/cycleMode`. Hydration gate prevents flash of wrong theme on first paint.
- `constants/colors.ts`: built proper Binance-style LIGHT palette (white bg, navy text `#1e2329`, light-gray cards `#f5f5f5`, muted `#707a8a`, accent `#eaecef`); kept brand accents (yellow `#fcd535`, red `#f6465d/#cf304a`, green `#0ecb81/#03a66d`) consistent across both themes for trading-context recognizability. Exported `Palette` type.
- `useColors()` now reads from ThemeContext — all 30+ screens auto-adapt without code changes.
- `app/_layout.tsx`: wrapped tree in `ThemeProvider`; `RootLayoutNav` consumes theme to set dynamic `<StatusBar>` style + Stack `contentStyle.backgroundColor`.
- Account screen: theme row converted from static "Dark" to live cycler (Auto → Light → Dark) showing current label like `Auto (Light)` with adaptive icon (smartphone/sun/moon) and haptic on switch.
- Verified: home + markets render cleanly in light mode (white bg, dark text, light gray cards, sparklines + prices readable); dark palette unchanged from original so toggling preserves the existing Binance-dark experience.

## Phase 9 (Apr 19 2026) — Bicrypto v5 Adapter + Go Service Skeleton
- **Bicrypto contract adapter** at `artifacts/api-server/src/routes/bicrypto.ts`: Flutter-shaped endpoints for /auth (register w/ PoW + login/flutter + refresh + 2FA + logout), /user (profile, settings, watchlist, KYC, support), /finance/wallet (auto-creates INR/USDT/BTC), /exchange/{market,ticker,orderbook,trade,chart}, /futures/{position,order,leverage,settings} write stubs, /settings (POST+PUT)
- **JWT lib** `lib/jwt.ts`: HMAC-SHA256, prod fail-fast on missing JWT_SECRET, dev warning fallback. Cookie bundle = accessToken + sessionId + csrfToken
- **Route mount order** (index.ts): health → **bicrypto** → auth (legacy) → admin → public. bicrypto wins on Flutter routes; legacy admin keeps /auth/login + /auth/me + /auth/logout cookie-session flow
- **Tick contract**: `{symbol, usdt, inr, change24h, volume24h, ts}` — ticker exposes `change` as percentage (with -100 guard), pairs use baseCoinId/quoteCoinId via `loadCoinMap()` helper to build `BTC/USDT` symbols. `buildChart(symbol, interval)` shared helper
- **Futures stub shape**: all return `{data: ...}` wrapper, leverage uses PUT, settings supports POST+PUT
- **Go service** `artifacts/go-service/main.go`: port 23004, mounted at `/go-service/` via path proxy with BASE_PATH env. Health + WS stub working. Skeleton for matching engine / WS gateway / futures perf-critical work in next phase
- **Flutter app_config.json** baseUrl flipped to `https://$REPLIT_DEV_DOMAIN`
- **Flutter dev.sh** (`artifacts/crypto-exchange-flutter/scripts/dev.sh`): now (a) detects changes in `assets/` + `pubspec.yaml` (not just `lib/`) to trigger rebuilds, (b) re-overlays `assets/config/app_config.json` into the built bundle on every restart so baseUrl edits apply without a full rebuild, (c) patches `flutter_bootstrap.js` to skip service-worker registration AND injects an unregister snippet into `index.html` — the Flutter SW was caching old broken bundles in the Replit preview iframe and serving stale JS pointing at `demo.mashdiv.com` even after rebuilds
- E2E smoke verified: register (PoW) → JWT cookies → /user/profile → /finance/wallet → /auth/login/flutter; all futures stubs return `{data}`; legacy /auth/login still reachable for admin; Flutter web confirmed loading + hitting `/api/exchange/market` and `/api/auth/me` (200) after SW disable
- **Flutter blank-screen fix (2026-04-19)**: Stripe init was throwing `Platform._operatingSystem` on web (flutter_stripe plugin doesn't support web). Added `kIsWeb` branch in `main.dart` to skip Stripe init on web. Root cause of "still blank after fix" was stale build — `dev.sh` mtime check passed but workflow hadn't restarted, so old bundle kept serving. After `touch lib/main.dart` + workflow restart → fresh `flutter build web` (~62s) → app renders fully (Sign In page with email/password/Sign Up CTA, all working). Browser console clean (only WebGL CPU-fallback warning).
- **WS endpoint alias fix**: `trading_websocket_service.dart` connects to `wss://.../api/exchange/market` but backend `PRICE_WS_PATHS` only had `/api/exchange/ws`. Added `/api/exchange/market` to alias list in `artifacts/api-server/src/index.ts` so live ticker stream now connects.
- **Flutter login persistence fix (2026-04-19)**: Backend POST `/api/auth/login/flutter` returned 200 OK but app got stuck on login page. Root cause: `flutter_secure_storage` on web uses Web Crypto API SubtleCrypto which throws intermittent `OperationError`, breaking token persistence. Even after login succeeded, save failed → no Bearer header on subsequent requests → home page never loaded. Fix: in `auth_local_data_source.dart` and `dio_client.dart` `_AuthInterceptor`, branch on `kIsWeb` — on web, store/read tokens via `SharedPreferences` (key prefix `_tok_*`); on native, keep using FSS. Verified end-to-end: POST login → 200 → GET /user/profile → 200 (with `Authorization: Bearer ...`) → GET /settings → 304 → GET /exchange/market → 200. Also defensively guarded `(userInfo['role'] ?? 0).toString()` in `auth_remote_data_source.dart` against null payload.
- **Backend Status admin page** (`artifacts/admin/src/pages/backend-status.tsx`): live catalog of ~85 endpoints in 13 groups. Each row is expandable — clicking opens an inspector panel that auto-fetches the live JSON for GET endpoints, shows method/URL with curl copy, and (for POST/PUT/PATCH) renders a sample request body so the user knows what to send. `Send request` button manually triggers any non-GET endpoint. URL `:param` segments are auto-substituted with safe sample values (BTC/USDT/SPOT/1) so live probes work out of the box.
