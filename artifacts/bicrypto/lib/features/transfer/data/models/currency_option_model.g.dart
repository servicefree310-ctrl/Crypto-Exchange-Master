// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_option_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CurrencyOptionModelImpl _$$CurrencyOptionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$CurrencyOptionModelImpl(
      value: json['value'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$CurrencyOptionModelImplToJson(
        _$CurrencyOptionModelImpl instance) =>
    <String, dynamic>{
      'value': instance.value,
      'label': instance.label,
      'icon': instance.icon,
      'balance': instance.balance,
    };
