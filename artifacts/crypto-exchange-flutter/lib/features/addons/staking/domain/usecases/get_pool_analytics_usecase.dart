import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import '../entities/pool_analytics_entity.dart';
import '../repositories/staking_repository.dart';

/// Parameters for fetching pool analytics
class GetPoolAnalyticsParams {
  final String poolId;
  final String? timeframe;

  const GetPoolAnalyticsParams({required this.poolId, this.timeframe});
}

/// Use case to fetch detailed analytics for a specific staking pool
@injectable
class GetPoolAnalyticsUseCase
    implements UseCase<PoolAnalyticsEntity, GetPoolAnalyticsParams> {
  final StakingRepository repository;

  const GetPoolAnalyticsUseCase(this.repository);

  @override
  Future<Either<Failure, PoolAnalyticsEntity>> call(
      GetPoolAnalyticsParams params) {
    return repository.getPoolAnalytics(
      params.poolId,
      timeframe: params.timeframe,
    );
  }
}
