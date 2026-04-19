@echo off
setlocal enabledelayedexpansion

REM BiCrypto Mobile App Installer for Windows
REM Version: 5.0.0

REM Color setup
set RED=[91m
set GREEN=[92m
set YELLOW=[93m
set BLUE=[94m
set PURPLE=[95m
set CYAN=[96m
set WHITE=[97m
set NC=[0m

REM Configuration paths
set CONFIG_FILE=assets\config\app_config.json
set CONFIG_EXAMPLE=assets\config\app_config.example.json

REM Print header
:print_header
cls
echo %CYAN%
echo ╔════════════════════════════════════════════════════════════╗
echo ║                                                            ║
echo ║              BiCrypto Mobile App Installer                 ║
echo ║                     Version 5.0.0                          ║
echo ║                   Windows Edition                          ║
echo ║                                                            ║
echo ╚════════════════════════════════════════════════════════════╝
echo %NC%
goto :eof

REM Function to update app name in platform files
:update_app_name_in_platforms
set app_name_param=%~1

echo %YELLOW%Updating app name in platform files...%NC%

REM Update Android app name
if exist "android\app\src\main\AndroidManifest.xml" (
    echo %CYAN%  ✓ Updating Android app name...%NC%
    
    REM Create a temporary PowerShell script to handle the regex replacement
    echo $content = Get-Content "android\app\src\main\AndroidManifest.xml" -Raw > temp_update.ps1
    echo $content = $content -replace 'android:label="[^"]*"', 'android:label="%app_name_param%"' >> temp_update.ps1
    echo $content ^| Set-Content "android\app\src\main\AndroidManifest.xml" >> temp_update.ps1
    
    powershell -ExecutionPolicy Bypass -File temp_update.ps1
    del temp_update.ps1
) else (
    echo %RED%  ✗ Android manifest not found%NC%
)

REM Update iOS app name
if exist "ios\Runner\Info.plist" (
    echo %CYAN%  ✓ Updating iOS app name...%NC%
    
    REM Create a temporary PowerShell script to handle the plist updates
    echo $content = Get-Content "ios\Runner\Info.plist" -Raw > temp_update_ios.ps1
    echo $content = $content -replace '(?s)^<key^>CFBundleDisplayName^</key^>\s*\n\s*^<string^>[^^<]*^</string^>', '^<key^>CFBundleDisplayName^</key^>`n`t^<string^>%app_name_param%^</string^>' >> temp_update_ios.ps1
    echo $content = $content -replace '(?s)^<key^>CFBundleName^</key^>\s*\n\s*^<string^>[^^<]*^</string^>', '^<key^>CFBundleName^</key^>`n`t^<string^>%app_name_param%^</string^>' >> temp_update_ios.ps1
    echo $content ^| Set-Content "ios\Runner\Info.plist" >> temp_update_ios.ps1
    
    powershell -ExecutionPolicy Bypass -File temp_update_ios.ps1
    del temp_update_ios.ps1
) else (
    echo %RED%  ✗ iOS Info.plist not found%NC%
)

echo %GREEN%✓ App name updated in platform files!%NC%
goto :eof

REM Main function
:main
call :print_header

REM Get the directory where this script is located and change to it
cd /d "%~dp0"

REM Check if we're in the right directory
if not exist pubspec.yaml (
    echo %RED%Error: pubspec.yaml not found!%NC%
    echo %YELLOW%This installer must be located in your Flutter project root directory.%NC%
    echo %YELLOW%Current directory: %CD%%NC%
    echo %YELLOW%Looking for pubspec.yaml...%NC%
    
    REM Try parent directory
    cd ..
    if exist pubspec.yaml (
        echo %GREEN%Found Flutter project at: %CD%%NC%
        goto project_found
    )
    
    REM Try one more level up
    cd ..
    if exist pubspec.yaml (
        echo %GREEN%Found Flutter project at: %CD%%NC%
        goto project_found
    )
    
    echo %RED%Could not find Flutter project!%NC%
    echo %YELLOW%Please ensure install.bat is in your Flutter project root directory.%NC%
    pause
    exit /b 1
)

:project_found
echo %GREEN%✓ Flutter project found at: %CD%%NC%

echo %CYAN%Welcome to the BiCrypto Mobile App installer!%NC%
echo %WHITE%This wizard will help you set up everything you need.%NC%
echo.
pause

REM Run installation steps
call :check_prerequisites
if %errorlevel% neq 0 exit /b %errorlevel%

call :configure_app
if %errorlevel% neq 0 exit /b %errorlevel%

call :install_dependencies
if %errorlevel% neq 0 exit /b %errorlevel%

call :setup_app_icon
if %errorlevel% neq 0 exit /b %errorlevel%

call :setup_platform
if %errorlevel% neq 0 exit /b %errorlevel%

call :run_code_generation
if %errorlevel% neq 0 exit /b %errorlevel%

call :verify_setup
if %errorlevel% neq 0 exit /b %errorlevel%

call :build_app
if %errorlevel% neq 0 exit /b %errorlevel%

call :show_next_steps

echo %GREEN%Installation completed successfully! 🚀%NC%
pause
exit /b 0

REM Check prerequisites
:check_prerequisites
echo.
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo %WHITE%  Checking Prerequisites%NC%
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo.

set prerequisites_met=1

REM Check Flutter
where flutter >nul 2>&1
if %errorlevel% equ 0 (
    echo %GREEN%✓ Flutter is installed%NC%
    flutter --version
) else (
    echo %RED%✗ Flutter is not installed%NC%
    set prerequisites_met=0
)

REM Check Git
where git >nul 2>&1
if %errorlevel% equ 0 (
    echo %GREEN%✓ Git is installed%NC%
) else (
    echo %RED%✗ Git is not installed%NC%
    set prerequisites_met=0
)

REM Check Dart
where dart >nul 2>&1
if %errorlevel% equ 0 (
    echo %GREEN%✓ Dart is installed%NC%
) else (
    echo %RED%✗ Dart is not installed%NC%
    set prerequisites_met=0
)

if %prerequisites_met% equ 0 (
    echo.
    echo %YELLOW%Some prerequisites are missing.%NC%
    echo.
    echo %CYAN%Please install the following:%NC%
    echo.
    echo 1. Flutter: https://flutter.dev/docs/get-started/install/windows
    echo 2. Git: https://git-scm.com/download/win
    echo 3. Android Studio: https://developer.android.com/studio
    echo.
    echo %YELLOW%After installation, add them to your PATH and run this script again.%NC%
    pause
    exit /b 1
)

exit /b 0

REM Configure app
:configure_app
echo.
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo %WHITE%  App Configuration%NC%
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo.

REM Check if config already exists
if exist %CONFIG_FILE% (
    echo %YELLOW%Configuration file already exists.%NC%
    echo Do you want to:
    echo 1) Keep existing configuration
    echo 2) Create new configuration
    echo 3) View current configuration
    set /p config_choice="Enter your choice (1-3): "
    
    if !config_choice! equ 1 (
        echo %GREEN%✓ Keeping existing configuration%NC%
        exit /b 0
    ) else if !config_choice! equ 3 (
        echo %CYAN%Current configuration:%NC%
        type %CONFIG_FILE%
        echo.
        pause
        goto :configure_app
    )
)

REM Copy example config
copy %CONFIG_EXAMPLE% %CONFIG_FILE% >nul

echo %CYAN%Let's configure your BiCrypto app!%NC%
echo.

REM Backend URL
:backend_url_input
echo %WHITE%1. Backend API URL%NC%
echo %YELLOW%   This is your server's API endpoint%NC%
echo %YELLOW%   Example: https://api.yourexchange.com%NC%
set /p backend_url="   Enter your backend URL: "

echo !backend_url! | findstr /R "^https*://" >nul
if %errorlevel% neq 0 (
    echo %RED%   ✗ Invalid URL. Must start with https:// or http://%NC%
    goto :backend_url_input
)

REM WebSocket URL
:ws_url_input
echo.
echo %WHITE%2. WebSocket URL%NC%
echo %YELLOW%   This is for real-time updates%NC%
echo %YELLOW%   Example: wss://api.yourexchange.com%NC%
set /p ws_url="   Enter your WebSocket URL: "

echo !ws_url! | findstr /R "^wss*://" >nul
if %errorlevel% neq 0 (
    echo %RED%   ✗ Invalid WebSocket URL. Must start with wss:// or ws://%NC%
    goto :ws_url_input
)

REM App Name
echo.
echo %WHITE%3. App Name%NC%
echo %YELLOW%   This will be displayed as your app's name everywhere%NC%
echo %YELLOW%   Including: device home screen, app drawer, and inside the app%NC%
set /p app_name="   Enter your app name (default: BiCrypto): "
if "!app_name!"=="" set app_name=BiCrypto

REM Update app name in platform files
call :update_app_name_in_platforms "!app_name!"

REM App Version
echo.
echo %WHITE%4. App Version%NC%
echo %YELLOW%   Your app's version number%NC%
set /p app_version="   Enter app version (default: 5.0.0): "
if "!app_version!"=="" set app_version=5.0.0

REM Exchange Provider
echo.
echo %WHITE%5. Default Exchange Provider%NC%
echo %YELLOW%   Choose your default exchange:%NC%
echo    1) Binance (bin)
echo    2) KuCoin (kuc)
echo    3) OKX (okx)
echo    4) XT (xt)
echo    5) Kraken (kra)
set /p exchange_choice="   Enter choice (1-5, default: 1): "
if "!exchange_choice!"=="" set exchange_choice=1

if !exchange_choice! equ 1 set exchange_provider=bin
if !exchange_choice! equ 2 set exchange_provider=kuc
if !exchange_choice! equ 3 set exchange_provider=okx
if !exchange_choice! equ 4 set exchange_provider=xt
if !exchange_choice! equ 5 set exchange_provider=kra

REM Trading Pair
echo.
echo %WHITE%6. Default Trading Pair%NC%
echo %YELLOW%   Format: BASE/QUOTE (uppercase)%NC%
set /p trading_pair="   Enter trading pair (default: BTC/USDT): "
if "!trading_pair!"=="" set trading_pair=BTC/USDT

REM Stripe Key
echo.
echo %WHITE%7. Stripe Publishable Key (Optional)%NC%
echo %YELLOW%   Leave empty if not using Stripe payments%NC%
set /p stripe_key="   Enter Stripe key: "

REM Google Client ID
echo.
echo %WHITE%8. Google OAuth Client ID (Optional)%NC%
echo %YELLOW%   Leave empty if not using Google Sign-In%NC%
set /p google_client_id="   Enter Google Client ID: "

REM Show Coming Soon
echo.
echo %WHITE%9. Show 'Coming Soon' Features?%NC%
echo %YELLOW%   Show incomplete features with 'Coming Soon' badge?%NC%
set /p show_coming_soon="   Enter choice (y/n, default: y): "
if "!show_coming_soon!"=="" set show_coming_soon=y
if /i "!show_coming_soon!"=="y" (
    set show_coming_soon_bool=true
) else (
    set show_coming_soon_bool=false
)

REM Create configuration
(
echo {
echo   "baseUrl": "!backend_url!",
echo   "wsBaseUrl": "!ws_url!",
echo   "appName": "!app_name!",
echo   "appVersion": "!app_version!",
echo.
echo   "stripePublishableKey": "!stripe_key!",
echo   "googleServerClientId": "!google_client_id!",
echo.
echo   "defaultExchangeProvider": "!exchange_provider!",
echo   "defaultTradingPair": "!trading_pair!",
echo.
echo   "defaultShowComingSoon": !show_coming_soon_bool!,
echo.
echo   "settingsCacheDuration": 3600,
echo   "backgroundUpdateInterval": 60
echo }
) > %CONFIG_FILE%

echo %GREEN%✓ Configuration saved successfully!%NC%
exit /b 0

REM Setup app icon
:setup_app_icon
echo.
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo %WHITE%  App Icon Setup%NC%
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo.

echo %CYAN%App Icon Configuration%NC%
echo.

REM Check if icon already exists
if exist "assets\icons\app_icon.png" (
    echo %YELLOW%An app icon already exists.%NC%
    echo What would you like to do?
    echo 1) Replace with a new icon
    echo 2) Keep existing icon
    echo 3) Skip icon setup
    set /p existing_icon_choice="Enter choice (1-3): "
    
    if !existing_icon_choice! equ 2 (
        echo %GREEN%✓ Keeping existing icon%NC%
        REM Still generate icons to ensure all platforms are updated
        echo %YELLOW%Regenerating icons for all platforms...%NC%
        flutter pub run flutter_launcher_icons
        if %errorlevel% neq 0 (
            echo %YELLOW%Icon generation skipped or failed%NC%
        )
        goto :icon_setup_done
    ) else if !existing_icon_choice! equ 3 (
        echo %YELLOW%Skipping icon setup%NC%
        goto :icon_setup_done
    )
)

echo Do you have a custom app icon (PNG file, 500x500 or larger)?
echo 1) Yes, I have an icon file
echo 2) No, use default placeholder
echo 3) I'll add it later
set /p icon_choice="Enter choice (1-3): "

if !icon_choice! equ 1 (
    :icon_path_input
    echo %YELLOW%Please enter the full path to your icon file:%NC%
    echo %YELLOW%Example: C:\Users\You\Desktop\icon.png%NC%
    set /p icon_path="Icon path: "
    
    if not exist "!icon_path!" (
        echo %RED%File not found: !icon_path!%NC%
        echo Would you like to:
        echo 1) Try again
        echo 2) Skip icon setup
        set /p retry_choice="Enter choice (1-2): "
        if !retry_choice! equ 1 goto :icon_path_input
        echo %YELLOW%Skipping icon setup%NC%
        goto :icon_setup_done
    )
    
    REM Create icons directory if it doesn't exist
    if not exist "assets\icons" mkdir "assets\icons"
    
    REM Copy icon to assets
    copy "!icon_path!" "assets\icons\app_icon.png" >nul
    if %errorlevel% equ 0 (
        echo %GREEN%✓ Icon copied successfully!%NC%
        
        REM Generate all icon sizes
        echo %YELLOW%Generating app icons for all platforms...%NC%
        flutter pub run flutter_launcher_icons
        if %errorlevel% equ 0 (
            echo %GREEN%✓ App icons generated successfully!%NC%
            echo %CYAN%Your custom icon has been applied to:%NC%
            echo   • Android app icon
            echo   • Web favicon
        ) else (
            echo %RED%Failed to generate icons!%NC%
            echo %YELLOW%The icon was copied but generation failed.%NC%
            echo %YELLOW%You can run this manually later:%NC%
            echo %WHITE%flutter pub run flutter_launcher_icons%NC%
        )
    ) else (
        echo %RED%Failed to copy icon file!%NC%
    )
) else if !icon_choice! equ 2 (
    echo %YELLOW%Using default placeholder icon...%NC%
    REM Create icons directory if it doesn't exist
    if not exist "assets\icons" mkdir "assets\icons"
    
    REM Create a placeholder icon if it doesn't exist
    if not exist "assets\icons\app_icon.png" (
        echo %YELLOW%Creating placeholder icon...%NC%
        type nul > "assets\icons\app_icon.png"
    )
    
    REM Generate icons
    echo %YELLOW%Generating app icons...%NC%
    flutter pub run flutter_launcher_icons
    if %errorlevel% equ 0 (
        echo %GREEN%✓ Placeholder icons generated!%NC%
    ) else (
        echo %YELLOW%Icon generation skipped%NC%
    )
) else (
    echo %YELLOW%You can add your icon later by:%NC%
    echo.
    echo %CYAN%Method 1: Re-run installer%NC%
    echo   %WHITE%setup\installers\install.bat%NC%
    echo.
    echo %CYAN%Method 2: Manual setup%NC%
    echo   1. Place your PNG icon at: assets\icons\app_icon.png
    echo   2. Run: flutter pub run flutter_launcher_icons
    echo   3. Clean and rebuild: flutter clean ^&^& flutter run
    echo.
    echo %CYAN%Icon Requirements:%NC%
    echo   • PNG format
    echo   • 512x512 pixels or larger
    echo   • Square aspect ratio
    echo   • No transparency for best results
)

:icon_setup_done
echo.
pause
exit /b 0

REM Install dependencies
:install_dependencies
echo.
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo %WHITE%  Installing Dependencies%NC%
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo.

echo %YELLOW%Running flutter pub get...%NC%
flutter pub get
if %errorlevel% neq 0 (
    echo %RED%Failed to install dependencies!%NC%
    echo %YELLOW%Trying to fix...%NC%
    flutter clean
    flutter pub get
)

echo %GREEN%✓ Dependencies installed successfully%NC%
exit /b 0

REM Setup platform
:setup_platform
echo.
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo %WHITE%  Platform Setup%NC%
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo.

echo Which platforms do you want to set up?
echo 1) Android only
echo 2) iOS (not available on Windows)
echo 3) Web
echo 4) Android and Web
set /p platform_choice="Enter your choice (1-4): "

if !platform_choice! equ 1 call :setup_android
if !platform_choice! equ 3 call :setup_web
if !platform_choice! equ 4 (
    call :setup_android
    call :setup_web
)

exit /b 0

REM Setup Android
:setup_android
echo.
echo %YELLOW%Setting up Android...%NC%

REM Check for Android SDK
if not defined ANDROID_HOME if not defined ANDROID_SDK_ROOT (
    echo %YELLOW%Android SDK not found in environment variables.%NC%
    echo.
    echo %CYAN%Android Studio Setup Instructions:%NC%
    echo 1. Download Android Studio from: https://developer.android.com/studio
    echo 2. Install and open Android Studio
    echo 3. Go to SDK Manager (Tools - SDK Manager)
    echo 4. Install Android SDK Platform-Tools
    echo 5. Set ANDROID_HOME environment variable to your SDK path
    echo    (Usually: C:\Users\%USERNAME%\AppData\Local\Android\Sdk)
    echo.
    pause
)

echo %YELLOW%Accepting Android licenses...%NC%
flutter doctor --android-licenses
if %errorlevel% neq 0 (
    echo %RED%Failed to accept licenses automatically.%NC%
    echo %YELLOW%Please run: flutter doctor --android-licenses%NC%
)

echo %GREEN%✓ Android setup completed%NC%
exit /b 0

REM Setup Web
:setup_web
echo.
echo %YELLOW%Enabling web support...%NC%
flutter config --enable-web
echo %GREEN%✓ Web setup completed%NC%
exit /b 0

REM Run code generation
:run_code_generation
echo.
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo %WHITE%  Code Generation%NC%
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo.

echo %YELLOW%Running build_runner...%NC%
flutter pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo %RED%Code generation failed!%NC%
    echo %YELLOW%This might be okay if no generated files have changed.%NC%
)

echo %GREEN%✓ Code generation completed%NC%
exit /b 0

REM Verify setup
:verify_setup
echo.
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo %WHITE%  Verifying Setup%NC%
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo.

echo %YELLOW%Running flutter doctor...%NC%
flutter doctor

echo.
echo %CYAN%Please review the output above.%NC%
echo %YELLOW%If there are any issues (marked with [X]), you should fix them.%NC%
pause
exit /b 0

REM Build app
:build_app
echo.
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo %WHITE%  Build App%NC%
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo.

echo Would you like to build the app now?
echo 1) Yes, build for Android (APK)
echo 2) Yes, build for Web
echo 3) Yes, build both
echo 4) No, I'll build later
set /p build_choice="Enter choice (1-4): "

if !build_choice! equ 1 goto :build_android
if !build_choice! equ 2 goto :build_web_app
if !build_choice! equ 3 (
    call :build_android
    call :build_web_app
)
exit /b 0

:build_android
echo %YELLOW%Building Android APK...%NC%
flutter build apk --release
if %errorlevel% neq 0 (
    echo %RED%Android build failed!%NC%
    echo %YELLOW%Common fixes:%NC%
    echo - Check your Android SDK setup
    echo - Run: flutter clean
    echo - Check for errors in android\app\build.gradle
) else (
    if exist "build\app\outputs\flutter-apk\app-release.apk" (
        echo %GREEN%✓ APK built successfully!%NC%
        echo %CYAN%Location: build\app\outputs\flutter-apk\app-release.apk%NC%
    )
)
exit /b 0

:build_web_app
echo %YELLOW%Building Web app...%NC%
flutter build web
if %errorlevel% neq 0 (
    echo %RED%Web build failed!%NC%
) else (
    echo %GREEN%✓ Web app built successfully!%NC%
    echo %CYAN%Location: build\web%NC%
)
exit /b 0

REM Show next steps
:show_next_steps
echo.
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo %WHITE%  Setup Complete! 🎉%NC%
echo %PURPLE%━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%NC%
echo.

echo %GREEN%Your BiCrypto app is ready!%NC%
echo.
echo %CYAN%Next steps:%NC%
echo.
echo 1. To run on Android emulator/device:
echo    %WHITE%flutter run%NC%
echo.
echo 2. To run on web:
echo    %WHITE%flutter run -d chrome%NC%
echo.
echo 3. To build release APK:
echo    %WHITE%flutter build apk --release%NC%
echo.
echo 4. To build web app:
echo    %WHITE%flutter build web%NC%
echo.
echo %YELLOW%Configuration file location:%NC%
echo    %WHITE%%CONFIG_FILE%%NC%
echo.
echo %YELLOW%Documentation:%NC%
echo    - CONFIGURATION_GUIDE.md
echo    - assets\config\CONFIG_FIELDS_EXPLAINED.md
echo    - assets\config\QUICK_REFERENCE.txt
echo.
exit /b 0 