import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/errors/failures.dart';
import 'package:mobile/core/usecases/usecase.dart';
import '../entities/staking_pool_entity.dart';
import '../repositories/staking_repository.dart';

@injectable
class GetStakingPoolsUseCase
    implements UseCase<List<StakingPoolEntity>, GetStakingPoolsParams> {
  final StakingRepository repository;

  const GetStakingPoolsUseCase(this.repository);

  @override
  Future<Either<Failure, List<StakingPoolEntity>>> call(
      GetStakingPoolsParams params) {
    return repository.getPools(
      status: params.status,
      minApr: params.minApr,
      maxApr: params.maxApr,
      token: params.token,
    );
  }
}

class GetStakingPoolsParams extends Equatable {
  final String? status;
  final double? minApr;
  final double? maxApr;
  final String? token;

  const GetStakingPoolsParams({
    this.status,
    this.minApr,
    this.maxApr,
    this.token,
  });

  @override
  List<Object?> get props => [status, minApr, maxApr, token];
}
