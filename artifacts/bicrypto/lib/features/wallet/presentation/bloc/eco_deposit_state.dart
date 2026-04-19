import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/eco_token_entity.dart';
import '../../domain/entities/eco_deposit_address_entity.dart';
import '../../domain/entities/eco_deposit_verification_entity.dart';

abstract class EcoDepositState extends Equatable {
  const EcoDepositState();

  @override
  List<Object?> get props => [];
}

// Initial State
class EcoDepositInitial extends EcoDepositState {
  const EcoDepositInitial();
}

// Loading State
class EcoDepositLoading extends EcoDepositState {
  final String? message;

  const EcoDepositLoading({this.message});

  @override
  List<Object?> get props => [message];
}

// Step 1: Currencies Loaded
class EcoCurrenciesLoaded extends EcoDepositState {
  final List<String> currencies;

  const EcoCurrenciesLoaded({required this.currencies});

  @override
  List<Object> get props => [currencies];
}

// Step 2: Tokens Loaded
class EcoTokensLoaded extends EcoDepositState {
  final List<EcoTokenEntity> tokens;
  final String selectedCurrency;

  const EcoTokensLoaded({
    required this.tokens,
    required this.selectedCurrency,
  });

  @override
  List<Object> get props => [tokens, selectedCurrency];
}

// Step 3: Address Generated
class EcoAddressGenerated extends EcoDepositState {
  final EcoDepositAddressEntity address;
  final EcoTokenEntity selectedToken;
  final bool isLocked; // For NO_PERMIT tracking

  const EcoAddressGenerated({
    required this.address,
    required this.selectedToken,
    required this.isLocked,
  });

  @override
  List<Object> get props => [address, selectedToken, isLocked];
}

// Step 4: Monitoring Active
class EcoDepositMonitoring extends EcoDepositState {
  final String currency;
  final String chain;
  final String address;
  final String contractType;
  final int timeoutMinutes; // Different timeouts per contract type
  final DateTime startTime;

  const EcoDepositMonitoring({
    required this.currency,
    required this.chain,
    required this.address,
    required this.contractType,
    required this.timeoutMinutes,
    required this.startTime,
  });

  @override
  List<Object> get props => [
        currency,
        chain,
        address,
        contractType,
        timeoutMinutes,
        startTime,
      ];

  // Helper getters
  Duration get remainingTime {
    final elapsed = DateTime.now().difference(startTime);
    final timeout = Duration(minutes: timeoutMinutes);
    final remaining = timeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isExpired => remainingTime == Duration.zero;
}

// Step 5: Deposit Verified
class EcoDepositVerified extends EcoDepositState {
  final EcoDepositVerificationEntity verification;
  final double newBalance;

  const EcoDepositVerified({
    required this.verification,
    required this.newBalance,
  });

  @override
  List<Object> get props => [verification, newBalance];
}

// Address Unlocked (NO_PERMIT)
class EcoAddressUnlocked extends EcoDepositState {
  final String address;

  const EcoAddressUnlocked({required this.address});

  @override
  List<Object> get props => [address];
}

// Error State
class EcoDepositError extends EcoDepositState {
  final Failure failure;
  final String? context; // Additional context about where error occurred

  const EcoDepositError({
    required this.failure,
    this.context,
  });

  @override
  List<Object?> get props => [failure, context];

  String get displayMessage {
    if (context != null) {
      return '$context: ${failure.message}';
    }
    return failure.message;
  }
}

// Timeout State
class EcoDepositTimeout extends EcoDepositState {
  final String contractType;
  final int timeoutMinutes;

  const EcoDepositTimeout({
    required this.contractType,
    required this.timeoutMinutes,
  });

  @override
  List<Object> get props => [contractType, timeoutMinutes];

  String get timeoutMessage {
    switch (contractType) {
      case 'NO_PERMIT':
        return 'Deposit monitoring timed out after $timeoutMinutes minutes. The address has been unlocked automatically.';
      case 'PERMIT':
      case 'NATIVE':
        return 'Deposit monitoring timed out after $timeoutMinutes minutes. Please try again or contact support.';
      default:
        return 'Deposit monitoring timed out after $timeoutMinutes minutes.';
    }
  }
}
