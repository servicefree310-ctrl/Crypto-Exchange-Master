import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

@injectable
class GetTransactionsUseCase
    implements UseCase<TransactionListEntity, GetTransactionsParams> {
  const GetTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, TransactionListEntity>> call(
      GetTransactionsParams params) async {
    if (params.page < 1) {
      return const Left(
          ValidationFailure('Page number must be greater than 0'));
    }

    if (params.pageSize < 1 || params.pageSize > 100) {
      return const Left(
          ValidationFailure('Page size must be between 1 and 100'));
    }

    return await _repository.getTransactions(
      filter: params.filter,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetTransactionsParams extends Equatable {
  final TransactionFilterEntity? filter;
  final int page;
  final int pageSize;

  const GetTransactionsParams({
    this.filter,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object?> get props => [filter, page, pageSize];
}
