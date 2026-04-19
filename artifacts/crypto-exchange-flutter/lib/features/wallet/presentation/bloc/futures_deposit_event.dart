import 'package:equatable/equatable.dart';

/// Base class for all FUTURES deposit events
abstract class FuturesDepositEvent extends Equatable {
  const FuturesDepositEvent();

  @override
  List<Object?> get props => [];
}

/// Event to fetch available FUTURES currencies
class FuturesDepositCurrenciesRequested extends FuturesDepositEvent {
  const FuturesDepositCurrenciesRequested();
}

/// Event to fetch available tokens for a FUTURES currency
class FuturesDepositTokensRequested extends FuturesDepositEvent {
  final String currency;

  const FuturesDepositTokensRequested({required this.currency});

  @override
  List<Object> get props => [currency];
}

/// Event to generate FUTURES deposit address
class FuturesDepositAddressRequested extends FuturesDepositEvent {
  final String currency;
  final String chain;
  final String contractType;

  const FuturesDepositAddressRequested({
    required this.currency,
    required this.chain,
    required this.contractType,
  });

  @override
  List<Object> get props => [currency, chain, contractType];
}

/// Event to start monitoring FUTURES deposits
class FuturesDepositMonitoringStarted extends FuturesDepositEvent {
  final String currency;
  final String chain;
  final String address;
  final String contractType;

  const FuturesDepositMonitoringStarted({
    required this.currency,
    required this.chain,
    required this.address,
    required this.contractType,
  });

  @override
  List<Object> get props => [currency, chain, address, contractType];
}

/// Event to complete FUTURES deposit
class FuturesDepositCompletionRequested extends FuturesDepositEvent {
  const FuturesDepositCompletionRequested();
}

/// Event to retry failed operations
class FuturesDepositRetryRequested extends FuturesDepositEvent {
  const FuturesDepositRetryRequested();
}

/// Event to reset to initial state
class FuturesDepositReset extends FuturesDepositEvent {
  const FuturesDepositReset();
}
