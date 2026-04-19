part of 'futures_orderbook_bloc.dart';

abstract class FuturesOrderBookState extends Equatable {
  const FuturesOrderBookState();

  @override
  List<Object?> get props => [];
}

class FuturesOrderBookInitial extends FuturesOrderBookState {
  const FuturesOrderBookInitial();
}

class FuturesOrderBookLoading extends FuturesOrderBookState {
  const FuturesOrderBookLoading();
}

class FuturesOrderBookConnected extends FuturesOrderBookState {
  const FuturesOrderBookConnected();
}

class FuturesOrderBookLoaded extends FuturesOrderBookState {
  const FuturesOrderBookLoaded({required this.orderBookData});

  final OrderBookData orderBookData;

  @override
  List<Object?> get props => [orderBookData];
}

class FuturesOrderBookDisconnected extends FuturesOrderBookState {
  const FuturesOrderBookDisconnected();
}

class FuturesOrderBookError extends FuturesOrderBookState {
  const FuturesOrderBookError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
