import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import '../entities/staking_position_entity.dart';
import '../repositories/staking_repository.dart';

@injectable
class ClaimRewardsUseCase
    implements UseCase<StakingPositionEntity, ClaimRewardsParams> {
  final StakingRepository repository;

  const ClaimRewardsUseCase(this.repository);

  @override
  Future<Either<Failure, StakingPositionEntity>> call(
      ClaimRewardsParams params) {
    return repository.claimRewards(params.positionId);
  }
}

class ClaimRewardsParams extends Equatable {
  final String positionId;

  const ClaimRewardsParams({required this.positionId});

  @override
  List<Object?> get props => [positionId];
}
