import 'package:equatable/equatable.dart';

class AiInvestmentPlanEntity extends Equatable {
  const AiInvestmentPlanEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.minAmount,
    required this.maxAmount,
    required this.profitPercentage,
    required this.invested,
    required this.trending,
    required this.status,
    required this.durations,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String description;
  final String? image;
  final double minAmount;
  final double maxAmount;
  final double profitPercentage;
  final double invested;
  final bool trending;
  final String status; // ACTIVE, INACTIVE
  final List<AiInvestmentDurationEntity> durations;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Convenience getters
  bool get isActive => status == 'ACTIVE';
  String get formattedProfitPercentage =>
      '${profitPercentage.toStringAsFixed(2)}%';
  String get formattedMinAmount => minAmount.toStringAsFixed(2);
  String get formattedMaxAmount => maxAmount.toStringAsFixed(2);
  String get formattedInvested => invested.toStringAsFixed(2);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        image,
        minAmount,
        maxAmount,
        profitPercentage,
        invested,
        trending,
        status,
        durations,
        createdAt,
        updatedAt,
      ];

  AiInvestmentPlanEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? image,
    double? minAmount,
    double? maxAmount,
    double? profitPercentage,
    double? invested,
    bool? trending,
    String? status,
    List<AiInvestmentDurationEntity>? durations,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AiInvestmentPlanEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      image: image ?? this.image,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      profitPercentage: profitPercentage ?? this.profitPercentage,
      invested: invested ?? this.invested,
      trending: trending ?? this.trending,
      status: status ?? this.status,
      durations: durations ?? this.durations,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AiInvestmentDurationEntity extends Equatable {
  const AiInvestmentDurationEntity({
    required this.id,
    required this.duration,
    required this.timeframe,
  });

  final String id;
  final int duration;
  final String timeframe; // HOUR, DAY, WEEK, MONTH

  // Convenience getters
  String get displayText {
    switch (timeframe) {
      case 'HOUR':
        return duration == 1 ? '1 Hour' : '$duration Hours';
      case 'DAY':
        return duration == 1 ? '1 Day' : '$duration Days';
      case 'WEEK':
        return duration == 1 ? '1 Week' : '$duration Weeks';
      case 'MONTH':
        return duration == 1 ? '1 Month' : '$duration Months';
      default:
        return '$duration $timeframe';
    }
  }

  @override
  List<Object?> get props => [id, duration, timeframe];

  AiInvestmentDurationEntity copyWith({
    String? id,
    int? duration,
    String? timeframe,
  }) {
    return AiInvestmentDurationEntity(
      id: id ?? this.id,
      duration: duration ?? this.duration,
      timeframe: timeframe ?? this.timeframe,
    );
  }
}
