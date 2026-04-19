part of 'trading_pair_selector_bloc.dart';

abstract class TradingPairSelectorEvent extends Equatable {
  const TradingPairSelectorEvent();

  @override
  List<Object?> get props => [];
}

class TradingPairSelectorLoadRequested extends TradingPairSelectorEvent {
  const TradingPairSelectorLoadRequested();
}

class TradingPairSelectorSearchChanged extends TradingPairSelectorEvent {
  const TradingPairSelectorSearchChanged({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class TradingPairSelectorCategoryChanged extends TradingPairSelectorEvent {
  const TradingPairSelectorCategoryChanged({required this.category});

  final String category;

  @override
  List<Object?> get props => [category];
}

class TradingPairSelectorFavoriteToggled extends TradingPairSelectorEvent {
  const TradingPairSelectorFavoriteToggled({required this.symbol});

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class TradingPairSelectorStartRealtime extends TradingPairSelectorEvent {
  const TradingPairSelectorStartRealtime();
}

class TradingPairSelectorStopRealtime extends TradingPairSelectorEvent {
  const TradingPairSelectorStopRealtime();
}

class TradingPairSelectorRealtimeDataReceived extends TradingPairSelectorEvent {
  const TradingPairSelectorRealtimeDataReceived({required this.markets});

  final List<MarketDataEntity> markets;

  @override
  List<Object?> get props => [markets];
}
