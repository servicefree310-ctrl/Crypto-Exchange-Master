import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/futures_position_entity.dart';
import '../../domain/repositories/futures_position_repository.dart';
import '../datasources/futures_position_remote_datasource.dart';

@Injectable(as: FuturesPositionRepository)
class FuturesPositionRepositoryImpl implements FuturesPositionRepository {
  const FuturesPositionRepositoryImpl(
    this._remoteDataSource,
    this._networkInfo,
  );

  final FuturesPositionRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<FuturesPositionEntity>>> getPositions({
    required String symbol,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final models = await _remoteDataSource.getPositions(symbol: symbol);
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FuturesPositionEntity>> closePosition({
    required String symbol,
    required String side,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final model = await _remoteDataSource.closePosition(
        symbol: symbol,
        side: side,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, FuturesPositionEntity>> updateLeverage({
    required String symbol,
    required double leverage,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('No internet connection'));
    }

    try {
      final model = await _remoteDataSource.updateLeverage(
        symbol: symbol,
        leverage: leverage,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
