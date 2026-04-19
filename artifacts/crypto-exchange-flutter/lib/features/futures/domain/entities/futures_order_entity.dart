import 'package:equatable/equatable.dart';

class FuturesOrderEntity extends Equatable {
  const FuturesOrderEntity({
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
  final String symbol; // BTC/USDT
  final String type; // limit, market
  final String side; // BUY / SELL
  final double amount;
  final double price;
  final double leverage;
  final String status; // OPEN / CLOSED / CANCELLED etc.
  final DateTime createdAt;

  @override
  List<Object?> get props =>
      [id, symbol, type, side, amount, price, leverage, status, createdAt];
}
