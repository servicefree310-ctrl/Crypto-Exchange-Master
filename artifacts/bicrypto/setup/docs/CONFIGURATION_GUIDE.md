# BiCrypto Mobile App Configuration Guide

## Overview

BiCrypto Mobile App uses a JSON configuration file to store environment-specific settings. This allows each user to customize their app without modifying source code, preventing corruption and making updates easier.

**What's configured in the app:**
- Backend API URLs
- App name and version
- API keys (Stripe, Google)
- Default exchange settings
- Cache/performance settings

**What's controlled by your backend:**
- Feature availability (Futures, P2P, Staking, etc.)
- User permissions and limits
- Available markets and trading pairs
- All business logic and rules

## Quick Start

1. Navigate to `assets/config/app_config.json`
2. Update the configuration values with your specific settings
   - Check `QUICK_REFERENCE.txt` for valid values
   - See `CONFIG_FIELDS_EXPLAINED.md` for detailed explanations
3. Build and run the app

## Configuration File Location

```
mobile/
├── assets/
│   └── config/
│       ├── app_config.json              <-- Your configuration file
│       ├── app_config.example.json      <-- Example template
│       ├── CONFIG_FIELDS_EXPLAINED.md   <-- Detailed field documentation
│       └── QUICK_REFERENCE.txt          <-- Quick reference for values
```

## Configuration Options

### Required Settings

```json
{
  "baseUrl": "https://your-backend-url.com",
  "wsBaseUrl": "wss://your-backend-url.com",
  "appName": "YourAppName",
  "appVersion": "5.0.0"
}
```

- **baseUrl**: Your backend API URL (must include https://)
- **wsBaseUrl**: Your WebSocket URL (must include wss://)
- **appName**: The name of your app
- **appVersion**: Current version of your app

### Optional API Keys

```json
{
  "stripePublishableKey": "pk_test_...",
  "googleServerClientId": "YOUR_GOOGLE_CLIENT_ID"
}
```

- **stripePublishableKey**: Your Stripe publishable key (leave empty if not using Stripe)
- **googleServerClientId**: Google OAuth client ID (leave empty if not using Google Sign-In)

### Exchange Configuration

```json
{
  "defaultExchangeProvider": "bin",
  "defaultTradingPair": "BTC/USDT"
}
```

- **defaultExchangeProvider**: Exchange provider code (use first 3 letters)
  - `"bin"` - Binance
  - `"kuc"` - KuCoin
  - `"okx"` - OKX
  - `"xt"` - XT
  - `"kra"` - Kraken
- **defaultTradingPair**: Default trading pair (e.g., "BTC/USDT", "ETH/USDT")

### Feature Settings

```json
{
  "defaultShowComingSoon": true
}
```

- **defaultShowComingSoon**: Whether to show "Coming Soon" badges
  - `true` - Show features with "Coming Soon" badge
  - `false` - Hide incomplete features entirely

### Performance Settings

```json
{
  "settingsCacheDuration": 3600,
  "backgroundUpdateInterval": 60
}
```

- **settingsCacheDuration**: How long to cache settings (in seconds)
- **backgroundUpdateInterval**: How often to update market data in background (in seconds)

## Complete Configuration Example

```json
{
  "baseUrl": "https://api.yourexchange.com",
  "wsBaseUrl": "wss://api.yourexchange.com",
  "appName": "MyExchange",
  "appVersion": "5.0.0",
  
  "stripePublishableKey": "",
  "googleServerClientId": "",
  
  "defaultExchangeProvider": "bin",
  "defaultTradingPair": "BTC/USDT",
  
  "defaultShowComingSoon": true,
  
  "settingsCacheDuration": 3600,
  "backgroundUpdateInterval": 60
}
```

**For detailed explanations of each field, see:** `assets/config/CONFIG_FIELDS_EXPLAINED.md`

**Documentation location:** All setup documentation is in the `setup/docs/` folder.

## Important Notes

1. **Do NOT modify** `lib/core/constants/api_constants.dart` - it now reads from your config file
2. **JSON syntax**: Ensure your JSON is valid (no trailing commas, proper quotes)
3. **URLs**: Always include protocol (https:// or wss://)
4. **Cache settings**: Lower values = more frequent updates but higher server load
5. **Feature availability**: Features/addons are controlled by your backend settings, not the app configuration

## Troubleshooting

### App shows "Configuration Error"

1. Check if `assets/config/app_config.json` exists
2. Validate JSON syntax (use jsonlint.com)
3. Ensure all required fields are present
4. Check file permissions

### Features/Addons not showing

Features and addons are controlled by your backend settings. If features are not showing:
1. Check your backend admin panel settings
2. Ensure the user has proper permissions
3. Verify the API is returning the correct settings
4. Clear app cache if needed

### Connection issues

1. Verify baseUrl and wsBaseUrl are correct
2. Ensure URLs include https:// or wss://
3. Check if your backend is running

## Performance Impact

The configuration is loaded once at app startup, so there's **no performance impact** during runtime. The app reads the configuration into memory and uses it throughout the session.

## Updating Configuration

When you need to change settings:

1. Modify `assets/config/app_config.json`
2. Rebuild the app
3. The new configuration will be used

For production apps, you may want to implement remote configuration to update settings without rebuilding.

## Security Best Practices

1. **Never commit** sensitive API keys to version control
2. Use different configurations for development and production
3. Consider encrypting sensitive values
4. Implement proper backend authentication

## Support

If you encounter issues:

1. Check this guide first
2. Validate your JSON configuration
3. Review the error messages in the app
4. Contact support with your configuration (remove sensitive data)

## Advanced Usage

### Multiple Environments

Create separate config files:
- `app_config.dev.json` - Development
- `app_config.staging.json` - Staging  
- `app_config.prod.json` - Production

Then rename the appropriate file to `app_config.json` before building.

### Remote Configuration

For production apps, consider implementing remote configuration:
1. Store config on your server
2. Fetch on app startup
3. Cache locally with expiration
4. Fall back to bundled config if offline

This allows updating configuration without app updates. 