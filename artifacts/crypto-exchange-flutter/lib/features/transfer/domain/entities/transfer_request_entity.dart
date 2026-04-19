import 'package:equatable/equatable.dart';

class TransferRequestEntity extends Equatable {
  final String fromType; // FIAT, SPOT, ECO, FUTURES
  final String fromCurrency; // BTC, ETH, USD, etc.
  final double amount;
  final String transferType; // "wallet" or "client"

  // For wallet transfers
  final String? toType; // Target wallet type
  final String? toCurrency; // Target currency

  // For client transfers
  final String? clientId; // Recipient UUID

  const TransferRequestEntity({
    required this.fromType,
    required this.fromCurrency,
    required this.amount,
    required this.transferType,
    this.toType,
    this.toCurrency,
    this.clientId,
  });

  @override
  List<Object?> get props => [
        fromType,
        fromCurrency,
        amount,
        transferType,
        toType,
        toCurrency,
        clientId,
      ];

  TransferRequestEntity copyWith({
    String? fromType,
    String? fromCurrency,
    double? amount,
    String? transferType,
    String? toType,
    String? toCurrency,
    String? clientId,
  }) {
    return TransferRequestEntity(
      fromType: fromType ?? this.fromType,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      amount: amount ?? this.amount,
      transferType: transferType ?? this.transferType,
      toType: toType ?? this.toType,
      toCurrency: toCurrency ?? this.toCurrency,
      clientId: clientId ?? this.clientId,
    );
  }
}
