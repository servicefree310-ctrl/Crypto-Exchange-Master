import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../transfer/domain/entities/currency_option_entity.dart';
import '../../domain/entities/withdraw_method_entity.dart';
import '../../domain/entities/withdraw_response_entity.dart';

abstract class WithdrawState extends Equatable {
  const WithdrawState();

  @override
  List<Object?> get props => [];
}

class WithdrawInitial extends WithdrawState {
  const WithdrawInitial();
}

class WithdrawLoading extends WithdrawState {
  const WithdrawLoading();
}

// Step 1: Select Wallet Type
class WalletTypesLoaded extends WithdrawState {
  final List<String> walletTypes;
  final int currentStep;

  const WalletTypesLoaded({
    required this.walletTypes,
    this.currentStep = 1,
  });

  @override
  List<Object?> get props => [walletTypes, currentStep];
}

// Step 2: Select Currency
class CurrenciesLoaded extends WithdrawState {
  final String selectedWalletType;
  final List<CurrencyOptionEntity> currencies;
  final int currentStep;

  const CurrenciesLoaded({
    required this.selectedWalletType,
    required this.currencies,
    this.currentStep = 2,
  });

  @override
  List<Object?> get props => [selectedWalletType, currencies, currentStep];
}

// Step 3: Select Method and Fill Details
class WithdrawMethodsLoaded extends WithdrawState {
  final String selectedWalletType;
  final String selectedCurrency;
  final double availableBalance;
  final List<WithdrawMethodEntity> methods;
  final String? selectedMethodId;
  final WithdrawMethodEntity? selectedMethod;
  final Map<String, dynamic> customFieldValues;
  final int currentStep;

  const WithdrawMethodsLoaded({
    required this.selectedWalletType,
    required this.selectedCurrency,
    required this.availableBalance,
    required this.methods,
    this.selectedMethodId,
    this.selectedMethod,
    this.customFieldValues = const {},
    this.currentStep = 3,
  });

  @override
  List<Object?> get props => [
        selectedWalletType,
        selectedCurrency,
        availableBalance,
        methods,
        selectedMethodId,
        selectedMethod,
        customFieldValues,
        currentStep,
      ];

  WithdrawMethodsLoaded copyWith({
    String? selectedWalletType,
    String? selectedCurrency,
    double? availableBalance,
    List<WithdrawMethodEntity>? methods,
    String? selectedMethodId,
    WithdrawMethodEntity? selectedMethod,
    Map<String, dynamic>? customFieldValues,
    int? currentStep,
  }) {
    return WithdrawMethodsLoaded(
      selectedWalletType: selectedWalletType ?? this.selectedWalletType,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      availableBalance: availableBalance ?? this.availableBalance,
      methods: methods ?? this.methods,
      selectedMethodId: selectedMethodId ?? this.selectedMethodId,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      customFieldValues: customFieldValues ?? this.customFieldValues,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

// Step 4: Enter Amount and Confirm
class WithdrawAmountReady extends WithdrawState {
  final String selectedWalletType;
  final String selectedCurrency;
  final double availableBalance;
  final WithdrawMethodEntity selectedMethod;
  final Map<String, dynamic> customFieldValues;
  final String amount;
  final double withdrawAmount;
  final double fee;
  final double netAmount;
  final bool isValidAmount;
  final String? errorMessage;
  final int currentStep;

  const WithdrawAmountReady({
    required this.selectedWalletType,
    required this.selectedCurrency,
    required this.availableBalance,
    required this.selectedMethod,
    required this.customFieldValues,
    required this.amount,
    required this.withdrawAmount,
    required this.fee,
    required this.netAmount,
    required this.isValidAmount,
    this.errorMessage,
    this.currentStep = 4,
  });

  @override
  List<Object?> get props => [
        selectedWalletType,
        selectedCurrency,
        availableBalance,
        selectedMethod,
        customFieldValues,
        amount,
        withdrawAmount,
        fee,
        netAmount,
        isValidAmount,
        errorMessage,
        currentStep,
      ];

  WithdrawAmountReady copyWith({
    String? selectedWalletType,
    String? selectedCurrency,
    double? availableBalance,
    WithdrawMethodEntity? selectedMethod,
    Map<String, dynamic>? customFieldValues,
    String? amount,
    double? withdrawAmount,
    double? fee,
    double? netAmount,
    bool? isValidAmount,
    String? errorMessage,
    int? currentStep,
  }) {
    return WithdrawAmountReady(
      selectedWalletType: selectedWalletType ?? this.selectedWalletType,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      availableBalance: availableBalance ?? this.availableBalance,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      customFieldValues: customFieldValues ?? this.customFieldValues,
      amount: amount ?? this.amount,
      withdrawAmount: withdrawAmount ?? this.withdrawAmount,
      fee: fee ?? this.fee,
      netAmount: netAmount ?? this.netAmount,
      isValidAmount: isValidAmount ?? this.isValidAmount,
      errorMessage: errorMessage,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

class WithdrawSubmitting extends WithdrawState {
  const WithdrawSubmitting();
}

class WithdrawSuccess extends WithdrawState {
  final WithdrawResponseEntity response;

  const WithdrawSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class WithdrawError extends WithdrawState {
  final Failure failure;

  const WithdrawError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
