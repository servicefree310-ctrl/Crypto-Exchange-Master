import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

@injectable
class GenerateTwoFactorSecretUseCase
    implements UseCase<Map<String, dynamic>, GenerateTwoFactorSecretParams> {
  final ProfileRepository repository;

  GenerateTwoFactorSecretUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
      GenerateTwoFactorSecretParams params) async {
    return await repository.generateTwoFactorSecret(
      type: params.type,
      phoneNumber: params.phoneNumber,
    );
  }
}

class GenerateTwoFactorSecretParams extends Equatable {
  final String type;
  final String? phoneNumber;

  const GenerateTwoFactorSecretParams({
    required this.type,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [type, phoneNumber];
}
