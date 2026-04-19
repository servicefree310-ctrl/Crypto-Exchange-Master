import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/entities/settings_params.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/update_settings_usecase.dart';
import 'settings_event.dart';
import 'settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc(
    this._getSettingsUseCase,
    this._updateSettingsUseCase,
  ) : super(const SettingsInitial()) {
    on<SettingsLoadRequested>(_onSettingsLoadRequested);
    on<SettingsUpdateRequested>(_onSettingsUpdateRequested);
    on<SettingsClearCacheRequested>(_onSettingsClearCacheRequested);
    on<SettingsRefreshRequested>(_onSettingsRefreshRequested);
  }

  final GetSettingsUseCase _getSettingsUseCase;
  final UpdateSettingsUseCase _updateSettingsUseCase;

  Future<void> _onSettingsLoadRequested(
    SettingsLoadRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(SettingsLoading(
      message: event.backgroundUpdate
          ? 'Updating settings...'
          : 'Loading settings...',
    ));

    final params = GetSettingsParams(
      forceRefresh: event.forceRefresh,
      backgroundUpdate: event.backgroundUpdate,
    );

    final result = await _getSettingsUseCase(params);

    result.fold(
      (failure) {
        emit(SettingsError(message: failure.message));
      },
      (settings) {
        emit(SettingsLoaded(
          settings: settings,
          isFromCache: !event.forceRefresh,
        ));
      },
    );
  }

  Future<void> _onSettingsUpdateRequested(
    SettingsUpdateRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading(message: 'Updating settings...'));

    final params = UpdateSettingsParams(
      settings: event.settings,
      clearCache: event.clearCache,
    );

    final result = await _updateSettingsUseCase(params);

    result.fold(
      (failure) {
        emit(SettingsError(message: failure.message));
      },
      (settings) {
        emit(SettingsUpdated(settings: settings));
      },
    );
  }

  Future<void> _onSettingsClearCacheRequested(
    SettingsClearCacheRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading(message: 'Clearing cache...'));

    // For now, we'll just reload settings which will clear cache
    final params = GetSettingsParams(forceRefresh: true);
    final result = await _getSettingsUseCase(params);

    result.fold(
      (failure) {
        emit(SettingsError(message: failure.message));
      },
      (settings) {
        emit(SettingsLoaded(settings: settings));
      },
    );
  }

  Future<void> _onSettingsRefreshRequested(
    SettingsRefreshRequested event,
    Emitter<SettingsState> emit,
  ) async {
    // Don't emit loading state for background refresh
    final params = GetSettingsParams(
      forceRefresh: true,
      backgroundUpdate: true,
    );

    final result = await _getSettingsUseCase(params);

    result.fold(
      (failure) {
        // Don't emit error state for background refresh
      },
      (settings) {
        emit(SettingsLoaded(settings: settings));
      },
    );
  }

  // Helper method to get current settings
  SettingsEntity? get currentSettings {
    final state = this.state;
    if (state is SettingsLoaded) {
      return state.settings;
    } else if (state is SettingsUpdated) {
      return state.settings;
    } else if (state is SettingsError) {
      return state.cachedSettings;
    }
    return null;
  }

  // Helper method to check if a feature is available
  bool isFeatureAvailable(String featureKey) {
    final settings = currentSettings;
    return settings?.isFeatureAvailable(featureKey) ?? false;
  }

  // Helper method to check if a feature is coming soon
  bool isFeatureComingSoon(String featureKey) {
    final settings = currentSettings;
    return settings?.comingSoonFeatures.contains(featureKey) ?? false;
  }

  // Helper method to get all available features
  List<String> get availableFeatures {
    final settings = currentSettings;
    return settings?.availableFeatures ?? [];
  }

  // Helper method to get all coming soon features
  List<String> get comingSoonFeatures {
    final settings = currentSettings;
    return settings?.comingSoonFeatures ?? [];
  }
}
