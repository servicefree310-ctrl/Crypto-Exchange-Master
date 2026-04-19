// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticker_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TickerModelImpl _$$TickerModelImplFromJson(Map<String, dynamic> json) =>
    _$TickerModelImpl(
      symbol: json['symbol'] as String,
      last: (json['last'] as num?)?.toDouble(),
      baseVolume: (json['baseVolume'] as num?)?.toDouble(),
      quoteVolume: (json['quoteVolume'] as num?)?.toDouble(),
      change: (json['change'] as num?)?.toDouble(),
      bid: (json['bid'] as num?)?.toDouble(),
      ask: (json['ask'] as num?)?.toDouble(),
      high: (json['high'] as num?)?.toDouble(),
      low: (json['low'] as num?)?.toDouble(),
      open: (json['open'] as num?)?.toDouble(),
      close: (json['close'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$TickerModelImplToJson(_$TickerModelImpl instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'last': instance.last,
      'baseVolume': instance.baseVolume,
      'quoteVolume': instance.quoteVolume,
      'change': instance.change,
      'bid': instance.bid,
      'ask': instance.ask,
      'high': instance.high,
      'low': instance.low,
      'open': instance.open,
      'close': instance.close,
    };
