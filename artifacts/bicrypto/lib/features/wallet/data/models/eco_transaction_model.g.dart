// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eco_transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EcoTransactionModelImpl _$$EcoTransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EcoTransactionModelImpl(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      status: json['status'] as String,
      referenceId: json['referenceId'] as String,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$EcoTransactionModelImplToJson(
        _$EcoTransactionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'fee': instance.fee,
      'status': instance.status,
      'referenceId': instance.referenceId,
      'description': instance.description,
      'metadata': instance.metadata,
      'createdAt': instance.createdAt.toIso8601String(),
    };
