import 'package:equatable/equatable.dart';

abstract class PaymentMethodsEvent extends Equatable {
  const PaymentMethodsEvent();
  @override
  List<Object?> get props => [];
}

class PaymentMethodsRequested extends PaymentMethodsEvent {
  const PaymentMethodsRequested({this.refresh = false});
  final bool refresh;
  @override
  List<Object?> get props => [refresh];
}

class CreatePaymentMethodRequested extends PaymentMethodsEvent {
  const CreatePaymentMethodRequested(this.params);
  final Map<String, dynamic> params;
  @override
  List<Object?> get props => [params];
}

class UpdatePaymentMethodRequested extends PaymentMethodsEvent {
  const UpdatePaymentMethodRequested({required this.id, required this.data});
  final String id;
  final Map<String, dynamic> data;
  @override
  List<Object?> get props => [id, data];
}

class DeletePaymentMethodRequested extends PaymentMethodsEvent {
  const DeletePaymentMethodRequested(this.id);
  final String id;
  @override
  List<Object?> get props => [id];
}
