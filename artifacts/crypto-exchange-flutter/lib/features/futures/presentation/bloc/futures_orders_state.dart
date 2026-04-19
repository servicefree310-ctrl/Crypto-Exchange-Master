part of 'futures_orders_bloc.dart';

enum OrderStatusFilter { all, open, filled, cancelled }

abstract class FuturesOrdersState extends Equatable {
  const FuturesOrdersState();

  @override
  List<Object?> get props => [];
}

class FuturesOrdersInitial extends FuturesOrdersState {
  const FuturesOrdersInitial();
}

class FuturesOrdersLoading extends FuturesOrdersState {
  const FuturesOrdersLoading();
}

class FuturesOrdersLoaded extends FuturesOrdersState {
  const FuturesOrdersLoaded({
    required this.orders,
    this.filter = OrderStatusFilter.all,
    this.cancellingOrderId,
    this.error,
    this.successMessage,
  });

  final List<FuturesOrderEntity> orders;
  final OrderStatusFilter filter;
  final String? cancellingOrderId;
  final String? error;
  final String? successMessage;

  List<FuturesOrderEntity> get allOrders => orders;

  List<FuturesOrderEntity> get filteredOrders {
    switch (filter) {
      case OrderStatusFilter.all:
        return orders;
      case OrderStatusFilter.open:
        return orders.where((order) => order.status == 'OPEN').toList();
      case OrderStatusFilter.filled:
        return orders.where((order) => order.status == 'FILLED').toList();
      case OrderStatusFilter.cancelled:
        return orders
            .where((order) =>
                order.status == 'CANCELLED' || order.status == 'REJECTED')
            .toList();
    }
  }

  int get openCount => orders.where((order) => order.status == 'OPEN').length;
  int get filledCount =>
      orders.where((order) => order.status == 'FILLED').length;
  int get cancelledCount => orders
      .where(
          (order) => order.status == 'CANCELLED' || order.status == 'REJECTED')
      .length;

  @override
  List<Object?> get props =>
      [orders, filter, cancellingOrderId, error, successMessage];
}

class FuturesOrdersError extends FuturesOrdersState {
  const FuturesOrdersError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
