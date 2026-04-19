import '../../domain/entities/futures_order_entity.dart';

double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

class FuturesOrderModel {
  FuturesOrderModel({
    required this.id,
    required this.symbol,
    required this.type,
    required this.side,
    required this.amount,
    required this.price,
    required this.leverage,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String symbol;
  final String type;
  final String side;
  final double amount;
  final double price;
  final double leverage;
  final String status;
  final DateTime createdAt;

  factory FuturesOrderModel.fromJson(Map<String, dynamic> json) {
    return FuturesOrderModel(
      id: json['id'].toString(),
      symbol: json['symbol'] ?? '',
      type: json['type'] ?? '',
      side: json['side'] ?? '',
      amount: _toDouble(json['amount']),
      price: _toDouble(json['price']),
      leverage: _toDouble(json['leverage']),
      status: json['status'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  FuturesOrderEntity toEntity() => FuturesOrderEntity(
        id: id,
        symbol: symbol,
        type: type,
        side: side,
        amount: amount,
        price: price,
        leverage: leverage,
        status: status,
        createdAt: createdAt,
      );
}
