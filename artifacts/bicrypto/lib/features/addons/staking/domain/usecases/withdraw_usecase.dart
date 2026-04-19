import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import '../entities/staking_position_entity.dart';
import '../repositories/staking_repository.dart';

@injectable
class WithdrawUseCase
    implements UseCase<StakingPositionEntity, WithdrawParams> {
  final StakingRepository repository;

  const WithdrawUseCase(this.repository);

  @override
  Future<Either<Failure, StakingPositionEntity>> call(WithdrawParams params) {
    return repository.withdraw(params.positionId);
  }
}

class WithdrawParams extends Equatable {
  final String positionId;

  const WithdrawParams({required this.positionId});

  @override
  List<Object?> get props => [positionId];
}
