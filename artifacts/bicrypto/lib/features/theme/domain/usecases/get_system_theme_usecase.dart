import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_theme_entity.dart';
import '../repositories/theme_repository.dart';

/// Use case for getting system theme preference
@injectable
class GetSystemThemeUseCase implements UseCase<AppThemeType, NoParams> {
  final ThemeRepository _repository;

  const GetSystemThemeUseCase(this._repository);

  @override
  Future<Either<Failure, AppThemeType>> call(NoParams params) async {
    return await _repository.getSystemTheme();
  }
}
