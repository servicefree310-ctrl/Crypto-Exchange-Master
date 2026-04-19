import 'package:equatable/equatable.dart';
import '../../domain/entities/app_theme_entity.dart';

/// Base theme event
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

/// Load saved theme event
class ThemeLoadRequested extends ThemeEvent {
  const ThemeLoadRequested();
}

/// Toggle between light and dark theme event
class ThemeToggleRequested extends ThemeEvent {
  const ThemeToggleRequested();
}

/// Change to specific theme event
class ThemeChangeRequested extends ThemeEvent {
  final AppThemeType theme;

  const ThemeChangeRequested({required this.theme});

  @override
  List<Object> get props => [theme];
}

/// Reset to system theme event
class ThemeResetToSystemRequested extends ThemeEvent {
  const ThemeResetToSystemRequested();
}
