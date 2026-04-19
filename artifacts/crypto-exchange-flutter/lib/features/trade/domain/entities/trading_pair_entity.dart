import 'package:equatable/equatable.dart';

import '../../../market/domain/entities/market_data_entity.dart';

class TradingPairEntity extends Equatable {
  const TradingPairEntity({
    required this.marketData,
    this.isFavorite = false,
    this.isRecent = false,
  });

  final MarketDataEntity marketData;
  final bool isFavorite;
  final bool isRecent;

  // Convenience getters
  String get symbol => marketData.symbol;
  String get currency => marketData.currency;
  String get pair => marketData.pair;
  double get price => marketData.price;
  double get change => marketData.change;
  double get changePercent => marketData.changePercent;
  bool get isPositive => marketData.isPositive;
  String get formattedPrice => marketData.formattedPrice;
  String get formattedChange => marketData.formattedChange;
  double get baseVolume => marketData.baseVolume;
  String get formattedVolume => marketData.formattedVolume;

  @override
  List<Object?> get props => [marketData, isFavorite, isRecent];

  TradingPairEntity copyWith({
    MarketDataEntity? marketData,
    bool? isFavorite,
    bool? isRecent,
  }) {
    return TradingPairEntity(
      marketData: marketData ?? this.marketData,
      isFavorite: isFavorite ?? this.isFavorite,
      isRecent: isRecent ?? this.isRecent,
    );
  }
}
