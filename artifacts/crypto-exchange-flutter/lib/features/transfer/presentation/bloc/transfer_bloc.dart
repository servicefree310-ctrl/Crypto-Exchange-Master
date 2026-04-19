import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/transfer_option_entity.dart';
import '../../domain/entities/transfer_request_entity.dart';
import '../../domain/entities/currency_option_entity.dart';
import '../../domain/repositories/transfer_repository.dart';
import '../../domain/usecases/get_transfer_options_usecase.dart';
import '../../domain/usecases/get_transfer_currencies_usecase.dart';
import '../../domain/usecases/get_wallet_balance_usecase.dart';
import '../../domain/usecases/create_transfer_usecase.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

@injectable
class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final GetTransferOptionsUseCase _getTransferOptionsUseCase;
  final GetTransferCurrenciesUseCase _getTransferCurrenciesUseCase;
  final GetWalletBalanceUseCase _getWalletBalanceUseCase;
  final CreateTransferUseCase _createTransferUseCase;
  final TransferRepository _transferRepository;

  // Cache to prevent multiple API calls
  bool _isInitialized = false;

  TransferBloc(
    this._getTransferOptionsUseCase,
    this._getTransferCurrenciesUseCase,
    this._getWalletBalanceUseCase,
    this._createTransferUseCase,
    this._transferRepository,
  ) : super(const TransferInitial()) {
    on<TransferInitialized>(_onTransferInitialized);
    on<TransferTypeSelected>(_onTransferTypeSelected);
    on<SourceWalletSelected>(_onSourceWalletSelected);
    on<SourceCurrencySelected>(_onSourceCurrencySelected);
    on<FetchBalanceRequested>(_onFetchBalanceRequested);
    on<DestinationWalletSelected>(_onDestinationWalletSelected);
    on<DestinationCurrencySelected>(_onDestinationCurrencySelected);
    on<RecipientChanged>(_onRecipientChanged);
    on<ContinueToAmountRequested>(_onContinueToAmountRequested);
    on<TransferAmountChanged>(_onTransferAmountChanged);
    on<TransferSubmitted>(_onTransferSubmitted);
    on<TransferReset>(_onTransferReset);
  }

  Future<void> _onTransferInitialized(
    TransferInitialized event,
    Emitter<TransferState> emit,
  ) async {
    // Prevent multiple initialization calls
    if (_isInitialized && state is! TransferError) {
      return;
    }

    emit(const TransferLoading());

    final result = await _getTransferOptionsUseCase(NoParams());

    result.fold(
      (failure) => emit(TransferError(failure: failure)),
      (walletTypes) {
        _isInitialized = true;
        emit(TransferOptionsLoaded(walletTypes: walletTypes));
      },
    );
  }

  void _onTransferTypeSelected(
    TransferTypeSelected event,
    Emitter<TransferState> emit,
  ) {
    final currentState = state;
    if (currentState is TransferOptionsLoaded) {
      emit(TransferTypeSelectedState(
        walletTypes: currentState.walletTypes,
        transferType: event.transferType,
      ));
    }
  }

  void _onSourceWalletSelected(
    SourceWalletSelected event,
    Emitter<TransferState> emit,
  ) async {
    final currentState = state;
    if (currentState is TransferTypeSelectedState) {
      emit(const TransferLoading());

      // Fetch currencies for the selected wallet type with proper transfer action
      final result = await _getTransferCurrenciesUseCase(
        GetTransferCurrenciesParams(
          walletType: event.walletType,
          targetWalletType:
              null, // No target wallet yet, just get source currencies
        ),
      );

      result.fold(
        (failure) => emit(TransferError(failure: failure)),
        (currencies) => emit(SourceWalletReady(
          walletTypes: currentState.walletTypes,
          transferType: currentState.transferType,
          sourceWalletType: event.walletType,
          sourceCurrencies: currencies,
        )),
      );
    }
  }

  void _onSourceCurrencySelected(
    SourceCurrencySelected event,
    Emitter<TransferState> emit,
  ) async {
    final currentState = state;
    if (currentState is SourceWalletReady) {
      // Check if we're selecting the same currency (prevent unnecessary calls)
      if (state is SourceCurrencySelectedState &&
          (state as SourceCurrencySelectedState).sourceCurrency ==
              event.currency) {
        return;
      }

      emit(const TransferLoading());

      // Fetch balance for the selected currency (like v5 fetchBalance)
      final result = await _getWalletBalanceUseCase(
        GetWalletBalanceParams(walletType: currentState.sourceWalletType),
      );

      result.fold(
        (failure) => emit(TransferError(failure: failure)),
        (currencies) {
          // Find the selected currency to get its balance
          final selectedCurrencyData = currencies.firstWhere(
            (c) => c.value == event.currency,
            orElse: () => CurrencyOptionEntity(
              value: event.currency,
              label: event.currency,
              balance: 0.0,
            ),
          );

          final availableBalance =
              _parseBalanceFromLabel(selectedCurrencyData.label);

          // Calculate available destination wallets based on v5 transfer rules
          final availableDestinations = _getAvailableDestinations(
            currentState.sourceWalletType,
          );

          emit(SourceCurrencySelectedState(
            walletTypes: currentState.walletTypes,
            transferType: currentState.transferType,
            sourceWalletType: currentState.sourceWalletType,
            sourceCurrencies: currentState.sourceCurrencies,
            sourceCurrency: event.currency,
            availableBalance: availableBalance,
            availableDestinations: availableDestinations,
          ));
        },
      );
    }
  }

  void _onFetchBalanceRequested(
    FetchBalanceRequested event,
    Emitter<TransferState> emit,
  ) async {
    // This is called when currency is selected to fetch specific balance
    final result = await _getWalletBalanceUseCase(
      GetWalletBalanceParams(walletType: event.walletType),
    );

    result.fold(
      (failure) => emit(TransferError(failure: failure)),
      (currencies) {
        // Find the specific currency and update balance
        final selectedCurrencyData = currencies.firstWhere(
          (c) => c.value == event.currency,
          orElse: () => CurrencyOptionEntity(
            value: event.currency,
            label: event.currency,
            balance: 0.0,
          ),
        );

        final availableBalance =
            _parseBalanceFromLabel(selectedCurrencyData.label);

        // Update current state with new balance
        final currentState = state;
        if (currentState is SourceCurrencySelectedState) {
          emit(currentState.copyWith(availableBalance: availableBalance));
        }
      },
    );
  }

  void _onDestinationWalletSelected(
    DestinationWalletSelected event,
    Emitter<TransferState> emit,
  ) async {
    final currentState = state;
    if (currentState is SourceCurrencySelectedState) {
      // Check if we're selecting the same destination wallet (prevent unnecessary calls)
      if (state is DestinationWalletSelectedState &&
          (state as DestinationWalletSelectedState).destinationWalletType ==
              event.walletType) {
        return;
      }

      emit(const TransferLoading());

      // Fetch destination currencies (like v5 fetchToCurrencies)
      final result = await _getTransferCurrenciesUseCase(
        GetTransferCurrenciesParams(
          walletType: currentState.sourceWalletType,
          targetWalletType: event.walletType,
        ),
      );

      result.fold(
        (failure) => emit(TransferError(failure: failure)),
        (destinationCurrencies) => emit(DestinationWalletSelectedState(
          walletTypes: currentState.walletTypes,
          transferType: currentState.transferType,
          sourceWalletType: currentState.sourceWalletType,
          sourceCurrencies: currentState.sourceCurrencies,
          sourceCurrency: currentState.sourceCurrency,
          availableBalance: currentState.availableBalance,
          availableDestinations: currentState.availableDestinations,
          destinationWalletType: event.walletType,
          destinationCurrencies: destinationCurrencies,
        )),
      );
    }
  }

  void _onDestinationCurrencySelected(
    DestinationCurrencySelected event,
    Emitter<TransferState> emit,
  ) {
    final currentState = state;
    if (currentState is DestinationWalletSelectedState) {
      // Calculate transfer amounts (fee and receive amount)
      final (transferFee, receiveAmount) = _calculateTransferAmounts(
        0.0, // Default amount, will be updated when user enters amount
        currentState.transferType,
      );

      emit(TransferReadyToSubmit(
        walletTypes: currentState.walletTypes,
        transferType: currentState.transferType,
        sourceWalletType: currentState.sourceWalletType,
        sourceCurrencies: currentState.sourceCurrencies,
        sourceCurrency: currentState.sourceCurrency,
        availableBalance: currentState.availableBalance,
        availableDestinations: currentState.availableDestinations,
        destinationWalletType: currentState.destinationWalletType,
        destinationCurrencies: currentState.destinationCurrencies,
        destinationCurrency: event.currency,
        amount: 0.0,
        transferFee: transferFee,
        receiveAmount: receiveAmount,
      ));
    }
  }

  void _onRecipientChanged(
    RecipientChanged event,
    Emitter<TransferState> emit,
  ) async {
    final currentState = state;
    if (currentState is SourceCurrencySelectedState &&
        currentState.transferType == 'client') {
      // Validate recipient via API
      final result =
          await _transferRepository.validateRecipient(event.recipientId);

      result.fold(
        (failure) {
          // Re-emit current state with error so the widget stays visible
          emit(currentState.copyWith(
            recipientError: failure.message,
          ));
        },
        (data) {
          final exists = data['exists'] == true;
          if (exists) {
            emit(ClientRecipientValidatedState(
              walletTypes: currentState.walletTypes,
              transferType: currentState.transferType,
              sourceWalletType: currentState.sourceWalletType,
              sourceCurrencies: currentState.sourceCurrencies,
              sourceCurrency: currentState.sourceCurrency,
              availableBalance: currentState.availableBalance,
              recipientId: event.recipientId,
            ));
          } else {
            final message =
                data['message'] as String? ?? 'Recipient not found';
            emit(currentState.copyWith(
              recipientError: message,
            ));
          }
        },
      );
    }
  }

  void _onContinueToAmountRequested(
    ContinueToAmountRequested event,
    Emitter<TransferState> emit,
  ) {
    final currentState = state;
    if (currentState is ClientRecipientValidatedState) {
      // Calculate transfer amounts for client transfers
      final (transferFee, receiveAmount) = _calculateTransferAmounts(
        0.0, // Default amount, will be updated when user enters amount
        currentState.transferType,
      );

      emit(TransferReadyToSubmit(
        walletTypes: currentState.walletTypes,
        transferType: currentState.transferType,
        sourceWalletType: currentState.sourceWalletType,
        sourceCurrencies: currentState.sourceCurrencies,
        sourceCurrency: currentState.sourceCurrency,
        availableBalance: currentState.availableBalance,
        availableDestinations: [], // No destinations needed for client transfers
        destinationWalletType: null,
        destinationCurrencies: [],
        destinationCurrency: null,
        recipientId: currentState.recipientId,
        amount: 0.0,
        transferFee: transferFee,
        receiveAmount: receiveAmount,
      ));
    }
  }

  void _onTransferAmountChanged(
    TransferAmountChanged event,
    Emitter<TransferState> emit,
  ) {
    final currentState = state;
    if (currentState is TransferReadyToSubmit) {
      // Calculate new fee and receive amount
      final (transferFee, receiveAmount) = _calculateTransferAmounts(
        event.amount,
        currentState.transferType,
      );

      emit(currentState.copyWith(
        amount: event.amount,
        transferFee: transferFee,
        receiveAmount: receiveAmount,
      ));
    }
  }

  void _onTransferSubmitted(
    TransferSubmitted event,
    Emitter<TransferState> emit,
  ) async {
    final currentState = state;
    if (currentState is TransferReadyToSubmit) {
      emit(const TransferSubmitting());

      // Validate that we have all required data
      if (currentState.transferType == 'wallet') {
        if (currentState.destinationWalletType == null ||
            currentState.destinationCurrency == null) {
          emit(TransferError(
            failure: ValidationFailure(
              'Missing destination wallet or currency for wallet transfer',
            ),
          ));
          return;
        }
      } else if (currentState.transferType == 'client') {
        if (currentState.recipientId == null) {
          emit(TransferError(
            failure: ValidationFailure(
              'Missing recipient for client transfer',
            ),
          ));
          return;
        }
      }

      // Create the transfer request
      final transferRequest = TransferRequestEntity(
        fromType: currentState.sourceWalletType,
        fromCurrency: currentState.sourceCurrency,
        amount: currentState.amount,
        toType: currentState.destinationWalletType,
        toCurrency: currentState.destinationCurrency,
        transferType: currentState.transferType,
        clientId: currentState.recipientId,
      );

      final result = await _createTransferUseCase(transferRequest);

      result.fold(
        (failure) => emit(TransferError(failure: failure)),
        (response) => emit(TransferSuccess(response: response)),
      );
    }
  }

  void _onTransferReset(
    TransferReset event,
    Emitter<TransferState> emit,
  ) {
    _isInitialized = false;
    emit(const TransferInitial());
    add(const TransferInitialized());
  }

  // Helper method to parse balance from currency label
  double _parseBalanceFromLabel(String label) {
    // Format: "usd - 52.76" -> extract 52.76
    final parts = label.split(' - ');
    if (parts.length >= 2) {
      try {
        return double.parse(parts[1]);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // Helper method to calculate transfer fees and receive amounts
  (double, double) _calculateTransferAmounts(
      double amount, String transferType) {
    // Transfer rules based on v5 logic
    double transferFee = 0.0;
    double receiveAmount = amount;

    if (transferType == 'client') {
      // Client transfers have a 1% fee with minimum 0.01
      transferFee = (amount * 0.01).clamp(0.01, double.infinity);
      receiveAmount = amount - transferFee;
    } else {
      // Wallet transfers are free
      transferFee = 0.0;
      receiveAmount = amount;
    }

    return (transferFee, receiveAmount);
  }

  // Helper method to get available destination wallets based on transfer rules
  List<TransferOptionEntity> _getAvailableDestinations(
      String sourceWalletType) {
    const validTransfers = {
      'FIAT': ['SPOT', 'ECO'],
      'SPOT': ['FIAT', 'ECO'],
      'ECO': ['FIAT', 'SPOT', 'FUTURES'],
      'FUTURES': ['ECO'],
    };

    final allowedTypes = validTransfers[sourceWalletType] ?? [];
    return allowedTypes
        .map((type) => TransferOptionEntity(id: type, name: type))
        .toList();
  }
}
