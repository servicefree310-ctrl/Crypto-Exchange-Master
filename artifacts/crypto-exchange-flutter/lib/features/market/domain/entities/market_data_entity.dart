import 'package:equatable/equatable.dart';

import 'market_entity.dart';
import 'ticker_entity.dart';

class MarketDataEntity extends Equatable {
  const MarketDataEntity({
    required this.market,
    this.ticker,
  });

  final MarketEntity market;
  final TickerEntity? ticker;

  // Computed properties
  String get symbol => market.symbol;
  String get currency => market.currency;
  String get pair => market.pair;
  bool get isTrending => market.isTrending;
  bool get isHot => market.isHot;
  bool get status => market.status;
  bool get isEco => market.isEco;
  String? get icon => market.icon;

  // Ticker data or defaults
  double get price => ticker?.last ?? 0.0;
  double get change => ticker?.change ?? 0.0;
  double get changePercent => ticker?.changePercent ?? 0.0;
  double get baseVolume => ticker?.baseVolume ?? 0.0;
  double get quoteVolume => ticker?.quoteVolume ?? 0.0;
  bool get isPositive => ticker?.isPositive ?? false;
  bool get isNegative => ticker?.isNegative ?? false;

  // Format helpers
  String get formattedPrice {
    final precision = market.precision?.price ?? 8;
    return price.toStringAsFixed(precision);
  }

  String get formattedChange {
    final sign = isPositive ? '+' : '';
    return '$sign${changePercent.toStringAsFixed(2)}%';
  }

  String get formattedVolume {
    if (baseVolume >= 1000000000) {
      return '${(baseVolume / 1000000000).toStringAsFixed(2)}B';
    } else if (baseVolume >= 1000000) {
      return '${(baseVolume / 1000000).toStringAsFixed(2)}M';
    } else if (baseVolume >= 1000) {
      return '${(baseVolume / 1000).toStringAsFixed(2)}K';
    }
    return baseVolume.toStringAsFixed(2);
  }

  @override
  List<Object?> get props => [market, ticker];

  MarketDataEntity copyWith({
    MarketEntity? market,
    TickerEntity? ticker,
  }) {
    return MarketDataEntity(
      market: market ?? this.market,
      ticker: ticker ?? this.ticker,
    );
  }
}
