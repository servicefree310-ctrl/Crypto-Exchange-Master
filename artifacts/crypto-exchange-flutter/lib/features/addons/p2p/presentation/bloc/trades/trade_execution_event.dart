import 'package:equatable/equatable.dart';

abstract class TradeExecutionEvent extends Equatable {
  const TradeExecutionEvent();

  @override
  List<Object?> get props => [];
}

class TradeInitiateRequested extends TradeExecutionEvent {
  const TradeInitiateRequested({
    required this.offerId,
    required this.amount,
    required this.paymentMethodId,
    this.notes,
  });

  final String offerId;
  final double amount;
  final String paymentMethodId;
  final String? notes;

  @override
  List<Object?> get props => [offerId, amount, paymentMethodId, notes];
}

class TradeConfirmRequested extends TradeExecutionEvent {
  const TradeConfirmRequested({
    required this.tradeId,
    required this.confirmationType,
    this.proofOfPayment,
  });

  final String tradeId;
  final String confirmationType; // 'payment_sent' or 'payment_received'
  final String? proofOfPayment; // Proof of payment URL

  @override
  List<Object?> get props => [tradeId, confirmationType, proofOfPayment];
}

class TradeCancelRequested extends TradeExecutionEvent {
  const TradeCancelRequested({
    required this.tradeId,
    required this.reason,
  });

  final String tradeId;
  final String reason;

  @override
  List<Object?> get props => [tradeId, reason];
}

class TradeEscrowReleaseRequested extends TradeExecutionEvent {
  const TradeEscrowReleaseRequested({
    required this.tradeId,
  });

  final String tradeId;

  @override
  List<Object?> get props => [tradeId];
}

class TradeDisputeRequested extends TradeExecutionEvent {
  const TradeDisputeRequested({
    required this.tradeId,
    required this.reason,
    required this.description,
    this.evidence,
  });

  final String tradeId;
  final String reason;
  final String description;
  final List<String>? evidence; // Evidence images/documents

  @override
  List<Object?> get props => [tradeId, reason, description, evidence];
}

class TradeExecutionReset extends TradeExecutionEvent {
  const TradeExecutionReset();
}
