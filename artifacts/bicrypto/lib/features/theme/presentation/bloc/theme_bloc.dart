import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/app_theme_entity.dart';
import '../../domain/usecases/get_saved_theme_usecase.dart';
import '../../domain/usecases/save_theme_usecase.dart';
import '../../domain/usecases/get_system_theme_usecase.dart';
import 'theme_event.dart';
import 'theme_state.dart';
import '../../../../core/errors/failures.dart';

/// BLoC for managing app theme state
@injectable
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final GetSavedThemeUseCase _getSavedThemeUseCase;
  final SaveThemeUseCase _saveThemeUseCase;
  final GetSystemThemeUseCase _getSystemThemeUseCase;

  ThemeBloc(
    this._getSavedThemeUseCase,
    this._saveThemeUseCase,
    this._getSystemThemeUseCase,
  ) : super(const ThemeInitial()) {
    on<ThemeLoadRequested>(_onThemeLoadRequested);
    on<ThemeToggleRequested>(_onThemeToggleRequested);
    on<ThemeChangeRequested>(_onThemeChangeRequested);
    on<ThemeResetToSystemRequested>(_onThemeResetToSystemRequested);
  }

  Future<void> _onThemeLoadRequested(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    emit(const ThemeLoading());

    // 1. Retrieve saved theme
    final savedThemeResult = await _getSavedThemeUseCase(const NoParams());

    // 2. Handle failure early and return
    if (savedThemeResult.isLeft()) {
      final failure = savedThemeResult.fold<Failure>(
          (f) => f, (_) => const UnknownFailure('Unknown error'));
      emit(ThemeError(failure: failure));
      return;
    }

    // 3. Extract the saved theme value (safe because we checked isLeft above)
    final AppThemeType savedTheme =
        savedThemeResult.getOrElse(() => AppThemeType.dark);

    // 4. Retrieve system theme (this can still fail)
    final systemThemeResult = await _getSystemThemeUseCase(const NoParams());

    if (systemThemeResult.isLeft()) {
      // If system theme fails, still emit with saved theme
      emit(ThemeLoaded(currentTheme: savedTheme, systemTheme: null));
    } else {
      final AppThemeType systemTheme =
          systemThemeResult.getOrElse(() => AppThemeType.dark);
      emit(ThemeLoaded(currentTheme: savedTheme, systemTheme: systemTheme));
    }
  }

  Future<void> _onThemeToggleRequested(
    ThemeToggleRequested event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is ThemeLoaded) {
      final currentState = state as ThemeLoaded;
      final newTheme = currentState.currentTheme == AppThemeType.light
          ? AppThemeType.dark
          : AppThemeType.light;

      await _changeTheme(newTheme, emit, currentState.systemTheme);
    }
  }

  Future<void> _onThemeChangeRequested(
    ThemeChangeRequested event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is ThemeLoaded) {
      final currentState = state as ThemeLoaded;
      await _changeTheme(event.theme, emit, currentState.systemTheme);
    } else {
      // If not loaded yet, load first then change
      add(const ThemeLoadRequested());
      await stream
          .firstWhere((state) => state is ThemeLoaded || state is ThemeError);
      if (state is ThemeLoaded) {
        final currentState = state as ThemeLoaded;
        await _changeTheme(event.theme, emit, currentState.systemTheme);
      }
    }
  }

  Future<void> _onThemeResetToSystemRequested(
    ThemeResetToSystemRequested event,
    Emitter<ThemeState> emit,
  ) async {
    if (state is ThemeLoaded) {
      final currentState = state as ThemeLoaded;
      await _changeTheme(AppThemeType.system, emit, currentState.systemTheme);
    }
  }

  Future<void> _changeTheme(
    AppThemeType theme,
    Emitter<ThemeState> emit,
    AppThemeType? systemTheme,
  ) async {
    final result = await _saveThemeUseCase(SaveThemeParams(theme: theme));

    result.fold(
      (failure) => emit(ThemeError(failure: failure)),
      (_) => emit(ThemeLoaded(
        currentTheme: theme,
        systemTheme: systemTheme,
      )),
    );
  }
}
