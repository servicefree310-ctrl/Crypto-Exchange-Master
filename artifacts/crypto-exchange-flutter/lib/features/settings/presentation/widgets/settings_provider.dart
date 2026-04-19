import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection/injection.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsProvider extends StatefulWidget {
  final Widget child;

  const SettingsProvider({
    super.key,
    required this.child,
  });

  @override
  State<SettingsProvider> createState() => _SettingsProviderState();
}

class _SettingsProviderState extends State<SettingsProvider> {
  late SettingsBloc _settingsBloc;
  Timer? _backgroundRefreshTimer;

  @override
  void initState() {
    super.initState();
    _settingsBloc = getIt<SettingsBloc>();

    // Load fresh settings from API on app startup (force refresh)
    _settingsBloc.add(const SettingsLoadRequested(forceRefresh: true));

    // Print current cache status
    _printCacheStatus();

    // Start background refresh timer (every 5 minutes)
    _startBackgroundRefresh();
  }

  void _printCacheStatus() async {
    final repository = getIt<SettingsRepository>();
    final isCached = await repository.isSettingsCached();
    final timestamp = await repository.getCachedTimestamp();

    dev.log('=== SETTINGS CACHE STATUS ===');
    dev.log('Is cached: $isCached');
    dev.log('Cache timestamp: $timestamp');
    if (timestamp != null) {
      final age = DateTime.now().difference(timestamp);
      dev.log(
          'Cache age: ${age.inMinutes} minutes ${age.inSeconds % 60} seconds');
    }
    dev.log('=== END CACHE STATUS ===');
  }

  void _startBackgroundRefresh() {
    _backgroundRefreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) {
        // Background refresh - don't show loading state
        _settingsBloc.add(const SettingsRefreshRequested());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _settingsBloc,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _backgroundRefreshTimer?.cancel();
    super.dispose();
  }
}

/// Extension to easily access settings from any widget
extension SettingsExtension on BuildContext {
  SettingsBloc get settingsBloc => BlocProvider.of<SettingsBloc>(this);

  /// Get current settings state
  SettingsState get settingsState => settingsBloc.state;

  /// Check if a feature is available
  bool isFeatureAvailable(String featureKey) {
    return settingsBloc.isFeatureAvailable(featureKey);
  }

  /// Check if a feature is coming soon
  bool isFeatureComingSoon(String featureKey) {
    return settingsBloc.isFeatureComingSoon(featureKey);
  }

  /// Get all available features
  List<String> get availableFeatures => settingsBloc.availableFeatures;

  /// Get all coming soon features
  List<String> get comingSoonFeatures => settingsBloc.comingSoonFeatures;

  /// Refresh settings
  void refreshSettings() {
    settingsBloc.add(const SettingsRefreshRequested());
  }
}
