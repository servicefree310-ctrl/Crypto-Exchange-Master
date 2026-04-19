import 'package:equatable/equatable.dart';

class WithdrawResponseEntity extends Equatable {
  final String message;
  final WithdrawTransactionEntity? transaction;
  final String? currency;
  final String? method;
  final double? balance;

  const WithdrawResponseEntity({
    required this.message,
    this.transaction,
    this.currency,
    this.method,
    this.balance,
  });

  @override
  List<Object?> get props => [
        message,
        transaction,
        currency,
        method,
        balance,
      ];
}

class WithdrawTransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String walletId;
  final String type;
  final double amount;
  final double fee;
  final String status;
  final String? description;
  final Map<String, dynamic>? metadata;
  final String? referenceId;
  final String createdAt;
  final String? updatedAt;

  const WithdrawTransactionEntity({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.fee,
    required this.status,
    this.description,
    this.metadata,
    this.referenceId,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        walletId,
        type,
        amount,
        fee,
        status,
        description,
        metadata,
        referenceId,
        createdAt,
        updatedAt,
      ];
}
