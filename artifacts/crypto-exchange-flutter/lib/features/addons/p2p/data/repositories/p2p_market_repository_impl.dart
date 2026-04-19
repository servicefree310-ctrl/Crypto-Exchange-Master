import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/network/network_info.dart';
import '../../domain/entities/p2p_market_stats_entity.dart';
import '../../domain/repositories/p2p_market_repository.dart';
import '../datasources/p2p_remote_datasource.dart';
import '../datasources/p2p_local_datasource.dart';
import '../datasources/p2p_market_remote_datasource.dart';
import '../models/p2p_market_stats_model.dart';
import '../../../../../core/errors/exceptions.dart';

@Injectable(as: P2PMarketRepository)
class P2PMarketRepositoryImpl implements P2PMarketRepository {
  final P2PRemoteDataSource _remoteDataSource;
  final P2PLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final P2PMarketRemoteDataSource _p2pMarketRemoteDataSource;

  const P2PMarketRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._p2pMarketRemoteDataSource,
  );

  @override
  Future<Either<Failure, P2PMarketStatsEntity>> getMarketStats() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final model = await _p2pMarketRemoteDataSource.getMarketStats();
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<P2PTopCryptoEntity>>> getTopCryptos() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final models = await _p2pMarketRemoteDataSource.getTopCryptos();
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<P2PTopCryptoEntity>>> getTopCurrencies({
    int limit = 5,
  }) async {
    // Delegate to getTopCryptos for now
    return getTopCryptos();
  }

  @override
  Future<Either<Failure, List<P2PMarketHighlightEntity>>>
      getMarketHighlights() async {
    try {
      // Check network connectivity
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final models = await _p2pMarketRemoteDataSource.getMarketHighlights();
      return Right(models.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getTopMarkets() async {
    try {
      if (await _networkInfo.isConnected) {
        final result = await _remoteDataSource.getTopMarkets();

        // Cache the result
        // await _localDataSource.cacheTopMarkets(result);

        return Right(result);
      } else {
        // Try to get cached data
        // final cachedData = await _localDataSource.getCachedTopMarkets();
        // if (cachedData != null) {
        //   return Right(cachedData);
        // }
        return Left(NetworkFailure('No internet connection'));
      }
    } catch (e) {
      // Try cached data on error
      // try {
      //   final cachedData = await _localDataSource.getCachedTopMarkets();
      //   if (cachedData != null) {
      //     return Right(cachedData);
      //   }
      // } catch (_) {}

      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> submitGuidedMatching(
    Map<String, dynamic> criteria,
  ) async {
    if (!await _networkInfo.isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final result = await _remoteDataSource.submitGuidedMatching(criteria);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
