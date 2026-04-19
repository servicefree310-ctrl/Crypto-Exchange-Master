import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/staking_pool_entity.dart';

part 'staking_pool_model.freezed.dart';

@freezed
class StakingPoolModel with _$StakingPoolModel {
  const factory StakingPoolModel({
    required String id,
    required String name,
    required String? description,
    required String? icon,
    required String symbol,
    required double apr,
    required double minStake,
    required double? maxStake,
    required int lockPeriod, // in days
    required double availableToStake,
    required double totalStaked,
    required String status,
    required String poolType,
    @Default(false) bool isPromoted,
    @Default(false) bool autoCompound,
    int? maxPositionsPerUser,
    double? earlyWithdrawalPenalty,
    @Default(0) int order,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Analytics data (optional, populated in some endpoints)
    @JsonKey(name: 'tvl') double? totalValueLocked,
    int? totalUsers,
    double? totalRewardsDistributed,
    // User specific data (optional)
    double? userStaked,
    int? userPositionCount,
  }) = _StakingPoolModel;

  factory StakingPoolModel.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    // Backend pool payload does not include `poolType`; use walletType fallback.
    normalized['poolType'] ??= normalized['walletType'] ?? 'SPOT';

    // Backend uses earlyWithdrawalFee; app model expects earlyWithdrawalPenalty.
    normalized['earlyWithdrawalPenalty'] ??= normalized['earlyWithdrawalFee'];

    // Backend sends analytics in nested object on pool list endpoint.
    final analytics = normalized['analytics'];
    if (analytics is Map<String, dynamic>) {
      normalized['totalUsers'] ??= analytics['totalStakers'];
      normalized['userStaked'] ??= analytics['userTotalStaked'];
      normalized['userPositionCount'] ??= analytics['userPositionsCount'];
    }

    // Normalize scalar types to avoid parse failures on string/number variance.
    normalized['id'] = _asString(normalized['id']);
    normalized['name'] =
        _asString(normalized['name'], fallback: 'Unnamed Pool');
    normalized['description'] = _asNullableString(normalized['description']);
    normalized['icon'] = _asNullableString(normalized['icon']);
    normalized['symbol'] = _asString(normalized['symbol'], fallback: 'UNKNOWN');
    normalized['apr'] = _asDouble(normalized['apr']);
    normalized['minStake'] = _asDouble(normalized['minStake']);
    normalized['maxStake'] = _asNullableDouble(normalized['maxStake']);
    normalized['lockPeriod'] = _asInt(normalized['lockPeriod']);
    normalized['availableToStake'] = _asDouble(normalized['availableToStake']);
    normalized['totalStaked'] = _asDouble(normalized['totalStaked']);
    normalized['status'] = _asString(normalized['status'], fallback: 'ACTIVE');
    normalized['poolType'] =
        _asString(normalized['poolType'], fallback: 'SPOT');
    normalized['isPromoted'] = _asBool(normalized['isPromoted']);
    normalized['autoCompound'] = _asBool(normalized['autoCompound']);
    normalized['maxPositionsPerUser'] =
        _asNullableInt(normalized['maxPositionsPerUser']);
    normalized['earlyWithdrawalPenalty'] =
        _asNullableDouble(normalized['earlyWithdrawalPenalty']);
    normalized['order'] = _asInt(normalized['order']);
    normalized['createdAt'] = _asIsoDateTimeString(normalized['createdAt']);
    normalized['updatedAt'] = _asIsoDateTimeString(normalized['updatedAt']);
    normalized['tvl'] = _asNullableDouble(normalized['tvl']) ??
        _asDouble(normalized['totalStaked']);
    normalized['totalUsers'] = _asNullableInt(normalized['totalUsers']);
    normalized['totalRewardsDistributed'] =
        _asNullableDouble(normalized['totalRewardsDistributed']);
    normalized['userStaked'] = _asNullableDouble(normalized['userStaked']);
    normalized['userPositionCount'] =
        _asNullableInt(normalized['userPositionCount']);

    return StakingPoolModel(
      id: normalized['id'] as String,
      name: normalized['name'] as String,
      description: normalized['description'] as String?,
      icon: normalized['icon'] as String?,
      symbol: normalized['symbol'] as String,
      apr: normalized['apr'] as double,
      minStake: normalized['minStake'] as double,
      maxStake: normalized['maxStake'] as double?,
      lockPeriod: normalized['lockPeriod'] as int,
      availableToStake: normalized['availableToStake'] as double,
      totalStaked: normalized['totalStaked'] as double,
      status: normalized['status'] as String,
      poolType: normalized['poolType'] as String,
      isPromoted: normalized['isPromoted'] as bool,
      autoCompound: normalized['autoCompound'] as bool,
      maxPositionsPerUser: normalized['maxPositionsPerUser'] as int?,
      earlyWithdrawalPenalty: normalized['earlyWithdrawalPenalty'] as double?,
      order: normalized['order'] as int,
      createdAt: normalized['createdAt'] != null
          ? DateTime.tryParse(normalized['createdAt'] as String)
          : null,
      updatedAt: normalized['updatedAt'] != null
          ? DateTime.tryParse(normalized['updatedAt'] as String)
          : null,
      totalValueLocked: normalized['tvl'] as double?,
      totalUsers: normalized['totalUsers'] as int?,
      totalRewardsDistributed: normalized['totalRewardsDistributed'] as double?,
      userStaked: normalized['userStaked'] as double?,
      userPositionCount: normalized['userPositionCount'] as int?,
    );
  }
}

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = value.toString().trim();
  return text.isEmpty ? fallback : text;
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

double? _asNullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt() ?? fallback;
  }
  return fallback;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final text = value.trim().toLowerCase();
    if (text == 'true' || text == '1' || text == 'yes') return true;
    if (text == 'false' || text == '0' || text == 'no') return false;
  }
  return fallback;
}

String? _asIsoDateTimeString(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.toIso8601String();
  if (value is String) {
    final parsed = DateTime.tryParse(value);
    return parsed?.toIso8601String();
  }
  return null;
}

extension StakingPoolModelX on StakingPoolModel {
  StakingPoolEntity toEntity() {
    return StakingPoolEntity(
      id: id,
      name: name,
      description: description,
      icon: icon,
      symbol: symbol,
      apr: apr,
      minStake: minStake,
      maxStake: maxStake,
      lockPeriod: lockPeriod,
      availableToStake: availableToStake,
      totalStaked: totalStaked,
      status: status,
      poolType: poolType,
      isPromoted: isPromoted,
      autoCompound: autoCompound,
      maxPositionsPerUser: maxPositionsPerUser,
      earlyWithdrawalPenalty: earlyWithdrawalPenalty,
      order: order,
      tvl: totalValueLocked ?? totalStaked,
      totalUsers: totalUsers,
      totalRewardsDistributed: totalRewardsDistributed,
      userStaked: userStaked,
      userPositionCount: userPositionCount,
    );
  }
}
