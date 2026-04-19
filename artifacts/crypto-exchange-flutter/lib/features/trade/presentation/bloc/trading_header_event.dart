part of 'trading_header_bloc.dart';

abstract class TradingHeaderEvent extends Equatable {
  const TradingHeaderEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize trading header with symbol
class TradingHeaderInitialized extends TradingHeaderEvent {
  final String symbol;

  const TradingHeaderInitialized({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Event to change trading pair
class TradingPairChanged extends TradingHeaderEvent {
  final String symbol;

  const TradingPairChanged({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Event to change trading type
class TradingTypeChanged extends TradingHeaderEvent {
  final TradingType tradingType;

  const TradingTypeChanged({required this.tradingType});

  @override
  List<Object?> get props => [tradingType];
}

/// Event to show pair selection dropdown
class TradingPairDropdownRequested extends TradingHeaderEvent {
  const TradingPairDropdownRequested();
}

/// Event to refresh price data
class TradingPriceDataRequested extends TradingHeaderEvent {
  final String symbol;
  final bool forceRefresh;

  const TradingPriceDataRequested({
    required this.symbol,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [symbol, forceRefresh];
}

/// Event to handle action button taps
class TradingActionRequested extends TradingHeaderEvent {
  final TradingAction action;

  const TradingActionRequested({required this.action});

  @override
  List<Object?> get props => [action];
}

/// Internal event for ticker updates from WebSocket
class _TradingHeaderTickerUpdated extends TradingHeaderEvent {
  final TradingPairData pairData;

  const _TradingHeaderTickerUpdated({
    required this.pairData,
  });

  @override
  List<Object?> get props => [pairData];
}
