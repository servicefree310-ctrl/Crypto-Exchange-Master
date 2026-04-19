import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import '../entities/staking_stats_entity.dart';
import '../repositories/staking_repository.dart';

/// Use case to fetch overall staking platform statistics
@injectable
class GetStakingStatsUseCase implements UseCase<StakingStatsEntity, NoParams> {
  final StakingRepository repository;

  const GetStakingStatsUseCase(this.repository);

  @override
  Future<Either<Failure, StakingStatsEntity>> call(NoParams params) {
    return repository.getStats();
  }
}
