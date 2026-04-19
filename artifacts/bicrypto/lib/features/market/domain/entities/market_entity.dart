import 'package:equatable/equatable.dart';

class MarketEntity extends Equatable {
  const MarketEntity({
    required this.id,
    required this.symbol,
    required this.currency,
    required this.pair,
    required this.isTrending,
    required this.isHot,
    required this.status,
    required this.isEco,
    this.icon,
    this.precision,
    this.limits,
    this.taker,
    this.maker,
  });

  final String id;
  final String symbol; // Combined currency/pair (e.g., "BTC/USDT")
  final String currency; // Base currency (e.g., "BTC")
  final String pair; // Quote currency (e.g., "USDT")
  final bool isTrending;
  final bool isHot;
  final bool status;
  final bool isEco;
  final String? icon; // For ecosystem tokens
  final MarketPrecisionEntity? precision;
  final MarketLimitsEntity? limits;
  final double? taker;
  final double? maker;

  @override
  List<Object?> get props => [
        id,
        symbol,
        currency,
        pair,
        isTrending,
        isHot,
        status,
        isEco,
        icon,
        precision,
        limits,
        taker,
        maker,
      ];

  MarketEntity copyWith({
    String? id,
    String? symbol,
    String? currency,
    String? pair,
    bool? isTrending,
    bool? isHot,
    bool? status,
    bool? isEco,
    String? icon,
    MarketPrecisionEntity? precision,
    MarketLimitsEntity? limits,
    double? taker,
    double? maker,
  }) {
    return MarketEntity(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      currency: currency ?? this.currency,
      pair: pair ?? this.pair,
      isTrending: isTrending ?? this.isTrending,
      isHot: isHot ?? this.isHot,
      status: status ?? this.status,
      isEco: isEco ?? this.isEco,
      icon: icon ?? this.icon,
      precision: precision ?? this.precision,
      limits: limits ?? this.limits,
      taker: taker ?? this.taker,
      maker: maker ?? this.maker,
    );
  }
}

class MarketPrecisionEntity extends Equatable {
  const MarketPrecisionEntity({
    required this.price,
    required this.amount,
  });

  final int price;
  final int amount;

  @override
  List<Object?> get props => [price, amount];
}

class MarketLimitsEntity extends Equatable {
  const MarketLimitsEntity({
    this.minAmount,
    this.maxAmount,
    this.minPrice,
    this.maxPrice,
    this.minCost,
    this.maxCost,
  });

  final double? minAmount;
  final double? maxAmount;
  final double? minPrice;
  final double? maxPrice;
  final double? minCost;
  final double? maxCost;

  @override
  List<Object?> get props => [
        minAmount,
        maxAmount,
        minPrice,
        maxPrice,
        minCost,
        maxCost,
      ];
}
