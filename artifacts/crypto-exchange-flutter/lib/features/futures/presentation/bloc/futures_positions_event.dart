part of 'futures_positions_bloc.dart';

abstract class FuturesPositionsEvent extends Equatable {
  const FuturesPositionsEvent();

  @override
  List<Object?> get props => [];
}

class FuturesPositionsLoadRequested extends FuturesPositionsEvent {
  const FuturesPositionsLoadRequested({required this.symbol});

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class FuturesPositionsRefreshRequested extends FuturesPositionsEvent {
  const FuturesPositionsRefreshRequested({required this.symbol});

  final String symbol;

  @override
  List<Object?> get props => [symbol];
}

class FuturesPositionCloseRequested extends FuturesPositionsEvent {
  const FuturesPositionCloseRequested({
    required this.positionId,
    required this.symbol,
    required this.side,
  });

  final String positionId;
  final String symbol;
  final String side;

  @override
  List<Object?> get props => [positionId, symbol, side];
}
