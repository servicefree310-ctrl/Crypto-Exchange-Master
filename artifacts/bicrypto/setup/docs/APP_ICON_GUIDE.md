# App Icon Configuration Guide

This guide explains how to set up your custom app icon for BiCrypto Mobile App.

## Icon Requirements

Your app icon should meet these requirements:
- **Format**: PNG (with transparency optional)
- **Size**: Minimum 500x500 pixels (1024x1024 recommended)
- **Style**: Simple, clear design that scales well to small sizes
- **No rounded corners**: The system will apply appropriate corner radius

## Automatic Icon Setup (Recommended)

The installer will automatically handle icon generation during setup:

1. When running the installer (`install.sh`, `install.bat`, or `install.command`), you'll be prompted:
   ```
   Do you have a custom app icon (PNG file, 500x500 or larger)?
   1) Yes, I have an icon file
   2) No, use default icon
   3) I'll add it later
   ```

2. If you choose option 1, provide the full path to your icon file.

3. The installer will:
   - Copy your icon to `assets/icons/app_icon.png`
   - Generate all required icon sizes for Android and iOS
   - Update the app with your new icon

## Updating Icons After Installation

To update your app icon after the initial setup, you have two options:

### Option 1: Re-run the Installer
The installer can be run again to update just the icon:

**macOS/Linux:**
```bash
./setup/installers/install.sh
```

**Windows:**
```cmd
setup\installers\install.bat
```

The installer will detect existing configuration and allow you to update only the icon.

### Option 2: Manual Update
Follow the manual setup steps below.

## Manual Icon Setup

If you prefer to update the icon manually:

### Step 1: Place Your Icon
Copy your icon file to:
```
assets/icons/app_icon.png
```

### Step 2: Generate Icons
Run the following command:
```bash
flutter pub run flutter_launcher_icons
```

This will generate:
- **Android**: Multiple sizes in `android/app/src/main/res/mipmap-*` folders
- **iOS**: All required sizes in `ios/Runner/Assets.xcassets/AppIcon.appiconset`
- **Web**: Favicon in `web/favicon.png` and `web/icons/`

## Platform-Specific Icons

### Android Adaptive Icons
Android 8.0+ supports adaptive icons with foreground and background layers. The configuration in `pubspec.yaml`:

```yaml
android_adaptive_icon:
  foreground_image: "assets/icons/app_icon.png"
  background_color: "#ffffff"  # Or use a background image
```

You can customize:
- `background_color`: Solid color background (hex value)
- Or use `background_image`: Path to a background image

### iOS Marketing Icon
For App Store submission, iOS requires a 1024x1024 marketing icon. This is automatically generated from your main icon.

### Web Favicon
The web favicon is generated automatically and placed in the `web/` directory.

## Icon Design Tips

1. **Keep it simple**: Complex designs don't scale well to small sizes
2. **Use bold shapes**: Thin lines may disappear at small sizes
3. **Consider all backgrounds**: Your icon should look good on both light and dark backgrounds
4. **Test at multiple sizes**: Check how your icon looks at 20x20, 40x40, and 60x60 pixels
5. **Avoid text**: Text becomes illegible at small sizes

## Troubleshooting

### Icons not updating?
1. Run `flutter clean`
2. Delete the app from your device/emulator
3. Run `flutter pub get`
4. Run `flutter pub run flutter_launcher_icons`
5. Rebuild and install the app

### iOS icons not showing?
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner > Runner > General
3. Check that App Icons Source is set to "AppIcon"
4. Clean build folder (Product > Clean Build Folder)
5. Rebuild

### Android icons not showing?
1. Check `android/app/src/main/AndroidManifest.xml`
2. Ensure `android:icon="@mipmap/ic_launcher"` is present
3. Clean and rebuild: `cd android && ./gradlew clean`

## Configuration Reference

The icon configuration in `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true              # Generate Android icons
  ios: true                 # Generate iOS icons
  image_path: "assets/icons/app_icon.png"  # Source icon
  min_sdk_android: 21       # Minimum Android SDK version
  
  # Android adaptive icon settings
  android_adaptive_icon:
    foreground_image: "assets/icons/app_icon.png"
    background_color: "#ffffff"
  
  # iOS specific settings
  ios_marketing: true       # Generate 1024x1024 marketing icon
  remove_alpha_ios: true    # Remove transparency for iOS
  
  # Web favicon
  web:
    generate: true
    image_path: "assets/icons/app_icon.png"
```

## Multiple Icon Variants

If you need different icons for different build flavors:

1. Create separate icon files:
   - `assets/icons/app_icon_dev.png`
   - `assets/icons/app_icon_prod.png`

2. Update `pubspec.yaml` before building:
   ```yaml
   image_path: "assets/icons/app_icon_prod.png"
   ```

3. Run icon generation:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

## Need Help?

If you encounter issues with icon setup:
1. Check the [flutter_launcher_icons documentation](https://pub.dev/packages/flutter_launcher_icons)
2. Ensure your PNG file is valid and not corrupted
3. Try with a different icon file to isolate the issue
4. Check the console output for specific error messages 