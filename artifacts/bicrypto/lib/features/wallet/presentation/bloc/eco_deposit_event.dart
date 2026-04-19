import 'package:equatable/equatable.dart';
import '../../domain/entities/eco_token_entity.dart';
import '../../domain/entities/eco_deposit_verification_entity.dart';

abstract class EcoDepositEvent extends Equatable {
  const EcoDepositEvent();

  @override
  List<Object?> get props => [];
}

// Step 1: Currency Selection
class EcoDepositCurrenciesRequested extends EcoDepositEvent {
  const EcoDepositCurrenciesRequested();
}

// Step 2: Token Selection
class EcoDepositTokensRequested extends EcoDepositEvent {
  final String currency;

  const EcoDepositTokensRequested({required this.currency});

  @override
  List<Object> get props => [currency];
}

// Step 3: Address Generation
class EcoDepositAddressRequested extends EcoDepositEvent {
  final String currency;
  final String chain;
  final String contractType;
  final EcoTokenEntity token;

  const EcoDepositAddressRequested({
    required this.currency,
    required this.chain,
    required this.contractType,
    required this.token,
  });

  @override
  List<Object> get props => [currency, chain, contractType, token];
}

// Step 4: Monitoring Start
class EcoDepositMonitoringStarted extends EcoDepositEvent {
  final String currency;
  final String chain;
  final String address;
  final String contractType;

  const EcoDepositMonitoringStarted({
    required this.currency,
    required this.chain,
    required this.address,
    required this.contractType,
  });

  @override
  List<Object> get props => [currency, chain, address, contractType];
}

// Address Unlock for NO_PERMIT
class EcoDepositAddressUnlocked extends EcoDepositEvent {
  final String address;

  const EcoDepositAddressUnlocked({required this.address});

  @override
  List<Object> get props => [address];
}

// Verification Received
class EcoDepositVerificationReceived extends EcoDepositEvent {
  final EcoDepositVerificationEntity verification;

  const EcoDepositVerificationReceived({required this.verification});

  @override
  List<Object> get props => [verification];
}

// Reset State
class EcoDepositReset extends EcoDepositEvent {
  const EcoDepositReset();
}

// Retry Events
class EcoDepositRetryRequested extends EcoDepositEvent {
  const EcoDepositRetryRequested();
}

// Monitoring Stop
class EcoDepositMonitoringStopped extends EcoDepositEvent {
  const EcoDepositMonitoringStopped();
}
