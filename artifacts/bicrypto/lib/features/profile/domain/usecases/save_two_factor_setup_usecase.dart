import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

@injectable
class SaveTwoFactorSetupUseCase
    implements UseCase<Map<String, dynamic>, SaveTwoFactorSetupParams> {
  final ProfileRepository repository;

  SaveTwoFactorSetupUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      SaveTwoFactorSetupParams params) async {
    return await repository.saveTwoFactorSetup(
      secret: params.secret,
      type: params.type,
    );
  }
}

class SaveTwoFactorSetupParams extends Equatable {
  final String secret;
  final String type;

  const SaveTwoFactorSetupParams({
    required this.secret,
    required this.type,
  });

  @override
  List<Object?> get props => [secret, type];
}
