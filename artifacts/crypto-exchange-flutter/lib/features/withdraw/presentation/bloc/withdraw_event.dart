import 'package:equatable/equatable.dart';

abstract class WithdrawEvent extends Equatable {
  const WithdrawEvent();

  @override
  List<Object?> get props => [];
}

class WithdrawInitialized extends WithdrawEvent {
  const WithdrawInitialized();
}

class WalletTypeSelected extends WithdrawEvent {
  final String walletType;

  const WalletTypeSelected({required this.walletType});

  @override
  List<Object?> get props => [walletType];
}

class CurrencySelected extends WithdrawEvent {
  final String currency;

  const CurrencySelected({required this.currency});

  @override
  List<Object?> get props => [currency];
}

class WithdrawMethodSelected extends WithdrawEvent {
  final String methodId;

  const WithdrawMethodSelected({required this.methodId});

  @override
  List<Object?> get props => [methodId];
}

class WithdrawAmountChanged extends WithdrawEvent {
  final String amount;

  const WithdrawAmountChanged({required this.amount});

  @override
  List<Object?> get props => [amount];
}

class CustomFieldChanged extends WithdrawEvent {
  final String fieldName;
  final dynamic value;

  const CustomFieldChanged({
    required this.fieldName,
    required this.value,
  });

  @override
  List<Object?> get props => [fieldName, value];
}

class WithdrawSubmitted extends WithdrawEvent {
  const WithdrawSubmitted();
}

class WithdrawReset extends WithdrawEvent {
  const WithdrawReset();
}

class NextStepRequested extends WithdrawEvent {
  const NextStepRequested();
}

class PreviousStepRequested extends WithdrawEvent {
  const PreviousStepRequested();
}
