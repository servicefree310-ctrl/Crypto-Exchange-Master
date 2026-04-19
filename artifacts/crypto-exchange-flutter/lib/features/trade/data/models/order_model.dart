import '../../domain/entities/order_entity.dart';

class OrderModel {
  OrderModel({
    required this.id,
    required this.symbol,
    required this.type,
    required this.side,
    required this.amount,
    required this.price,
    required this.cost,
    required this.status,
    required this.createdAt,
    this.filledQty = 0,
    this.avgPrice = 0,
    this.fee = 0,
    this.tds = 0,
  });

  final String id;
  final String symbol;
  final String type;
  final String side;
  final double amount;
  final double price;
  final double cost;
  final String status;
  final DateTime createdAt;
  final double filledQty;
  final double avgPrice;
  final double fee;
  final double tds;

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _asDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;

      final millis = int.tryParse(value);
      if (millis != null) {
        return DateTime.fromMillisecondsSinceEpoch(millis);
      }
    }
    return DateTime.now();
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final dynamic createdAtRaw =
        json['createdAt'] ?? json['created_at'] ?? json['timestamp'];
    final String symbolValue =
        (json['symbol'] ?? '${json['currency'] ?? ''}/${json['pair'] ?? ''}')
            .toString();

    return OrderModel(
      id: json['id'].toString(),
      symbol: symbolValue,
      type: (json['type'] ?? '').toString(),
      side: (json['side'] ?? '').toString(),
      amount: _asDouble(json['amount']),
      price: _asDouble(json['price']),
      cost: _asDouble(json['cost']),
      status: (json['status'] ?? '').toString(),
      createdAt: _asDateTime(createdAtRaw),
      filledQty: _asDouble(json['filledQty'] ?? json['filled_qty']),
      avgPrice: _asDouble(json['avgPrice'] ?? json['avg_price']),
      fee: _asDouble(json['fee']),
      tds: _asDouble(json['tds']),
    );
  }

  OrderEntity toEntity() {
    return OrderEntity(
      id: id,
      symbol: symbol,
      type: type,
      side: side,
      amount: amount,
      price: price,
      cost: cost,
      status: status,
      createdAt: createdAt,
      filledQty: filledQty,
      avgPrice: avgPrice,
      fee: fee,
      tds: tds,
    );
  }
}
