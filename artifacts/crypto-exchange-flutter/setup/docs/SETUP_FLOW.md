# BiCrypto Mobile App - Setup Flow

## 🚀 Installation Flow Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    START INSTALLATION                        │
│                                                             │
│  Navigate to: setup/installers/                             │
│  macOS/Linux: ./install.sh    Windows: install.bat         │
└──────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               1. PREREQUISITES CHECK                         │
├─────────────────────────────────────────────────────────────┤
│  ✓ Flutter SDK          ✓ Git                              │
│  ✓ Dart                 ✓ Platform Tools                   │
│                                                             │
│  Missing? → Installer guides you to install them           │
└──────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               2. APP CONFIGURATION                           │
├─────────────────────────────────────────────────────────────┤
│  Interactive wizard asks for:                               │
│  • Backend URL (https://your-api.com)                      │
│  • WebSocket URL (wss://your-api.com)                      │
│  • App Name                                                 │
│  • Exchange Provider (Binance, KuCoin, etc.)              │
│  • API Keys (optional)                                      │
│                                                             │
│  Creates: assets/config/app_config.json                    │
└──────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               3. DEPENDENCY INSTALLATION                     │
├─────────────────────────────────────────────────────────────┤
│  • flutter pub get                                          │
│  • Resolves all package dependencies                        │
│  • Downloads required libraries                             │
└──────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               4. PLATFORM SETUP                              │
├─────────────────────────────────────────────────────────────┤
│  Choose platforms:                                          │
│  □ Android → Accepts licenses, checks SDK                  │
│  □ iOS → Installs CocoaPods (macOS only)                  │
│  □ Web → Enables web support                               │
└──────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               5. CODE GENERATION                             │
├─────────────────────────────────────────────────────────────┤
│  • build_runner generates required code                     │
│  • Creates serialization code                              │
│  • Dependency injection setup                               │
└──────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│               6. BUILD APP (OPTIONAL)                        │
├─────────────────────────────────────────────────────────────┤
│  Build for release:                                         │
│  • Android APK → build/app/outputs/flutter-apk/           │
│  • iOS App → Use Xcode to archive                         │
│  • Web → build/web/                                        │
└──────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    ✅ SETUP COMPLETE!                        │
├─────────────────────────────────────────────────────────────┤
│  Your app is ready to run:                                 │
│  • flutter run           (debug mode)                      │
│  • flutter run --release (release mode)                    │
│                                                             │
│  Documentation:                                             │
│  • CONFIGURATION_GUIDE.md                                   │
│  • assets/config/CONFIG_FIELDS_EXPLAINED.md                │
└─────────────────────────────────────────────────────────────┘
```

## 📱 First Run Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    APP LAUNCH                                │
└──────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│            Load Configuration File                           │
│         assets/config/app_config.json                       │
└──────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
                    Config exists?
                    /           \
                  Yes            No
                  /               \
                 ▼                 ▼
         Load Settings      Show Error Screen
               │            "Configuration Error"
               │            with instructions
               ▼
┌─────────────────────────────────────────────────────────────┐
│           Initialize Services                                │
│  • API Client (using baseUrl)                              │
│  • WebSocket (using wsBaseUrl)                             │
│  • Theme, Storage, etc.                                     │
└──────────────────────────┬──────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│           Check Authentication                               │
└──────────────────────────┬──────────────────────────────────┘
                          │
                    Authenticated?
                    /           \
                  Yes            No
                  /               \
                 ▼                 ▼
           Load User          Show Login
           Dashboard            Screen
```

## 🛠️ Manual Configuration Flow

If you need to configure manually:

```
1. Copy Template
   assets/config/app_config.example.json
                    │
                    ▼
   assets/config/app_config.json

2. Edit Configuration
   • Open in text editor
   • Update all values
   • Save file

3. Validate
   • Check JSON syntax
   • Ensure URLs are correct
   • Verify all required fields

4. Run App
   • flutter run
   • Check for errors
   • Verify connection
```

## 📊 Configuration Decision Tree

```
Need Stripe Payments?
├─ Yes → Add stripePublishableKey
└─ No → Leave empty ""

Need Google Sign-In?
├─ Yes → Add googleServerClientId
└─ No → Leave empty ""

Which Exchange?
├─ Binance → "bin"
├─ KuCoin → "kuc"
├─ OKX → "okx"
├─ XT → "xt"
└─ Kraken → "kra"

Show Coming Soon Features?
├─ Yes → true (shows with badge)
└─ No → false (hides completely)
```

## 🔄 Update Flow

When updating the app:

```
1. Backup Current Config
   cp assets/config/app_config.json assets/config/app_config.backup.json

2. Pull Latest Code
   git pull origin main

3. Restore Config
   cp assets/config/app_config.backup.json assets/config/app_config.json

4. Update Dependencies
   flutter pub get

5. Clean & Rebuild
   flutter clean
   flutter pub get
   flutter run
```

## ✅ Success Checklist

- [ ] Installer completed without errors
- [ ] Configuration file created
- [ ] flutter doctor shows no issues
- [ ] App launches without config error
- [ ] Login screen appears
- [ ] Can connect to backend API
- [ ] Real-time data updates working

## 🚨 Quick Fixes

**App won't start?**
→ Check app_config.json exists

**Connection failed?**
→ Verify backend URLs

**Build failed?**
→ Run flutter clean

**Missing features?**
→ Check backend settings

---

For detailed help, see:
- `setup/docs/INSTALLATION_GUIDE.md`
- `setup/docs/CONFIGURATION_GUIDE.md`
- `setup/docs/README_CODECANYON.md` 