part of 'order_tabs_bloc.dart';

abstract class OrderTabsEvent extends Equatable {
  const OrderTabsEvent();

  @override
  List<Object?> get props => [];
}

class FetchOpenOrders extends OrderTabsEvent {
  const FetchOpenOrders({required this.symbol});
  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class FetchOrderHistory extends OrderTabsEvent {
  const FetchOrderHistory({required this.symbol});
  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class InitializeOrderRealtime extends OrderTabsEvent {
  const InitializeOrderRealtime({required this.symbol});
  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class RealtimeOrderUpdateReceived extends OrderTabsEvent {
  const RealtimeOrderUpdateReceived();
}

class CancelOpenOrder extends OrderTabsEvent {
  const CancelOpenOrder({required this.orderId, required this.symbol});
  final String orderId;
  final String symbol;

  @override
  List<Object?> get props => [orderId, symbol];
}
