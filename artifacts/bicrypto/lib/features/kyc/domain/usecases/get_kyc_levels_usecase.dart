import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kyc_level_entity.dart';
import '../repositories/kyc_repository.dart';

@injectable
class GetKycLevelsUseCase implements UseCase<List<KycLevelEntity>, NoParams> {
  final KycRepository repository;

  const GetKycLevelsUseCase(this.repository);

  @override
  Future<Either<Failure, List<KycLevelEntity>>> call(NoParams params) async {
    return await repository.getKycLevels();
  }
}
