// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionWalletModel _$TransactionWalletModelFromJson(
        Map<String, dynamic> json) =>
    TransactionWalletModel(
      currency: json['currency'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$TransactionWalletModelToJson(
        TransactionWalletModel instance) =>
    <String, dynamic>{
      'currency': instance.currency,
      'type': instance.type,
    };

TransactionModel _$TransactionModelFromJson(Map<String, dynamic> json) =>
    TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      walletId: json['walletId'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      referenceId: json['referenceId'] as String?,
      trxId: json['trxId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      wallet: json['wallet'] == null
          ? null
          : TransactionWalletModel.fromJson(
              json['wallet'] as Map<String, dynamic>),
      user: json['user'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$TransactionModelToJson(TransactionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'walletId': instance.walletId,
      'type': instance.type,
      'status': instance.status,
      'amount': instance.amount,
      'fee': instance.fee,
      'description': instance.description,
      'metadata': instance.metadata,
      'referenceId': instance.referenceId,
      'trxId': instance.trxId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'wallet': instance.wallet,
      'user': instance.user,
    };

TransactionListModel _$TransactionListModelFromJson(
        Map<String, dynamic> json) =>
    TransactionListModel(
      items: (json['items'] as List<dynamic>)
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: TransactionPaginationModel.fromJson(
          json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TransactionListModelToJson(
        TransactionListModel instance) =>
    <String, dynamic>{
      'items': instance.items,
      'pagination': instance.pagination,
    };

TransactionPaginationModel _$TransactionPaginationModelFromJson(
        Map<String, dynamic> json) =>
    TransactionPaginationModel(
      totalItems: (json['totalItems'] as num).toInt(),
      currentPage: (json['currentPage'] as num).toInt(),
      perPage: (json['perPage'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
    );

Map<String, dynamic> _$TransactionPaginationModelToJson(
        TransactionPaginationModel instance) =>
    <String, dynamic>{
      'totalItems': instance.totalItems,
      'currentPage': instance.currentPage,
      'perPage': instance.perPage,
      'totalPages': instance.totalPages,
    };
