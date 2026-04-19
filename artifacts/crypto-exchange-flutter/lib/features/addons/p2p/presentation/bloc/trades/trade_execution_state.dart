import 'package:equatable/equatable.dart';
import '../../../../../../../core/errors/failures.dart';
import '../../../domain/entities/p2p_trade_entity.dart';

abstract class TradeExecutionState extends Equatable {
  const TradeExecutionState();

  @override
  List<Object?> get props => [];
}

class TradeExecutionInitial extends TradeExecutionState {
  const TradeExecutionInitial();
}

class TradeExecutionLoading extends TradeExecutionState {
  const TradeExecutionLoading();
}

class TradeExecutionSuccess extends TradeExecutionState {
  const TradeExecutionSuccess({
    this.trade,
    required this.message,
  });

  final P2PTradeEntity? trade;
  final String message;

  @override
  List<Object?> get props => [trade, message];
}

class TradeExecutionError extends TradeExecutionState {
  const TradeExecutionError({
    required this.failure,
  });

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
