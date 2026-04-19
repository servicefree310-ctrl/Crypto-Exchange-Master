import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/mlm_condition_entity.dart';
import '../repositories/mlm_repository.dart';

@injectable
class GetMlmConditionsUseCase
    implements UseCase<List<MlmConditionEntity>, NoParams> {
  const GetMlmConditionsUseCase(this._repository);

  final MlmRepository _repository;

  @override
  Future<Either<Failure, List<MlmConditionEntity>>> call(
      NoParams params) async {
    return await _repository.getConditions();
  }
}
