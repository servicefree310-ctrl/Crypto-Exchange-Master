// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SettingsModelImpl _$$SettingsModelImplFromJson(Map<String, dynamic> json) =>
    _$SettingsModelImpl(
      settings: (json['settings'] as List<dynamic>)
          .map((e) => SettingItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      extensions: (json['extensions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$SettingsModelImplToJson(_$SettingsModelImpl instance) =>
    <String, dynamic>{
      'settings': instance.settings,
      'extensions': instance.extensions,
    };

_$SettingItemModelImpl _$$SettingItemModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SettingItemModelImpl(
      key: json['key'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$$SettingItemModelImplToJson(
        _$SettingItemModelImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'value': instance.value,
    };
