import 'package:equatable/equatable.dart';

abstract class FuturesHeaderState extends Equatable {
  const FuturesHeaderState();

  @override
  List<Object?> get props => [];
}

class FuturesHeaderInitial extends FuturesHeaderState {
  const FuturesHeaderInitial();
}

class FuturesHeaderLoading extends FuturesHeaderState {
  const FuturesHeaderLoading();
}

class FuturesHeaderLoaded extends FuturesHeaderState {
  const FuturesHeaderLoaded({
    required this.symbol,
    required this.price,
    required this.changePercent,
    this.currentPrice = 0.0,
    this.availableBalance = 0.0,
    this.fundingRate = 0.0,
    this.fundingCountdown = '00:00:00',
    this.maxLeverage = 100,
    this.takerFee,
    this.makerFee,
  });

  final String symbol;
  final double price;
  final double changePercent;
  final double currentPrice;
  final double availableBalance;
  final double fundingRate;
  final String fundingCountdown;
  final int maxLeverage;
  final double? takerFee;
  final double? makerFee;

  bool get isPositive => changePercent >= 0;

  @override
  List<Object?> get props => [
        symbol,
        price,
        changePercent,
        currentPrice,
        availableBalance,
        fundingRate,
        fundingCountdown,
        maxLeverage,
        takerFee,
        makerFee,
      ];
}

class FuturesHeaderError extends FuturesHeaderState {
  const FuturesHeaderError({required this.message});
  final String message;
  @override
  List<Object?> get props => [message];
}

/// State when backend returns no futures markets – trading disabled
class FuturesHeaderNoMarket extends FuturesHeaderState {
  const FuturesHeaderNoMarket();

  @override
  List<Object?> get props => [];
}
