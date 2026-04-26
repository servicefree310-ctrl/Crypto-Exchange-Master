# CryptoX Exchange Mobile App

A comprehensive Flutter-based cryptocurrency trading platform with support for spot trading, futures, P2P marketplace, staking, and many more advanced features.

## 🚀 Quick Start

**New to this project? Start here:**

1. **Navigate to the setup directory**: `cd setup/installers/`
2. **Run the automated installer**:
   - **macOS/Linux**: `./install.sh` or double-click `install.command`
   - **Windows**: Double-click `install.bat`

The installer will guide you through everything - from checking prerequisites to configuring your app!

## 📁 What's in the Setup Directory

The `setup/` directory contains everything you need to get started:

```
setup/
├── installers/          # Automated installation scripts
│   ├── install.sh       # macOS/Linux installer
│   ├── install.command  # macOS double-click installer
│   └── install.bat      # Windows installer
│
└── docs/               # Complete documentation
    ├── README_CODECANYON.md     # Main guide for CodeCanyon buyers
    ├── INSTALLATION_GUIDE.md    # Detailed installation instructions
    ├── CONFIGURATION_GUIDE.md   # Configuration reference
    ├── SETUP_FLOW.md           # Visual setup flow diagrams
    ├── APP_ICON_GUIDE.md       # App icon customization guide
    ├── APP_NAME_CONFIGURATION.md # App naming guide
    └── ORIENTATION_MANAGEMENT.md # Device orientation system
```

## 🎯 Key Features

- **Complete Trading Platform** - Spot trading, futures, P2P marketplace
- **Multi-Platform Support** - Android, iOS, and Web from single codebase
- **Real-time Updates** - WebSocket integration for live market data
- **Advanced Features** - Staking, ICO platform, AI trading, MLM system
- **Beautiful UI** - Modern design with dark/light themes
- **Easy Configuration** - JSON-based config without code modification
- **Automated Setup** - Get running in minutes with our installer

## 📚 Documentation

**Start with these guides in the `setup/docs/` directory:**

1. **`README_CODECANYON.md`** - Complete overview and quick start
2. **`INSTALLATION_GUIDE.md`** - Detailed installation instructions
3. **`CONFIGURATION_GUIDE.md`** - Configuration options and examples
4. **`SETUP_FLOW.md`** - Visual diagrams of the setup process

**Configuration files in `assets/config/`:**
- **`CONFIG_FIELDS_EXPLAINED.md`** - Detailed explanation of all config options
- **`QUICK_REFERENCE.txt`** - Quick lookup for configuration values

## ⚙️ Configuration

The app uses a simple JSON configuration file located at `assets/config/app_config.json`. The installer creates this for you, but you can also configure manually:

```json
{
  "baseUrl": "https://your-api.com",
  "wsBaseUrl": "wss://your-api.com",
  "appName": "YourExchange",
  "appVersion": "5.0.0",
  "defaultExchangeProvider": "bin",
  "defaultTradingPair": "BTC/USDT"
}
```

## 🛠️ Manual Setup (Advanced Users)

If you prefer manual setup instead of using the installer:

1. **Install Prerequisites**: Flutter SDK, Dart, Git, platform tools
2. **Configure App**: Copy `assets/config/app_config.example.json` to `app_config.json`
3. **Install Dependencies**: `flutter pub get`
4. **Generate Code**: `flutter pub run build_runner build --delete-conflicting-outputs`
5. **Run App**: `flutter run`

See `setup/docs/INSTALLATION_GUIDE.md` for detailed manual setup instructions.

## 📱 Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (macOS required)
flutter build ios --release

# Web
flutter build web
```

## 🔧 Customization

- **App Icon**: Use the installer or see `setup/docs/APP_ICON_GUIDE.md`
- **App Name**: Configured during installation or see `setup/docs/APP_NAME_CONFIGURATION.md`
- **Features**: Controlled by your backend settings
- **Themes**: Modify files in `lib/core/theme/`

## 🆘 Need Help?

1. **Check the documentation** in `setup/docs/` first
2. **Run the installer** - it handles most common issues automatically
3. **Validate your configuration** - ensure `assets/config/app_config.json` is correct
4. **Run `flutter doctor -v`** to check your development environment

## 📋 Requirements

- **Flutter SDK** 3.0.0+
- **Dart SDK** 2.17.0+
- **Backend**: CryptoX Exchange v5 backend (sold separately)
- **Platform Tools**: Android Studio for Android, Xcode for iOS (macOS only)

## 🎉 Getting Started

**The fastest way to get started:**

1. Open terminal/command prompt
2. Navigate to `setup/installers/`
3. Run the installer for your platform
4. Follow the interactive setup wizard
5. Your app will be ready to run!

For detailed information, see the comprehensive documentation in the `setup/docs/` directory.

---

**Version**: 5.0.0  
**Documentation**: See `setup/docs/` for complete guides  
**Support**: Check documentation before requesting help
