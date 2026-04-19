import 'package:equatable/equatable.dart';

abstract class AiInvestmentEvent extends Equatable {
  const AiInvestmentEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load AI investment plans
class AiInvestmentPlansLoadRequested extends AiInvestmentEvent {
  const AiInvestmentPlansLoadRequested();
}

/// Event to load user's AI investments
class AiInvestmentUserInvestmentsLoadRequested extends AiInvestmentEvent {
  const AiInvestmentUserInvestmentsLoadRequested({
    this.status,
    this.type,
    this.limit,
    this.offset,
  });

  final String? status;
  final String? type;
  final int? limit;
  final int? offset;

  @override
  List<Object?> get props => [status, type, limit, offset];
}

/// Event to create a new AI investment
class AiInvestmentCreateRequested extends AiInvestmentEvent {
  const AiInvestmentCreateRequested({
    required this.planId,
    required this.durationId,
    required this.symbol,
    required this.amount,
    required this.walletType,
  });

  final String planId;
  final String durationId;
  final String symbol;
  final double amount;
  final String walletType;

  @override
  List<Object?> get props => [planId, durationId, symbol, amount, walletType];
}

/// Event to cancel an AI investment
class AiInvestmentCancelRequested extends AiInvestmentEvent {
  const AiInvestmentCancelRequested({
    required this.investmentId,
  });

  final String investmentId;

  @override
  List<Object?> get props => [investmentId];
}

/// Event to refresh AI investment data
class AiInvestmentRefreshRequested extends AiInvestmentEvent {
  const AiInvestmentRefreshRequested();
}

/// Event to reset AI investment state
class AiInvestmentResetRequested extends AiInvestmentEvent {
  const AiInvestmentResetRequested();
}
