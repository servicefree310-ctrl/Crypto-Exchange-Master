import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/mlm_repository.dart';

@injectable
class ClaimMlmRewardUseCase
    implements UseCase<Map<String, dynamic>, ClaimMlmRewardParams> {
  const ClaimMlmRewardUseCase(this._repository);

  final MlmRepository _repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      ClaimMlmRewardParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // Execute business logic
    return await _repository.claimReward(params.rewardId);
  }

  ValidationFailure? _validateParams(ClaimMlmRewardParams params) {
    // Validate reward ID
    if (params.rewardId.isEmpty) {
      return const ValidationFailure('Reward ID cannot be empty');
    }

    return null;
  }
}

class ClaimMlmRewardParams {
  const ClaimMlmRewardParams({
    required this.rewardId,
  });

  final String rewardId;
}
