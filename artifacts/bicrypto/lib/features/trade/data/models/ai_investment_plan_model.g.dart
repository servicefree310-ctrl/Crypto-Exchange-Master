// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_investment_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiInvestmentPlanModelImpl _$$AiInvestmentPlanModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AiInvestmentPlanModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      image: json['image'] as String?,
      minAmount: (json['minAmount'] as num).toDouble(),
      maxAmount: (json['maxAmount'] as num).toDouble(),
      profitPercentage: (json['profitPercentage'] as num).toDouble(),
      invested: (json['invested'] as num).toDouble(),
      trending: json['trending'] as bool?,
      status: json['status'] as bool?,
      durations: (json['durations'] as List<dynamic>?)
          ?.map((e) =>
              AiInvestmentDurationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$AiInvestmentPlanModelImplToJson(
        _$AiInvestmentPlanModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'image': instance.image,
      'minAmount': instance.minAmount,
      'maxAmount': instance.maxAmount,
      'profitPercentage': instance.profitPercentage,
      'invested': instance.invested,
      'trending': instance.trending,
      'status': instance.status,
      'durations': instance.durations,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

_$AiInvestmentDurationModelImpl _$$AiInvestmentDurationModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AiInvestmentDurationModelImpl(
      id: json['id'] as String,
      duration: (json['duration'] as num).toInt(),
      timeframe: json['timeframe'] as String,
    );

Map<String, dynamic> _$$AiInvestmentDurationModelImplToJson(
        _$AiInvestmentDurationModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'duration': instance.duration,
      'timeframe': instance.timeframe,
    };
