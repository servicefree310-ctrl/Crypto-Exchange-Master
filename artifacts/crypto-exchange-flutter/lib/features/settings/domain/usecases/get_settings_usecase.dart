import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/settings_entity.dart';
import '../entities/settings_params.dart';
import '../repositories/settings_repository.dart';

@injectable
class GetSettingsUseCase implements UseCase<SettingsEntity, GetSettingsParams> {
  const GetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Either<Failure, SettingsEntity>> call(GetSettingsParams params) async {
    return await _repository.getSettings(params);
  }
}
