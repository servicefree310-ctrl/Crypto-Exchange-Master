import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import '../entities/staking_position_entity.dart';
import '../repositories/staking_repository.dart';

@injectable
class StakeUseCase implements UseCase<StakingPositionEntity, StakeParams> {
  final StakingRepository repository;

  const StakeUseCase(this.repository);

  @override
  Future<Either<Failure, StakingPositionEntity>> call(StakeParams params) {
    return repository.stake(
      poolId: params.poolId,
      amount: params.amount,
    );
  }
}

class StakeParams extends Equatable {
  final String poolId;
  final double amount;

  const StakeParams({required this.poolId, required this.amount});

  @override
  List<Object?> get props => [poolId, amount];
}
