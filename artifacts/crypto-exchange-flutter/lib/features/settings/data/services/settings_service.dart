import 'dart:async';
import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/settings_params.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../datasources/settings_local_datasource.dart';

@injectable
class SettingsService {
  SettingsService(
    this._getSettingsUseCase,
    this._localDataSource,
  );

  final GetSettingsUseCase _getSettingsUseCase;
  final SettingsLocalDataSource _localDataSource;

  Timer? _backgroundTimer;
  bool _isInitialized = false;

  /// Initialize settings service
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Load initial settings
      final params = GetSettingsParams(
        forceRefresh: false,
        backgroundUpdate: false,
      );

      final result = await _getSettingsUseCase(params);

      result.fold(
        (failure) {
          // Handle initialization failure silently
        },
        (settings) {
          _isInitialized = true;
          // Start background updates
          _startBackgroundUpdates();
        },
      );
    } catch (e) {
      // Handle initialization error silently
    }
  }

  /// Start background updates
  void _startBackgroundUpdates() {
    if (_backgroundTimer != null) {
      return;
    }

    _backgroundTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performBackgroundUpdate(),
    );
  }

  /// Perform background update
  Future<void> _performBackgroundUpdate() async {
    try {
      final params = GetSettingsParams(
        forceRefresh: true,
        backgroundUpdate: true,
      );

      final result = await _getSettingsUseCase(params);

      result.fold(
        (failure) {
          // Handle background update failure silently
        },
        (settings) {
          // Background update successful
        },
      );
    } catch (e) {
      // Handle background update error silently
    }
  }

  /// Get user preference for showing "Coming Soon" features
  Future<bool> getShowComingSoon() async {
    try {
      final showComingSoon = await _localDataSource.getShowComingSoon();
      return showComingSoon;
    } catch (e) {
      return AppConstants.defaultShowComingSoon;
    }
  }

  /// Set user preference for showing "Coming Soon" features
  Future<void> setShowComingSoon(bool value) async {
    try {
      await _localDataSource.setShowComingSoon(value);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Clear settings cache
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }

  /// Check if settings are cached
  Future<bool> isSettingsCached() async {
    return await _localDataSource.isSettingsCached();
  }

  /// Get cached settings timestamp
  Future<DateTime?> getCachedTimestamp() async {
    return await _localDataSource.getCachedTimestamp();
  }

  /// Dispose resources
  void dispose() {
    _backgroundTimer?.cancel();
    _backgroundTimer = null;
    _isInitialized = false;
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}
