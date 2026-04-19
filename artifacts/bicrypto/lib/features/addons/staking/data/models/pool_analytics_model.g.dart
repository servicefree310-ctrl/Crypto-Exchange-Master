// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pool_analytics_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PoolAnalyticsModel _$PoolAnalyticsModelFromJson(Map<String, dynamic> json) =>
    PoolAnalyticsModel(
      poolId: json['poolId'] as String,
      poolName: json['poolName'] as String,
      tokenSymbol: json['tokenSymbol'] as String,
      apr: (json['apr'] as num).toDouble(),
      totalStaked: (json['totalStaked'] as num).toDouble(),
      totalStakers: (json['totalStakers'] as num).toInt(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      performanceHistory: (json['performanceHistory'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      stakingGrowth: (json['stakingGrowth'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      withdrawals: (json['withdrawals'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      timeframe: json['timeframe'] as String,
    );

Map<String, dynamic> _$PoolAnalyticsModelToJson(PoolAnalyticsModel instance) =>
    <String, dynamic>{
      'poolId': instance.poolId,
      'poolName': instance.poolName,
      'tokenSymbol': instance.tokenSymbol,
      'apr': instance.apr,
      'totalStaked': instance.totalStaked,
      'totalStakers': instance.totalStakers,
      'totalEarnings': instance.totalEarnings,
      'performanceHistory': instance.performanceHistory,
      'stakingGrowth': instance.stakingGrowth,
      'withdrawals': instance.withdrawals,
      'timeframe': instance.timeframe,
    };
