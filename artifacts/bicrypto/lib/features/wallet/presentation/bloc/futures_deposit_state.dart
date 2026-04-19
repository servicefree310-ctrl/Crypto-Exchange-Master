import 'package:equatable/equatable.dart';

import '../../domain/entities/eco_token_entity.dart';
import '../../domain/entities/eco_deposit_address_entity.dart';
import '../../domain/entities/eco_deposit_verification_entity.dart';
import '../../../../core/errors/failures.dart';

/// Base class for all FUTURES deposit states
abstract class FuturesDepositState extends Equatable {
  const FuturesDepositState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class FuturesDepositInitial extends FuturesDepositState {
  const FuturesDepositInitial();
}

/// Loading state
class FuturesDepositLoading extends FuturesDepositState {
  final String? message;

  const FuturesDepositLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// State when currencies are loaded
class FuturesDepositCurrenciesLoaded extends FuturesDepositState {
  final List<EcoTokenEntity> currencies;

  const FuturesDepositCurrenciesLoaded({required this.currencies});

  @override
  List<Object> get props => [currencies];
}

/// State when tokens are loaded
class FuturesDepositTokensLoaded extends FuturesDepositState {
  final List<EcoTokenEntity> tokens;
  final String selectedCurrency;

  const FuturesDepositTokensLoaded({
    required this.tokens,
    required this.selectedCurrency,
  });

  @override
  List<Object> get props => [tokens, selectedCurrency];
}

/// State when address is generated
class FuturesDepositAddressGenerated extends FuturesDepositState {
  final EcoDepositAddressEntity address;
  final String selectedCurrency;
  final String selectedChain;
  final String contractType;

  const FuturesDepositAddressGenerated({
    required this.address,
    required this.selectedCurrency,
    required this.selectedChain,
    required this.contractType,
  });

  @override
  List<Object> get props =>
      [address, selectedCurrency, selectedChain, contractType];
}

/// State when monitoring deposits
class FuturesDepositMonitoring extends FuturesDepositState {
  final String currency;
  final String chain;
  final String address;
  final String contractType;
  final DateTime startTime;

  const FuturesDepositMonitoring({
    required this.currency,
    required this.chain,
    required this.address,
    required this.contractType,
    required this.startTime,
  });

  @override
  List<Object> get props => [currency, chain, address, contractType, startTime];
}

/// State when deposit is completed successfully
class FuturesDepositCompleted extends FuturesDepositState {
  final EcoDepositVerificationEntity verification;
  final String currency;
  final String chain;

  const FuturesDepositCompleted({
    required this.verification,
    required this.currency,
    required this.chain,
  });

  @override
  List<Object> get props => [verification, currency, chain];
}

/// Error state
class FuturesDepositError extends FuturesDepositState {
  final Failure failure;
  final String? previousStep;

  const FuturesDepositError({
    required this.failure,
    this.previousStep,
  });

  @override
  List<Object?> get props => [failure, previousStep];
}
