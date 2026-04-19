part of 'futures_form_bloc.dart';

abstract class FuturesFormState extends Equatable {
  const FuturesFormState();

  @override
  List<Object?> get props => [];
}

class FuturesFormInitial extends FuturesFormState {
  const FuturesFormInitial();
}

class FuturesFormLoading extends FuturesFormState {
  const FuturesFormLoading();
}

class FuturesFormLoaded extends FuturesFormState {
  const FuturesFormLoaded({
    this.orderType = 'market',
    this.side = 'BUY',
    this.amount = 100.0,
    this.price,
    this.leverage = 10.0,
    this.stopLossPrice,
    this.takeProfitPrice,
  });

  final String orderType;
  final String side;
  final double amount;
  final double? price;
  final double leverage;
  final double? stopLossPrice;
  final double? takeProfitPrice;

  @override
  List<Object?> get props => [
        orderType,
        side,
        amount,
        price,
        leverage,
        stopLossPrice,
        takeProfitPrice,
      ];

  FuturesFormLoaded copyWith({
    String? orderType,
    String? side,
    double? amount,
    double? price,
    double? leverage,
    double? stopLossPrice,
    double? takeProfitPrice,
  }) {
    return FuturesFormLoaded(
      orderType: orderType ?? this.orderType,
      side: side ?? this.side,
      amount: amount ?? this.amount,
      price: price ?? this.price,
      leverage: leverage ?? this.leverage,
      stopLossPrice: stopLossPrice ?? this.stopLossPrice,
      takeProfitPrice: takeProfitPrice ?? this.takeProfitPrice,
    );
  }
}

class FuturesFormOrderPlaced extends FuturesFormState {
  const FuturesFormOrderPlaced({required this.order});

  final FuturesOrderEntity order;

  @override
  List<Object?> get props => [order];
}

class FuturesFormLeverageUpdateSuccess extends FuturesFormState {
  const FuturesFormLeverageUpdateSuccess({required this.position});

  final FuturesPositionEntity position;

  @override
  List<Object?> get props => [position];
}

class FuturesFormError extends FuturesFormState {
  const FuturesFormError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
