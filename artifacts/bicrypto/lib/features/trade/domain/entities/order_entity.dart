/// Domain entity representing an exchange order.
/// Only the fields required by the mobile app right now are included.
library;
import 'package:equatable/equatable.dart';

class OrderEntity extends Equatable {
  const OrderEntity({
    required this.id,
    required this.symbol,
    required this.type,
    required this.side,
    required this.amount,
    required this.price,
    required this.cost,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String symbol; // e.g. BTC/USDT
  final String type; // limit / market / stop
  final String side; // BUY / SELL
  final double amount;
  final double price;
  final double cost;
  final String status; // open / closed / etc.
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, symbol, type, side, amount, price, cost, status, createdAt];
}
