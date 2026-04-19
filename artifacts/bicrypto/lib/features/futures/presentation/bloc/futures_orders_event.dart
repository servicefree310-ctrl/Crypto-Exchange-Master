part of 'futures_orders_bloc.dart';

abstract class FuturesOrdersEvent extends Equatable {
  const FuturesOrdersEvent();

  @override
  List<Object?> get props => [];
}

class FuturesOrdersLoadRequested extends FuturesOrdersEvent {
  const FuturesOrdersLoadRequested({required this.symbol});

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class FuturesOrdersRefreshRequested extends FuturesOrdersEvent {
  const FuturesOrdersRefreshRequested({required this.symbol});

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class FuturesOrdersFilterChanged extends FuturesOrdersEvent {
  const FuturesOrdersFilterChanged(this.filter);

  final OrderStatusFilter filter;

  @override
  List<Object?> get props => [filter];
}

class FuturesOrderCancelRequested extends FuturesOrdersEvent {
  const FuturesOrderCancelRequested({
    required this.orderId,
    required this.symbol,
    required this.createdAt,
  });

  final String orderId;
  final String symbol;
  final DateTime createdAt;

  @override
  List<Object?> get props => [orderId, symbol, createdAt];
}
