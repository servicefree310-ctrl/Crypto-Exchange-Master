import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'dart:developer' as dev;
import '../../../wallet/domain/entities/wallet_entity.dart';
import '../../domain/entities/transaction_entity.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionWalletModel {
  final String currency;
  final String type;

  const TransactionWalletModel({
    required this.currency,
    required this.type,
  });

  factory TransactionWalletModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionWalletModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionWalletModelToJson(this);

  WalletEntity toEntity() {
    return WalletEntity(
      id: '', // Not provided in transaction response
      userId: '', // Not provided in transaction response
      type: _parseWalletType(type),
      currency: currency,
      balance: 0.0, // Not provided in transaction response
      inOrder: 0.0, // Not provided in transaction response
      status: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static WalletType _parseWalletType(String typeString) {
    switch (typeString.toUpperCase()) {
      case 'FIAT':
        return WalletType.FIAT;
      case 'SPOT':
        return WalletType.SPOT;
      case 'ECO':
        return WalletType.ECO;
      case 'FUTURES':
        return WalletType.FUTURES;
      default:
        return WalletType.SPOT;
    }
  }
}

@JsonSerializable()
class TransactionModel {
  final String id;
  final String userId;
  final String walletId;
  final String type;
  final String status;
  final double amount;
  final double fee;
  final String? description;
  final Map<String, dynamic>? metadata;
  final String? referenceId;
  final String? trxId;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Related entities
  final TransactionWalletModel? wallet;
  final Map<String, dynamic>? user;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.walletId,
    required this.type,
    required this.status,
    required this.amount,
    required this.fee,
    this.description,
    this.metadata,
    this.referenceId,
    this.trxId,
    required this.createdAt,
    required this.updatedAt,
    this.wallet,
    this.user,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    try {
      // Handle metadata field - it can be a JSON string or Map or null
      if (json['metadata'] != null && json['metadata'] is String) {
        try {
          json['metadata'] = json['metadata'] == ''
              ? null
              : jsonDecode(json['metadata'] as String);
        } catch (e) {
          dev.log(
              '⚠️ Warning: Could not parse metadata JSON string: ${json['metadata']}');
          json['metadata'] = null; // Set to null if parsing fails
        }
      }

      return _$TransactionModelFromJson(json);
    } catch (e) {
      // Add detailed error logging for debugging
      dev.log('❌ TransactionModel.fromJson error: $e');
      dev.log('❌ JSON data causing error: $json');

      // Try to identify which field is null
      final requiredFields = [
        'id',
        'userId',
        'walletId',
        'type',
        'status',
        'amount',
        'fee',
        'createdAt',
        'updatedAt'
      ];
      for (final field in requiredFields) {
        if (json[field] == null) {
          dev.log('❌ NULL FIELD DETECTED: $field is null in transaction data');
        }
      }

      // Re-throw with more context
      throw Exception(
          'Failed to parse TransactionModel from JSON: $e. Check logs for null fields.');
    }
  }

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      walletId: walletId,
      type: _parseTransactionType(type),
      status: _parseTransactionStatus(status),
      amount: amount,
      fee: fee,
      description: description,
      metadata: metadata,
      referenceId: referenceId,
      trxId: trxId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      wallet: wallet?.toEntity(),
      user: user,
    );
  }

  static TransactionType _parseTransactionType(String type) {
    switch (type.toUpperCase()) {
      case 'DEPOSIT':
        return TransactionType.DEPOSIT;
      case 'WITHDRAW':
        return TransactionType.WITHDRAW;
      case 'TRANSFER':
        return TransactionType.TRANSFER;
      case 'INCOMING_TRANSFER':
        return TransactionType.INCOMING_TRANSFER;
      case 'OUTGOING_TRANSFER':
        return TransactionType.OUTGOING_TRANSFER;
      case 'TRADE':
        return TransactionType.TRADE;
      case 'BINARY_ORDER':
        return TransactionType.BINARY_ORDER;
      case 'EXCHANGE_ORDER':
        return TransactionType.EXCHANGE_ORDER;
      case 'FOREX_DEPOSIT':
        return TransactionType.FOREX_DEPOSIT;
      case 'FOREX_WITHDRAW':
        return TransactionType.FOREX_WITHDRAW;
      case 'ICO_CONTRIBUTION':
        return TransactionType.ICO_CONTRIBUTION;
      case 'BONUS':
        return TransactionType.BONUS;
      case 'FEE':
        return TransactionType.FEE;
      case 'STAKING_REWARD':
        return TransactionType.STAKING_REWARD;
      case 'STAKING_STAKE':
        return TransactionType.STAKING_STAKE;
      case 'STAKING_UNSTAKE':
        return TransactionType.STAKING_UNSTAKE;
      case 'REFERRAL_REWARD':
        return TransactionType.REFERRAL_REWARD;
      case 'AI_INVESTMENT':
        return TransactionType.AI_INVESTMENT;
      case 'P2P_TRADE':
        return TransactionType.P2P_TRADE;
      case 'FUTURES_ORDER':
        return TransactionType.FUTURES_ORDER;
      case 'SPOT_ORDER':
        return TransactionType.SPOT_ORDER;
      case 'ECO_TRANSFER':
        return TransactionType.ECO_TRANSFER;
      default:
        return TransactionType.OTHER;
    }
  }

  static TransactionStatus _parseTransactionStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return TransactionStatus.PENDING;
      case 'COMPLETED':
        return TransactionStatus.COMPLETED;
      case 'CANCELLED':
        return TransactionStatus.CANCELLED;
      case 'FAILED':
        return TransactionStatus.FAILED;
      case 'PROCESSING':
        return TransactionStatus.PROCESSING;
      case 'REJECTED':
        return TransactionStatus.REJECTED;
      case 'EXPIRED':
        return TransactionStatus.EXPIRED;
      default:
        return TransactionStatus.PENDING;
    }
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      walletId: entity.walletId,
      type: entity.type.name,
      status: entity.status.name,
      amount: entity.amount,
      fee: entity.fee,
      description: entity.description,
      metadata: entity.metadata,
      referenceId: entity.referenceId,
      trxId: entity.trxId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      wallet: entity.wallet != null
          ? TransactionWalletModel(
              currency: entity.wallet!.currency,
              type: entity.wallet!.type.name,
            )
          : null,
      user: entity.user,
    );
  }
}

@JsonSerializable()
class TransactionListModel {
  final List<TransactionModel> items;
  final TransactionPaginationModel pagination;

  const TransactionListModel({
    required this.items,
    required this.pagination,
  });

  factory TransactionListModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionListModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionListModelToJson(this);

  TransactionListEntity toEntity() {
    return TransactionListEntity(
      transactions: items.map((model) => model.toEntity()).toList(),
      totalCount: pagination.totalItems,
      currentPage: pagination.currentPage,
      pageSize: pagination.perPage,
      hasNextPage: pagination.currentPage < pagination.totalPages,
    );
  }

  factory TransactionListModel.fromEntity(TransactionListEntity entity) {
    return TransactionListModel(
      items: entity.transactions
          .map((e) => TransactionModel.fromEntity(e))
          .toList(),
      pagination: TransactionPaginationModel(
        totalItems: entity.totalCount,
        currentPage: entity.currentPage,
        perPage: entity.pageSize,
        totalPages: (entity.totalCount / entity.pageSize).ceil(),
      ),
    );
  }
}

@JsonSerializable()
class TransactionPaginationModel {
  final int totalItems;
  final int currentPage;
  final int perPage;
  final int totalPages;

  const TransactionPaginationModel({
    required this.totalItems,
    required this.currentPage,
    required this.perPage,
    required this.totalPages,
  });

  factory TransactionPaginationModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionPaginationModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionPaginationModelToJson(this);
}
