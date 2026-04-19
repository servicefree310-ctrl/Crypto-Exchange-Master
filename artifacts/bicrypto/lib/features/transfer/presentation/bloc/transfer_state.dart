import 'package:equatable/equatable.dart';

import '../../domain/entities/transfer_option_entity.dart';
import '../../domain/entities/currency_option_entity.dart';
import '../../domain/entities/transfer_response_entity.dart';
import '../../../../core/errors/failures.dart';

abstract class TransferState extends Equatable {
  const TransferState();

  @override
  List<Object?> get props => [];
}

class TransferInitial extends TransferState {
  const TransferInitial();
}

class TransferLoading extends TransferState {
  const TransferLoading();
}

class TransferOptionsLoaded extends TransferState {
  final List<TransferOptionEntity> walletTypes;
  final int currentStep;

  const TransferOptionsLoaded({
    required this.walletTypes,
    this.currentStep = 1,
  });

  @override
  List<Object?> get props => [walletTypes, currentStep];
}

class TransferTypeSelectedState extends TransferState {
  final List<TransferOptionEntity> walletTypes;
  final String transferType;
  final int currentStep;

  const TransferTypeSelectedState({
    required this.walletTypes,
    required this.transferType,
    this.currentStep = 2,
  });

  @override
  List<Object?> get props => [walletTypes, transferType, currentStep];
}

class SourceWalletReady extends TransferState {
  final List<TransferOptionEntity> walletTypes;
  final String transferType;
  final String sourceWalletType;
  final List<CurrencyOptionEntity> sourceCurrencies;
  final int currentStep;

  const SourceWalletReady({
    required this.walletTypes,
    required this.transferType,
    required this.sourceWalletType,
    required this.sourceCurrencies,
    this.currentStep = 3,
  });

  @override
  List<Object?> get props => [
        walletTypes,
        transferType,
        sourceWalletType,
        sourceCurrencies,
        currentStep,
      ];
}

class SourceCurrencySelectedState extends TransferState {
  final List<TransferOptionEntity> walletTypes;
  final String transferType;
  final String sourceWalletType;
  final List<CurrencyOptionEntity> sourceCurrencies;
  final String sourceCurrency;
  final double availableBalance;
  final List<TransferOptionEntity> availableDestinations;
  final String? recipientError;
  final int currentStep;

  const SourceCurrencySelectedState({
    required this.walletTypes,
    required this.transferType,
    required this.sourceWalletType,
    required this.sourceCurrencies,
    required this.sourceCurrency,
    required this.availableBalance,
    required this.availableDestinations,
    this.recipientError,
    this.currentStep = 4,
  });

  @override
  List<Object?> get props => [
        walletTypes,
        transferType,
        sourceWalletType,
        sourceCurrencies,
        sourceCurrency,
        availableBalance,
        availableDestinations,
        recipientError,
        currentStep,
      ];

  SourceCurrencySelectedState copyWith({
    List<TransferOptionEntity>? walletTypes,
    String? transferType,
    String? sourceWalletType,
    List<CurrencyOptionEntity>? sourceCurrencies,
    String? sourceCurrency,
    double? availableBalance,
    List<TransferOptionEntity>? availableDestinations,
    String? recipientError,
    int? currentStep,
  }) {
    return SourceCurrencySelectedState(
      walletTypes: walletTypes ?? this.walletTypes,
      transferType: transferType ?? this.transferType,
      sourceWalletType: sourceWalletType ?? this.sourceWalletType,
      sourceCurrencies: sourceCurrencies ?? this.sourceCurrencies,
      sourceCurrency: sourceCurrency ?? this.sourceCurrency,
      availableBalance: availableBalance ?? this.availableBalance,
      availableDestinations:
          availableDestinations ?? this.availableDestinations,
      recipientError: recipientError,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

class DestinationWalletSelectedState extends TransferState {
  final List<TransferOptionEntity> walletTypes;
  final String transferType;
  final String sourceWalletType;
  final List<CurrencyOptionEntity> sourceCurrencies;
  final String sourceCurrency;
  final double availableBalance;
  final List<TransferOptionEntity> availableDestinations;
  final String destinationWalletType;
  final List<CurrencyOptionEntity> destinationCurrencies;
  final int currentStep;

  const DestinationWalletSelectedState({
    required this.walletTypes,
    required this.transferType,
    required this.sourceWalletType,
    required this.sourceCurrencies,
    required this.sourceCurrency,
    required this.availableBalance,
    required this.availableDestinations,
    required this.destinationWalletType,
    required this.destinationCurrencies,
    this.currentStep = 5,
  });

  @override
  List<Object?> get props => [
        walletTypes,
        transferType,
        sourceWalletType,
        sourceCurrencies,
        sourceCurrency,
        availableBalance,
        availableDestinations,
        destinationWalletType,
        destinationCurrencies,
        currentStep,
      ];
}

class ClientRecipientValidatedState extends TransferState {
  final List<TransferOptionEntity> walletTypes;
  final String transferType;
  final String sourceWalletType;
  final List<CurrencyOptionEntity> sourceCurrencies;
  final String sourceCurrency;
  final double availableBalance;
  final String recipientId;
  final int currentStep;

  const ClientRecipientValidatedState({
    required this.walletTypes,
    required this.transferType,
    required this.sourceWalletType,
    required this.sourceCurrencies,
    required this.sourceCurrency,
    required this.availableBalance,
    required this.recipientId,
    this.currentStep = 4,
  });

  @override
  List<Object?> get props => [
        walletTypes,
        transferType,
        sourceWalletType,
        sourceCurrencies,
        sourceCurrency,
        availableBalance,
        recipientId,
        currentStep,
      ];
}

class TransferReadyToSubmit extends TransferState {
  final List<TransferOptionEntity> walletTypes;
  final String transferType;
  final String sourceWalletType;
  final List<CurrencyOptionEntity> sourceCurrencies;
  final String sourceCurrency;
  final double availableBalance;
  final List<TransferOptionEntity> availableDestinations;
  final String? destinationWalletType;
  final List<CurrencyOptionEntity> destinationCurrencies;
  final String? destinationCurrency;
  final String? recipientId;
  final double amount;
  final double transferFee;
  final double receiveAmount;
  final double? exchangeRate;
  final int currentStep;

  const TransferReadyToSubmit({
    required this.walletTypes,
    required this.transferType,
    required this.sourceWalletType,
    required this.sourceCurrencies,
    required this.sourceCurrency,
    required this.availableBalance,
    required this.availableDestinations,
    this.destinationWalletType,
    required this.destinationCurrencies,
    this.destinationCurrency,
    this.recipientId,
    required this.amount,
    required this.transferFee,
    required this.receiveAmount,
    this.exchangeRate,
    this.currentStep = 6,
  });

  @override
  List<Object?> get props => [
        walletTypes,
        transferType,
        sourceWalletType,
        sourceCurrencies,
        sourceCurrency,
        availableBalance,
        availableDestinations,
        destinationWalletType,
        destinationCurrencies,
        destinationCurrency,
        recipientId,
        amount,
        transferFee,
        receiveAmount,
        exchangeRate,
        currentStep,
      ];

  bool get isReadyToSubmit {
    if (transferType == 'wallet') {
      return destinationWalletType != null &&
          destinationCurrency != null &&
          amount > 0 &&
          amount <= availableBalance;
    } else {
      return recipientId != null &&
          recipientId!.isNotEmpty &&
          amount > 0 &&
          amount <= availableBalance;
    }
  }

  TransferReadyToSubmit copyWith({
    List<TransferOptionEntity>? walletTypes,
    String? transferType,
    String? sourceWalletType,
    List<CurrencyOptionEntity>? sourceCurrencies,
    String? sourceCurrency,
    double? availableBalance,
    List<TransferOptionEntity>? availableDestinations,
    String? destinationWalletType,
    List<CurrencyOptionEntity>? destinationCurrencies,
    String? destinationCurrency,
    String? recipientId,
    double? amount,
    double? transferFee,
    double? receiveAmount,
    double? exchangeRate,
    int? currentStep,
  }) {
    return TransferReadyToSubmit(
      walletTypes: walletTypes ?? this.walletTypes,
      transferType: transferType ?? this.transferType,
      sourceWalletType: sourceWalletType ?? this.sourceWalletType,
      sourceCurrencies: sourceCurrencies ?? this.sourceCurrencies,
      sourceCurrency: sourceCurrency ?? this.sourceCurrency,
      availableBalance: availableBalance ?? this.availableBalance,
      availableDestinations:
          availableDestinations ?? this.availableDestinations,
      destinationWalletType:
          destinationWalletType ?? this.destinationWalletType,
      destinationCurrencies:
          destinationCurrencies ?? this.destinationCurrencies,
      destinationCurrency: destinationCurrency ?? this.destinationCurrency,
      recipientId: recipientId ?? this.recipientId,
      amount: amount ?? this.amount,
      transferFee: transferFee ?? this.transferFee,
      receiveAmount: receiveAmount ?? this.receiveAmount,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

class TransferSubmitting extends TransferState {
  const TransferSubmitting();
}

class TransferSuccess extends TransferState {
  final TransferResponseEntity response;

  const TransferSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class TransferError extends TransferState {
  final Failure failure;
  final String? previousStateData;

  const TransferError({
    required this.failure,
    this.previousStateData,
  });

  @override
  List<Object?> get props => [failure, previousStateData];
}
