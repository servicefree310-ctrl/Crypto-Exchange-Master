import 'package:equatable/equatable.dart';

abstract class FuturesHeaderEvent extends Equatable {
  const FuturesHeaderEvent();

  @override
  List<Object?> get props => [];
}

class FuturesHeaderInitialized extends FuturesHeaderEvent {
  const FuturesHeaderInitialized({this.symbol});

  final String? symbol;

  @override
  List<Object?> get props => [symbol];
}

class FuturesHeaderSymbolChanged extends FuturesHeaderEvent {
  const FuturesHeaderSymbolChanged({required this.symbol});

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class FuturesTickerUpdated extends FuturesHeaderEvent {
  const FuturesTickerUpdated({
    required this.price,
    required this.changePercent,
  });

  final double price;
  final double changePercent;

  @override
  List<Object?> get props => [price, changePercent];
}
