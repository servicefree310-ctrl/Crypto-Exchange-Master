import 'dart:ui';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/app_theme_entity.dart';
import '../../../../core/errors/exceptions.dart';

/// Local data source interface for theme operations
abstract class ThemeLocalDataSource {
  Future<AppThemeType> getSavedTheme();
  Future<void> saveTheme(AppThemeType theme);
  Future<AppThemeType> getSystemTheme();
}

/// Implementation of theme local data source using SharedPreferences
@Injectable(as: ThemeLocalDataSource)
class ThemeLocalDataSourceImpl implements ThemeLocalDataSource {
  final SharedPreferences _sharedPreferences;
  static const String _cachedThemeKey = 'CACHED_THEME';

  const ThemeLocalDataSourceImpl(this._sharedPreferences);

  @override
  Future<AppThemeType> getSavedTheme() async {
    try {
      final themeString = _sharedPreferences.getString(_cachedThemeKey);
      if (themeString != null) {
        return _parseThemeType(themeString);
      }
      // Return dark theme as default if no saved theme
      // This ensures the app always starts in dark mode unless user has changed it
      return AppThemeType.dark;
    } catch (e) {
      throw const CacheException('Failed to get saved theme');
    }
  }

  @override
  Future<void> saveTheme(AppThemeType theme) async {
    try {
      final themeString = _themeTypeToString(theme);
      await _sharedPreferences.setString(_cachedThemeKey, themeString);
    } catch (e) {
      throw const CacheException('Failed to save theme');
    }
  }

  @override
  Future<AppThemeType> getSystemTheme() async {
    try {
      // Get system brightness
      final brightness = PlatformDispatcher.instance.platformBrightness;
      return brightness == Brightness.dark
          ? AppThemeType.dark
          : AppThemeType.light;
    } catch (e) {
      // Default to dark theme if we can't determine system theme
      return AppThemeType.dark;
    }
  }

  AppThemeType _parseThemeType(String themeString) {
    switch (themeString) {
      case 'light':
        return AppThemeType.light;
      case 'dark':
        return AppThemeType.dark;
      case 'system':
        return AppThemeType.system;
      default:
        return AppThemeType.dark; // Default fallback
    }
  }

  String _themeTypeToString(AppThemeType theme) {
    switch (theme) {
      case AppThemeType.light:
        return 'light';
      case AppThemeType.dark:
        return 'dark';
      case AppThemeType.system:
        return 'system';
    }
  }
}
