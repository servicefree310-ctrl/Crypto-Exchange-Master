import '../../domain/entities/futures_position_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class FuturesPositionModel {
  FuturesPositionModel({
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
  final String side;
  final double amount;
  final double entryPrice;
  final double markPrice;
  final double leverage;
  final double unrealisedPnl;
  final double liquidationPrice;
  final DateTime createdAt;

  factory FuturesPositionModel.fromJson(Map<String, dynamic> json) {
    return FuturesPositionModel(
      id: json['id'].toString(),
      symbol: json['symbol'] ?? '',
      side: json['side'] ?? '',
      amount: _toDouble(json['amount']),
      entryPrice: _toDouble(json['entryPrice']),
      markPrice: _toDouble(json['markPrice']),
      leverage: _toDouble(json['leverage']),
      unrealisedPnl: _toDouble(json['unrealisedPnl']),
      liquidationPrice: _toDouble(json['liquidationPrice']),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  FuturesPositionEntity toEntity() => FuturesPositionEntity(
        id: id,
        symbol: symbol,
        side: side,
        amount: amount,
        entryPrice: entryPrice,
        markPrice: markPrice,
        leverage: leverage,
        unrealisedPnl: unrealisedPnl,
        liquidationPrice: liquidationPrice,
        createdAt: createdAt,
      );
}
