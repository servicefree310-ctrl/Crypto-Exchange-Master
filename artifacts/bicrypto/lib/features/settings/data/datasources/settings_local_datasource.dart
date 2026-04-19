import 'dart:convert';
import 'dart:async';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/settings_model.dart';
import '../../domain/entities/settings_entity.dart';

@injectable
class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  Future<void> cacheSettings(SettingsModel settings) async {
    final settingsJson = jsonEncode(settings.toJson());
    await _prefs.setString(AppConstants.settingsKey, settingsJson);
    await _prefs.setString(
        AppConstants.settingsTimestampKey, DateTime.now().toIso8601String());
  }

  Future<SettingsModel?> getCachedSettings() async {
    final settingsJson = _prefs.getString(AppConstants.settingsKey);
    if (settingsJson == null) return null;

    try {
      final settingsMap = jsonDecode(settingsJson) as Map<String, dynamic>;
      return SettingsModel.fromJson(settingsMap);
    } catch (e) {
      // If cached data is corrupted, remove it
      await clearCache();
      return null;
    }
  }

  Future<DateTime?> getCachedTimestamp() async {
    final timestampString = _prefs.getString(AppConstants.settingsTimestampKey);
    if (timestampString == null) return null;

    try {
      return DateTime.parse(timestampString);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isSettingsCached() async {
    final timestamp = await getCachedTimestamp();
    if (timestamp == null) return false;

    // Check if cache is still valid (1 hour)
    final now = DateTime.now();
    final cacheAge = now.difference(timestamp);
    return cacheAge.inSeconds < AppConstants.settingsCacheDuration;
  }

  Future<void> clearCache() async {
    await _prefs.remove(AppConstants.settingsKey);
    await _prefs.remove(AppConstants.settingsTimestampKey);
  }

  // User preference for showing "Coming Soon" features
  Future<bool> getShowComingSoon() async {
    return _prefs.getBool(AppConstants.showComingSoonKey) ??
        AppConstants.defaultShowComingSoon;
  }

  Future<void> setShowComingSoon(bool value) async {
    await _prefs.setBool(AppConstants.showComingSoonKey, value);
  }

  // Stream for watching settings changes
  Stream<SettingsEntity> watchSettings() {
    return Stream.periodic(const Duration(seconds: 30), (_) async {
      final cachedSettings = await getCachedSettings();
      if (cachedSettings != null) {
        return SettingsEntity(
          settings: cachedSettings.toSettingsMap(),
          extensions: cachedSettings.extensions,
          lastUpdated: DateTime.now(),
        );
      }
      return null;
    })
        .asyncMap((event) => event)
        .where((settings) => settings != null)
        .cast<SettingsEntity>();
  }
}
