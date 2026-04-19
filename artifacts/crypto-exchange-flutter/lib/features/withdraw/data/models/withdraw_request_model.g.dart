// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'withdraw_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WithdrawRequestModelImpl _$$WithdrawRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$WithdrawRequestModelImpl(
      walletType: json['walletType'] as String,
      currency: json['currency'] as String,
      amount: (json['amount'] as num).toDouble(),
      methodId: json['methodId'] as String?,
      toAddress: json['toAddress'] as String?,
      chain: json['chain'] as String?,
      memo: json['memo'] as String?,
      customFields: json['customFields'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$WithdrawRequestModelImplToJson(
        _$WithdrawRequestModelImpl instance) =>
    <String, dynamic>{
      'walletType': instance.walletType,
      'currency': instance.currency,
      'amount': instance.amount,
      'methodId': instance.methodId,
      'toAddress': instance.toAddress,
      'chain': instance.chain,
      'memo': instance.memo,
      'customFields': instance.customFields,
    };
