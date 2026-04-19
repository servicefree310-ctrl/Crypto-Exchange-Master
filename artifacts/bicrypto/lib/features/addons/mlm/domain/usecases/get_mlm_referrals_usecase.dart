import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/mlm_referral_entity.dart';
import '../repositories/mlm_repository.dart';

@injectable
class GetMlmReferralsUseCase
    implements UseCase<List<MlmReferralEntity>, GetMlmReferralsParams> {
  const GetMlmReferralsUseCase(this._repository);

  final MlmRepository _repository;

  @override
  Future<Either<Failure, List<MlmReferralEntity>>> call(
      GetMlmReferralsParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // Execute business logic
    return await _repository.getReferrals(
      page: params.page,
      perPage: params.perPage,
    );
  }

  ValidationFailure? _validateParams(GetMlmReferralsParams params) {
    // Validate page parameter
    if (params.page < 1) {
      return const ValidationFailure('Page must be greater than 0');
    }

    // Validate perPage parameter
    if (params.perPage < 1 || params.perPage > 100) {
      return const ValidationFailure('PerPage must be between 1 and 100');
    }

    return null;
  }
}

class GetMlmReferralsParams {
  const GetMlmReferralsParams({
    this.page = 1,
    this.perPage = 10,
  });

  final int page;
  final int perPage;
}
