import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
class SettingsModel with _$SettingsModel {
  const factory SettingsModel({
    required List<SettingItemModel> settings,
    required List<String> extensions,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);
}

@freezed
class SettingItemModel with _$SettingItemModel {
  const factory SettingItemModel({
    required String key,
    required String value,
  }) = _SettingItemModel;

  factory SettingItemModel.fromJson(Map<String, dynamic> json) =>
      _$SettingItemModelFromJson(json);
}

extension SettingsModelX on SettingsModel {
  Map<String, dynamic> toSettingsMap() {
    return {
      for (final setting in settings) setting.key: setting.value,
    };
  }
}
