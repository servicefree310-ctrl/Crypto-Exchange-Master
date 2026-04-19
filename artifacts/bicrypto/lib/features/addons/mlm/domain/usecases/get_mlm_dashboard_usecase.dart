import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/mlm_dashboard_entity.dart';
import '../repositories/mlm_repository.dart';

@injectable
class GetMlmDashboardUseCase
    implements UseCase<MlmDashboardEntity, GetMlmDashboardParams> {
  const GetMlmDashboardUseCase(this._repository);

  final MlmRepository _repository;

  @override
  Future<Either<Failure, MlmDashboardEntity>> call(
      GetMlmDashboardParams params) async {
    // Validate input parameters
    final validation = _validateParams(params);
    if (validation != null) return Left(validation);

    // Execute business logic
    return await _repository.getDashboard(period: params.period);
  }

  ValidationFailure? _validateParams(GetMlmDashboardParams params) {
    // Validate period parameter
    const validPeriods = ['1m', '3m', '6m', '1y'];
    if (!validPeriods.contains(params.period)) {
      return const ValidationFailure(
        'Invalid period. Must be one of: 1m, 3m, 6m, 1y',
      );
    }
    return null;
  }
}

class GetMlmDashboardParams {
  const GetMlmDashboardParams({
    this.period = '6m',
  });

  final String period;
}
