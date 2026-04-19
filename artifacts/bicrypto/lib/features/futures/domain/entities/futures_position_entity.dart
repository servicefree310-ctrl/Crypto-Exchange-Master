import 'package:equatable/equatable.dart';

class FuturesPositionEntity extends Equatable {
  const FuturesPositionEntity({
    required this.id,
    required this.symbol,
    required this.side,
    required this.amount,
    required this.entryPrice,
    required this.markPrice,
    required this.leverage,
    required this.unrealisedPnl,
    required this.liquidationPrice,
    required this.createdAt,
  });

  final String id;
  final String symbol;
  final String side; // LONG / SHORT
  final double amount;
  final double entryPrice;
  final double markPrice;
  final double leverage;
  final double unrealisedPnl;
  final double liquidationPrice;
  final DateTime createdAt;

  bool get isProfit => unrealisedPnl >= 0;

  @override
  List<Object?> get props => [
        id,
        symbol,
        side,
        amount,
        entryPrice,
        markPrice,
        leverage,
        unrealisedPnl,
        liquidationPrice,
        createdAt
      ];
}
