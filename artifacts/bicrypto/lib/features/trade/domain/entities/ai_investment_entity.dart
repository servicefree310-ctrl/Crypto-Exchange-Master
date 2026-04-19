import 'package:equatable/equatable.dart';

class AiInvestmentEntity extends Equatable {
  const AiInvestmentEntity({
    required this.id,
    required this.userId,
    required this.planId,
    required this.planTitle,
    required this.durationId,
    required this.symbol,
    required this.amount,
    required this.profit,
    required this.result,
    required this.status,
    required this.type,
    required this.createdAt,
    this.endedAt,
    this.profitPercentage,
    this.durationText,
  });

  final String id;
  final String userId;
  final String planId;
  final String planTitle;
  final String durationId;
  final String symbol;
  final double amount;
  final double profit;
  final String result; // WIN, LOSS, DRAW
  final String status; // ACTIVE, COMPLETED, CANCELLED, REJECTED
  final String type;
  final DateTime createdAt;
  final DateTime? endedAt;
  final double? profitPercentage;
  final String? durationText;

  // Convenience getters
  bool get isActive => status == 'ACTIVE';
  bool get isCompleted => status == 'COMPLETED';
  bool get isCancelled => status == 'CANCELLED';
  bool get isRejected => status == 'REJECTED';

  bool get isWin => result == 'WIN';
  bool get isLoss => result == 'LOSS';
  bool get isDraw => result == 'DRAW';

  double get totalReturn => amount + profit;
  String get formattedAmount => amount.toStringAsFixed(2);
  String get formattedProfit => profit.toStringAsFixed(2);
  String get formattedTotalReturn => totalReturn.toStringAsFixed(2);
  String get formattedProfitPercentage => profitPercentage != null
      ? '${profitPercentage!.toStringAsFixed(2)}%'
      : '0.00%';

  String get statusColor {
    switch (status) {
      case 'ACTIVE':
        return '#FFB800'; // Orange/Yellow for active
      case 'COMPLETED':
        return isWin
            ? '#00C896'
            : isLoss
                ? '#FF6B6B'
                : '#8E8E93'; // Green for win, red for loss, gray for draw
      case 'CANCELLED':
        return '#8E8E93'; // Gray
      case 'REJECTED':
        return '#FF6B6B'; // Red
      default:
        return '#8E8E93'; // Gray
    }
  }

  String get resultColor {
    switch (result) {
      case 'WIN':
        return '#00C896'; // Green
      case 'LOSS':
        return '#FF6B6B'; // Red
      case 'DRAW':
        return '#8E8E93'; // Gray
      default:
        return '#8E8E93'; // Gray
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        planId,
        planTitle,
        durationId,
        symbol,
        amount,
        profit,
        result,
        status,
        type,
        createdAt,
        endedAt,
        profitPercentage,
        durationText,
      ];

  AiInvestmentEntity copyWith({
    String? id,
    String? userId,
    String? planId,
    String? planTitle,
    String? durationId,
    String? symbol,
    double? amount,
    double? profit,
    String? result,
    String? status,
    String? type,
    DateTime? createdAt,
    DateTime? endedAt,
    double? profitPercentage,
    String? durationText,
  }) {
    return AiInvestmentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      planId: planId ?? this.planId,
      planTitle: planTitle ?? this.planTitle,
      durationId: durationId ?? this.durationId,
      symbol: symbol ?? this.symbol,
      amount: amount ?? this.amount,
      profit: profit ?? this.profit,
      result: result ?? this.result,
      status: status ?? this.status,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      profitPercentage: profitPercentage ?? this.profitPercentage,
      durationText: durationText ?? this.durationText,
    );
  }
}
