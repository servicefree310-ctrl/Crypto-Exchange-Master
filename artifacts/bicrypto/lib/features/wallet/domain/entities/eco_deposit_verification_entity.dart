import 'package:equatable/equatable.dart';

class EcoDepositVerificationEntity extends Equatable {
  final String status;
  final String message;
  final EcoTransactionEntity? transaction;
  final EcoWalletEntity? wallet;
  final Map<String, dynamic>? trx;
  final double? balance;
  final String? currency;
  final String? chain;
  final String? method;

  const EcoDepositVerificationEntity({
    required this.status,
    required this.message,
    this.transaction,
    this.wallet,
    this.trx,
    this.balance,
    this.currency,
    this.chain,
    this.method,
  });

  bool get isSuccessful => status == '200' || status == 'COMPLETED';
  bool get isError => !isSuccessful;

  String get transactionHash => trx?['hash'] ?? transaction?.referenceId ?? '';
  String get fromAddress => trx?['from'] ?? '';
  String get toAddress => trx?['to'] ?? '';
  double get depositAmount =>
      trx?['amount']?.toDouble() ?? transaction?.amount ?? 0.0;

  @override
  List<Object?> get props => [
        status,
        message,
        transaction,
        wallet,
        trx,
        balance,
        currency,
        chain,
        method,
      ];

  EcoDepositVerificationEntity copyWith({
    String? status,
    String? message,
    EcoTransactionEntity? transaction,
    EcoWalletEntity? wallet,
    Map<String, dynamic>? trx,
    double? balance,
    String? currency,
    String? chain,
    String? method,
  }) {
    return EcoDepositVerificationEntity(
      status: status ?? this.status,
      message: message ?? this.message,
      transaction: transaction ?? this.transaction,
      wallet: wallet ?? this.wallet,
      trx: trx ?? this.trx,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      chain: chain ?? this.chain,
      method: method ?? this.method,
    );
  }
}

class EcoTransactionEntity extends Equatable {
  final String id;
  final double amount;
  final double fee;
  final String status;
  final String referenceId;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const EcoTransactionEntity({
    required this.id,
    required this.amount,
    required this.fee,
    required this.status,
    required this.referenceId,
    this.description,
    this.metadata,
    required this.createdAt,
  });

  bool get isCompleted => status == 'COMPLETED';
  bool get isPending => status == 'PENDING';

  @override
  List<Object?> get props => [
        id,
        amount,
        fee,
        status,
        referenceId,
        description,
        metadata,
        createdAt,
      ];
}

class EcoWalletEntity extends Equatable {
  final String id;
  final String currency;
  final double balance;
  final String type;
  final Map<String, dynamic>? address;

  const EcoWalletEntity({
    required this.id,
    required this.currency,
    required this.balance,
    required this.type,
    this.address,
  });

  @override
  List<Object?> get props => [id, currency, balance, type, address];
}
