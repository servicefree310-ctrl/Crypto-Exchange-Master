// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot_network_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpotNetworkModelImpl _$$SpotNetworkModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SpotNetworkModelImpl(
      id: json['id'] as String,
      chain: json['chain'] as String,
      fee: (json['fee'] as num?)?.toDouble(),
      precision: (json['precision'] as num?)?.toDouble(),
      limits: SpotLimitsModel.fromJson(json['limits'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SpotNetworkModelImplToJson(
        _$SpotNetworkModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chain': instance.chain,
      'fee': instance.fee,
      'precision': instance.precision,
      'limits': instance.limits,
    };

_$SpotLimitsModelImpl _$$SpotLimitsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SpotLimitsModelImpl(
      withdraw: SpotDepositLimitsModel.fromJson(
          json['withdraw'] as Map<String, dynamic>),
      deposit: SpotDepositLimitsModel.fromJson(
          json['deposit'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$SpotLimitsModelImplToJson(
        _$SpotLimitsModelImpl instance) =>
    <String, dynamic>{
      'withdraw': instance.withdraw,
      'deposit': instance.deposit,
    };

_$SpotDepositLimitsModelImpl _$$SpotDepositLimitsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SpotDepositLimitsModelImpl(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$SpotDepositLimitsModelImplToJson(
        _$SpotDepositLimitsModelImpl instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };
