import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/settings_entity.dart';
import '../entities/settings_params.dart';

abstract class SettingsRepository {
  /// Get settings from cache or remote source
  Future<Either<Failure, SettingsEntity>> getSettings(GetSettingsParams params);

  /// Update settings locally and optionally sync to remote
  Future<Either<Failure, SettingsEntity>> updateSettings(
      UpdateSettingsParams params);

  /// Clear settings cache
  Future<Either<Failure, void>> clearCache();

  /// Check if settings are cached and valid
  Future<bool> isSettingsCached();

  /// Get cached settings timestamp
  Future<DateTime?> getCachedTimestamp();

  /// Stream settings changes for real-time updates
  Stream<SettingsEntity> watchSettings();
}
