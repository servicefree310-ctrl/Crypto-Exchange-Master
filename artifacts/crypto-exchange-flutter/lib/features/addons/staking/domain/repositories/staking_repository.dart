import 'package:dartz/dartz.dart';
import 'package:mobile/core/errors/failures.dart';
import '../entities/staking_pool_entity.dart';
import '../entities/staking_position_entity.dart';
import '../entities/staking_stats_entity.dart';
import '../entities/pool_analytics_entity.dart';

abstract class StakingRepository {
  Future<Either<Failure, List<StakingPoolEntity>>> getPools({
    String? status,
    double? minApr,
    double? maxApr,
    String? token,
  });

  Future<Either<Failure, List<StakingPositionEntity>>> getUserPositions({
    String? poolId,
    String? status,
  });

  /// Stake into a pool
  Future<Either<Failure, StakingPositionEntity>> stake({
    required String poolId,
    required double amount,
  });

  /// Withdraw from a position
  Future<Either<Failure, StakingPositionEntity>> withdraw(String positionId);

  /// Claim rewards for a position
  Future<Either<Failure, StakingPositionEntity>> claimRewards(
      String positionId);

  /// Get overall staking platform statistics
  Future<Either<Failure, StakingStatsEntity>> getStats();

  /// Fetch detailed analytics for a specific staking pool
  Future<Either<Failure, PoolAnalyticsEntity>> getPoolAnalytics(
    String poolId, {
    String? timeframe,
  });
}
