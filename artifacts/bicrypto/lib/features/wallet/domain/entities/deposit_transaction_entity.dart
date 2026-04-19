import 'package:equatable/equatable.dart';

enum DepositTransactionStatus { pending, completed, cancelled, failed }

class DepositTransactionEntity extends Equatable {
  const DepositTransactionEntity({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.status,
    required this.currency,
    required this.method,
    this.fee,
    this.metadata,
    this.description,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String walletId;
  final String type; // DEPOSIT
  final double amount;
  final DepositTransactionStatus status;
  final String currency;
  final String method;
  final double? fee;
  final Map<String, dynamic>? metadata;
  final String? description;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        walletId,
        type,
        amount,
        status,
        currency,
        method,
        fee,
        metadata,
        description,
        createdAt,
      ];

  DepositTransactionEntity copyWith({
    String? id,
    String? userId,
    String? walletId,
    String? type,
    double? amount,
    DepositTransactionStatus? status,
    String? currency,
    String? method,
    double? fee,
    Map<String, dynamic>? metadata,
    String? description,
    DateTime? createdAt,
  }) {
    return DepositTransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      walletId: walletId ?? this.walletId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      method: method ?? this.method,
      fee: fee ?? this.fee,
      metadata: metadata ?? this.metadata,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
