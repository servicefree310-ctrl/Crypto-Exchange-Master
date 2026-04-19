import 'package:equatable/equatable.dart';

class GetSettingsParams extends Equatable {
  final bool forceRefresh;
  final bool backgroundUpdate;

  const GetSettingsParams({
    this.forceRefresh = false,
    this.backgroundUpdate = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'forceRefresh': forceRefresh,
      'backgroundUpdate': backgroundUpdate,
    };
  }

  @override
  List<Object?> get props => [forceRefresh, backgroundUpdate];
}

class UpdateSettingsParams extends Equatable {
  final Map<String, dynamic> settings;
  final bool clearCache;

  const UpdateSettingsParams({
    required this.settings,
    this.clearCache = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'settings': settings,
      'clearCache': clearCache,
    };
  }

  @override
  List<Object?> get props => [settings, clearCache];
}
