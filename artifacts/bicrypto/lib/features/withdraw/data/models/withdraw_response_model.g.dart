// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WithdrawResponseModelImpl _$$WithdrawResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$WithdrawResponseModelImpl(
      message: json['message'] as String,
      transaction: json['transaction'] == null
          ? null
          : WithdrawTransactionModel.fromJson(
              json['transaction'] as Map<String, dynamic>),
      currency: json['currency'] as String?,
      method: json['method'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$WithdrawResponseModelImplToJson(
        _$WithdrawResponseModelImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'transaction': instance.transaction,
      'currency': instance.currency,
      'method': instance.method,
      'balance': instance.balance,
    };

_$WithdrawTransactionModelImpl _$$WithdrawTransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$WithdrawTransactionModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      walletId: json['walletId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      status: json['status'] as String,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      referenceId: json['referenceId'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$WithdrawTransactionModelImplToJson(
        _$WithdrawTransactionModelImpl instance) =>
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
      'referenceId': instance.referenceId,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
