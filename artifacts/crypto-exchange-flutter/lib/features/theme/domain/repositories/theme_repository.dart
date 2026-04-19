import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/app_theme_entity.dart';

/// Repository interface for theme operations
abstract class ThemeRepository {
  /// Get saved theme from local storage
  Future<Either<Failure, AppThemeType>> getSavedTheme();

  /// Save theme to local storage
  Future<Either<Failure, void>> saveTheme(AppThemeType theme);

  /// Get default theme (system preference)
  Future<Either<Failure, AppThemeType>> getSystemTheme();
}
