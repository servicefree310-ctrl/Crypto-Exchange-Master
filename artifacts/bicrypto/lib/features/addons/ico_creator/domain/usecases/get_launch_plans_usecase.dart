import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/errors/failures.dart';
import '../entities/launch_plan_entity.dart';
import '../repositories/creator_repository.dart';

@injectable
class GetLaunchPlansUseCase {
  const GetLaunchPlansUseCase(this._repository);

  final CreatorRepository _repository;

  Future<Either<Failure, List<LaunchPlanEntity>>> call() {
    return _repository.getLaunchPlans();
  }
}
