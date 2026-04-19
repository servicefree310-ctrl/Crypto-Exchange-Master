import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import '../entities/staking_position_entity.dart';
import '../repositories/staking_repository.dart';

@injectable
class GetUserPositionsUseCase
    implements UseCase<List<StakingPositionEntity>, GetUserPositionsParams> {
  final StakingRepository repository;

  const GetUserPositionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<StakingPositionEntity>>> call(
      GetUserPositionsParams params) {
    return repository.getUserPositions(
      poolId: params.poolId,
      status: params.status,
    );
  }
}

class GetUserPositionsParams extends Equatable {
  final String? poolId;
  final String? status;

  const GetUserPositionsParams({this.poolId, this.status});

  @override
  List<Object?> get props => [poolId, status];
}
