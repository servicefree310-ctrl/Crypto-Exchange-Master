import 'dart:developer' as dev;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class ForgotPasswordUseCase implements UseCase<Unit, ForgotPasswordParams> {
  final AuthRepository repository;

  ForgotPasswordUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ForgotPasswordParams params) async {
    dev.log('🔵 FORGOT_PASSWORD_USECASE: Requesting password reset for: ${params.email}');
    return await repository.requestPasswordReset(email: params.email);
  }
}

class ForgotPasswordParams {
  final String email;

  ForgotPasswordParams({required this.email});
} 