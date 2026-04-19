// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SupportMessageModelImpl _$$SupportMessageModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SupportMessageModelImpl(
      id: json['id'] as String?,
      type: json['type'] as String,
      text: json['text'] as String,
      time: json['time'] as String,
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$SupportMessageModelImplToJson(
        _$SupportMessageModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'text': instance.text,
      'time': instance.time,
      'userId': instance.userId,
    };
