# Configuration Fields Explained

This document explains each field in the `app_config.json` file with examples and valid values.

## API Configuration

### baseUrl
- **Description**: Your backend API URL
- **Required**: Yes
- **Format**: Must include `https://` or `http://`
- **Examples**:
  ```
  "baseUrl": "https://api.yourexchange.com"
  "baseUrl": "https://backend.myapp.io"
  "baseUrl": "http://localhost:8000"  // For local development only
  ```

### wsBaseUrl
- **Description**: Your WebSocket URL for real-time updates
- **Required**: Yes
- **Format**: Must include `wss://` (secure) or `ws://` (insecure)
- **Examples**:
  ```
  "wsBaseUrl": "wss://api.yourexchange.com"
  "wsBaseUrl": "wss://ws.myapp.io"
  "wsBaseUrl": "ws://localhost:8000"  // For local development only
  ```

## App Branding

### appName
- **Description**: Your app's display name
- **Required**: Yes
- **Examples**:
  ```
  "appName": "BiCrypto"
  "appName": "MyExchange"
  "appName": "CryptoTrader Pro"
  ```

### appVersion
- **Description**: Current version of your app
- **Required**: Yes
- **Format**: Semantic versioning (major.minor.patch)
- **Examples**:
  ```
  "appVersion": "5.0.0"
  "appVersion": "5.1.0"
  "appVersion": "5.0.0-beta"
  ```

## Third-Party Services

### stripePublishableKey
- **Description**: Stripe payment gateway publishable key
- **Required**: No (leave empty string if not using Stripe)
- **Format**: Starts with `pk_test_` (test) or `pk_live_` (production)
- **Examples**:
  ```
  "stripePublishableKey": "pk_test_51ABC..."  // Test key
  "stripePublishableKey": "pk_live_51XYZ..."  // Production key
  "stripePublishableKey": ""                  // Not using Stripe
  ```

### googleServerClientId
- **Description**: Google OAuth client ID for Google Sign-In
- **Required**: No (leave empty string if not using Google Sign-In)
- **Format**: Long string ending with `.apps.googleusercontent.com`
- **Examples**:
  ```
  "googleServerClientId": "123456789-abcdef.apps.googleusercontent.com"
  "googleServerClientId": ""  // Not using Google Sign-In
  ```

## Exchange Settings

### defaultExchangeProvider
- **Description**: Default exchange provider (first 3 letters)
- **Required**: Yes
- **Valid Values**:
  - `"bin"` - Binance
  - `"kuc"` - KuCoin
  - `"okx"` - OKX
  - `"xt"` - XT
  - `"kra"` - Kraken
- **Default**: `"bin"`
- **Examples**:
  ```
  "defaultExchangeProvider": "bin"  // Binance
  "defaultExchangeProvider": "kuc"  // KuCoin
  "defaultExchangeProvider": "okx"  // OKX
  ```

### defaultTradingPair
- **Description**: Default trading pair shown in the app
- **Required**: Yes
- **Format**: `BASE/QUOTE` (uppercase)
- **Examples**:
  ```
  "defaultTradingPair": "BTC/USDT"
  "defaultTradingPair": "ETH/USDT"
  "defaultTradingPair": "BNB/BUSD"
  ```

## Feature Settings

### defaultShowComingSoon
- **Description**: Whether to show "Coming Soon" badges on features in development
- **Required**: Yes
- **Type**: Boolean
- **Values**:
  - `true` - Show "Coming Soon" badges on incomplete features
  - `false` - Hide incomplete features entirely
- **Examples**:
  ```
  "defaultShowComingSoon": true   // Show features with "Coming Soon" badge
  "defaultShowComingSoon": false  // Hide incomplete features
  ```

## Performance Settings

### settingsCacheDuration
- **Description**: How long to cache app settings (in seconds)
- **Required**: Yes
- **Type**: Integer
- **Recommended Values**:
  - `3600` - 1 hour (recommended)
  - `1800` - 30 minutes
  - `7200` - 2 hours
  - `0` - No caching (not recommended)
- **Examples**:
  ```
  "settingsCacheDuration": 3600  // Cache for 1 hour
  "settingsCacheDuration": 1800  // Cache for 30 minutes
  ```

### backgroundUpdateInterval
- **Description**: How often to update market data in background (in seconds)
- **Required**: Yes
- **Type**: Integer
- **Recommended Values**:
  - `60` - Every minute (recommended for most users)
  - `30` - Every 30 seconds (higher server load)
  - `120` - Every 2 minutes (lower server load)
  - `300` - Every 5 minutes (minimal server load)
- **Examples**:
  ```
  "backgroundUpdateInterval": 60   // Update every minute
  "backgroundUpdateInterval": 30   // Update every 30 seconds
  ```

## Complete Example

```json
{
  "baseUrl": "https://api.myexchange.com",
  "wsBaseUrl": "wss://api.myexchange.com",
  "appName": "MyExchange",
  "appVersion": "5.0.0",
  
  "stripePublishableKey": "pk_live_51ABC123...",
  "googleServerClientId": "123456-abc.apps.googleusercontent.com",
  
  "defaultExchangeProvider": "bin",
  "defaultTradingPair": "BTC/USDT",
  
  "defaultShowComingSoon": true,
  
  "settingsCacheDuration": 3600,
  "backgroundUpdateInterval": 60
}
``` 