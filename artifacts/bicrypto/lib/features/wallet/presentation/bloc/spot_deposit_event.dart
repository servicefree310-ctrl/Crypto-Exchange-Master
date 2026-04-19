import 'package:equatable/equatable.dart';

abstract class SpotDepositEvent extends Equatable {
  const SpotDepositEvent();

  @override
  List<Object> get props => [];
}

class SpotCurrenciesRequested extends SpotDepositEvent {
  const SpotCurrenciesRequested();
}

class SpotNetworksRequested extends SpotDepositEvent {
  const SpotNetworksRequested(this.currency);

  final String currency;

  @override
  List<Object> get props => [currency];
}

class SpotDepositAddressRequested extends SpotDepositEvent {
  const SpotDepositAddressRequested(this.currency, this.network);

  final String currency;
  final String network;

  @override
  List<Object> get props => [currency, network];
}

class SpotDepositCreated extends SpotDepositEvent {
  const SpotDepositCreated(this.currency, this.chain, this.transactionHash);

  final String currency;
  final String chain;
  final String transactionHash;

  @override
  List<Object> get props => [currency, chain, transactionHash];
}

class SpotDepositVerificationStarted extends SpotDepositEvent {
  const SpotDepositVerificationStarted(this.transactionId);

  final String transactionId;

  @override
  List<Object> get props => [transactionId];
}

class SpotDepositVerificationStopped extends SpotDepositEvent {
  const SpotDepositVerificationStopped();
}

class SpotDepositReset extends SpotDepositEvent {
  const SpotDepositReset();
}
