import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/p2p_market_stats_entity.dart';

part 'p2p_market_stats_model.freezed.dart';
part 'p2p_market_stats_model.g.dart';

@freezed
class P2PMarketStatsModel with _$P2PMarketStatsModel {
  const factory P2PMarketStatsModel({
    @JsonKey(name: 'totalTrades') required int totalTrades,
    @JsonKey(name: 'totalVolume') required double totalVolume,
    @JsonKey(name: 'avgTradeSize') required double avgTradeSize,
    @JsonKey(name: 'activeTrades') required int activeTrades,
    @JsonKey(name: 'last24hTrades') required int last24hTrades,
    @JsonKey(name: 'last24hVolume') required double last24hVolume,
    @JsonKey(name: 'topCurrencies') required List<String> topCurrencies,
  }) = _P2PMarketStatsModel;

  factory P2PMarketStatsModel.fromJson(Map<String, dynamic> json) =>
      _$P2PMarketStatsModelFromJson(json);
}

@freezed
class P2PTopCryptoModel with _$P2PTopCryptoModel {
  const factory P2PTopCryptoModel({
    required String symbol,
    required String name,
    @JsonKey(name: 'volume24h') required double volume24h,
    @JsonKey(name: 'tradeCount') required int tradeCount,
    @JsonKey(name: 'avgPrice') required double avgPrice,
  }) = _P2PTopCryptoModel;

  factory P2PTopCryptoModel.fromJson(Map<String, dynamic> json) =>
      _$P2PTopCryptoModelFromJson(json);
}

@freezed
class P2PMarketHighlightModel with _$P2PMarketHighlightModel {
  const factory P2PMarketHighlightModel({
    required String id,
    required String type,
    required String currency,
    required double price,
    required double amount,
    @JsonKey(name: 'paymentMethod') required String paymentMethod,
    @JsonKey(name: 'country') required String country,
    DateTime? createdAt,
    int? views,
    double? matchScore,
  }) = _P2PMarketHighlightModel;

  factory P2PMarketHighlightModel.fromJson(Map<String, dynamic> json) =>
      _$P2PMarketHighlightModelFromJson(json);
}

extension P2PMarketStatsModelX on P2PMarketStatsModel {
  P2PMarketStatsEntity toEntity() {
    return P2PMarketStatsEntity(
      totalTrades: totalTrades,
      totalVolume: totalVolume,
      avgTradeSize: avgTradeSize,
      activeTrades: activeTrades,
      last24hTrades: last24hTrades,
      last24hVolume: last24hVolume,
      topCurrencies: topCurrencies,
    );
  }
}

extension P2PTopCryptoModelX on P2PTopCryptoModel {
  P2PTopCryptoEntity toEntity() {
    return P2PTopCryptoEntity(
      symbol: symbol,
      name: name,
      volume24h: volume24h,
      tradeCount: tradeCount,
      avgPrice: avgPrice,
    );
  }
}

extension P2PMarketHighlightModelX on P2PMarketHighlightModel {
  P2PMarketHighlightEntity toEntity() {
    return P2PMarketHighlightEntity(
      id: id,
      type: type,
      currency: currency,
      price: price,
      amount: amount,
      paymentMethod: paymentMethod,
      country: country,
    );
  }
}
