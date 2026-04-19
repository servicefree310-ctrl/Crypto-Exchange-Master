import 'package:equatable/equatable.dart';
import '../../../domain/entities/order_entity.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrdersRequested extends OrdersEvent {
  const LoadOrdersRequested();
}

class FilterOrdersRequested extends OrdersEvent {
  final OrderStatus? status;

  const FilterOrdersRequested({this.status});

  @override
  List<Object?> get props => [status];
}
