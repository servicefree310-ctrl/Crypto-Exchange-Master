import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class ToggleTwoFactorUseCase implements UseCase<void, ToggleTwoFactorParams> {
  final ProfileRepository repository;

  ToggleTwoFactorUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleTwoFactorParams params) async {
    return await repository.toggleTwoFactor(params.enabled);
  }
}

class ToggleTwoFactorParams extends Equatable {
  final bool enabled;

  const ToggleTwoFactorParams({required this.enabled});

  @override
  List<Object?> get props => [enabled];
} 