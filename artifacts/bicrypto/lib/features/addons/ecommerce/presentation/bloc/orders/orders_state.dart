import 'package:equatable/equatable.dart';
import '../../../domain/entities/order_entity.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  final List<OrderEntity> filteredOrders;
  final OrderStatus? selectedStatus;

  const OrdersLoaded({
    required this.orders,
    required this.filteredOrders,
    this.selectedStatus,
  });

  @override
  List<Object?> get props => [orders, filteredOrders, selectedStatus];

  OrdersLoaded copyWith({
    List<OrderEntity>? orders,
    List<OrderEntity>? filteredOrders,
    OrderStatus? selectedStatus,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      selectedStatus: selectedStatus,
    );
  }
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError({required this.message});

  @override
  List<Object?> get props => [message];
}

class TrackingLoading extends OrdersState {
  const TrackingLoading();
}

class TrackingLoaded extends OrdersState {
  const TrackingLoaded(this.data);
  final dynamic data;
  @override
  List<Object?> get props => [data];
}

class Downloading extends OrdersState {
  const Downloading();
}

class DownloadSuccess extends OrdersState {
  const DownloadSuccess(this.url);
  final String url;
  @override
  List<Object?> get props => [url];
}
