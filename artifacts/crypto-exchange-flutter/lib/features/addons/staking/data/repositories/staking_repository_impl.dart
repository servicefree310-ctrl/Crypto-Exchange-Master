import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/exceptions.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/features/addons/staking/domain/entities/staking_pool_entity.dart';
import 'package:mobile/features/addons/staking/domain/entities/staking_position_entity.dart';
import 'package:mobile/features/addons/staking/domain/repositories/staking_repository.dart';
import 'package:mobile/features/addons/staking/data/datasources/staking_remote_data_source.dart';
import 'package:mobile/features/addons/staking/data/models/staking_pool_model.dart';
import 'package:mobile/features/addons/staking/domain/entities/staking_stats_entity.dart';
import 'package:mobile/features/addons/staking/domain/entities/pool_analytics_entity.dart';

@Injectable(as: StakingRepository)
class StakingRepositoryImpl implements StakingRepository {
  final StakingRemoteDataSource remoteDataSource;

  const StakingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<StakingPoolEntity>>> getPools({
    String? status,
    double? minApr,
    double? maxApr,
    String? token,
  }) async {
    try {
      final models = await remoteDataSource.getPools(
        status: status,
        minApr: minApr,
        maxApr: maxApr,
        token: token,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on NetworkException {
      return const Left(NetworkFailure('Network error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StakingPositionEntity>>> getUserPositions({
    String? poolId,
    String? status,
  }) async {
    try {
      final models = await remoteDataSource.getUserPositions(
        poolId: poolId,
        status: status,
      );
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on NetworkException {
      return const Left(NetworkFailure('Network error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StakingPositionEntity>> stake({
    required String poolId,
    required double amount,
  }) async {
    try {
      final model = await remoteDataSource.stake(
        poolId: poolId,
        amount: amount,
      );
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure('Network error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StakingPositionEntity>> withdraw(
      String positionId) async {
    try {
      final model = await remoteDataSource.withdraw(positionId);
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure('Network error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StakingPositionEntity>> claimRewards(
      String positionId) async {
    try {
      final model = await remoteDataSource.claimRewards(positionId);
      return Right(model.toEntity());
    } on NetworkException {
      return const Left(NetworkFailure('Network error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StakingStatsEntity>> getStats() async {
    try {
      final model = await remoteDataSource.getStats();
      return Right(model);
    } on NetworkException {
      return const Left(NetworkFailure('Network error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PoolAnalyticsEntity>> getPoolAnalytics(
    String poolId, {
    String? timeframe,
  }) async {
    try {
      final model = await remoteDataSource.getPoolAnalytics(
        poolId,
        timeframe: timeframe,
      );
      return Right(model);
    } on NetworkException {
      return const Left(NetworkFailure('Network error'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
