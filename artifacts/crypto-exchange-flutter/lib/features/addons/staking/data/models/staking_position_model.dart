import '../../domain/entities/staking_position_entity.dart';

class StakingPositionModel {
  final String id;
  final String poolId;
  final String status;
  final DateTime createdAt;
  final DateTime? endDate;
  final double amount;
  final double earningsTotal;
  final double earningsUnclaimed;
  final int? timeRemaining;

  StakingPositionModel({
    required this.id,
    required this.poolId,
    required this.status,
    required this.createdAt,
    this.endDate,
    required this.amount,
    required this.earningsTotal,
    required this.earningsUnclaimed,
    this.timeRemaining,
  });

  factory StakingPositionModel.fromJson(Map<String, dynamic> json) {
    final rawEarnings = json['earnings'];
    final earnings = rawEarnings is Map
        ? Map<String, dynamic>.from(rawEarnings)
        : <String, dynamic>{};

    // Handle both string and int IDs from API
    final id = json['id']?.toString() ?? '';
    final poolId = json['poolId']?.toString() ?? '';
    final status = json['status']?.toString() ?? 'UNKNOWN';

    // Parse dates safely
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    DateTime? parseDateNullable(dynamic dateValue) {
      if (dateValue == null) return null;
      if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return StakingPositionModel(
      id: id,
      poolId: poolId,
      status: status,
      createdAt: parseDate(json['createdAt']),
      endDate: parseDateNullable(json['endDate']),
      amount: _parseDouble(json['amount']),
      earningsTotal: _parseDouble(earnings['total']),
      earningsUnclaimed: _parseDouble(earnings['unclaimed']),
      timeRemaining: _parseIntNullable(json['timeRemaining']),
    );
  }

  StakingPositionEntity toEntity() => StakingPositionEntity(
        id: id,
        poolId: poolId,
        status: status,
        createdAt: createdAt,
        endDate: endDate,
        amount: amount,
        earningsTotal: earningsTotal,
        earningsUnclaimed: earningsUnclaimed,
        timeRemaining: timeRemaining,
      );
}

double _parseDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int? _parseIntNullable(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? double.tryParse(value)?.toInt();
  }
  return null;
}
