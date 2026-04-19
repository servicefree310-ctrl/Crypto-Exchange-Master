// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eco_wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EcoWalletModelImpl _$$EcoWalletModelImplFromJson(Map<String, dynamic> json) =>
    _$EcoWalletModelImpl(
      id: json['id'] as String,
      currency: json['currency'] as String,
      balance: (json['balance'] as num).toDouble(),
      type: json['type'] as String,
      address: json['address'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$EcoWalletModelImplToJson(
        _$EcoWalletModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currency': instance.currency,
      'balance': instance.balance,
      'type': instance.type,
      'address': instance.address,
    };
