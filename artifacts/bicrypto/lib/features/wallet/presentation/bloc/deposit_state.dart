part of 'deposit_bloc.dart';

abstract class DepositState extends Equatable {
  const DepositState();

  @override
  List<Object?> get props => [];
}

class DepositInitial extends DepositState {
  const DepositInitial();
}

class DepositLoading extends DepositState {
  const DepositLoading();
}

class CurrencyOptionsLoaded extends DepositState {
  const CurrencyOptionsLoaded({
    required this.currencies,
  });

  final List<CurrencyOptionEntity> currencies;

  @override
  List<Object?> get props => [currencies];
}

class DepositMethodsLoaded extends DepositState {
  const DepositMethodsLoaded({
    required this.gateways,
    required this.methods,
  });

  final List<DepositGatewayEntity> gateways;
  final List<DepositMethodEntity> methods;

  @override
  List<Object?> get props => [gateways, methods];
}

class DepositCreating extends DepositState {
  const DepositCreating();
}

class DepositCreated extends DepositState {
  const DepositCreated({required this.transaction});

  final DepositTransactionEntity transaction;

  @override
  List<Object?> get props => [transaction];
}

class DepositError extends DepositState {
  const DepositError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

class DepositStripePaymentIntentCreated extends DepositState {
  const DepositStripePaymentIntentCreated({
    required this.paymentIntentId,
    required this.clientSecret,
  });

  final String paymentIntentId;
  final String clientSecret;

  @override
  List<Object?> get props => [paymentIntentId, clientSecret];
}

class DepositStripePaymentVerified extends DepositState {
  const DepositStripePaymentVerified({required this.transaction});

  final DepositTransactionEntity transaction;

  @override
  List<Object?> get props => [transaction];
}

// PayPal States
class DepositPayPalOrderCreated extends DepositState {
  const DepositPayPalOrderCreated({
    required this.orderId,
    required this.approvalUrl,
  });

  final String orderId;
  final String approvalUrl;

  @override
  List<Object?> get props => [orderId, approvalUrl];
}

class DepositPayPalPaymentVerified extends DepositState {
  const DepositPayPalPaymentVerified({required this.transaction});

  final DepositTransactionEntity transaction;

  @override
  List<Object?> get props => [transaction];
}
