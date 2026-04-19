// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eco_deposit_address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EcoDepositAddressModelImpl _$$EcoDepositAddressModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EcoDepositAddressModelImpl(
      address: json['address'] as String,
      currency: json['currency'] as String,
      chain: json['chain'] as String,
      contractType: json['contractType'] as String,
      network: json['network'] as String?,
      locked: json['locked'] as bool? ?? false,
      id: json['id'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$EcoDepositAddressModelImplToJson(
        _$EcoDepositAddressModelImpl instance) =>
    <String, dynamic>{
      'address': instance.address,
      'currency': instance.currency,
      'chain': instance.chain,
      'contractType': instance.contractType,
      'network': instance.network,
      'locked': instance.locked,
      'id': instance.id,
      'status': instance.status,
    };
