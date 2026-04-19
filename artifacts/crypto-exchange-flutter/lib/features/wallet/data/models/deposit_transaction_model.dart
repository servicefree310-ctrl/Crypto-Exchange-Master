import 'dart:convert';
import '../../domain/entities/deposit_transaction_entity.dart';

class DepositTransactionModel {
  const DepositTransactionModel({
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
  final String type;
  final double amount;
  final String status;
  final String currency;
  final String method;
  final double? fee;
  final Map<String, dynamic>? metadata;
  final String? description;
  final DateTime? createdAt;

  factory DepositTransactionModel.fromJson(Map<String, dynamic> json) {
    // Parse metadata - handle both JSON string and Map formats
    Map<String, dynamic>? metadata;
    if (json['metadata'] != null) {
      if (json['metadata'] is String) {
        // Parse JSON string
        try {
          metadata = Map<String, dynamic>.from(
            jsonDecode(json['metadata'] as String) as Map,
          );
        } catch (e) {
          // If parsing fails, keep as null
          metadata = null;
        }
      } else if (json['metadata'] is Map) {
        metadata = Map<String, dynamic>.from(json['metadata'] as Map);
      }
    }

    return DepositTransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      walletId: json['walletId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      currency: json['currency'] as String,
      method: json['method'] as String,
      fee: json['fee']?.toDouble(),
      metadata: metadata,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'walletId': walletId,
      'type': type,
      'amount': amount,
      'status': status,
      'currency': currency,
      'method': method,
      'fee': fee,
      'metadata': metadata,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

extension DepositTransactionModelExtension on DepositTransactionModel {
  DepositTransactionEntity toEntity() {
    DepositTransactionStatus entityStatus;
    switch (status.toLowerCase()) {
      case 'pending':
        entityStatus = DepositTransactionStatus.pending;
        break;
      case 'completed':
        entityStatus = DepositTransactionStatus.completed;
        break;
      case 'cancelled':
        entityStatus = DepositTransactionStatus.cancelled;
        break;
      case 'failed':
        entityStatus = DepositTransactionStatus.failed;
        break;
      default:
        entityStatus = DepositTransactionStatus.pending;
    }

    return DepositTransactionEntity(
      id: id,
      userId: userId,
      walletId: walletId,
      type: type,
      amount: amount,
      status: entityStatus,
      currency: currency,
      method: method,
      fee: fee,
      metadata: metadata,
      description: description,
      createdAt: createdAt,
    );
  }
}
