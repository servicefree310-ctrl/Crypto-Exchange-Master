// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'eco_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EcoTokenModelImpl _$$EcoTokenModelImplFromJson(Map<String, dynamic> json) =>
    _$EcoTokenModelImpl(
      name: json['name'] as String,
      currency: json['currency'] as String,
      chain: json['chain'] as String,
      icon: json['icon'] as String,
      limits: json['limits'] == null
          ? null
          : EcoLimitsModel.fromJson(json['limits'] as Map<String, dynamic>),
      fee: json['fee'] == null
          ? null
          : EcoFeeModel.fromJson(json['fee'] as Map<String, dynamic>),
      contractType: json['contractType'] as String,
      contract: json['contract'] as String?,
      decimals: (json['decimals'] as num?)?.toInt(),
      network: json['network'] as String?,
      type: json['type'] as String?,
      precision: (json['precision'] as num?)?.toInt(),
      status: json['status'] as bool? ?? true,
    );

Map<String, dynamic> _$$EcoTokenModelImplToJson(_$EcoTokenModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'currency': instance.currency,
      'chain': instance.chain,
      'icon': instance.icon,
      'limits': instance.limits,
      'fee': instance.fee,
      'contractType': instance.contractType,
      'contract': instance.contract,
      'decimals': instance.decimals,
      'network': instance.network,
      'type': instance.type,
      'precision': instance.precision,
      'status': instance.status,
    };

_$EcoLimitsModelImpl _$$EcoLimitsModelImplFromJson(Map<String, dynamic> json) =>
    _$EcoLimitsModelImpl(
      deposit: EcoDepositLimitsModel.fromJson(
          json['deposit'] as Map<String, dynamic>),
      withdraw: json['withdraw'] == null
          ? null
          : EcoWithdrawLimitsModel.fromJson(
              json['withdraw'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$EcoLimitsModelImplToJson(
        _$EcoLimitsModelImpl instance) =>
    <String, dynamic>{
      'deposit': instance.deposit,
      'withdraw': instance.withdraw,
    };

_$EcoDepositLimitsModelImpl _$$EcoDepositLimitsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EcoDepositLimitsModelImpl(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );

Map<String, dynamic> _$$EcoDepositLimitsModelImplToJson(
        _$EcoDepositLimitsModelImpl instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };

_$EcoWithdrawLimitsModelImpl _$$EcoWithdrawLimitsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$EcoWithdrawLimitsModelImpl(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num).toDouble(),
    );

Map<String, dynamic> _$$EcoWithdrawLimitsModelImplToJson(
        _$EcoWithdrawLimitsModelImpl instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };

_$EcoFeeModelImpl _$$EcoFeeModelImplFromJson(Map<String, dynamic> json) =>
    _$EcoFeeModelImpl(
      min: (json['min'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$$EcoFeeModelImplToJson(_$EcoFeeModelImpl instance) =>
    <String, dynamic>{
      'min': instance.min,
      'percentage': instance.percentage,
    };
