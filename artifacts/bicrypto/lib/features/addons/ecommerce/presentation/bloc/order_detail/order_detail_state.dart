import 'package:equatable/equatable.dart';
import '../../../domain/entities/order_entity.dart';

abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

class OrderDetailInitial extends OrderDetailState {
  const OrderDetailInitial();
}

class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderDetailState {
  final OrderEntity order;

  const OrderDetailLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderDetailError extends OrderDetailState {
  final String message;

  const OrderDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
