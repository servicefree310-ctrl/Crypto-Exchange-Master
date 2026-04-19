part of 'futures_form_bloc.dart';

abstract class FuturesFormEvent extends Equatable {
  const FuturesFormEvent();

  @override
  List<Object?> get props => [];
}

class FuturesFormInitialized extends FuturesFormEvent {
  const FuturesFormInitialized({required this.symbol});

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class FuturesFormOrderTypeChanged extends FuturesFormEvent {
  const FuturesFormOrderTypeChanged(this.orderType);

  final String orderType;

  @override
  List<Object?> get props => [orderType];
}

class FuturesFormSideChanged extends FuturesFormEvent {
  const FuturesFormSideChanged(this.side);

  final String side;

  @override
  List<Object?> get props => [side];
}

class FuturesFormAmountChanged extends FuturesFormEvent {
  const FuturesFormAmountChanged(this.amount);

  final double amount;

  @override
  List<Object?> get props => [amount];
}

class FuturesFormPriceChanged extends FuturesFormEvent {
  const FuturesFormPriceChanged(this.price);

  final double? price;

  @override
  List<Object?> get props => [price];
}

class FuturesFormLeverageChanged extends FuturesFormEvent {
  const FuturesFormLeverageChanged(this.leverage);

  final double leverage;

  @override
  List<Object?> get props => [leverage];
}

class FuturesFormStopLossChanged extends FuturesFormEvent {
  const FuturesFormStopLossChanged(this.stopLossPrice);

  final double? stopLossPrice;

  @override
  List<Object?> get props => [stopLossPrice];
}

class FuturesFormTakeProfitChanged extends FuturesFormEvent {
  const FuturesFormTakeProfitChanged(this.takeProfitPrice);

  final double? takeProfitPrice;

  @override
  List<Object?> get props => [takeProfitPrice];
}

class FuturesFormOrderSubmitted extends FuturesFormEvent {
  const FuturesFormOrderSubmitted({
    required this.currency,
    required this.pair,
  });

  final String currency;
  final String pair;

  @override
  List<Object?> get props => [currency, pair];
}

class FuturesFormSubmitted extends FuturesFormEvent {
  const FuturesFormSubmitted(this.orderData);

  final Map<String, dynamic> orderData;

  @override
  List<Object?> get props => [orderData];
}

class FuturesFormLeverageUpdated extends FuturesFormEvent {
  const FuturesFormLeverageUpdated({
    required this.symbol,
    required this.leverage,
  });

  final String symbol;
  final double leverage;

  @override
  List<Object?> get props => [symbol, leverage];
}
