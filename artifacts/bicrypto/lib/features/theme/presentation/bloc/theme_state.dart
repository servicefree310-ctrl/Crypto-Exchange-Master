import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_theme_entity.dart';

/// Base theme state
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

/// Initial theme state
class ThemeInitial extends ThemeState {
  const ThemeInitial();
}

/// Theme loading state
class ThemeLoading extends ThemeState {
  const ThemeLoading();
}

/// Theme loaded state
class ThemeLoaded extends ThemeState {
  final AppThemeType currentTheme;
  final AppThemeType? systemTheme;

  const ThemeLoaded({
    required this.currentTheme,
    this.systemTheme,
  });

  @override
  List<Object?> get props => [currentTheme, systemTheme];

  ThemeLoaded copyWith({
    AppThemeType? currentTheme,
    AppThemeType? systemTheme,
  }) {
    return ThemeLoaded(
      currentTheme: currentTheme ?? this.currentTheme,
      systemTheme: systemTheme ?? this.systemTheme,
    );
  }
}

/// Theme error state
class ThemeError extends ThemeState {
  final Failure failure;

  const ThemeError({required this.failure});

  @override
  List<Object> get props => [failure];
}
