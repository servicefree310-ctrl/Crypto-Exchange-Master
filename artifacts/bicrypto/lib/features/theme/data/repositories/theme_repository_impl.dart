import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/app_theme_entity.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_datasource.dart';

/// Implementation of theme repository
@Injectable(as: ThemeRepository)
class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource _localDataSource;

  const ThemeRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, AppThemeType>> getSavedTheme() async {
    try {
      final theme = await _localDataSource.getSavedTheme();
      return Right(theme);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(
          CacheFailure('Unknown error occurred while getting saved theme'));
    }
  }

  @override
  Future<Either<Failure, void>> saveTheme(AppThemeType theme) async {
    try {
      await _localDataSource.saveTheme(theme);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Unknown error occurred while saving theme'));
    }
  }

  @override
  Future<Either<Failure, AppThemeType>> getSystemTheme() async {
    try {
      final theme = await _localDataSource.getSystemTheme();
      return Right(theme);
    } catch (e) {
      return Left(CacheFailure('Failed to get system theme'));
    }
  }
}
