// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot_deposit_address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpotDepositAddressModelImpl _$$SpotDepositAddressModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SpotDepositAddressModelImpl(
      address: json['address'] as String,
      tag: json['tag'] as String?,
      network: json['network'] as String,
      currency: json['currency'] as String,
      trx: json['trx'] as bool,
    );

Map<String, dynamic> _$$SpotDepositAddressModelImplToJson(
        _$SpotDepositAddressModelImpl instance) =>
    <String, dynamic>{
      'address': instance.address,
      'tag': instance.tag,
      'network': instance.network,
      'currency': instance.currency,
      'trx': instance.trx,
    };
