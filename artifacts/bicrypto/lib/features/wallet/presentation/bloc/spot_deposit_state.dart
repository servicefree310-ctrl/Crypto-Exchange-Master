import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/spot_currency_entity.dart';
import '../../domain/entities/spot_network_entity.dart';
import '../../domain/entities/spot_deposit_address_entity.dart';
import '../../domain/entities/spot_deposit_transaction_entity.dart';
import '../../domain/entities/spot_deposit_verification_result.dart';

abstract class SpotDepositState extends Equatable {
  const SpotDepositState();

  @override
  List<Object?> get props => [];
}

class SpotDepositInitial extends SpotDepositState {
  const SpotDepositInitial();
}

class SpotDepositLoading extends SpotDepositState {
  const SpotDepositLoading();
}

class SpotCurrenciesLoaded extends SpotDepositState {
  const SpotCurrenciesLoaded(this.currencies);

  final List<SpotCurrencyEntity> currencies;

  @override
  List<Object> get props => [currencies];
}

class SpotNetworksLoaded extends SpotDepositState {
  const SpotNetworksLoaded(this.networks);

  final List<SpotNetworkEntity> networks;

  @override
  List<Object> get props => [networks];
}

class SpotDepositAddressGenerated extends SpotDepositState {
  const SpotDepositAddressGenerated(this.address);

  final SpotDepositAddressEntity address;

  @override
  List<Object> get props => [address];
}

class SpotDepositTransactionCreated extends SpotDepositState {
  const SpotDepositTransactionCreated(this.transaction);

  final SpotDepositTransactionEntity transaction;

  @override
  List<Object> get props => [transaction];
}

class SpotDepositVerifying extends SpotDepositState {
  const SpotDepositVerifying(this.transactionId, this.message);

  final String transactionId;
  final String message;

  @override
  List<Object> get props => [transactionId, message];
}

class SpotDepositVerified extends SpotDepositState {
  const SpotDepositVerified(this.result);

  final SpotDepositVerificationResult result;

  @override
  List<Object> get props => [result];
}

class SpotDepositError extends SpotDepositState {
  const SpotDepositError(this.failure);

  final Failure failure;

  @override
  List<Object> get props => [failure];
}

class SpotDepositNetworkError extends SpotDepositState {
  const SpotDepositNetworkError(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}
