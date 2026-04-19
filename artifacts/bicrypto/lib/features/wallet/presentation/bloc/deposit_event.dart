part of 'deposit_bloc.dart';

abstract class DepositEvent extends Equatable {
  const DepositEvent();

  @override
  List<Object?> get props => [];
}

class CurrencyOptionsRequested extends DepositEvent {
  const CurrencyOptionsRequested({required this.walletType});

  final String walletType;

  @override
  List<Object?> get props => [walletType];
}

class DepositMethodsRequested extends DepositEvent {
  const DepositMethodsRequested({required this.currency});

  final String currency;

  @override
  List<Object?> get props => [currency];
}

class FiatDepositCreated extends DepositEvent {
  const FiatDepositCreated({
    required this.methodId,
    required this.amount,
    required this.currency,
    required this.customFields,
  });

  final String methodId;
  final double amount;
  final String currency;
  final Map<String, dynamic> customFields;

  @override
  List<Object?> get props => [methodId, amount, currency, customFields];
}

class DepositReset extends DepositEvent {
  const DepositReset();
}

class DepositCreateStripePaymentIntentRequested extends DepositEvent {
  const DepositCreateStripePaymentIntentRequested({
    required this.amount,
    required this.currency,
  });

  final double amount;
  final String currency;

  @override
  List<Object?> get props => [amount, currency];
}

class DepositVerifyStripePaymentRequested extends DepositEvent {
  const DepositVerifyStripePaymentRequested({
    required this.paymentIntentId,
  });

  final String paymentIntentId;

  @override
  List<Object?> get props => [paymentIntentId];
}

// PayPal Events
class DepositCreatePayPalOrderRequested extends DepositEvent {
  const DepositCreatePayPalOrderRequested({
    required this.amount,
    required this.currency,
  });

  final double amount;
  final String currency;

  @override
  List<Object?> get props => [amount, currency];
}

class DepositVerifyPayPalPaymentRequested extends DepositEvent {
  const DepositVerifyPayPalPaymentRequested({
    required this.orderId,
  });

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
