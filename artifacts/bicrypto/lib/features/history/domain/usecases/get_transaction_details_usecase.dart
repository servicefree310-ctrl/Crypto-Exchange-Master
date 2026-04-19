import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

@injectable
class GetTransactionDetailsUseCase
    implements UseCase<TransactionEntity, GetTransactionDetailsParams> {
  const GetTransactionDetailsUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, TransactionEntity>> call(
      GetTransactionDetailsParams params) async {
    if (params.transactionId.isEmpty) {
      return const Left(ValidationFailure('Transaction ID is required'));
    }

    return await _repository.getTransactionById(params.transactionId);
  }
}

class GetTransactionDetailsParams extends Equatable {
  final String transactionId;

  const GetTransactionDetailsParams({
    required this.transactionId,
  });

  @override
  List<Object> get props => [transactionId];
}
