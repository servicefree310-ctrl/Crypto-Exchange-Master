// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransferRequestModelImpl _$$TransferRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransferRequestModelImpl(
      fromType: json['fromType'] as String,
      fromCurrency: json['fromCurrency'] as String,
      amount: (json['amount'] as num).toDouble(),
      transferType: json['transferType'] as String,
      toType: json['toType'] as String?,
      toCurrency: json['toCurrency'] as String?,
      clientId: json['clientId'] as String?,
    );

Map<String, dynamic> _$$TransferRequestModelImplToJson(
        _$TransferRequestModelImpl instance) =>
    <String, dynamic>{
      'fromType': instance.fromType,
      'fromCurrency': instance.fromCurrency,
      'amount': instance.amount,
      'transferType': instance.transferType,
      'toType': instance.toType,
      'toCurrency': instance.toCurrency,
      'clientId': instance.clientId,
    };
