// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ico_token_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IcoTokenTypeModelImpl _$$IcoTokenTypeModelImplFromJson(
        Map<String, dynamic> json) =>
    _$IcoTokenTypeModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$IcoTokenTypeModelImplToJson(
        _$IcoTokenTypeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'isActive': instance.isActive,
    };
