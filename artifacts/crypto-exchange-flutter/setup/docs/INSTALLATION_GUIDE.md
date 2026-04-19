# BiCrypto Mobile App Installation Guide

## 🚀 Quick Start - Automated Installation

We provide automated installation scripts that handle everything for you!

### For macOS/Linux:

**Option 1 - Double-click method:**
- Navigate to `setup/installers/` in Finder
- Double-click `install.command`

**Option 2 - Terminal method:**
```bash
cd setup/installers
./install.sh
```

### For Windows:
- Navigate to `setup\installers\` in File Explorer
- Double-click `install.bat`
- Or run in Command Prompt:
```cmd
cd setup\installers
install.bat
```

## 📋 What the Installer Does

The automated installer will:

1. **Check Prerequisites**
   - Flutter SDK
   - Dart
   - Git
   - Platform-specific tools (Xcode for iOS, Android SDK, etc.)

2. **Configure Your App**
   - Interactive setup wizard
   - Creates your `app_config.json` with your backend settings
   - Validates all inputs

3. **Install Dependencies**
   - Runs `flutter pub get`
   - Handles any dependency issues

4. **Platform Setup**
   - Android: Accepts licenses, checks SDK
   - iOS: Installs CocoaPods dependencies (macOS only)
   - Web: Enables web support

5. **Code Generation**
   - Runs build_runner for generated code

6. **Build App** (Optional)
   - Can build APK, iOS app, or web app
   - Provides built file locations

## 🖥️ System Requirements

### All Platforms:
- Flutter SDK 3.0.0 or higher
- Dart SDK 2.17.0 or higher
- Git

### Android Development:
- Android Studio
- Android SDK (API level 21 or higher)
- Java Development Kit (JDK) 11 or higher

### iOS Development (macOS only):
- macOS 10.14 or higher
- Xcode 13.0 or higher
- CocoaPods
- Valid Apple Developer account (for device testing)

### Web Development:
- Chrome browser (for debugging)
- Any modern web browser for running

## 🛠️ Manual Installation

If you prefer manual installation or the automated installer encounters issues:

### 1. Install Prerequisites

#### Flutter Installation:

**macOS:**
```bash
brew install --cask flutter
```

**Linux:**
```bash
# Download Flutter
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
tar xf flutter_linux_3.16.0-stable.tar.xz
sudo mv flutter /opt/
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
```

**Windows:**
1. Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
2. Extract to a suitable location (e.g., `C:\src\flutter`)
3. Add Flutter to PATH

### 2. Configure the App

1. Copy the example configuration:
```bash
cp assets/config/app_config.example.json assets/config/app_config.json
```

2. Edit `assets/config/app_config.json` with your settings:
```json
{
  "baseUrl": "https://your-api.com",
  "wsBaseUrl": "wss://your-api.com",
  "appName": "YourAppName",
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

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Platform-Specific Setup

#### Android:
```bash
# Accept Android licenses
flutter doctor --android-licenses

# Verify Android setup
flutter doctor -v
```

#### iOS (macOS only):
```bash
cd ios
pod install
cd ..
```

#### Web:
```bash
flutter config --enable-web
```

### 5. Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. Run the App

```bash
# List available devices
flutter devices

# Run on default device
flutter run

# Run on specific device
flutter run -d <device_id>

# Run on Chrome (web)
flutter run -d chrome
```

### 7. Build for Release

#### Android APK:
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle:
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (macOS only):
```bash
flutter build ios --release
# Then archive in Xcode
```

#### Web:
```bash
flutter build web
# Output: build/web/
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Flutter Not Found
**Error:** `flutter: command not found`
**Solution:** 
- Ensure Flutter is in your PATH
- Run `source ~/.bashrc` (Linux/macOS) or restart terminal
- On Windows, restart Command Prompt after adding to PATH

#### Android Licenses Not Accepted
**Error:** Android license status unknown
**Solution:**
```bash
flutter doctor --android-licenses
```

#### CocoaPods Issues (iOS)
**Error:** Pod install fails
**Solution:**
```bash
sudo gem install cocoapods
pod repo update
cd ios && pod install
```

#### Build Failures
**Error:** Build failed with compilation errors
**Solution:**
1. Clean the project:
   ```bash
   flutter clean
   flutter pub get
   ```
2. Delete generated files:
   ```bash
   rm -rf .dart_tool/
   rm -rf build/
   ```
3. Regenerate code:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

#### Configuration File Issues
**Error:** Failed to load app configuration
**Solution:**
1. Ensure `assets/config/app_config.json` exists
2. Validate JSON syntax (no trailing commas)
3. Check all required fields are present
4. Verify URLs include protocol (https://, wss://)

#### Network/API Connection Issues
**Error:** Unable to connect to backend
**Solution:**
1. Verify `baseUrl` and `wsBaseUrl` are correct
2. Check if backend is running
3. Test API endpoint in browser
4. Check for CORS issues (web platform)

## 📱 Platform-Specific Notes

### Android
- Minimum SDK: API 21 (Android 5.0)
- Target SDK: Latest stable
- Ensure `ANDROID_HOME` is set
- May need to configure signing for release builds

### iOS
- Requires macOS for building
- Need Apple Developer account for device testing
- Configure signing in Xcode
- Update bundle identifier to be unique

### Web
- CORS must be configured on backend
- Some features may not work on web (device-specific APIs)
- Test on multiple browsers

## 🔐 Security Considerations

1. **Never commit** `app_config.json` to version control
2. Keep API keys secure
3. Use different configs for dev/staging/production
4. Enable code obfuscation for release builds:
   ```bash
   flutter build apk --obfuscate --split-debug-info=./debug_info
   ```

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
- [Android Studio Setup](https://developer.android.com/studio)
- [Xcode Setup](https://developer.apple.com/xcode/)
- Configuration Documentation:
  - `setup/docs/CONFIGURATION_GUIDE.md` - Main configuration guide
  - `assets/config/CONFIG_FIELDS_EXPLAINED.md` - Detailed field explanations
  - `assets/config/QUICK_REFERENCE.txt` - Quick value reference

## 🆘 Getting Help

If you encounter issues not covered here:

1. Run `flutter doctor -v` and check all issues
2. Check the error logs carefully
3. Ensure all prerequisites are properly installed
4. Verify your configuration file is valid JSON
5. Check if your backend API is accessible

For platform-specific issues:
- **Android**: Check Android Studio SDK Manager
- **iOS**: Check Xcode settings and provisioning
- **Web**: Check browser console for errors

## ✅ Success Indicators

You'll know the installation was successful when:
- `flutter doctor` shows no critical issues
- The app runs without configuration errors
- You can see the login screen
- The app connects to your backend successfully

## 🎉 Next Steps

After successful installation:
1. Test on different devices/platforms
2. Configure app icons and splash screens
3. Set up code signing for production
4. Customize the app with your branding
5. Test all features with your backend

Happy coding! 🚀 