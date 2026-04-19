import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/mlm_reward_entity.dart';
import '../repositories/mlm_repository.dart';

@injectable
class GetMlmRewardsUseCase
    implements UseCase<List<MlmRewardEntity>, GetMlmRewardsParams> {
  const GetMlmRewardsUseCase(this._repository);

  final MlmRepository _repository;

  @override
  Future<Either<Failure, List<MlmRewardEntity>>> call(
      GetMlmRewardsParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // Execute business logic
    return await _repository.getRewards(
      page: params.page,
      perPage: params.perPage,
      sortField: params.sortField,
      sortOrder: params.sortOrder,
    );
  }

  ValidationFailure? _validateParams(GetMlmRewardsParams params) {
    // Validate page parameter
    if (params.page < 1) {
      return const ValidationFailure('Page must be greater than 0');
    }

    // Validate perPage parameter
    if (params.perPage < 1 || params.perPage > 100) {
      return const ValidationFailure('PerPage must be between 1 and 100');
    }

    // Validate sortOrder parameter if provided
    if (params.sortOrder != null &&
        !['asc', 'desc'].contains(params.sortOrder!.toLowerCase())) {
      return const ValidationFailure(
          'SortOrder must be either "asc" or "desc"');
    }

    return null;
  }
}

class GetMlmRewardsParams {
  const GetMlmRewardsParams({
    this.page = 1,
    this.perPage = 10,
    this.sortField,
    this.sortOrder,
  });

  final int page;
  final int perPage;
  final String? sortField;
  final String? sortOrder;
}
