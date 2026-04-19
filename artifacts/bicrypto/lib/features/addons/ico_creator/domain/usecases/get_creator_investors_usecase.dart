import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/creator_investor_entity.dart';
import '../repositories/creator_investor_repository.dart';

@injectable
class GetCreatorInvestorsUseCase
    implements UseCase<List<CreatorInvestorEntity>, GetInvestorsParams> {
  const GetCreatorInvestorsUseCase(this._repository);

  final CreatorInvestorRepository _repository;

  @override
  Future<Either<Failure, List<CreatorInvestorEntity>>> call(
      GetInvestorsParams params) async {
    return await _repository.getInvestors(
      page: params.page,
      limit: params.limit,
      sortField: params.sortField,
      sortDirection: params.sortDirection,
      search: params.search,
    );
  }
}

class GetInvestorsParams extends Equatable {
  const GetInvestorsParams({
    this.page = 1,
    this.limit = 10,
    this.sortField,
    this.sortDirection,
    this.search,
  });

  final int page;
  final int limit;
  final String? sortField;
  final String? sortDirection;
  final String? search;

  @override
  List<Object?> get props => [page, limit, sortField, sortDirection, search];
}
