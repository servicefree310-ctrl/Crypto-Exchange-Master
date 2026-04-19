// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_investment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AiInvestmentModelImpl _$$AiInvestmentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AiInvestmentModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      planId: json['planId'] as String,
      durationId: json['durationId'] as String,
      symbol: json['symbol'] as String,
      amount: (json['amount'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      result: json['result'] as String,
      status: json['status'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      profitPercentage: (json['profitPercentage'] as num?)?.toDouble(),
      durationText: json['durationText'] as String?,
      plan: json['plan'] as Map<String, dynamic>?,
      duration: json['duration'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AiInvestmentModelImplToJson(
        _$AiInvestmentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'planId': instance.planId,
      'durationId': instance.durationId,
      'symbol': instance.symbol,
      'amount': instance.amount,
      'profit': instance.profit,
      'result': instance.result,
      'status': instance.status,
      'type': instance.type,
      'createdAt': instance.createdAt.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'profitPercentage': instance.profitPercentage,
      'durationText': instance.durationText,
      'plan': instance.plan,
      'duration': instance.duration,
    };
