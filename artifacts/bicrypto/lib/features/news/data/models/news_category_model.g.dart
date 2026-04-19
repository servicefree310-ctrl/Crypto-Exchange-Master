// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsCategoryModelImpl _$$NewsCategoryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NewsCategoryModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      isActive: json['is_active'] as bool,
    );

Map<String, dynamic> _$$NewsCategoryModelImplToJson(
        _$NewsCategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'icon': instance.icon,
      'is_active': instance.isActive,
    };
