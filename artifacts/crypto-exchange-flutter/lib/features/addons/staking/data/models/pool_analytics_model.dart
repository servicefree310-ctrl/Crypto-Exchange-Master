import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/pool_analytics_entity.dart';

part 'pool_analytics_model.g.dart';

/// Data model for pooling analytics fetched from API
@JsonSerializable(explicitToJson: true)
class PoolAnalyticsModel extends PoolAnalyticsEntity {
  const PoolAnalyticsModel({
    required super.poolId,
    required super.poolName,
    required super.tokenSymbol,
    required super.apr,
    required super.totalStaked,
    required super.totalStakers,
    required super.totalEarnings,
    required super.performanceHistory,
    required super.stakingGrowth,
    required super.withdrawals,
    required super.timeframe,
  });

  factory PoolAnalyticsModel.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{
      'poolId': _asString(json['poolId']),
      'poolName': _asString(json['poolName']),
      'tokenSymbol': _asString(json['tokenSymbol']),
      'apr': _asDouble(json['apr']),
      'totalStaked': _asDouble(json['totalStaked']),
      'totalStakers': _asInt(json['totalStakers']),
      'totalEarnings': _asDouble(json['totalEarnings']),
      'performanceHistory': _asListOfMap(json['performanceHistory']),
      'stakingGrowth': _asListOfMap(json['stakingGrowth']),
      'withdrawals': _asListOfMap(json['withdrawals']),
      'timeframe': _asString(json['timeframe'], fallback: 'month'),
    };

    return _$PoolAnalyticsModelFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$PoolAnalyticsModelToJson(this);
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
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

List<Map<String, dynamic>> _asListOfMap(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];

  return value.map<Map<String, dynamic>>((item) {
    if (item is Map<String, dynamic>) return item;
    if (item is Map) return Map<String, dynamic>.from(item);
    return <String, dynamic>{};
  }).toList();
}
