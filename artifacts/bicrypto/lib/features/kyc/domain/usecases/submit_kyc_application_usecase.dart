import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/kyc_application_entity.dart';
import '../repositories/kyc_repository.dart';

@injectable
class SubmitKycApplicationUseCase
    implements UseCase<KycApplicationEntity, SubmitKycApplicationParams> {
  final KycRepository repository;

  const SubmitKycApplicationUseCase(this.repository);

  @override
  Future<Either<Failure, KycApplicationEntity>> call(
      SubmitKycApplicationParams params) async {
    return await repository.submitKycApplication(
      levelId: params.levelId,
      fields: params.fields,
    );
  }
}

class SubmitKycApplicationParams extends Equatable {
  final String levelId;
  final Map<String, dynamic> fields;

  const SubmitKycApplicationParams({
    required this.levelId,
    required this.fields,
  });

  @override
  List<Object?> get props => [levelId, fields];
}
