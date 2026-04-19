import 'dart:async';
import 'dart:developer' as dev;
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../datasources/settings_local_datasource.dart';
import '../datasources/settings_remote_datasource.dart';
import '../models/settings_model.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/entities/settings_params.dart';
import '../../domain/repositories/settings_repository.dart';

@Injectable(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  final SettingsRemoteDataSource _remoteDataSource;
  final SettingsLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  // Stream controller for real-time updates
  final StreamController<SettingsEntity> _settingsController =
      StreamController<SettingsEntity>.broadcast();

  @override
  Future<Either<Failure, SettingsEntity>> getSettings(
      GetSettingsParams params) async {
    try {
      // Check network connectivity
      final isConnected = await _networkInfo.isConnected;

      if (!isConnected) {
        try {
          final cachedSettings = await _localDataSource.getCachedSettings();
          if (cachedSettings != null) {
            final entity = _convertToEntity(cachedSettings);
            return Right(entity);
          } else {
            return Left(
                NetworkFailure('No network connection and no cached data'));
          }
        } catch (e) {
          return Left(NetworkFailure('Failed to access cached data: $e'));
        }
      }

      // Check if we should use cache (if not forcing refresh)
      if (!params.forceRefresh) {
        final isCached = await _localDataSource.isSettingsCached();
        if (isCached) {
          final cachedSettings = await _localDataSource.getCachedSettings();
          if (cachedSettings != null) {
            final entity = _convertToEntity(cachedSettings);
            dev.log('=== SETTINGS LOADED FROM CACHE ===');
            dev.log('Extensions: ${cachedSettings.extensions}');
            dev.log('Cache loaded at: ${DateTime.now()}');
            dev.log('=== END CACHE LOAD ===');
            return Right(entity);
          }
        }
      }

      dev.log('=== SETTINGS LOADING FROM API ===');
      dev.log('Force refresh: ${params.forceRefresh}');
      dev.log('Background update: ${params.backgroundUpdate}');
      final settings = await _remoteDataSource.getSettings();
      final entity = _convertToEntity(settings);

      // Cache the settings locally
      await _localDataSource.cacheSettings(settings);

      // Print cache update status
      dev.log('=== SETTINGS CACHE UPDATED ===');
      dev.log('Extensions: ${settings.extensions}');
      dev.log('Cache updated at: ${DateTime.now()}');
      dev.log('=== END CACHE UPDATE ===');

      // Emit to stream if not background update
      if (!params.backgroundUpdate) {
        _settingsController.add(entity);
      }

      return Right(entity);
    } on Exception catch (e) {
      // Try to get cached data
      try {
        final cachedSettings = await _localDataSource.getCachedSettings();
        if (cachedSettings != null) {
          final entity = _convertToEntity(cachedSettings);
          return Right(entity);
        } else {
          return Left(ServerFailure('Server error and no cached data: $e'));
        }
      } catch (cacheError) {
        return Left(ServerFailure('Server error and cache access failed: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, SettingsEntity>> updateSettings(
      UpdateSettingsParams params) async {
    try {
      // Check network connectivity
      final isConnected = await _networkInfo.isConnected;

      if (!isConnected) {
        return Left(
            NetworkFailure('No network connection for settings update'));
      }

      final updatedSettings = await _remoteDataSource.updateSettings(params);
      final entity = _convertToEntity(updatedSettings);

      // Update local cache
      await _localDataSource.cacheSettings(updatedSettings);

      // Clear cache if requested
      if (params.clearCache) {
        await clearCache();
      }

      // Emit to stream
      _settingsController.add(entity);

      return Right(entity);
    } on Exception catch (e) {
      return Left(ServerFailure('Failed to update settings: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await _localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear cache: $e'));
    }
  }

  @override
  Future<bool> isSettingsCached() async {
    return await _localDataSource.isSettingsCached();
  }

  @override
  Future<DateTime?> getCachedTimestamp() async {
    return await _localDataSource.getCachedTimestamp();
  }

  @override
  Stream<SettingsEntity> watchSettings() {
    return _settingsController.stream;
  }

  // Helper method to convert model to entity
  SettingsEntity _convertToEntity(SettingsModel model) {
    final entity = SettingsEntity(
      settings: model.toSettingsMap(),
      extensions: model.extensions,
      lastUpdated: DateTime.now(),
    );

    return entity;
  }

  // Dispose method for cleanup
  void dispose() {
    _settingsController.close();
  }
}
