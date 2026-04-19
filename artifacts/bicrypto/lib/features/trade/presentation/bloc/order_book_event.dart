part of 'order_book_bloc.dart';

abstract class OrderBookEvent extends Equatable {
  const OrderBookEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize order book with symbol
class OrderBookInitialized extends OrderBookEvent {
  final String symbol;

  const OrderBookInitialized({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Event to load order book data
class OrderBookDataRequested extends OrderBookEvent {
  final String symbol;
  final bool forceRefresh;

  const OrderBookDataRequested({
    required this.symbol,
    this.forceRefresh = false,
  });

  @override
  List<Object?> get props => [symbol, forceRefresh];
}

/// Event to handle real-time order book updates
class OrderBookRealtimeDataReceived extends OrderBookEvent {
  final OrderBookData orderBookData;

  const OrderBookRealtimeDataReceived({required this.orderBookData});

  @override
  List<Object?> get props => [orderBookData];
}

/// Event to handle current price updates (from ticker stream)
class OrderBookPriceUpdated extends OrderBookEvent {
  final double currentPrice;
  final Color currentPriceColor;

  const OrderBookPriceUpdated(
      {required this.currentPrice, required this.currentPriceColor});

  @override
  List<Object?> get props => [currentPrice, currentPriceColor];
}

/// Event to change symbol
class OrderBookSymbolChanged extends OrderBookEvent {
  final String symbol;

  const OrderBookSymbolChanged({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Event to handle order book entry selection
class OrderBookEntrySelected extends OrderBookEvent {
  final OrderBookEntry entry;
  final OrderBookSide side;

  const OrderBookEntrySelected({
    required this.entry,
    required this.side,
  });

  @override
  List<Object?> get props => [entry, side];
}

/// Event to refresh order book
class OrderBookRefreshRequested extends OrderBookEvent {
  final String symbol;

  const OrderBookRefreshRequested({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}

/// Event to reset order book state
class OrderBookReset extends OrderBookEvent {
  const OrderBookReset();
}

/// Event to cleanup order book without disconnecting shared WebSocket
class OrderBookCleanupRequested extends OrderBookEvent {
  const OrderBookCleanupRequested();
}
