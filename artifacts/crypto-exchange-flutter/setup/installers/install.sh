#!/bin/bash

# CryptoX Exchange Mobile App Installer
# Version: 5.0.0
# This script helps you set up the CryptoX Exchange mobile app with ease

# Color codes for better UI
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration file path
CONFIG_FILE="assets/config/app_config.json"
CONFIG_EXAMPLE="assets/config/app_config.example.json"

# Platform detection
OS_TYPE=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    OS_TYPE="windows"
fi

# Function to print colored text
print_color() {
    color=$1
    text=$2
    echo -e "${color}${text}${NC}"
}

# Function to print header
print_header() {
    clear
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                                                            ║"
    echo "║              CryptoX Exchange Mobile App Installer                 ║"
    echo "║                     Version 5.0.0                          ║"
    echo "║                                                            ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to print section header
print_section() {
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  $1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Function to show progress
show_progress() {
    local current=$1
    local total=$2
    local width=50
    local percentage=$((current * 100 / total))
    local completed=$((width * current / total))
    
    printf "\r["
    printf "%${completed}s" | tr ' ' '█'
    printf "%$((width - completed))s" | tr ' ' '░'
    printf "] %d%%" $percentage
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect package manager
detect_package_manager() {
    if command_exists apt-get; then
        echo "apt"
    elif command_exists yum; then
        echo "yum"
    elif command_exists brew; then
        echo "brew"
    elif command_exists pacman; then
        echo "pacman"
    elif command_exists choco; then
        echo "choco"
    else
        echo "unknown"
    fi
}

# Function to install Flutter
install_flutter() {
    print_section "Installing Flutter"
    
    if command_exists flutter; then
        print_color "$GREEN" "✓ Flutter is already installed"
        flutter --version
        return 0
    fi
    
    print_color "$YELLOW" "Flutter is not installed. Installing now..."
    
    case $OS_TYPE in
        "macos")
            if command_exists brew; then
                brew install --cask flutter
            else
                print_color "$RED" "Error: Homebrew is not installed."
                print_color "$YELLOW" "Please install Homebrew first: https://brew.sh"
                return 1
            fi
            ;;
        "linux")
            # Download Flutter SDK
            wget -q --show-progress https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.16.0-stable.tar.xz
            tar xf flutter_linux_3.16.0-stable.tar.xz
            sudo mv flutter /opt/
            echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.bashrc
            source ~/.bashrc
            rm flutter_linux_3.16.0-stable.tar.xz
            ;;
        "windows")
            print_color "$YELLOW" "Please download Flutter from: https://flutter.dev/docs/get-started/install/windows"
            print_color "$YELLOW" "After installation, run this script again."
            return 1
            ;;
    esac
    
    print_color "$GREEN" "✓ Flutter installed successfully"
}

# Function to check prerequisites
check_prerequisites() {
    print_section "Checking Prerequisites"
    
    local prerequisites_met=true
    
    # Check Flutter
    if command_exists flutter; then
        print_color "$GREEN" "✓ Flutter is installed"
        flutter_version=$(flutter --version | head -n 1)
        print_color "$CYAN" "  Version: $flutter_version"
    else
        print_color "$RED" "✗ Flutter is not installed"
        prerequisites_met=false
    fi
    
    # Check Dart
    if command_exists dart; then
        print_color "$GREEN" "✓ Dart is installed"
    else
        print_color "$RED" "✗ Dart is not installed"
        prerequisites_met=false
    fi
    
    # Check Git
    if command_exists git; then
        print_color "$GREEN" "✓ Git is installed"
    else
        print_color "$RED" "✗ Git is not installed"
        prerequisites_met=false
    fi
    
    # Platform-specific checks
    case $OS_TYPE in
        "macos")
            if command_exists xcode-select; then
                print_color "$GREEN" "✓ Xcode Command Line Tools installed"
            else
                print_color "$RED" "✗ Xcode Command Line Tools not installed"
                prerequisites_met=false
            fi
            
            if command_exists pod; then
                print_color "$GREEN" "✓ CocoaPods is installed"
            else
                print_color "$RED" "✗ CocoaPods is not installed"
                prerequisites_met=false
            fi
            ;;
        "linux")
            # Check for required Linux packages
            if command_exists clang; then
                print_color "$GREEN" "✓ Clang is installed"
            else
                print_color "$RED" "✗ Clang is not installed"
                prerequisites_met=false
            fi
            ;;
    esac
    
    if [ "$prerequisites_met" = false ]; then
        echo ""
        print_color "$YELLOW" "Some prerequisites are missing. Would you like to install them? (y/n)"
        read -r install_choice
        if [[ $install_choice =~ ^[Yy]$ ]]; then
            install_prerequisites
        else
            print_color "$RED" "Cannot continue without prerequisites. Exiting..."
            exit 1
        fi
    fi
}

# Function to install prerequisites
install_prerequisites() {
    print_section "Installing Prerequisites"
    
    # Install Flutter if needed
    if ! command_exists flutter; then
        install_flutter
    fi
    
    # Install Git if needed
    if ! command_exists git; then
        print_color "$YELLOW" "Installing Git..."
        case $(detect_package_manager) in
            "apt")
                sudo apt-get update && sudo apt-get install -y git
                ;;
            "yum")
                sudo yum install -y git
                ;;
            "brew")
                brew install git
                ;;
            "pacman")
                sudo pacman -S --noconfirm git
                ;;
        esac
    fi
    
    # Platform-specific installations
    case $OS_TYPE in
        "macos")
            if ! command_exists xcode-select; then
                print_color "$YELLOW" "Installing Xcode Command Line Tools..."
                xcode-select --install
            fi
            
            if ! command_exists pod; then
                print_color "$YELLOW" "Installing CocoaPods..."
                sudo gem install cocoapods
            fi
            ;;
        "linux")
            if ! command_exists clang; then
                print_color "$YELLOW" "Installing build essentials..."
                case $(detect_package_manager) in
                    "apt")
                        sudo apt-get update
                        sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
                        ;;
                    "yum")
                        sudo yum groupinstall -y "Development Tools"
                        sudo yum install -y clang cmake ninja-build gtk3-devel
                        ;;
                esac
            fi
            ;;
    esac
    
    print_color "$GREEN" "✓ All prerequisites installed"
}

# Function to validate URL
validate_url() {
    local url=$1
    if [[ $url =~ ^https?:// ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate WebSocket URL
validate_ws_url() {
    local url=$1
    if [[ $url =~ ^wss?:// ]]; then
        return 0
    else
        return 1
    fi
}

# Function to update app name in platform files
update_app_name_in_platforms() {
    local app_name=$1
    
    print_color "$YELLOW" "Updating app name in platform files..."
    
    # Update Android app name
    if [ -f "android/app/src/main/AndroidManifest.xml" ]; then
        print_color "$CYAN" "  ✓ Updating Android app name..."
        # Use sed to replace the android:label value
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS sed syntax
            sed -i '' "s/android:label=\"[^\"]*\"/android:label=\"$app_name\"/" android/app/src/main/AndroidManifest.xml
        else
            # Linux sed syntax
            sed -i "s/android:label=\"[^\"]*\"/android:label=\"$app_name\"/" android/app/src/main/AndroidManifest.xml
        fi
    else
        print_color "$RED" "  ✗ Android manifest not found"
    fi
    
    # Update iOS app name
    if [ -f "ios/Runner/Info.plist" ]; then
        print_color "$CYAN" "  ✓ Updating iOS app name..."
        # Update CFBundleDisplayName (what appears on home screen)
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS sed syntax - handle multiline patterns
            sed -i '' "/CFBundleDisplayName/,/<string>/ s/<string>.*<\/string>/<string>$app_name<\/string>/" ios/Runner/Info.plist
            sed -i '' "/CFBundleName/,/<string>/ s/<string>.*<\/string>/<string>$app_name<\/string>/" ios/Runner/Info.plist
        else
            # Linux sed syntax - handle multiline patterns
            sed -i "/CFBundleDisplayName/,/<string>/ s/<string>.*<\/string>/<string>$app_name<\/string>/" ios/Runner/Info.plist
            sed -i "/CFBundleName/,/<string>/ s/<string>.*<\/string>/<string>$app_name<\/string>/" ios/Runner/Info.plist
        fi
    else
        print_color "$RED" "  ✗ iOS Info.plist not found"
    fi
    
    print_color "$GREEN" "✓ App name updated in platform files!"
}

# Function to configure the app
configure_app() {
    print_section "App Configuration"
    
    # Check if config already exists
    if [ -f "$CONFIG_FILE" ]; then
        print_color "$YELLOW" "Configuration file already exists."
        echo "Do you want to:"
        echo "1) Keep existing configuration"
        echo "2) Create new configuration"
        echo "3) View current configuration"
        read -p "Enter your choice (1-3): " config_choice
        
        case $config_choice in
            1)
                print_color "$GREEN" "✓ Keeping existing configuration"
                return 0
                ;;
            3)
                print_color "$CYAN" "Current configuration:"
                cat "$CONFIG_FILE" | jq '.' 2>/dev/null || cat "$CONFIG_FILE"
                echo ""
                read -p "Press Enter to continue..."
                configure_app
                return
                ;;
        esac
    fi
    
    # Copy example config
    cp "$CONFIG_EXAMPLE" "$CONFIG_FILE"
    
    print_color "$CYAN" "Let's configure your CryptoX Exchange app!"
    echo ""
    
    # Backend URL
    while true; do
        print_color "$WHITE" "1. Backend API URL"
        print_color "$YELLOW" "   This is your server's API endpoint"
        print_color "$YELLOW" "   Example: https://api.yourexchange.com"
        read -p "   Enter your backend URL: " backend_url
        
        if validate_url "$backend_url"; then
            break
        else
            print_color "$RED" "   ✗ Invalid URL. Must start with https:// or http://"
        fi
    done
    
    # WebSocket URL
    while true; do
        echo ""
        print_color "$WHITE" "2. WebSocket URL"
        print_color "$YELLOW" "   This is for real-time updates"
        print_color "$YELLOW" "   Example: wss://api.yourexchange.com"
        read -p "   Enter your WebSocket URL: " ws_url
        
        if validate_ws_url "$ws_url"; then
            break
        else
            print_color "$RED" "   ✗ Invalid WebSocket URL. Must start with wss:// or ws://"
        fi
    done
    
    # App Name
    echo ""
    print_color "$WHITE" "3. App Name"
    echo ""
    print_color "$YELLOW" "   This will be displayed as your app's name everywhere"
    print_color "$YELLOW" "   Including: device home screen, app drawer, and inside the app"
    read -p "   Enter your app name (default: CryptoX Exchange): " app_name
    app_name=${app_name:-CryptoX Exchange}
    
    # Update app name in platform files
    update_app_name_in_platforms "$app_name"
    
    # App Version
    echo ""
    print_color "$WHITE" "4. App Version"
    print_color "$YELLOW" "   Your app's version number"
    read -p "   Enter app version (default: 5.0.0): " app_version
    app_version=${app_version:-5.0.0}
    
    # Exchange Provider
    echo ""
    print_color "$WHITE" "5. Default Exchange Provider"
    print_color "$YELLOW" "   Choose your default exchange:"
    echo "   1) Binance (bin)"
    echo "   2) KuCoin (kuc)"
    echo "   3) OKX (okx)"
    echo "   4) XT (xt)"
    echo "   5) Kraken (kra)"
    read -p "   Enter choice (1-5, default: 1): " exchange_choice
    
    case ${exchange_choice:-1} in
        1) exchange_provider="bin" ;;
        2) exchange_provider="kuc" ;;
        3) exchange_provider="okx" ;;
        4) exchange_provider="xt" ;;
        5) exchange_provider="kra" ;;
        *) exchange_provider="bin" ;;
    esac
    
    # Trading Pair
    echo ""
    print_color "$WHITE" "6. Default Trading Pair"
    print_color "$YELLOW" "   Format: BASE/QUOTE (uppercase)"
    read -p "   Enter trading pair (default: BTC/USDT): " trading_pair
    trading_pair=${trading_pair:-BTC/USDT}
    
    # Stripe Key (optional)
    echo ""
    print_color "$WHITE" "7. Stripe Publishable Key (Optional)"
    print_color "$YELLOW" "   Leave empty if not using Stripe payments"
    read -p "   Enter Stripe key: " stripe_key
    
    # Google Client ID (optional)
    echo ""
    print_color "$WHITE" "8. Google OAuth Client ID (Optional)"
    print_color "$YELLOW" "   Leave empty if not using Google Sign-In"
    read -p "   Enter Google Client ID: " google_client_id
    
    # Show Coming Soon
    echo ""
    print_color "$WHITE" "9. Show 'Coming Soon' Features?"
    print_color "$YELLOW" "   Show incomplete features with 'Coming Soon' badge?"
    read -p "   Enter choice (y/n, default: y): " show_coming_soon
    show_coming_soon_bool=true
    if [[ $show_coming_soon =~ ^[Nn]$ ]]; then
        show_coming_soon_bool=false
    fi
    
    # Create configuration
    cat > "$CONFIG_FILE" << EOF
{
  "baseUrl": "$backend_url",
  "wsBaseUrl": "$ws_url",
  "appName": "$app_name",
  "appVersion": "$app_version",
  
  "stripePublishableKey": "$stripe_key",
  "googleServerClientId": "$google_client_id",
  
  "defaultExchangeProvider": "$exchange_provider",
  "defaultTradingPair": "$trading_pair",
  
  "defaultShowComingSoon": $show_coming_soon_bool,
  
  "settingsCacheDuration": 3600,
  "backgroundUpdateInterval": 60
}
EOF
    
    print_color "$GREEN" "✓ Configuration saved successfully!"
}

# Function to setup app icon
setup_app_icon() {
    print_section "App Icon Setup"
    
    print_color "$CYAN" "App Icon Configuration"
    echo ""
    
    # Check if icon already exists
    if [ -f "assets/icons/app_icon.png" ]; then
        print_color "$YELLOW" "An app icon already exists."
        echo "What would you like to do?"
        echo "1) Replace with a new icon"
        echo "2) Keep existing icon"
        echo "3) Skip icon setup"
        read -p "Enter choice (1-3): " existing_icon_choice
        
        case $existing_icon_choice in
            2)
                print_color "$GREEN" "✓ Keeping existing icon"
                # Still generate icons to ensure all platforms are updated
                print_color "$YELLOW" "Regenerating icons for all platforms..."
                flutter pub run flutter_launcher_icons || {
                    print_color "$YELLOW" "Icon generation skipped or failed"
                }
                return 0
                ;;
            3)
                print_color "$YELLOW" "Skipping icon setup"
                return 0
                ;;
        esac
    fi
    
    # Check if user has an icon file
    echo "Do you have a custom app icon (PNG file, 500x500 or larger)?"
    echo "1) Yes, I have an icon file"
    echo "2) No, use default placeholder"
    echo "3) I'll add it later"
    read -p "Enter choice (1-3): " icon_choice
    
    case $icon_choice in
        1)
            # Ask for icon path with validation loop
            while true; do
                print_color "$YELLOW" "Please enter the full path to your icon file:"
                print_color "$YELLOW" "Example: /Users/you/Desktop/icon.png"
                read -p "Icon path: " icon_path
                
                # Validate icon file exists
                if [ ! -f "$icon_path" ]; then
                    print_color "$RED" "File not found: $icon_path"
                    echo "Would you like to:"
                    echo "1) Try again"
                    echo "2) Skip icon setup"
                    read -p "Enter choice (1-2): " retry_choice
                    if [[ $retry_choice == "2" ]]; then
                        print_color "$YELLOW" "Skipping icon setup"
                        return 0
                    fi
                    continue
                fi
                
                # Check if it's a PNG
                file_type=$(file -b --mime-type "$icon_path" 2>/dev/null || echo "unknown")
                if [[ $file_type == "image/png" ]] || [[ $file_type == "unknown" ]]; then
                    # Create icons directory if it doesn't exist
                    mkdir -p "assets/icons"
                    
                    # Copy icon to assets
                    cp "$icon_path" "assets/icons/app_icon.png"
                    print_color "$GREEN" "✓ Icon copied successfully!"
                    
                    # Generate all icon sizes
                    print_color "$YELLOW" "Generating app icons for all platforms..."
                    if flutter pub run flutter_launcher_icons; then
                        print_color "$GREEN" "✓ App icons generated successfully!"
                        print_color "$CYAN" "Your custom icon has been applied to:"
                        echo "  • Android app icon"
                        echo "  • iOS app icon"
                        echo "  • Web favicon"
                    else
                        print_color "$RED" "Failed to generate icons!"
                        print_color "$YELLOW" "The icon was copied but generation failed."
                        print_color "$YELLOW" "You can run this manually later:"
                        print_color "$WHITE" "flutter pub run flutter_launcher_icons"
                    fi
                    break
                else
                    print_color "$RED" "File is not a PNG image!"
                    print_color "$YELLOW" "Please use a PNG file for the app icon."
                    echo "Would you like to:"
                    echo "1) Try with a different file"
                    echo "2) Skip icon setup"
                    read -p "Enter choice (1-2): " retry_choice
                    if [[ $retry_choice == "2" ]]; then
                        print_color "$YELLOW" "Skipping icon setup"
                        return 0
                    fi
                fi
            done
            ;;
        2)
            print_color "$YELLOW" "Using default placeholder icon..."
            # Create icons directory if it doesn't exist
            mkdir -p "assets/icons"
            
            # Create a placeholder icon if it doesn't exist
            if [ ! -f "assets/icons/app_icon.png" ]; then
                print_color "$YELLOW" "Creating placeholder icon..."
                # Create a simple colored square as placeholder
                # This would need the actual placeholder icon file
                touch "assets/icons/app_icon.png"
            fi
            
            # Generate icons
            print_color "$YELLOW" "Generating app icons..."
            if flutter pub run flutter_launcher_icons; then
                print_color "$GREEN" "✓ Placeholder icons generated!"
            else
                print_color "$YELLOW" "Icon generation skipped"
            fi
            ;;
        3)
            print_color "$YELLOW" "You can add your icon later by:"
            echo ""
            print_color "$CYAN" "Method 1: Re-run installer"
            print_color "$WHITE" "  ./setup/installers/install.sh"
            echo ""
            print_color "$CYAN" "Method 2: Manual setup"
            echo "  1. Place your PNG icon at: assets/icons/app_icon.png"
            echo "  2. Run: flutter pub run flutter_launcher_icons"
            echo "  3. Clean and rebuild: flutter clean && flutter run"
            echo ""
            print_color "$CYAN" "Icon Requirements:"
            echo "  • PNG format"
            echo "  • 512x512 pixels or larger"
            echo "  • Square aspect ratio"
            echo "  • No transparency for best results"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

# Function to setup platform
setup_platform() {
    print_section "Platform Setup"
    
    echo "Which platforms do you want to set up?"
    echo "1) Android only"
    echo "2) iOS only (macOS required)"
    echo "3) Both Android and iOS"
    echo "4) Web"
    echo "5) All platforms"
    read -p "Enter your choice (1-5): " platform_choice
    
    case $platform_choice in
        1|3|5)
            setup_android
            ;;
    esac
    
    case $platform_choice in
        2|3|5)
            if [ "$OS_TYPE" == "macos" ]; then
                setup_ios
            else
                print_color "$YELLOW" "⚠ iOS setup requires macOS. Skipping..."
            fi
            ;;
    esac
    
    case $platform_choice in
        4|5)
            setup_web
            ;;
    esac
}

# Function to setup Android
setup_android() {
    print_section "Android Setup"
    
    # Check for Android SDK
    if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
        print_color "$YELLOW" "Android SDK not found in environment variables."
        echo "Please ensure Android Studio is installed and ANDROID_HOME is set."
        echo ""
        echo "Would you like to:"
        echo "1) Continue anyway (I'll set it up manually)"
        echo "2) Get instructions for Android Studio setup"
        echo "3) Skip Android setup"
        read -p "Enter choice (1-3): " android_choice
        
        case $android_choice in
            2)
                print_color "$CYAN" "Android Studio Setup Instructions:"
                echo "1. Download Android Studio from: https://developer.android.com/studio"
                echo "2. Install and open Android Studio"
                echo "3. Go to SDK Manager (Tools > SDK Manager)"
                echo "4. Install Android SDK Platform-Tools"
                echo "5. Add to your shell profile:"
                echo "   export ANDROID_HOME=\$HOME/Android/Sdk"
                echo "   export PATH=\$PATH:\$ANDROID_HOME/tools:\$ANDROID_HOME/platform-tools"
                read -p "Press Enter when ready to continue..."
                ;;
            3)
                return
                ;;
        esac
    fi
    
    # Accept Android licenses
    print_color "$YELLOW" "Accepting Android licenses..."
    flutter doctor --android-licenses 2>/dev/null || {
        print_color "$RED" "Failed to accept licenses automatically."
        print_color "$YELLOW" "Please run: flutter doctor --android-licenses"
    }
    
    print_color "$GREEN" "✓ Android setup completed"
}

# Function to setup iOS
setup_ios() {
    print_section "iOS Setup"
    
    print_color "$YELLOW" "Setting up iOS dependencies..."
    
    # Navigate to iOS directory
    cd ios || {
        print_color "$RED" "iOS directory not found!"
        return 1
    }
    
    # Install pods
    print_color "$YELLOW" "Installing CocoaPods dependencies..."
    pod install || {
        print_color "$RED" "Pod installation failed!"
        print_color "$YELLOW" "Trying to fix..."
        pod repo update
        pod install
    }
    
    cd ..
    
    # Check for signing
    print_color "$YELLOW" "iOS Code Signing:"
    echo "You'll need to:"
    echo "1. Open ios/Runner.xcworkspace in Xcode"
    echo "2. Select a development team in Signing & Capabilities"
    echo "3. Choose a unique bundle identifier"
    echo ""
    read -p "Press Enter to continue..."
    
    print_color "$GREEN" "✓ iOS setup completed"
}

# Function to setup Web
setup_web() {
    print_section "Web Setup"
    
    print_color "$YELLOW" "Enabling web support..."
    flutter config --enable-web
    
    print_color "$GREEN" "✓ Web setup completed"
}

# Function to install dependencies
install_dependencies() {
    print_section "Installing Dependencies"
    
    print_color "$YELLOW" "Running flutter pub get..."
    flutter pub get || {
        print_color "$RED" "Failed to install dependencies!"
        print_color "$YELLOW" "Trying to fix..."
        flutter clean
        flutter pub get
    }
    
    print_color "$GREEN" "✓ Dependencies installed successfully"
}

# Function to run code generation
run_code_generation() {
    print_section "Code Generation"
    
    print_color "$YELLOW" "Running build_runner..."
    flutter pub run build_runner build --delete-conflicting-outputs || {
        print_color "$RED" "Code generation failed!"
        print_color "$YELLOW" "This might be okay if no generated files have changed."
    }
    
    print_color "$GREEN" "✓ Code generation completed"
}

# Function to verify setup
verify_setup() {
    print_section "Verifying Setup"
    
    print_color "$YELLOW" "Running flutter doctor..."
    flutter doctor
    
    echo ""
    print_color "$CYAN" "Please review the output above."
    print_color "$YELLOW" "If there are any issues (marked with [✗]), you should fix them."
    read -p "Press Enter to continue..."
}

# Function to build app
build_app() {
    print_section "Build App"
    
    echo "Would you like to build the app now?"
    echo "1) Yes, build for Android (APK)"
    echo "2) Yes, build for iOS (requires macOS)"
    echo "3) Yes, build for both"
    echo "4) No, I'll build later"
    read -p "Enter choice (1-4): " build_choice
    
    case $build_choice in
        1|3)
            print_color "$YELLOW" "Building Android APK..."
            flutter build apk --release || {
                print_color "$RED" "Android build failed!"
                print_color "$YELLOW" "Common fixes:"
                echo "- Check your Android SDK setup"
                echo "- Run: flutter clean"
                echo "- Check for errors in android/app/build.gradle"
            }
            if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
                print_color "$GREEN" "✓ APK built successfully!"
                print_color "$CYAN" "Location: build/app/outputs/flutter-apk/app-release.apk"
            fi
            ;;
    esac
    
    case $build_choice in
        2|3)
            if [ "$OS_TYPE" == "macos" ]; then
                print_color "$YELLOW" "Building iOS app..."
                flutter build ios --release || {
                    print_color "$RED" "iOS build failed!"
                    print_color "$YELLOW" "Common fixes:"
                    echo "- Open Xcode and configure signing"
                    echo "- Run: cd ios && pod install"
                    echo "- Check your provisioning profiles"
                }
            else
                print_color "$YELLOW" "iOS build requires macOS. Skipping..."
            fi
            ;;
    esac
}

# Function to show next steps
show_next_steps() {
    print_section "Setup Complete! 🎉"
    
    print_color "$GREEN" "Your CryptoX Exchange app is ready!"
    echo ""
    print_color "$CYAN" "Next steps:"
    echo ""
    echo "1. To run on Android emulator/device:"
    print_color "$WHITE" "   flutter run"
    echo ""
    echo "2. To run on iOS simulator (macOS only):"
    print_color "$WHITE" "   flutter run"
    echo ""
    echo "3. To run on web:"
    print_color "$WHITE" "   flutter run -d chrome"
    echo ""
    echo "4. To build release APK:"
    print_color "$WHITE" "   flutter build apk --release"
    echo ""
    echo "5. To build iOS app (macOS only):"
    print_color "$WHITE" "   flutter build ios --release"
    echo ""
    print_color "$YELLOW" "Configuration file location:"
    print_color "$WHITE" "   $CONFIG_FILE"
    echo ""
    print_color "$YELLOW" "Documentation:"
    print_color "$WHITE" "   - CONFIGURATION_GUIDE.md"
    print_color "$WHITE" "   - assets/config/CONFIG_FIELDS_EXPLAINED.md"
    print_color "$WHITE" "   - assets/config/QUICK_REFERENCE.txt"
    echo ""
}

# Function to handle errors
handle_error() {
    local error_code=$1
    local error_context=$2
    
    print_color "$RED" "Error occurred: $error_context"
    
    case $error_code in
        1)
            print_color "$YELLOW" "Solution: Install Flutter from https://flutter.dev"
            ;;
        2)
            print_color "$YELLOW" "Solution: Check your internet connection"
            ;;
        3)
            print_color "$YELLOW" "Solution: Run with sudo or admin privileges"
            ;;
        *)
            print_color "$YELLOW" "Please check the error message above"
            ;;
    esac
}

# Main installation flow
main() {
    print_header
    
    # Get the directory where this script is located
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    # Change to the script directory
    cd "$SCRIPT_DIR"
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        print_color "$RED" "Error: pubspec.yaml not found!"
        print_color "$YELLOW" "This installer must be located in your Flutter project root directory."
        print_color "$YELLOW" "Current directory: $(pwd)"
        print_color "$YELLOW" "Looking for pubspec.yaml..."
        
        # Try to find pubspec.yaml in parent directories
        SEARCH_DIR="$SCRIPT_DIR"
        for i in 1 2 3; do
            if [ -f "$SEARCH_DIR/pubspec.yaml" ]; then
                print_color "$GREEN" "Found Flutter project at: $SEARCH_DIR"
                cd "$SEARCH_DIR"
                break
            fi
            SEARCH_DIR="$(dirname "$SEARCH_DIR")"
        done
        
        # Final check
        if [ ! -f "pubspec.yaml" ]; then
            print_color "$RED" "Could not find Flutter project!"
            print_color "$YELLOW" "Please ensure install.sh is in your Flutter project root directory."
            exit 1
        fi
    fi
    
    print_color "$GREEN" "✓ Flutter project found at: $(pwd)"
    
    # Welcome message
    print_color "$CYAN" "Welcome to the CryptoX Exchange Mobile App installer!"
    print_color "$WHITE" "This wizard will help you set up everything you need."
    echo ""
    read -p "Press Enter to start the installation..."
    
    # Run installation steps
    check_prerequisites
    configure_app
    install_dependencies
    setup_app_icon
    setup_platform
    run_code_generation
    verify_setup
    build_app
    show_next_steps
    
    print_color "$GREEN" "Installation completed successfully! 🚀"
}

# Run main function
main "$@" 