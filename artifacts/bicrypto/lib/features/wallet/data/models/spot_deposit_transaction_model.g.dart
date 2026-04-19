// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot_deposit_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpotDepositTransactionModelImpl _$$SpotDepositTransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SpotDepositTransactionModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      walletId: json['walletId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      currency: json['currency'] as String,
      chain: json['chain'] as String,
      referenceId: json['referenceId'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SpotDepositTransactionModelImplToJson(
        _$SpotDepositTransactionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'walletId': instance.walletId,
      'type': instance.type,
      'amount': instance.amount,
      'status': instance.status,
      'currency': instance.currency,
      'chain': instance.chain,
      'referenceId': instance.referenceId,
      'metadata': instance.metadata,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
    };
