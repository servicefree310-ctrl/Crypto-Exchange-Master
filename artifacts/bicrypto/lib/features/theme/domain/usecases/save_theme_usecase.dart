import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_theme_entity.dart';
import '../repositories/theme_repository.dart';

/// Parameters for saving theme
class SaveThemeParams {
  final AppThemeType theme;

  const SaveThemeParams({required this.theme});
}

/// Use case for saving theme to storage
@injectable
class SaveThemeUseCase implements UseCase<void, SaveThemeParams> {
  final ThemeRepository _repository;

  const SaveThemeUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(SaveThemeParams params) async {
    return await _repository.saveTheme(params.theme);
  }
}
