import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../entities/mlm_landing_entity.dart';
import '../repositories/mlm_repository.dart';

@injectable
class GetMlmLandingUseCase {
  final MlmRepository _repository;
  const GetMlmLandingUseCase(this._repository);

  Future<Either<Failure, MlmLandingEntity>> call() async {
    return await _repository.getLanding();
  }
}
