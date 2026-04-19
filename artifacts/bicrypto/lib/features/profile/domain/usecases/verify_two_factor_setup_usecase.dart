import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

@injectable
class VerifyTwoFactorSetupUseCase
    implements UseCase<void, VerifyTwoFactorSetupParams> {
  final ProfileRepository repository;

  VerifyTwoFactorSetupUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyTwoFactorSetupParams params) async {
    return await repository.verifyTwoFactorSetup(
      secret: params.secret,
      code: params.code,
      type: params.type,
    );
  }
}

class VerifyTwoFactorSetupParams extends Equatable {
  final String secret;
  final String code;
  final String type;

  const VerifyTwoFactorSetupParams({
    required this.secret,
    required this.code,
    required this.type,
  });

  @override
  List<Object?> get props => [secret, code, type];
}
