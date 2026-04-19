import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failures.dart';
import '../../../transfer/domain/entities/currency_option_entity.dart';
import '../../domain/entities/withdraw_method_entity.dart';
import '../../domain/entities/withdraw_request_entity.dart';
import '../../domain/usecases/get_withdraw_currencies_usecase.dart';
import '../../domain/usecases/get_withdraw_methods_usecase.dart';
import '../../domain/usecases/submit_withdraw_usecase.dart';
import 'withdraw_event.dart';
import 'withdraw_state.dart';

@injectable
class WithdrawBloc extends Bloc<WithdrawEvent, WithdrawState> {
  final GetWithdrawCurrenciesUseCase _getWithdrawCurrenciesUseCase;
  final GetWithdrawMethodsUseCase _getWithdrawMethodsUseCase;
  final SubmitWithdrawUseCase _submitWithdrawUseCase;

  // Cache data
  String? _selectedWalletType;
  String? _selectedCurrency;
  double _availableBalance = 0.0;
  WithdrawMethodEntity? _selectedMethod;
  Map<String, dynamic> _customFieldValues = {};

  WithdrawBloc(
    this._getWithdrawCurrenciesUseCase,
    this._getWithdrawMethodsUseCase,
    this._submitWithdrawUseCase,
  ) : super(const WithdrawInitial()) {
    on<WithdrawInitialized>(_onWithdrawInitialized);
    on<WalletTypeSelected>(_onWalletTypeSelected);
    on<CurrencySelected>(_onCurrencySelected);
    on<WithdrawMethodSelected>(_onWithdrawMethodSelected);
    on<WithdrawAmountChanged>(_onWithdrawAmountChanged);
    on<CustomFieldChanged>(_onCustomFieldChanged);
    on<WithdrawSubmitted>(_onWithdrawSubmitted);
    on<WithdrawReset>(_onWithdrawReset);
    on<NextStepRequested>(_onNextStepRequested);
    on<PreviousStepRequested>(_onPreviousStepRequested);
  }

  Future<void> _onWithdrawInitialized(
    WithdrawInitialized event,
    Emitter<WithdrawState> emit,
  ) async {
    emit(const WithdrawLoading());

    try {
      // Check available wallet types
      final availableWalletTypes = <String>{};
      final walletTypes = ['FIAT', 'SPOT', 'ECO'];

      dev.log('🔍 Checking available wallet types...');

      for (final type in walletTypes) {
        dev.log('📍 Checking wallet type: $type');
        final result = await _getWithdrawCurrenciesUseCase(
          GetWithdrawCurrenciesParams(walletType: type),
        );

        result.fold(
          (failure) {
            dev.log('❌ Failed to get currencies for $type: ${failure.message}');
          },
          (currencies) {
            dev.log('✅ Got ${currencies.length} currencies for $type');
            if (currencies.isNotEmpty) {
              availableWalletTypes.add(type);
              dev.log('✨ Added $type to available wallet types');
            } else {
              dev.log('⚠️ No currencies available for $type');
            }
          },
        );
      }

      dev.log('📊 Available wallet types: ${availableWalletTypes.toList()}');

      if (availableWalletTypes.isEmpty) {
        emit(WithdrawError(
          failure: ValidationFailure(
              'No wallets with balance available for withdrawal'),
        ));
        return;
      }

      emit(WalletTypesLoaded(
        walletTypes: availableWalletTypes.toList(),
      ));
    } catch (e) {
      dev.log('💥 Unexpected error in withdraw initialization: $e');
      emit(WithdrawError(
        failure: ServerFailure(e.toString()),
      ));
    }
  }

  Future<void> _onWalletTypeSelected(
    WalletTypeSelected event,
    Emitter<WithdrawState> emit,
  ) async {
    emit(const WithdrawLoading());

    _selectedWalletType = event.walletType;
    _selectedCurrency = null;
    _availableBalance = 0.0;
    _selectedMethod = null;
    _customFieldValues = {};

    final result = await _getWithdrawCurrenciesUseCase(
      GetWithdrawCurrenciesParams(walletType: event.walletType),
    );

    result.fold(
      (failure) => emit(WithdrawError(failure: failure)),
      (currencies) => emit(CurrenciesLoaded(
        selectedWalletType: event.walletType,
        currencies: currencies,
      )),
    );
  }

  Future<void> _onCurrencySelected(
    CurrencySelected event,
    Emitter<WithdrawState> emit,
  ) async {
    if (_selectedWalletType == null) return;

    emit(const WithdrawLoading());

    _selectedCurrency = event.currency;

    // Get the selected currency data to extract balance
    final currentState = state;
    if (currentState is CurrenciesLoaded) {
      final selectedCurrencyData = currentState.currencies.firstWhere(
        (c) => c.value == event.currency,
        orElse: () => CurrencyOptionEntity(
          value: event.currency,
          label: event.currency,
          balance: 0.0,
        ),
      );
      _availableBalance = selectedCurrencyData.balance ?? 0.0;
    }

    final result = await _getWithdrawMethodsUseCase(
      GetWithdrawMethodsParams(
        walletType: _selectedWalletType!,
        currency: event.currency,
      ),
    );

    result.fold(
      (failure) => emit(WithdrawError(failure: failure)),
      (methods) => emit(WithdrawMethodsLoaded(
        selectedWalletType: _selectedWalletType!,
        selectedCurrency: event.currency,
        availableBalance: _availableBalance,
        methods: methods,
      )),
    );
  }

  void _onWithdrawMethodSelected(
    WithdrawMethodSelected event,
    Emitter<WithdrawState> emit,
  ) {
    final currentState = state;
    if (currentState is WithdrawMethodsLoaded) {
      final selectedMethod = currentState.methods.firstWhere(
        (m) => m.id == event.methodId,
      );

      _selectedMethod = selectedMethod;

      emit(currentState.copyWith(
        selectedMethodId: event.methodId,
        selectedMethod: selectedMethod,
      ));
    }
  }

  void _onCustomFieldChanged(
    CustomFieldChanged event,
    Emitter<WithdrawState> emit,
  ) {
    _customFieldValues[event.fieldName] = event.value;

    final currentState = state;
    if (currentState is WithdrawMethodsLoaded) {
      emit(currentState.copyWith(
        customFieldValues: Map.from(_customFieldValues),
      ));
    }
  }

  void _onWithdrawAmountChanged(
    WithdrawAmountChanged event,
    Emitter<WithdrawState> emit,
  ) {
    if (_selectedMethod == null ||
        _selectedWalletType == null ||
        _selectedCurrency == null) {
      return;
    }

    final amount = event.amount.isEmpty ? '0' : event.amount;
    final withdrawAmount = double.tryParse(amount) ?? 0.0;

    // Calculate fees
    // For FIAT: use method's fixed fee + percentage fee
    // For SPOT/ECO: use network's fixed fee + currency percentage fee (if any)
    final fixedFee = _selectedMethod!.fixedFee ?? 0.0;
    final percentageFee = _selectedMethod!.percentageFee ?? 0.0;

    // Note: In v5, there's also a spotWithdrawFee setting that adds to percentage
    // For now, we'll use what's provided by the method
    final percentageFeeAmount = (withdrawAmount * percentageFee / 100);
    final fee = fixedFee + percentageFeeAmount;

    // Backend fee semantics differ by wallet type.
    double estimatedWalletDeduction = withdrawAmount;
    double netAmount = withdrawAmount;
    switch (_selectedWalletType!) {
      case 'FIAT':
        netAmount = withdrawAmount - fee;
        estimatedWalletDeduction = withdrawAmount;
        break;
      case 'SPOT':
        netAmount = withdrawAmount - fixedFee;
        estimatedWalletDeduction = withdrawAmount + percentageFeeAmount;
        break;
      case 'ECO':
      default:
        netAmount = withdrawAmount;
        estimatedWalletDeduction = withdrawAmount + fee;
        break;
    }

    // Validate amount
    bool isValidAmount = true;
    String? errorMessage;
    final maxDecimals =
        _getMaxAllowedDecimals(_selectedWalletType!, _selectedMethod!);

    if (withdrawAmount <= 0) {
      isValidAmount = false;
      errorMessage = 'Amount must be greater than zero';
    } else if (_hasTooManyDecimals(event.amount, maxDecimals)) {
      isValidAmount = false;
      errorMessage =
          'Maximum $maxDecimals decimal places allowed for this withdrawal method';
    } else if (estimatedWalletDeduction > _availableBalance) {
      isValidAmount = false;
      errorMessage = 'Insufficient balance';
    } else if (_selectedMethod!.minAmount != null &&
        withdrawAmount < _selectedMethod!.minAmount!) {
      isValidAmount = false;
      errorMessage =
          'Minimum amount is ${_selectedMethod!.minAmount} $_selectedCurrency';
    } else if (_selectedMethod!.maxAmount != null &&
        withdrawAmount > _selectedMethod!.maxAmount!) {
      isValidAmount = false;
      errorMessage =
          'Maximum amount is ${_selectedMethod!.maxAmount} $_selectedCurrency';
    } else if (netAmount <= 0) {
      isValidAmount = false;
      errorMessage = 'Amount is too small after fees';
    }

    emit(WithdrawAmountReady(
      selectedWalletType: _selectedWalletType!,
      selectedCurrency: _selectedCurrency!,
      availableBalance: _availableBalance,
      selectedMethod: _selectedMethod!,
      customFieldValues: _customFieldValues,
      amount: event.amount,
      withdrawAmount: withdrawAmount,
      fee: fee,
      netAmount: netAmount,
      isValidAmount: isValidAmount,
      errorMessage: errorMessage,
    ));
  }

  Future<void> _onWithdrawSubmitted(
    WithdrawSubmitted event,
    Emitter<WithdrawState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WithdrawAmountReady || !currentState.isValidAmount) {
      return;
    }

    emit(const WithdrawSubmitting());

    // Build request based on wallet type
    WithdrawRequestEntity request;

    if (_selectedWalletType == 'FIAT') {
      request = WithdrawRequestEntity(
        walletType: _selectedWalletType!,
        currency: _selectedCurrency!,
        amount: currentState.withdrawAmount,
        methodId: _selectedMethod!.id,
        customFields: _customFieldValues,
      );
    } else {
      // For SPOT/ECO, extract address from custom fields
      String? toAddress;
      String? memo;

      if (_customFieldValues.containsKey('address')) {
        toAddress = _customFieldValues['address']?.toString();
      }
      if (toAddress == null || toAddress.trim().isEmpty) {
        final addressEntry = _customFieldValues.entries.firstWhere(
          (entry) =>
              entry.key.toLowerCase().contains('address') &&
              entry.value != null &&
              entry.value.toString().trim().isNotEmpty,
          orElse: () => const MapEntry('', null),
        );
        if (addressEntry.key.isNotEmpty) {
          toAddress = addressEntry.value.toString();
        }
      }
      if (_customFieldValues.containsKey('memo')) {
        memo = _customFieldValues['memo']?.toString();
      }
      if (memo == null || memo.trim().isEmpty) {
        final memoEntry = _customFieldValues.entries.firstWhere(
          (entry) =>
              (entry.key.toLowerCase().contains('memo') ||
                  entry.key.toLowerCase().contains('tag')) &&
              entry.value != null &&
              entry.value.toString().trim().isNotEmpty,
          orElse: () => const MapEntry('', null),
        );
        if (memoEntry.key.isNotEmpty) {
          memo = memoEntry.value.toString();
        }
      }

      request = WithdrawRequestEntity(
        walletType: _selectedWalletType!,
        currency: _selectedCurrency!,
        amount: currentState.withdrawAmount,
        methodId: _selectedMethod!.id,
        chain: _selectedMethod!.network ?? _selectedMethod!.id,
        toAddress: toAddress,
        memo: memo,
        customFields: _customFieldValues,
      );
    }

    final result = await _submitWithdrawUseCase(request);

    result.fold(
      (failure) => emit(WithdrawError(failure: failure)),
      (response) => emit(WithdrawSuccess(response: response)),
    );
  }

  void _onWithdrawReset(
    WithdrawReset event,
    Emitter<WithdrawState> emit,
  ) {
    _selectedWalletType = null;
    _selectedCurrency = null;
    _availableBalance = 0.0;
    _selectedMethod = null;
    _customFieldValues = {};

    emit(const WithdrawInitial());
    add(const WithdrawInitialized());
  }

  void _onNextStepRequested(
    NextStepRequested event,
    Emitter<WithdrawState> emit,
  ) {
    final currentState = state;

    if (currentState is WithdrawMethodsLoaded &&
        currentState.selectedMethod != null) {
      // Check if all required custom fields are filled
      bool allFieldsFilled = true;

      if (currentState.selectedMethod!.customFields != null) {
        for (final field in currentState.selectedMethod!.customFields!) {
          if (field.required && !_customFieldValues.containsKey(field.name)) {
            allFieldsFilled = false;
            break;
          }
        }
      }

      if (allFieldsFilled) {
        // Move to amount input step
        add(const WithdrawAmountChanged(amount: ''));
      }
    }
  }

  void _onPreviousStepRequested(
    PreviousStepRequested event,
    Emitter<WithdrawState> emit,
  ) {
    final currentState = state;

    if (currentState is CurrenciesLoaded) {
      add(const WithdrawInitialized());
    } else if (currentState is WithdrawMethodsLoaded) {
      add(WalletTypeSelected(walletType: _selectedWalletType!));
    } else if (currentState is WithdrawAmountReady) {
      add(CurrencySelected(currency: _selectedCurrency!));
    }
  }

  bool _hasTooManyDecimals(String amount, int maxDecimals) {
    if (amount.isEmpty || !amount.contains('.')) return false;
    final parts = amount.split('.');
    if (parts.length < 2) return false;
    return parts[1].length > maxDecimals;
  }

  int _getMaxAllowedDecimals(
    String walletType,
    WithdrawMethodEntity method,
  ) {
    if (walletType == 'FIAT') {
      return 2;
    }

    if (walletType == 'SPOT') {
      return 8;
    }

    final network = (method.network ?? '').toUpperCase();
    const networkPrecision = <String, int>{
      'TRON': 6,
      'XRP': 6,
      'XLM': 7,
      'BTC': 8,
      'LTC': 8,
      'DOGE': 8,
      'DASH': 8,
      'SOL': 9,
      'TON': 9,
      'XMR': 12,
      'ETH': 18,
      'BSC': 18,
      'POLYGON': 18,
      'ARBITRUM': 18,
      'OPTIMISM': 18,
      'BASE': 18,
      'AVAX': 18,
      'FTM': 18,
      'CELO': 18,
      'RSK': 18,
    };

    return networkPrecision[network] ?? 8;
  }
}
