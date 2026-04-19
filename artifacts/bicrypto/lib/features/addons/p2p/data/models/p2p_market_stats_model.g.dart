// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'p2p_market_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$P2PMarketStatsModelImpl _$$P2PMarketStatsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$P2PMarketStatsModelImpl(
      totalTrades: (json['totalTrades'] as num).toInt(),
      totalVolume: (json['totalVolume'] as num).toDouble(),
      avgTradeSize: (json['avgTradeSize'] as num).toDouble(),
      activeTrades: (json['activeTrades'] as num).toInt(),
      last24hTrades: (json['last24hTrades'] as num).toInt(),
      last24hVolume: (json['last24hVolume'] as num).toDouble(),
      topCurrencies: (json['topCurrencies'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$P2PMarketStatsModelImplToJson(
        _$P2PMarketStatsModelImpl instance) =>
    <String, dynamic>{
      'totalTrades': instance.totalTrades,
      'totalVolume': instance.totalVolume,
      'avgTradeSize': instance.avgTradeSize,
      'activeTrades': instance.activeTrades,
      'last24hTrades': instance.last24hTrades,
      'last24hVolume': instance.last24hVolume,
      'topCurrencies': instance.topCurrencies,
    };

_$P2PTopCryptoModelImpl _$$P2PTopCryptoModelImplFromJson(
        Map<String, dynamic> json) =>
    _$P2PTopCryptoModelImpl(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      volume24h: (json['volume24h'] as num).toDouble(),
      tradeCount: (json['tradeCount'] as num).toInt(),
      avgPrice: (json['avgPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$$P2PTopCryptoModelImplToJson(
        _$P2PTopCryptoModelImpl instance) =>
    <String, dynamic>{
      'symbol': instance.symbol,
      'name': instance.name,
      'volume24h': instance.volume24h,
      'tradeCount': instance.tradeCount,
      'avgPrice': instance.avgPrice,
    };

_$P2PMarketHighlightModelImpl _$$P2PMarketHighlightModelImplFromJson(
        Map<String, dynamic> json) =>
    _$P2PMarketHighlightModelImpl(
      id: json['id'] as String,
      type: json['type'] as String,
      currency: json['currency'] as String,
      price: (json['price'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      country: json['country'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      views: (json['views'] as num?)?.toInt(),
      matchScore: (json['matchScore'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$P2PMarketHighlightModelImplToJson(
        _$P2PMarketHighlightModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'currency': instance.currency,
      'price': instance.price,
      'amount': instance.amount,
      'paymentMethod': instance.paymentMethod,
      'country': instance.country,
      'createdAt': instance.createdAt?.toIso8601String(),
      'views': instance.views,
      'matchScore': instance.matchScore,
    };
