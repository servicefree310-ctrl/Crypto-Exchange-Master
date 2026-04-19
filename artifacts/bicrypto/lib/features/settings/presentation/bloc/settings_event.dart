import 'package:flutter/foundation.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {
  final bool forceRefresh;
  final bool backgroundUpdate;

  const SettingsLoadRequested({
    this.forceRefresh = false,
    this.backgroundUpdate = false,
  });

  @override
  List<Object?> get props => [forceRefresh, backgroundUpdate];
}

class SettingsUpdateRequested extends SettingsEvent {
  final Map<String, dynamic> settings;
  final bool clearCache;

  const SettingsUpdateRequested({
    required this.settings,
    this.clearCache = false,
  });

  @override
  List<Object?> get props => [settings, clearCache];
}

class SettingsClearCacheRequested extends SettingsEvent {
  const SettingsClearCacheRequested();
}

class SettingsRefreshRequested extends SettingsEvent {
  const SettingsRefreshRequested();
}
