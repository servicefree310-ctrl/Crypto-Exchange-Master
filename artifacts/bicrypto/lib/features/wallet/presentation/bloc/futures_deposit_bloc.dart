import 'dart:async';
import 'dart:developer' as dev;
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import 'futures_deposit_event.dart';
import 'futures_deposit_state.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_futures_currencies_usecase.dart';
import '../../domain/usecases/get_futures_tokens_usecase.dart';
import '../../domain/usecases/generate_futures_address_usecase.dart';
import '../../domain/repositories/futures_deposit_repository.dart';
import '../../../../core/usecases/usecase.dart';

/// BLoC for managing FUTURES deposit flow
@injectable
class FuturesDepositBloc
    extends Bloc<FuturesDepositEvent, FuturesDepositState> {
  final GetFuturesCurrenciesUseCase _getFuturesCurrencies;
  final GetFuturesTokensUseCase _getFuturesTokens;
  final GenerateFuturesAddressUseCase _generateAddress;
  final FuturesDepositRepository _repository;

  StreamSubscription? _monitoringSubscription;

  FuturesDepositBloc(
    this._getFuturesCurrencies,
    this._getFuturesTokens,
    this._generateAddress,
    this._repository,
  ) : super(const FuturesDepositInitial()) {
    on<FuturesDepositCurrenciesRequested>(_onCurrenciesRequested);
    on<FuturesDepositTokensRequested>(_onTokensRequested);
    on<FuturesDepositAddressRequested>(_onAddressRequested);
    on<FuturesDepositMonitoringStarted>(_onMonitoringStarted);
    on<FuturesDepositCompletionRequested>(_onDepositCompleted);
    on<FuturesDepositRetryRequested>(_onRetryRequested);
    on<FuturesDepositReset>(_onReset);
  }

  /// Handle fetching FUTURES currencies
  Future<void> _onCurrenciesRequested(
    FuturesDepositCurrenciesRequested event,
    Emitter<FuturesDepositState> emit,
  ) async {
    emit(const FuturesDepositLoading(message: 'Loading FUTURES currencies...'));

    final result = await _getFuturesCurrencies(NoParams());
    result.fold(
      (failure) => emit(
          FuturesDepositError(failure: failure, previousStep: 'currencies')),
      (currencies) {
        if (currencies.isEmpty) {
          emit(const FuturesDepositError(
            failure: ServerFailure('No FUTURES currencies available'),
            previousStep: 'currencies',
          ));
        } else {
          emit(FuturesDepositCurrenciesLoaded(currencies: currencies));
        }
      },
    );
  }

  /// Handle fetching tokens for selected currency
  Future<void> _onTokensRequested(
    FuturesDepositTokensRequested event,
    Emitter<FuturesDepositState> emit,
  ) async {
    emit(const FuturesDepositLoading(message: 'Loading tokens...'));

    final result = await _getFuturesTokens(
      GetFuturesTokensParams(currency: event.currency),
    );
    result.fold(
      (failure) =>
          emit(FuturesDepositError(failure: failure, previousStep: 'tokens')),
      (tokens) {
        if (tokens.isEmpty) {
          emit(FuturesDepositError(
            failure: ServerFailure('No tokens available for ${event.currency}'),
            previousStep: 'tokens',
          ));
        } else {
          emit(FuturesDepositTokensLoaded(
            tokens: tokens,
            selectedCurrency: event.currency,
          ));
        }
      },
    );
  }

  /// Handle generating FUTURES deposit address
  Future<void> _onAddressRequested(
    FuturesDepositAddressRequested event,
    Emitter<FuturesDepositState> emit,
  ) async {
    emit(const FuturesDepositLoading(message: 'Generating FUTURES address...'));

    final result = await _generateAddress(
      GenerateFuturesAddressParams(
        currency: event.currency,
        chain: event.chain,
        contractType: event.contractType,
      ),
    );
    result.fold(
      (failure) =>
          emit(FuturesDepositError(failure: failure, previousStep: 'address')),
      (address) {
        emit(FuturesDepositAddressGenerated(
          address: address,
          selectedCurrency: event.currency,
          selectedChain: event.chain,
          contractType: event.contractType,
        ));
      },
    );
  }

  /// Handle starting deposit monitoring
  Future<void> _onMonitoringStarted(
    FuturesDepositMonitoringStarted event,
    Emitter<FuturesDepositState> emit,
  ) async {
    dev.log(
        '🔵 FUTURES_BLOC: Starting monitoring for ${event.currency} on ${event.chain}');

    // Cancel any existing monitoring
    await _monitoringSubscription?.cancel();

    emit(FuturesDepositMonitoring(
      currency: event.currency,
      chain: event.chain,
      address: event.address,
      contractType: event.contractType,
      startTime: DateTime.now(),
    ));

    // Start monitoring deposits
    try {
      final String? addressForMonitoring =
          event.contractType == 'NO_PERMIT' ? event.address : null;

      _monitoringSubscription = _repository
          .monitorFuturesDeposit(
              event.currency, event.chain, addressForMonitoring)
          .listen(
        (verification) {
          dev.log('✅ FUTURES_BLOC: Deposit verified: ${verification.status}');
          add(const FuturesDepositCompletionRequested());
          emit(FuturesDepositCompleted(
            verification: verification,
            currency: event.currency,
            chain: event.chain,
          ));
        },
        onError: (error) {
          dev.log('❌ FUTURES_BLOC: Monitoring error: $error');
          emit(FuturesDepositError(
            failure: ServerFailure('Monitoring failed: $error'),
            previousStep: 'monitoring',
          ));
        },
      );

      // Set timeout for monitoring based on contract type
      final timeout = event.contractType == 'NO_PERMIT'
          ? const Duration(minutes: 2) // Shorter timeout for NO_PERMIT
          : const Duration(minutes: 10); // Longer timeout for others

      Timer(timeout, () {
        if (state is FuturesDepositMonitoring) {
          _monitoringSubscription?.cancel();
          emit(const FuturesDepositError(
            failure: TimeoutFailure(
                'Deposit monitoring timed out. Please check your transaction and try again.'),
            previousStep: 'monitoring',
          ));
        }
      });
    } catch (e) {
      dev.log('❌ FUTURES_BLOC: Failed to start monitoring: $e');
      emit(FuturesDepositError(
        failure: ServerFailure('Failed to start monitoring: $e'),
        previousStep: 'monitoring',
      ));
    }
  }

  /// Handle deposit completion
  Future<void> _onDepositCompleted(
    FuturesDepositCompletionRequested event,
    Emitter<FuturesDepositState> emit,
  ) async {
    await _monitoringSubscription?.cancel();
    dev.log('🎉 FUTURES_BLOC: Deposit completed successfully');
  }

  /// Handle retry requests
  Future<void> _onRetryRequested(
    FuturesDepositRetryRequested event,
    Emitter<FuturesDepositState> emit,
  ) async {
    await _monitoringSubscription?.cancel();

    final currentState = state;
    if (currentState is FuturesDepositError) {
      // Retry based on the previous step that failed
      switch (currentState.previousStep) {
        case 'currencies':
          add(const FuturesDepositCurrenciesRequested());
          break;
        case 'tokens':
          // We'd need to store the currency to retry, for now go back to currencies
          add(const FuturesDepositCurrenciesRequested());
          break;
        case 'address':
          // We'd need to store the parameters to retry, for now go back to currencies
          add(const FuturesDepositCurrenciesRequested());
          break;
        case 'monitoring':
          // We'd need to store the monitoring parameters to retry, for now go back to currencies
          add(const FuturesDepositCurrenciesRequested());
          break;
        default:
          add(const FuturesDepositCurrenciesRequested());
      }
    } else {
      add(const FuturesDepositCurrenciesRequested());
    }
  }

  /// Handle reset to initial state
  Future<void> _onReset(
    FuturesDepositReset event,
    Emitter<FuturesDepositState> emit,
  ) async {
    await _monitoringSubscription?.cancel();
    emit(const FuturesDepositInitial());
  }

  @override
  Future<void> close() {
    _monitoringSubscription?.cancel();
    return super.close();
  }
}
