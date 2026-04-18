# CryptoX Exchange (Pro Edition)

Pro-level mobile crypto exchange built with Expo Router, mimicking Binance/CoinDCX UX.

## Architecture
- **Routing**: expo-router file-based; tabs in `app/(tabs)/`, services in `app/services/`
- **State**: `context/AppContext.tsx` — single source for user, wallets, KYC, fees, earn, transactions
- **Theming**: `constants/colors.ts` (dark + light pro palettes), `hooks/useColors.ts`
- **Persistence**: AsyncStorage (theme, language, user)
- **Mock prices**: 3s tick simulation in AppContext

## Key Domains
1. **Wallet types** (`WalletType`): spot, inr, earn, futures — separate balance arrays per type
2. **KYC levels** (0–3): `KycLevelInfo` with daily/monthly/deposit limits and feature gating
3. **Fee tiers** (Regular → VIP 5): volume-based; auto-derived from `user.monthlyVolume`
4. **Earn**: Simple (flexible, unlock anytime) + Advanced (locked term, fixed APY, auto-maturity)
5. **TDS**: 1% applied on crypto sells/withdrawals (Indian regulation)

## Service Screens (`app/services/`)
- `deposit-inr` — UPI/IMPS/NEFT/RTGS with bank details
- `withdraw-inr` — to verified bank account
- `deposit-crypto` — multi-network with QR
- `withdraw-crypto` — address + network + 1% TDS preview
- `transfer` — between own wallet types
- `earn` — Simple/Advanced/My Positions tabs
- `kyc` — level cards with required docs and unlocked features
- `fees` — VIP tier table with progress to next tier
- `banks` — add/under_review/verified bank accounts

## Tabs
- `index` — home with portfolio, quick actions, service grid, gainers/losers, market
- `markets` — full coin list
- `trade` — spot trading with order book + chart
- `wallet` — wallet type selector + balances + 5 quick actions
- `account` — settings, KYC, security

## Conventions
- All routes use `as any` for typed-route bypass (some routes lack generated types)
- Use `useColors()` instead of hardcoded color values
- Use `Header` component for service screens for consistent back nav
- Currency formatting: ₹ + `toLocaleString('en-IN')`
