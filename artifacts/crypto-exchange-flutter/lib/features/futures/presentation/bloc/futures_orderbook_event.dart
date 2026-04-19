part of 'futures_orderbook_bloc.dart';

abstract class FuturesOrderBookEvent extends Equatable {
  const FuturesOrderBookEvent();

  @override
  List<Object?> get props => [];
}

class FuturesOrderBookConnectRequested extends FuturesOrderBookEvent {
  const FuturesOrderBookConnectRequested({required this.symbol});

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class FuturesOrderBookDisconnectRequested extends FuturesOrderBookEvent {
  const FuturesOrderBookDisconnectRequested();
}

class FuturesOrderBookDataReceived extends FuturesOrderBookEvent {
  const FuturesOrderBookDataReceived(this.orderBookData);

  final OrderBookData orderBookData;

  @override
  List<Object?> get props => [orderBookData];
}

class FuturesOrderBookErrorOccurred extends FuturesOrderBookEvent {
  const FuturesOrderBookErrorOccurred(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}
