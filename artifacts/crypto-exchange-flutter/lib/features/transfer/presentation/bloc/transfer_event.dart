import 'package:equatable/equatable.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => [];
}

class TransferInitialized extends TransferEvent {
  const TransferInitialized();
}

class TransferTypeSelected extends TransferEvent {
  final String transferType; // "wallet" or "client"

  const TransferTypeSelected({required this.transferType});

  @override
  List<Object?> get props => [transferType];
}

class SourceWalletSelected extends TransferEvent {
  final String walletType; // FIAT, SPOT, ECO, FUTURES

  const SourceWalletSelected({required this.walletType});

  @override
  List<Object?> get props => [walletType];
}

class SourceCurrencySelected extends TransferEvent {
  final String currency;

  const SourceCurrencySelected({required this.currency});

  @override
  List<Object?> get props => [currency];
}

class DestinationWalletSelected extends TransferEvent {
  final String walletType;

  const DestinationWalletSelected({required this.walletType});

  @override
  List<Object?> get props => [walletType];
}

class DestinationCurrencySelected extends TransferEvent {
  final String currency;

  const DestinationCurrencySelected({required this.currency});

  @override
  List<Object?> get props => [currency];
}

class RecipientChanged extends TransferEvent {
  final String recipientId;

  const RecipientChanged({required this.recipientId});

  @override
  List<Object?> get props => [recipientId];
}

class TransferAmountChanged extends TransferEvent {
  final double amount;

  const TransferAmountChanged({required this.amount});

  @override
  List<Object?> get props => [amount];
}

class TransferSubmitted extends TransferEvent {
  const TransferSubmitted();
}

class TransferReset extends TransferEvent {
  const TransferReset();
}

class TransferStepChanged extends TransferEvent {
  final int step;

  const TransferStepChanged({required this.step});

  @override
  List<Object?> get props => [step];
}

class FetchBalanceRequested extends TransferEvent {
  final String walletType;
  final String currency;

  const FetchBalanceRequested({
    required this.walletType,
    required this.currency,
  });

  @override
  List<Object?> get props => [walletType, currency];
}

class ContinueToAmountRequested extends TransferEvent {
  const ContinueToAmountRequested();
}
