import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../../../core/errors/failures.dart';
import '../../../../../../../core/errors/exceptions.dart';
import '../../../../../../../core/network/network_info.dart';
import '../../domain/entities/p2p_recommendation_entity.dart';
import '../../domain/repositories/p2p_recommendation_repository.dart';
import '../datasources/p2p_recommendation_remote_datasource.dart';
import '../datasources/p2p_recommendation_local_datasource.dart';
import '../models/p2p_recommendation_model.dart';

/// Repository implementation for P2P recommendations
@Injectable(as: P2PRecommendationRepository)
class P2PRecommendationRepositoryImpl implements P2PRecommendationRepository {
  const P2PRecommendationRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  final P2PRecommendationRemoteDataSource _remoteDataSource;
  final P2PRecommendationLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<P2PRecommendationEntity>>> getRecommendations({
    String? category,
    int limit = 20,
  }) async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        // Return cached data if offline
        final cachedData = await _localDataSource.getCachedRecommendations();
        return Right(cachedData.map((model) => model.toEntity()).toList());
      }

      // Try remote source
      final models = await _remoteDataSource.getRecommendations(
        category: category,
        limit: limit,
      );

      // Cache the data
      await _localDataSource.cacheRecommendations(models);

      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      // Try local cache on server error
      try {
        final cachedData = await _localDataSource.getCachedRecommendations();
        return Right(cachedData.map((model) => model.toEntity()).toList());
      } catch (_) {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<P2PRecommendationEntity>>> getPriceAlerts({
    String? cryptocurrency,
    int limit = 10,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        final cachedData = await _localDataSource.getCachedPriceAlerts();
        return Right(cachedData.map((model) => model.toEntity()).toList());
      }

      final models = await _remoteDataSource.getPriceAlerts(
        cryptocurrency: cryptocurrency,
        limit: limit,
      );

      await _localDataSource.cachePriceAlerts(models);

      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      try {
        final cachedData = await _localDataSource.getCachedPriceAlerts();
        return Right(cachedData.map((model) => model.toEntity()).toList());
      } catch (_) {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<P2PRecommendationEntity>>> getOfferSuggestions({
    String? cryptocurrency,
    String? tradeType,
    int limit = 10,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        final cachedData = await _localDataSource.getCachedOfferSuggestions();
        return Right(cachedData.map((model) => model.toEntity()).toList());
      }

      final models = await _remoteDataSource.getOfferSuggestions(
        cryptocurrency: cryptocurrency,
        tradeType: tradeType,
        limit: limit,
      );

      await _localDataSource.cacheOfferSuggestions(models);

      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      try {
        final cachedData = await _localDataSource.getCachedOfferSuggestions();
        return Right(cachedData.map((model) => model.toEntity()).toList());
      } catch (_) {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<P2PRecommendationEntity>>> getMarketInsights({
    String? cryptocurrency,
    int limit = 5,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        final cachedData = await _localDataSource.getCachedMarketInsights();
        return Right(cachedData.map((model) => model.toEntity()).toList());
      }

      final models = await _remoteDataSource.getMarketInsights(
        cryptocurrency: cryptocurrency,
        limit: limit,
      );

      await _localDataSource.cacheMarketInsights(models);

      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      try {
        final cachedData = await _localDataSource.getCachedMarketInsights();
        return Right(cachedData.map((model) => model.toEntity()).toList());
      } catch (_) {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<P2PRecommendationEntity>>>
      getTraderRecommendations({
    String? cryptocurrency,
    int limit = 5,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        final cachedData =
            await _localDataSource.getCachedTraderRecommendations();
        return Right(cachedData.map((model) => model.toEntity()).toList());
      }

      final models = await _remoteDataSource.getTraderRecommendations(
        cryptocurrency: cryptocurrency,
        limit: limit,
      );

      await _localDataSource.cacheTraderRecommendations(models);

      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      try {
        final cachedData =
            await _localDataSource.getCachedTraderRecommendations();
        return Right(cachedData.map((model) => model.toEntity()).toList());
      } catch (_) {
        return Left(ServerFailure(e.message));
      }
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String recommendationId) async {
    try {
      if (await _networkInfo.isConnected) {
        await _remoteDataSource.markAsRead(recommendationId);
      }

      await _localDataSource.markAsRead(recommendationId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      if (await _networkInfo.isConnected) {
        await _remoteDataSource.markAllAsRead();
      }

      await _localDataSource.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecommendation(
      String recommendationId) async {
    try {
      if (await _networkInfo.isConnected) {
        await _remoteDataSource.deleteRecommendation(recommendationId);
      }

      await _localDataSource.deleteRecommendation(recommendationId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      if (await _networkInfo.isConnected) {
        final count = await _remoteDataSource.getUnreadCount();
        await _localDataSource.cacheUnreadCount(count);
        return Right(count);
      }

      final cachedCount = await _localDataSource.getCachedUnreadCount();
      return Right(cachedCount);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, P2PRecommendationEntity>> createPriceAlert({
    required String cryptocurrency,
    required double targetPrice,
    required PriceAlertType alertType,
  }) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final model = await _remoteDataSource.createPriceAlert(
        cryptocurrency: cryptocurrency,
        targetPrice: targetPrice,
        alertType: alertType.name,
      );

      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePreferences({
    required Map<String, dynamic> preferences,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        await _remoteDataSource.updatePreferences(preferences);
      }

      await _localDataSource.cachePreferences(preferences);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPreferences() async {
    try {
      if (await _networkInfo.isConnected) {
        final preferences = await _remoteDataSource.getPreferences();
        await _localDataSource.cachePreferences(preferences);
        return Right(preferences);
      }

      final cachedPreferences = await _localDataSource.getCachedPreferences();
      return Right(cachedPreferences);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<List<P2PRecommendationEntity>> watchRecommendations() {
    // This would typically involve WebSocket or periodic polling
    // For now, return an empty stream
    return Stream.empty();
  }

  @override
  Stream<List<P2PRecommendationEntity>> watchPriceAlerts() {
    // This would typically involve WebSocket or periodic polling
    // For now, return an empty stream
    return Stream.empty();
  }
}
