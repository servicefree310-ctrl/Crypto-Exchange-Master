import 'package:equatable/equatable.dart';

class FuturesMarketMetadataEntity extends Equatable {
  const FuturesMarketMetadataEntity({
    this.precision,
    this.limits,
    this.taker,
    this.maker,
    this.fundingRate,
  });

  final Map<String, dynamic>? precision;
  final Map<String, dynamic>? limits;
  final double? taker;
  final double? maker;
  final double? fundingRate;

  @override
  List<Object?> get props => [precision, limits, taker, maker, fundingRate];
}

class FuturesMarketEntity extends Equatable {
  const FuturesMarketEntity({
    required this.id,
    required this.symbol,
    required this.currency,
    required this.pair,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.baseVolume,
    this.metadata,
    this.isTrending = false,
    this.isHot = false,
    this.status = true,
  });

  final String id;
  final String symbol; // e.g. BTC/USDT
  final String currency;
  final String pair;
  final double price;
  final double change;
  final double changePercent;
  final double baseVolume;
  final FuturesMarketMetadataEntity? metadata;
  final bool isTrending;
  final bool isHot;
  final bool status;

  bool get isPositive => change >= 0;

  @override
  List<Object?> get props => [
        id,
        symbol,
        price,
        change,
        changePercent,
        baseVolume,
        metadata,
        isTrending,
        isHot,
        status,
      ];
}
