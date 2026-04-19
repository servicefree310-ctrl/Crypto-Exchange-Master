import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_theme_entity.dart';
import '../repositories/theme_repository.dart';

/// Use case for getting saved theme from storage
@injectable
class GetSavedThemeUseCase implements UseCase<AppThemeType, NoParams> {
  final ThemeRepository _repository;

  const GetSavedThemeUseCase(this._repository);

  @override
  Future<Either<Failure, AppThemeType>> call(NoParams params) async {
    return await _repository.getSavedTheme();
  }
}
