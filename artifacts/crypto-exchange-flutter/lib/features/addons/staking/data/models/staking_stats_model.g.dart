// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staking_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StakingStatsModel _$StakingStatsModelFromJson(Map<String, dynamic> json) =>
    StakingStatsModel(
      totalStaked: (json['totalStaked'] as num).toDouble(),
      activeUsers: (json['activeUsers'] as num).toInt(),
      avgApr: (json['avgApr'] as num).toDouble(),
      totalRewards: (json['totalRewards'] as num).toDouble(),
    );

Map<String, dynamic> _$StakingStatsModelToJson(StakingStatsModel instance) =>
    <String, dynamic>{
      'totalStaked': instance.totalStaked,
      'activeUsers': instance.activeUsers,
      'avgApr': instance.avgApr,
      'totalRewards': instance.totalRewards,
    };
