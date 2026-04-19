import 'package:equatable/equatable.dart';

class TransferResponseEntity extends Equatable {
  final String message;
  final TransferTransactionEntity fromTransfer;
  final TransferTransactionEntity toTransfer;
  final String fromType;
  final String toType;
  final String fromCurrency;
  final String toCurrency;

  const TransferResponseEntity({
    required this.message,
    required this.fromTransfer,
    required this.toTransfer,
    required this.fromType,
    required this.toType,
    required this.fromCurrency,
    required this.toCurrency,
  });

  @override
  List<Object?> get props => [
        message,
        fromTransfer,
        toTransfer,
        fromType,
        toType,
        fromCurrency,
        toCurrency,
      ];
}

class TransferTransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String walletId;
  final String type;
  final double amount;
  final double fee;
  final String status;
  final String description;
  final String? metadata;
  final String createdAt;
  final String updatedAt;

  const TransferTransactionEntity({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.fee,
    required this.status,
    required this.description,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
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
        createdAt,
        updatedAt,
      ];
}
