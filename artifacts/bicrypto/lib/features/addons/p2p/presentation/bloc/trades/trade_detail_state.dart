import 'package:equatable/equatable.dart';
import '../../../domain/entities/p2p_trade_entity.dart';
import '../../../domain/entities/p2p_dispute_entity.dart';
import '../../../domain/entities/p2p_review_entity.dart';
import '../../../../../../../core/errors/failures.dart';

abstract class TradeDetailState extends Equatable {
  const TradeDetailState();
  @override
  List<Object?> get props => [];
}

class TradeDetailInitial extends TradeDetailState {
  const TradeDetailInitial();
}

class TradeDetailLoading extends TradeDetailState {
  const TradeDetailLoading(this.tradeId, {this.isRefresh = false});
  final String tradeId;
  final bool isRefresh;
  @override
  List<Object?> get props => [tradeId, isRefresh];
}

class TradeDetailLoaded extends TradeDetailState {
  const TradeDetailLoaded(this.trade);
  final P2PTradeEntity trade;
  @override
  List<Object?> get props => [trade];
}

class TradeDetailError extends TradeDetailState {
  const TradeDetailError(this.failure, this.tradeId);
  final Failure failure;
  final String tradeId;
  @override
  List<Object?> get props => [failure, tradeId];
}

class TradeActionInProgress extends TradeDetailState {
  const TradeActionInProgress(this.trade);
  final P2PTradeEntity trade;
  @override
  List<Object?> get props => [trade];
}

class TradeActionSuccess extends TradeDetailState {
  const TradeActionSuccess(this.trade, {this.review, this.dispute});
  final P2PTradeEntity trade;
  final P2PReviewEntity? review;
  final P2PDisputeEntity? dispute;
  @override
  List<Object?> get props => [trade, review, dispute];
}

class TradeActionFailure extends TradeDetailState {
  const TradeActionFailure(this.failure, this.trade);
  final Failure failure;
  final P2PTradeEntity? trade;
  @override
  List<Object?> get props => [failure, trade];
}
