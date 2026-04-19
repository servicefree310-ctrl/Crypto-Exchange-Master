import 'package:equatable/equatable.dart';
import '../../../domain/entities/payment_method_entity.dart';
import '../../../../../../../core/errors/failures.dart';

abstract class PaymentMethodsState extends Equatable {
  const PaymentMethodsState();
  @override
  List<Object?> get props => [];
}

class PaymentMethodsInitial extends PaymentMethodsState {
  const PaymentMethodsInitial();
}

class PaymentMethodsLoading extends PaymentMethodsState {
  const PaymentMethodsLoading({this.isRefresh = false});
  final bool isRefresh;
  @override
  List<Object?> get props => [isRefresh];
}

class PaymentMethodsLoaded extends PaymentMethodsState {
  const PaymentMethodsLoaded(this.methods);
  final List<PaymentMethodEntity> methods;
  @override
  List<Object?> get props => [methods];
}

class PaymentMethodsError extends PaymentMethodsState {
  const PaymentMethodsError(this.failure);
  final Failure failure;
  @override
  List<Object?> get props => [failure];
}
