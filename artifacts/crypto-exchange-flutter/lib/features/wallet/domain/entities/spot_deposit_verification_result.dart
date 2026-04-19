import 'package:equatable/equatable.dart';
import 'spot_deposit_transaction_entity.dart';

class SpotDepositVerificationResult extends Equatable {
  const SpotDepositVerificationResult({
    required this.status,
    required this.message,
    this.transaction,
    this.balance,
    this.currency,
    this.chain,
    this.method,
  });

  final int status;
  final String message;
  final SpotDepositTransactionEntity? transaction;
  final double? balance;
  final String? currency;
  final String? chain;
  final String? method;

  @override
  List<Object?> get props => [
        status,
        message,
        transaction,
        balance,
        currency,
        chain,
        method,
      ];

  bool get isSuccess => status >= 200 && status < 300;
  bool get isCompleted => status == 201;
  bool get isError => status >= 400;

  SpotDepositVerificationResult copyWith({
    int? status,
    String? message,
    SpotDepositTransactionEntity? transaction,
    double? balance,
    String? currency,
    String? chain,
    String? method,
  }) {
    return SpotDepositVerificationResult(
      status: status ?? this.status,
      message: message ?? this.message,
      transaction: transaction ?? this.transaction,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      chain: chain ?? this.chain,
      method: method ?? this.method,
    );
  }
}
