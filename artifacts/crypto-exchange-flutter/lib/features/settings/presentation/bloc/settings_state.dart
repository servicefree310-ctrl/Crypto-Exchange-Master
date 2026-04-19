import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/settings_entity.dart';

@immutable
abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

class SettingsLoading extends SettingsState {
  final String? message;

  const SettingsLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class SettingsLoaded extends SettingsState {
  final SettingsEntity settings;
  final bool isFromCache;

  const SettingsLoaded({
    required this.settings,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [settings, isFromCache];
}

class SettingsError extends SettingsState {
  final String message;
  final SettingsEntity? cachedSettings;

  const SettingsError({
    required this.message,
    this.cachedSettings,
  });

  @override
  List<Object?> get props => [message, cachedSettings];
}

class SettingsUpdated extends SettingsState {
  final SettingsEntity settings;

  const SettingsUpdated({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class SettingsCacheCleared extends SettingsState {
  const SettingsCacheCleared();
}
