part of 'order_tabs_bloc.dart';

abstract class OrderTabsState extends Equatable {
  const OrderTabsState();
  @override
  List<Object?> get props => [];
}

class OrderTabsInitial extends OrderTabsState {
  const OrderTabsInitial();
}

class OrderTabsLoading extends OrderTabsState {
  const OrderTabsLoading();
}

class OrderTabsError extends OrderTabsState {
  const OrderTabsError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

class OpenOrdersLoaded extends OrderTabsState {
  const OpenOrdersLoaded({required this.orders});
  final List<OrderEntity> orders;
  @override
  List<Object?> get props => [orders];
}

class OrderHistoryLoaded extends OrderTabsState {
  const OrderHistoryLoaded({required this.orders});
  final List<OrderEntity> orders;
  @override
  List<Object?> get props => [orders];
}
