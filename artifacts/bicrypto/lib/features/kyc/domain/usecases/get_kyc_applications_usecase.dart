import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kyc_application_entity.dart';
import '../repositories/kyc_repository.dart';

@injectable
class GetKycApplicationsUseCase
    implements UseCase<List<KycApplicationEntity>, NoParams> {
  final KycRepository repository;

  const GetKycApplicationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<KycApplicationEntity>>> call(
      NoParams params) async {
    return await repository.getKycApplications();
  }
}
