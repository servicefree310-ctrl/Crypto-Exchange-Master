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

