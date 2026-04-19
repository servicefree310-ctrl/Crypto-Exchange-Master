// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'market_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MarketModelImpl _$$MarketModelImplFromJson(Map<String, dynamic> json) =>
    _$MarketModelImpl(
      id: json['id'] as String,
      currency: json['currency'] as String,
      pair: json['pair'] as String,
      isTrending: json['isTrending'] as bool,
      isHot: json['isHot'] as bool,
      status: json['status'] as bool,
      isEco: json['isEco'] as bool,
      metadata: json['metadata'] == null
          ? null
          : MarketMetadataModel.fromJson(
              json['metadata'] as Map<String, dynamic>),
      icon: json['icon'] as String?,
    );

Map<String, dynamic> _$$MarketModelImplToJson(_$MarketModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'currency': instance.currency,
      'pair': instance.pair,
      'isTrending': instance.isTrending,
      'isHot': instance.isHot,
      'status': instance.status,
      'isEco': instance.isEco,
      'metadata': instance.metadata,
      'icon': instance.icon,
    };

_$MarketMetadataModelImpl _$$MarketMetadataModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MarketMetadataModelImpl(
      taker: (json['taker'] as num?)?.toDouble(),
      maker: (json['maker'] as num?)?.toDouble(),
      precision: MarketPrecisionModel.fromJson(
          json['precision'] as Map<String, dynamic>),
      limits:
          MarketLimitsModel.fromJson(json['limits'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MarketMetadataModelImplToJson(
        _$MarketMetadataModelImpl instance) =>
    <String, dynamic>{
      'taker': instance.taker,
      'maker': instance.maker,
      'precision': instance.precision,
      'limits': instance.limits,
    };

_$MarketPrecisionModelImpl _$$MarketPrecisionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MarketPrecisionModelImpl(
      price: (json['price'] as num).toInt(),
      amount: (json['amount'] as num).toInt(),
    );

Map<String, dynamic> _$$MarketPrecisionModelImplToJson(
        _$MarketPrecisionModelImpl instance) =>
    <String, dynamic>{
      'price': instance.price,
      'amount': instance.amount,
    };

_$MarketLimitsModelImpl _$$MarketLimitsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MarketLimitsModelImpl(
      amount: _limitFromJson(json['amount']),
      price: _limitFromJson(json['price']),
      cost: _limitFromJson(json['cost']),
      leverage: _leverageFromJson(json['leverage']),
    );

Map<String, dynamic> _$$MarketLimitsModelImplToJson(
        _$MarketLimitsModelImpl instance) =>
    <String, dynamic>{
      'amount': _limitToJson(instance.amount),
      'price': _limitToJson(instance.price),
      'cost': _limitToJson(instance.cost),
      'leverage': _leverageToJson(instance.leverage),
    };

_$MarketLimitModelImpl _$$MarketLimitModelImplFromJson(
        Map<String, dynamic> json) =>
    _$MarketLimitModelImpl(
      min: (json['min'] as num).toDouble(),
      max: (json['max'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$MarketLimitModelImplToJson(
        _$MarketLimitModelImpl instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
    };
