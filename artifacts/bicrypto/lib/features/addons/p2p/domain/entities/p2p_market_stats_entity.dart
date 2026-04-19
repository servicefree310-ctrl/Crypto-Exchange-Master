import 'package:equatable/equatable.dart';
import 'p2p_offer_entity.dart';
import 'p2p_user_entity.dart';

/// P2P Market Statistics Entity
class P2PMarketStatsEntity {
  final int totalTrades;
  final double totalVolume;
  final double avgTradeSize;
  final int activeTrades;
  final int last24hTrades;
  final double last24hVolume;
  final List<String> topCurrencies;

  const P2PMarketStatsEntity({
    required this.totalTrades,
    required this.totalVolume,
    required this.avgTradeSize,
    required this.activeTrades,
    required this.last24hTrades,
    required this.last24hVolume,
    required this.topCurrencies,
  });

  factory P2PMarketStatsEntity.fromJson(Map<String, dynamic> json) {
    return P2PMarketStatsEntity(
      totalTrades: json['totalTrades'] ?? 0,
      totalVolume: (json['totalVolume'] as num?)?.toDouble() ?? 0.0,
      avgTradeSize: (json['avgTradeSize'] as num?)?.toDouble() ?? 0.0,
      activeTrades: json['activeTrades'] ?? 0,
      last24hTrades: json['last24hTrades'] ?? 0,
      last24hVolume: (json['last24hVolume'] as num?)?.toDouble() ?? 0.0,
      topCurrencies: List<String>.from(json['topCurrencies'] ?? []),
    );
  }
}

/// P2P Top Crypto Entity
class P2PTopCryptoEntity {
  final String symbol;
  final String name;
  final double volume24h;
  final int tradeCount;
  final double avgPrice;

  const P2PTopCryptoEntity({
    required this.symbol,
    required this.name,
    required this.volume24h,
    required this.tradeCount,
    required this.avgPrice,
  });

  factory P2PTopCryptoEntity.fromJson(Map<String, dynamic> json) {
    return P2PTopCryptoEntity(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      volume24h: (json['volume24h'] as num?)?.toDouble() ?? 0.0,
      tradeCount: json['tradeCount'] ?? 0,
      avgPrice: (json['avgPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// P2P Market Highlight Entity
class P2PMarketHighlightEntity {
  final String id;
  final String type;
  final String currency;
  final double price;
  final double amount;
  final String paymentMethod;
  final String country;

  const P2PMarketHighlightEntity({
    required this.id,
    required this.type,
    required this.currency,
    required this.price,
    required this.amount,
    required this.paymentMethod,
    required this.country,
  });

  factory P2PMarketHighlightEntity.fromJson(Map<String, dynamic> json) {
    return P2PMarketHighlightEntity(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      currency: json['currency'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      country: json['country'] ?? '',
    );
  }
}

class P2PCurrencyStatsEntity extends Equatable {
  const P2PCurrencyStatsEntity({
    required this.symbol,
    required this.name,
    required this.volume24h,
    required this.trades24h,
    required this.change24h,
    this.price,
    this.marketCap,
    this.available,
  });

  final String symbol;
  final String name;
  final double volume24h;
  final int trades24h;
  final double change24h;
  final double? price;
  final double? marketCap;
  final bool? available;

  @override
  List<Object?> get props => [
        symbol,
        name,
        volume24h,
        trades24h,
        change24h,
        price,
        marketCap,
        available,
      ];

  P2PCurrencyStatsEntity copyWith({
    String? symbol,
    String? name,
    double? volume24h,
    int? trades24h,
    double? change24h,
    double? price,
    double? marketCap,
    bool? available,
  }) {
    return P2PCurrencyStatsEntity(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      volume24h: volume24h ?? this.volume24h,
      trades24h: trades24h ?? this.trades24h,
      change24h: change24h ?? this.change24h,
      price: price ?? this.price,
      marketCap: marketCap ?? this.marketCap,
      available: available ?? this.available,
    );
  }

  bool get isPositiveChange => change24h > 0;
  bool get isNegativeChange => change24h < 0;
  String get displayChange24h =>
      '${change24h >= 0 ? '+' : ''}${change24h.toStringAsFixed(2)}%';
  String get displayVolume24h => volume24h.toStringAsFixed(2);
  String get displayPrice => price != null ? price!.toStringAsFixed(2) : 'N/A';
}

class P2PPaymentMethodStatsEntity extends Equatable {
  const P2PPaymentMethodStatsEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.usageCount,
    required this.popularityRank,
    this.avgProcessingTime,
    this.successRate,
  });

  final String id;
  final String name;
  final String icon;
  final int usageCount;
  final int popularityRank;
  final String? avgProcessingTime;
  final double? successRate;

  @override
  List<Object?> get props => [
        id,
        name,
        icon,
        usageCount,
        popularityRank,
        avgProcessingTime,
        successRate,
      ];

  P2PPaymentMethodStatsEntity copyWith({
    String? id,
    String? name,
    String? icon,
    int? usageCount,
    int? popularityRank,
    String? avgProcessingTime,
    double? successRate,
  }) {
    return P2PPaymentMethodStatsEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      usageCount: usageCount ?? this.usageCount,
      popularityRank: popularityRank ?? this.popularityRank,
      avgProcessingTime: avgProcessingTime ?? this.avgProcessingTime,
      successRate: successRate ?? this.successRate,
    );
  }

  String get displaySuccessRate =>
      successRate != null ? '${successRate!.toStringAsFixed(1)}%' : 'N/A';
  String get displayProcessingTime => avgProcessingTime ?? 'Unknown';
}

// Guided Matching Related Entities
class P2PMatchedOfferEntity extends Equatable {
  const P2PMatchedOfferEntity({
    required this.offer,
    required this.trader,
    required this.matchScore,
    this.estimatedSavings,
    this.benefits,
  });

  final P2POfferEntity offer;
  final P2PUserEntity trader;
  final double matchScore;
  final String? estimatedSavings;
  final List<String>? benefits;

  @override
  List<Object?> get props => [
        offer,
        trader,
        matchScore,
        estimatedSavings,
        benefits,
      ];

  P2PMatchedOfferEntity copyWith({
    P2POfferEntity? offer,
    P2PUserEntity? trader,
    double? matchScore,
    String? estimatedSavings,
    List<String>? benefits,
  }) {
    return P2PMatchedOfferEntity(
      offer: offer ?? this.offer,
      trader: trader ?? this.trader,
      matchScore: matchScore ?? this.matchScore,
      estimatedSavings: estimatedSavings ?? this.estimatedSavings,
      benefits: benefits ?? this.benefits,
    );
  }

  bool get isHighMatch => matchScore >= 80;
  bool get isMediumMatch => matchScore >= 60 && matchScore < 80;
  bool get isLowMatch => matchScore < 60;

  String get displayMatchScore => '${matchScore.toStringAsFixed(0)}%';
  String get matchQuality {
    if (isHighMatch) return 'Excellent';
    if (isMediumMatch) return 'Good';
    return 'Fair';
  }
}

class P2PMatchingResultsEntity extends Equatable {
  const P2PMatchingResultsEntity({
    required this.matches,
    required this.matchCount,
    this.estimatedSavings,
    this.bestPrice,
  });

  final List<P2PMatchedOfferEntity> matches;
  final int matchCount;
  final String? estimatedSavings;
  final String? bestPrice;

  @override
  List<Object?> get props => [
        matches,
        matchCount,
        estimatedSavings,
        bestPrice,
      ];

  P2PMatchingResultsEntity copyWith({
    List<P2PMatchedOfferEntity>? matches,
    int? matchCount,
    String? estimatedSavings,
    String? bestPrice,
  }) {
    return P2PMatchingResultsEntity(
      matches: matches ?? this.matches,
      matchCount: matchCount ?? this.matchCount,
      estimatedSavings: estimatedSavings ?? this.estimatedSavings,
      bestPrice: bestPrice ?? this.bestPrice,
    );
  }

  bool get hasMatches => matches.isNotEmpty;
  List<P2PMatchedOfferEntity> get highQualityMatches =>
      matches.where((m) => m.isHighMatch).toList();
  P2PMatchedOfferEntity? get bestMatch =>
      matches.isNotEmpty ? matches.first : null;
}
