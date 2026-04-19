import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

@injectable
class SearchTransactionsUseCase
    implements UseCase<TransactionListEntity, SearchTransactionsParams> {
  const SearchTransactionsUseCase(this._repository);

  final TransactionRepository _repository;

  @override
  Future<Either<Failure, TransactionListEntity>> call(
      SearchTransactionsParams params) async {
    if (params.query.trim().isEmpty) {
      return const Left(ValidationFailure('Search query is required'));
    }

    if (params.page < 1) {
      return const Left(
          ValidationFailure('Page number must be greater than 0'));
    }

    if (params.pageSize < 1 || params.pageSize > 100) {
      return const Left(
          ValidationFailure('Page size must be between 1 and 100'));
    }

    return await _repository.searchTransactions(
      query: params.query.trim(),
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class SearchTransactionsParams extends Equatable {
  final String query;
  final int page;
  final int pageSize;

  const SearchTransactionsParams({
    required this.query,
    this.page = 1,
    this.pageSize = 20,
  });

  @override
  List<Object> get props => [query, page, pageSize];
}
