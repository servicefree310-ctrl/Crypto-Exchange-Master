import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyTwoFactorLoginUseCase
    implements UseCase<UserEntity, VerifyTwoFactorLoginParams> {
  final AuthRepository repository;

  VerifyTwoFactorLoginUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(
      VerifyTwoFactorLoginParams params) async {
    return await repository.verifyTwoFactorLogin(
      userId: params.userId,
      otp: params.otp,
    );
  }
}

class VerifyTwoFactorLoginParams {
  final String userId;
  final String otp;

  VerifyTwoFactorLoginParams({
    required this.userId,
    required this.otp,
  });
}
