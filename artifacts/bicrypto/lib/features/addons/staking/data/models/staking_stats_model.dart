import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/staking_stats_entity.dart';

part 'staking_stats_model.g.dart';

/// Data model for staking statistics coming from API
@JsonSerializable()
class StakingStatsModel extends StakingStatsEntity {
  const StakingStatsModel({
    required super.totalStaked,
    required super.activeUsers,
    required super.avgApr,
    required super.totalRewards,
  });

  factory StakingStatsModel.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{
      'totalStaked': _asDouble(json['totalStaked']),
      'activeUsers': _asInt(json['activeUsers']),
      'avgApr': _asDouble(json['avgApr']),
      'totalRewards': _asDouble(json['totalRewards']),
    };

    return _$StakingStatsModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$StakingStatsModelToJson(this);
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
  }
  return fallback;
}
