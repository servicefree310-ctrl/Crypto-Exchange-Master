# Orientation Management System

This document explains how device orientation is managed throughout the mobile trading app.

## Overview

The app implements a **global portrait lock** with specific exceptions for certain features that require landscape mode, such as the fullscreen chart view.

## Global Portrait Lock

### Implementation
- **Location**: `lib/main.dart` in the `main()` function
- **Utility**: `OrientationHelper.lockPortrait()`
- **Scope**: Entire application by default

```dart
// Applied globally at app startup
await OrientationHelper.lockPortrait();
```

### Supported Orientations
- ✅ `DeviceOrientation.portraitUp`
- ✅ `DeviceOrientation.portraitDown`
- ❌ `DeviceOrientation.landscapeLeft` (blocked globally)
- ❌ `DeviceOrientation.landscapeRight` (blocked globally)

## Exceptions to Portrait Lock

### Fullscreen Chart View
The fullscreen chart page (`lib/features/chart/presentation/pages/fullscreen_chart_page.dart`) is the **only** screen that overrides the global portrait lock.

#### Behavior
1. **On Enter**: Temporarily enables landscape mode and immersive UI
2. **On Exit**: Immediately restores portrait lock and normal UI
3. **On Dispose**: Ensures portrait lock is restored even if user navigates away unexpectedly

#### Implementation
```dart
@override
void initState() {
  super.initState();
  // Override global portrait lock for fullscreen chart
  OrientationHelper.enableFullscreenChart();
}

@override
void dispose() {
  // Restore global portrait lock
  OrientationHelper.restoreNormalMode();
  super.dispose();
}

void _exitFullscreen() {
  // Immediate restore before navigation
  OrientationHelper.restoreNormalMode();
  Navigator.of(context).pop();
}
```

## OrientationHelper Utility

### Purpose
Centralized utility class for consistent orientation management across the app.

### Methods

#### Basic Orientation Control
- `lockPortrait()` - Lock to portrait only (default app state)
- `allowLandscape()` - Allow landscape only (for fullscreen features)
- `allowAll()` - Allow all orientations (rarely used)

#### System UI Control
- `enableImmersiveMode()` - Hide status bar and navigation bar
- `restoreSystemUI()` - Show status bar and navigation bar

#### Combined Actions
- `enableFullscreenChart()` - Landscape + immersive mode
- `restoreNormalMode()` - Portrait + normal UI

### Usage Example
```dart
// For fullscreen features
await OrientationHelper.enableFullscreenChart();

// Return to normal app mode
await OrientationHelper.restoreNormalMode();
```

## Platform Configuration

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<activity
    android:configChanges="orientation|keyboardHidden|keyboard|screenSize|..."
    ...>
```
The `orientation` in `configChanges` allows the app to handle orientation changes dynamically.

### iOS (`ios/Runner/Info.plist`)
```xml
<key>UISupportedInterfaceOrientations</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```
Supports both portrait and landscape orientations at the platform level.

### Web (`web/manifest.json`)
```json
{
    "orientation": "portrait-primary"
}
```
Default to portrait for web platform.

## Best Practices

### ✅ Do
- Use `OrientationHelper` for all orientation changes
- Always restore portrait mode when exiting landscape features
- Test orientation changes on both Android and iOS
- Ensure UI layouts work in both orientations for landscape features

### ❌ Don't
- Call `SystemChrome.setPreferredOrientations()` directly
- Forget to restore portrait mode in `dispose()` methods
- Add orientation overrides to regular pages (only fullscreen features should need them)
- Allow landscape mode for regular app screens

## Testing

### Manual Testing
1. **Portrait Lock**: Navigate through all app screens - should remain in portrait
2. **Fullscreen Chart**: 
   - Open chart page → should be portrait
   - Tap fullscreen → should switch to landscape
   - Exit fullscreen → should return to portrait
   - Navigate away from chart → should remain in portrait

### Edge Cases
- Device rotation during orientation change
- App backgrounding/foregrounding during landscape mode
- Navigation gestures during orientation transitions
- System UI visibility during immersive mode

## Troubleshooting

### Common Issues

#### Orientation not changing
- Check platform configuration files
- Verify `OrientationHelper` is being called
- Test on physical device (simulator may behave differently)

#### Stuck in landscape
- Ensure `dispose()` method calls `restoreNormalMode()`
- Check for exceptions during orientation change
- Verify navigation doesn't skip dispose

#### UI layout issues
- Test both orientations for landscape features
- Use responsive design principles
- Consider different screen sizes and aspect ratios

### Debug Logging
The orientation system includes comprehensive logging:
```
🔒 MAIN: Setting global portrait orientation lock
✅ MAIN: Portrait orientation lock applied globally
🔄 FULLSCREEN_CHART: Overriding global portrait lock for landscape mode
✅ FULLSCREEN_CHART: Landscape orientation and immersive mode activated
🔄 FULLSCREEN_CHART: Restoring global portrait orientation lock
✅ FULLSCREEN_CHART: Portrait orientation lock and system UI restored
```

## Future Considerations

### Potential Additions
- **Video Player**: May need landscape mode for fullscreen video
- **Image Viewer**: Could benefit from landscape orientation
- **Game Features**: Might require landscape mode

### Implementation Guidelines
1. Follow the same pattern as fullscreen chart
2. Use `OrientationHelper` utility
3. Always restore portrait mode
4. Add comprehensive logging
5. Test on multiple devices

---

*Last updated: [Current Date]*
*Version: 1.0* 