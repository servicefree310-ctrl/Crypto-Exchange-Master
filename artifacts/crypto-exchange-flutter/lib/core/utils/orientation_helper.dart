import 'package:flutter/services.dart';

/// Utility class for managing device orientation throughout the app
///
/// This class provides methods to handle orientation changes consistently,
/// ensuring the global portrait lock is maintained except for specific cases
/// like the fullscreen chart view.
class OrientationHelper {
  /// Lock the device to portrait orientation only
  /// This is the default state for the entire app
  static Future<void> lockPortrait() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Allow landscape orientation (for fullscreen chart)
  /// This temporarily overrides the global portrait lock
  static Future<void> allowLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Allow all orientations (rarely used)
  /// This completely removes orientation restrictions
  static Future<void> allowAll() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Enable immersive mode (hide system UI)
  /// Typically used with landscape mode for fullscreen experiences
  static Future<void> enableImmersiveMode() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  /// Restore normal system UI
  /// Shows status bar and navigation bar
  static Future<void> restoreSystemUI() async {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }

  /// Complete setup for fullscreen chart mode
  /// Combines landscape orientation with immersive UI
  static Future<void> enableFullscreenChart() async {
    await Future.wait([
      allowLandscape(),
      enableImmersiveMode(),
    ]);
  }

  /// Complete restoration to normal app mode
  /// Combines portrait lock with normal system UI
  static Future<void> restoreNormalMode() async {
    await Future.wait([
      lockPortrait(),
      restoreSystemUI(),
    ]);
  }
}
