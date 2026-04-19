part of 'trading_header_bloc.dart';

// Note: MarketDataEntity import is handled by the bloc file

abstract class TradingHeaderState extends Equatable {
  const TradingHeaderState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TradingHeaderInitial extends TradingHeaderState {
  const TradingHeaderInitial();
}

/// Loading state
class TradingHeaderLoading extends TradingHeaderState {
  final String? symbol;

  const TradingHeaderLoading({this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Loaded state with trading data
class TradingHeaderLoaded extends TradingHeaderState {
  final String symbol;
  final TradingType selectedType;
  final TradingPairData pairData;
  final List<MarketDataEntity> availableMarkets;

  const TradingHeaderLoaded({
    required this.symbol,
    required this.selectedType,
    required this.pairData,
    this.availableMarkets = const [],
  });

  @override
  List<Object?> get props => [symbol, selectedType, pairData, availableMarkets];

  TradingHeaderLoaded copyWith({
    String? symbol,
    TradingType? selectedType,
    TradingPairData? pairData,
    List<MarketDataEntity>? availableMarkets,
  }) {
    return TradingHeaderLoaded(
      symbol: symbol ?? this.symbol,
      selectedType: selectedType ?? this.selectedType,
      pairData: pairData ?? this.pairData,
      availableMarkets: availableMarkets ?? this.availableMarkets,
    );
  }
}

/// Error state
class TradingHeaderError extends TradingHeaderState {
  final String message;
  final String? symbol;

  const TradingHeaderError({
    required this.message,
    this.symbol,
  });

  @override
  List<Object?> get props => [message, symbol];
}

/// Enums for trading configuration
enum TradingType { spot, futures, isolatedMargin, grid, fiat, convert }

enum TradingAction { info, analytics, more }

/// Trading pair data model
class TradingPairData extends Equatable {
  final String symbol;
  final double price;
  final double change24h;
  final double changePercentage24h;
  final double high24h;
  final double low24h;
  final double volume24h;
  final DateTime lastUpdated;

  const TradingPairData({
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.changePercentage24h,
    required this.high24h,
    required this.low24h,
    required this.volume24h,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        symbol,
        price,
        change24h,
        changePercentage24h,
        high24h,
        low24h,
        volume24h,
        lastUpdated,
      ];

  bool get isPositiveChange => change24h >= 0;

  Color get changeColor => isPositiveChange ? Colors.green : Colors.red;

  String get formattedPrice => price.toStringAsFixed(4);

  String get formattedChangePercentage =>
      '${isPositiveChange ? '+' : ''}${changePercentage24h.toStringAsFixed(2)}%';

  TradingPairData copyWith({
    String? symbol,
    double? price,
    double? change24h,
    double? changePercentage24h,
    double? high24h,
    double? low24h,
    double? volume24h,
    DateTime? lastUpdated,
  }) {
    return TradingPairData(
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      change24h: change24h ?? this.change24h,
      changePercentage24h: changePercentage24h ?? this.changePercentage24h,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      volume24h: volume24h ?? this.volume24h,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  factory TradingPairData.mock(String symbol) {
    return TradingPairData(
      symbol: symbol,
      price: 0.0516,
      change24h: -0.00166,
      changePercentage24h: -3.18,
      high24h: 0.0536,
      low24h: 0.0500,
      volume24h: 708.5455,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Trading type extensions
extension TradingTypeExtension on TradingType {
  String get displayName {
    switch (this) {
      case TradingType.spot:
        return 'Spot';
      case TradingType.futures:
        return 'Futures';
      case TradingType.isolatedMargin:
        return 'AI Investment';
      case TradingType.grid:
        return 'Grid';
      case TradingType.fiat:
        return 'Fiat';
      case TradingType.convert:
        return 'Convert';
    }
  }
}
