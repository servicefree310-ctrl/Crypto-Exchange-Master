// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_recommendation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$P2PRecommendationModelImpl _$$P2PRecommendationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$P2PRecommendationModelImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      category: json['category'] as String,
      data: json['data'] as Map<String, dynamic>,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$P2PRecommendationModelImplToJson(
        _$P2PRecommendationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'category': instance.category,
      'data': instance.data,
      'isRead': instance.isRead,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };
