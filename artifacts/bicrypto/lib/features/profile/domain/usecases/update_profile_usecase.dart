import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase implements UseCase<void, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      firstName: params.firstName,
      lastName: params.lastName,
      phone: params.phone,
      avatar: params.avatar,
      profile: params.profile,
      settings: params.settings,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? avatar;
  final ProfileInfoEntity? profile;
  final NotificationSettingsEntity? settings;

  const UpdateProfileParams({
    this.firstName,
    this.lastName,
    this.phone,
    this.avatar,
    this.profile,
    this.settings,
  });

  @override
  List<Object?> get props => [firstName, lastName, phone, avatar, profile, settings];
} 