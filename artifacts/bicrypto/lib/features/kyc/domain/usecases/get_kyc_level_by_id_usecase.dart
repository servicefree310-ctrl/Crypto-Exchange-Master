import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kyc_level_entity.dart';
import '../repositories/kyc_repository.dart';

@injectable
class GetKycLevelByIdUseCase implements UseCase<KycLevelEntity, String> {
  final KycRepository repository;

  const GetKycLevelByIdUseCase(this.repository);

  @override
  Future<Either<Failure, KycLevelEntity>> call(String levelId) async {
    return await repository.getKycLevelById(levelId);
  }
}
