// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_payment_method_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$P2PPaymentMethodModelImpl _$$P2PPaymentMethodModelImplFromJson(
        Map<String, dynamic> json) =>
    _$P2PPaymentMethodModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      currency: json['currency'] as String,
      isEnabled: json['isEnabled'] as bool,
      config: json['config'] as Map<String, dynamic>?,
      supportedCountries: (json['supportedCountries'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      limits: json['limits'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$P2PPaymentMethodModelImplToJson(
        _$P2PPaymentMethodModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'currency': instance.currency,
      'isEnabled': instance.isEnabled,
      'config': instance.config,
      'supportedCountries': instance.supportedCountries,
      'limits': instance.limits,
    };
