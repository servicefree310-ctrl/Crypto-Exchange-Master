import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/mlm_network_entity.dart';
import '../repositories/mlm_repository.dart';

@injectable
class GetMlmNetworkUseCase implements UseCase<MlmNetworkEntity, NoParams> {
  const GetMlmNetworkUseCase(this._repository);

  final MlmRepository _repository;

  @override
  Future<Either<Failure, MlmNetworkEntity>> call(NoParams params) async {
    // Execute business logic
    return await _repository.getNetwork();
  }
}
