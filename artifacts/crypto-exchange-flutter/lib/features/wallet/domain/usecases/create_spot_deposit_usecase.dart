import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/spot_deposit_transaction_entity.dart';
import '../repositories/spot_deposit_repository.dart';

class CreateSpotDepositParams extends Equatable {
  const CreateSpotDepositParams({
    required this.currency,
    required this.chain,
    required this.transactionHash,
  });

  final String currency;
  final String chain;
  final String transactionHash;

  @override
  List<Object> get props => [currency, chain, transactionHash];
}

@injectable
class CreateSpotDepositUseCase
    implements UseCase<SpotDepositTransactionEntity, CreateSpotDepositParams> {
  const CreateSpotDepositUseCase(this._repository);

  final SpotDepositRepository _repository;

  @override
  Future<Either<Failure, SpotDepositTransactionEntity>> call(
      CreateSpotDepositParams params) {
    return _repository.createSpotDeposit(
      params.currency,
      params.chain,
      params.transactionHash,
    );
  }
}
