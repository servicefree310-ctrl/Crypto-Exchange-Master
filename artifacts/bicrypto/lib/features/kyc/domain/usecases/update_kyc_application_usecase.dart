import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kyc_application_entity.dart';
import '../repositories/kyc_repository.dart';

@injectable
class UpdateKycApplicationUseCase
    implements UseCase<KycApplicationEntity, UpdateKycApplicationParams> {
  final KycRepository repository;

  const UpdateKycApplicationUseCase(this.repository);

  @override
  Future<Either<Failure, KycApplicationEntity>> call(
      UpdateKycApplicationParams params) async {
    return await repository.updateKycApplication(
      applicationId: params.applicationId,
      fields: params.fields,
    );
  }
}

class UpdateKycApplicationParams extends Equatable {
  final String applicationId;
  final Map<String, dynamic> fields;

  const UpdateKycApplicationParams({
    required this.applicationId,
    required this.fields,
  });

  @override
  List<Object?> get props => [applicationId, fields];
}
