import 'package:equatable/equatable.dart';

class SpotDepositTransactionEntity extends Equatable {
  const SpotDepositTransactionEntity({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.status,
    required this.currency,
    required this.chain,
    required this.referenceId,
    this.metadata,
    this.description,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String walletId;
  final String type;
  final double amount;
  final String status;
  final String currency;
  final String chain;
  final String referenceId;
  final Map<String, dynamic>? metadata;
  final String? description;
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        userId,
        walletId,
        type,
        amount,
        status,
        currency,
        chain,
        referenceId,
        metadata,
        description,
        createdAt,
      ];

  SpotDepositTransactionEntity copyWith({
    String? id,
    String? userId,
    String? walletId,
    String? type,
    double? amount,
    String? status,
    String? currency,
    String? chain,
    String? referenceId,
    Map<String, dynamic>? metadata,
    String? description,
    DateTime? createdAt,
  }) {
    return SpotDepositTransactionEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      walletId: walletId ?? this.walletId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      currency: currency ?? this.currency,
      chain: chain ?? this.chain,
      referenceId: referenceId ?? this.referenceId,
      metadata: metadata ?? this.metadata,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
