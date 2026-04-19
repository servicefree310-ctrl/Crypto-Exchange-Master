import 'package:equatable/equatable.dart';

abstract class TradeDetailEvent extends Equatable {
  const TradeDetailEvent();
  @override
  List<Object?> get props => [];
}

class TradeDetailRequested extends TradeDetailEvent {
  const TradeDetailRequested(this.tradeId, {this.refresh = false});
  final String tradeId;
  final bool refresh;
  @override
  List<Object?> get props => [tradeId, refresh];
}

class TradeConfirmPaymentRequested extends TradeDetailEvent {
  const TradeConfirmPaymentRequested({
    required this.paymentReference,
    this.paymentProof,
    this.notes,
  });
  final String paymentReference;
  final String? paymentProof;
  final String? notes;
  @override
  List<Object?> get props => [paymentReference, paymentProof, notes];
}

class TradeCancelRequested extends TradeDetailEvent {
  const TradeCancelRequested({required this.reason, this.forceCancel = false});
  final String reason;
  final bool forceCancel;
  @override
  List<Object?> get props => [reason, forceCancel];
}

class TradeReleaseEscrowRequested extends TradeDetailEvent {
  const TradeReleaseEscrowRequested(
      {this.releaseReason, this.partialRelease = false, this.releaseAmount});
  final String? releaseReason;
  final bool partialRelease;
  final double? releaseAmount;
  @override
  List<Object?> get props => [releaseReason, partialRelease, releaseAmount];
}

class TradeDisputeRequested extends TradeDetailEvent {
  const TradeDisputeRequested(
      {required this.reason,
      required this.description,
      this.evidence,
      this.priority});
  final String reason;
  final String description;
  final List<String>? evidence;
  final String? priority;
  @override
  List<Object?> get props => [reason, description, evidence, priority];
}

class TradeReviewSubmitted extends TradeDetailEvent {
  const TradeReviewSubmitted({
    required this.communicationRating,
    required this.speedRating,
    required this.trustRating,
    required this.comment,
    this.isPositive,
  });
  final int communicationRating;
  final int speedRating;
  final int trustRating;
  final String comment;
  final bool? isPositive;
  @override
  List<Object?> get props =>
      [communicationRating, speedRating, trustRating, comment, isPositive];
}

class TradeDetailRetryRequested extends TradeDetailEvent {
  const TradeDetailRetryRequested();
}
