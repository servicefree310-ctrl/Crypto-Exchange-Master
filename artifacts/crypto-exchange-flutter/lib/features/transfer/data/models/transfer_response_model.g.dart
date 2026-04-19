// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransferResponseModelImpl _$$TransferResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransferResponseModelImpl(
      message: json['message'] as String,
      fromTransfer: TransferTransactionModel.fromJson(
          json['fromTransfer'] as Map<String, dynamic>),
      toTransfer: TransferTransactionModel.fromJson(
          json['toTransfer'] as Map<String, dynamic>),
      fromType: json['fromType'] as String,
      toType: json['toType'] as String,
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
    );

Map<String, dynamic> _$$TransferResponseModelImplToJson(
        _$TransferResponseModelImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'fromTransfer': instance.fromTransfer,
      'toTransfer': instance.toTransfer,
      'fromType': instance.fromType,
      'toType': instance.toType,
      'fromCurrency': instance.fromCurrency,
      'toCurrency': instance.toCurrency,
    };

_$TransferTransactionModelImpl _$$TransferTransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransferTransactionModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      walletId: json['walletId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      status: json['status'] as String,
      description: json['description'] as String,
      metadata: json['metadata'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$$TransferTransactionModelImplToJson(
        _$TransferTransactionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'walletId': instance.walletId,
      'type': instance.type,
      'amount': instance.amount,
      'fee': instance.fee,
      'status': instance.status,
      'description': instance.description,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
