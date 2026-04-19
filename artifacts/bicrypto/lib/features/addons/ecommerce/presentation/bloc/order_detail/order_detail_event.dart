import 'package:equatable/equatable.dart';

abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderDetailRequested extends OrderDetailEvent {
  final String orderId;

  const LoadOrderDetailRequested({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
