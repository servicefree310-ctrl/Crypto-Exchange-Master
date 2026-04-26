# CryptoX Exchange Mobile App Setup

This folder contains everything you need to set up your CryptoX Exchange Mobile App.

## 📁 Folder Structure

```
setup/
├── installers/          # Automated installation scripts
│   ├── install.sh      # macOS/Linux installer
│   ├── install.command # macOS double-click installer
│   └── install.bat     # Windows installer
│
├── docs/               # Setup documentation
│   ├── README_CODECANYON.md    # Main guide for CodeCanyon buyers
│   ├── INSTALLATION_GUIDE.md   # Detailed installation instructions
│   ├── CONFIGURATION_GUIDE.md  # Configuration reference
│   ├── SETUP_FLOW.md          # Visual setup flow diagrams
│   └── APP_ICON_GUIDE.md      # App icon customization guide
│
├── update_icon.sh      # Update app icon script (macOS/Linux)
└── update_icon.bat     # Update app icon script (Windows)
```

## 🚀 Quick Start

### macOS/Linux:
```bash
cd installers
./install.sh
```
Or double-click `install.command`

### Windows:
Double-click `installers\install.bat`

## 🛠️ Utility Scripts

### Update App Icon
After installation, you can easily update your app icon:

**macOS/Linux:**
```bash
./update_icon.sh
```

**Windows:**
```cmd
update_icon.bat
```

## 📚 Documentation

Start with `docs/README_CODECANYON.md` for a complete overview.

## ⚙️ Configuration

After running the installer, your configuration will be saved to:
`../assets/config/app_config.json`

For configuration details, see:
- `../assets/config/CONFIG_FIELDS_EXPLAINED.md`
- `../assets/config/QUICK_REFERENCE.txt` 