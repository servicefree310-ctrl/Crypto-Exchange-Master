# App Name Configuration Guide

## Problem Solved

Previously, when users configured their app name through the installer, it would only change the name displayed **inside** the app, but the app would still appear as "mobile" on the device's home screen and app drawer.

## What Was Fixed

The installer now properly updates the app name in **three different places**:

### 1. JSON Configuration (`assets/config/app_config.json`)
- Controls the app name displayed **inside** the app
- Used in app bars, about pages, and throughout the UI

### 2. Android Configuration (`android/app/src/main/AndroidManifest.xml`)
- Controls what appears on Android home screen and app drawer
- Updated line: `android:label="YourAppName"`

### 3. iOS Configuration (`ios/Runner/Info.plist`)
- Controls what appears on iOS home screen
- Updates both:
  - `CFBundleDisplayName` (home screen name)
  - `CFBundleName` (internal bundle name)

## How It Works

When you run the installer and enter your app name:

1. **User Input**: "MyAwesomeCryptoApp"
2. **Automatic Updates**:
   - ✅ JSON config updated
   - ✅ Android manifest updated
   - ✅ iOS Info.plist updated
3. **Result**: App appears as "MyAwesomeCryptoApp" everywhere

## Before vs After

### Before (Old Behavior)
- **Device Home Screen**: "mobile" (hardcoded)
- **Inside App**: "YourAppName" (from config)
- **Problem**: Inconsistent naming

### After (Fixed Behavior)
- **Device Home Screen**: "YourAppName" ✅
- **App Drawer**: "YourAppName" ✅
- **Inside App**: "YourAppName" ✅
- **Result**: Consistent naming everywhere

## Technical Details

### Android Update
```xml
<!-- Before -->
<application android:label="mobile">

<!-- After -->
<application android:label="YourAppName">
```

### iOS Update
```xml
<!-- Before -->
<key>CFBundleDisplayName</key>
<string>Mobile</string>
<key>CFBundleName</key>
<string>mobile</string>

<!-- After -->
<key>CFBundleDisplayName</key>
<string>YourAppName</string>
<key>CFBundleName</key>
<string>YourAppName</string>
```

## Manual Configuration

If you need to change the app name after installation:

### Option 1: Re-run Installer
```bash
# macOS/Linux
./setup/installers/install.sh

# Windows
setup\installers\install.bat
```

### Option 2: Manual Edit
1. **Edit JSON**: `assets/config/app_config.json`
2. **Edit Android**: `android/app/src/main/AndroidManifest.xml`
3. **Edit iOS**: `ios/Runner/Info.plist`

### Option 3: Use Installer
```bash
# macOS/Linux
./setup/installers/install.sh

# Windows
setup\installers\install.bat
```

The installer can detect existing configuration and allow you to update specific settings.

## Validation

After updating, verify the changes:

### Android
```bash
grep 'android:label=' android/app/src/main/AndroidManifest.xml
```

### iOS
```bash
grep -A 1 'CFBundleDisplayName\|CFBundleName' ios/Runner/Info.plist
```

### JSON Config
```bash
grep 'appName' assets/config/app_config.json
```

## Platform-Specific Notes

### Android
- App name appears in home screen, app drawer, and recent apps
- Maximum recommended length: 30 characters
- Supports Unicode characters

### iOS
- `CFBundleDisplayName` is what users see on home screen
- `CFBundleName` is used internally by iOS
- Maximum recommended length: 15 characters for home screen
- Longer names may be truncated with "..."

### Flutter
- JSON config name is used throughout the app UI
- No length restrictions
- Supports full Unicode and emojis

## Troubleshooting

### App Name Not Updating on Device
1. **Clean and rebuild** the app:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **For iOS**: Delete app from simulator/device and reinstall

3. **For Android**: Clear app data or reinstall

### Special Characters
- Avoid special characters in app names: `<>:"/\|?*`
- Use alphanumeric characters and spaces
- Emojis work but may not display consistently across platforms

### Build Issues
If you encounter build issues after changing the app name:
1. Run `flutter clean`
2. Delete `ios/Pods` and run `cd ios && pod install`
3. Restart your IDE/editor

## Best Practices

1. **Keep it short**: 15 characters or less for best display
2. **Be descriptive**: Users should understand what the app does
3. **Avoid generic names**: "App", "Mobile", "Trading" alone
4. **Test on devices**: Verify how it appears on actual devices
5. **Consider localization**: If supporting multiple languages

## Examples

### Good App Names
- "CryptoTrader Pro"
- "BitExchange"
- "Digital Wallet"
- "Crypto Portfolio"

### Names to Avoid
- "mobile" (too generic)
- "App" (not descriptive)
- "MyVeryLongCryptocurrencyTradingApplicationName" (too long)
- "Crypto<>Trader" (special characters)

---

This fix ensures that your app has a consistent, professional appearance across all platforms and contexts. 