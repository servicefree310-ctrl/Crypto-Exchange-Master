import 'package:equatable/equatable.dart';

class WithdrawRequestEntity extends Equatable {
  final String walletType; // FIAT, SPOT, ECO
  final String currency;
  final double amount;
  final String? methodId;
  final String? toAddress;
  final String? chain;
  final String? memo;
  final Map<String, dynamic>? customFields;

  const WithdrawRequestEntity({
    required this.walletType,
    required this.currency,
    required this.amount,
    this.methodId,
    this.toAddress,
    this.chain,
    this.memo,
    this.customFields,
  });

  @override
  List<Object?> get props => [
        walletType,
        currency,
        amount,
        methodId,
        toAddress,
        chain,
        memo,
        customFields,
      ];

  WithdrawRequestEntity copyWith({
    String? walletType,
    String? currency,
    double? amount,
    String? methodId,
    String? toAddress,
    String? chain,
    String? memo,
    Map<String, dynamic>? customFields,
  }) {
    return WithdrawRequestEntity(
      walletType: walletType ?? this.walletType,
      currency: currency ?? this.currency,
      amount: amount ?? this.amount,
      methodId: methodId ?? this.methodId,
      toAddress: toAddress ?? this.toAddress,
      chain: chain ?? this.chain,
      memo: memo ?? this.memo,
      customFields: customFields ?? this.customFields,
    );
  }
}
