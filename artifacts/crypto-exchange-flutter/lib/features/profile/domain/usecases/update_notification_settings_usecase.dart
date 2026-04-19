import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/profile_entity.dart';
import '../repositories/profile_repository.dart';

@injectable
class UpdateNotificationSettingsUseCase
    implements UseCase<void, NotificationSettingsEntity> {
  final ProfileRepository _repository;

  const UpdateNotificationSettingsUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NotificationSettingsEntity params) async {
    return await _repository.updateProfile(settings: params);
  }
}
