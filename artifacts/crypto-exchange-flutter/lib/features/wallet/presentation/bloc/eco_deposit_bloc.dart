import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_eco_currencies_usecase.dart';
import '../../domain/usecases/get_eco_tokens_usecase.dart';
import '../../domain/usecases/generate_eco_address_usecase.dart';
import '../../domain/repositories/eco_deposit_repository.dart';
import 'eco_deposit_event.dart';
import 'eco_deposit_state.dart';

@injectable
class EcoDepositBloc extends Bloc<EcoDepositEvent, EcoDepositState> {
  final GetEcoCurrenciesUseCase _getCurrenciesUseCase;
  final GetEcoTokensUseCase _getTokensUseCase;
  final GenerateEcoAddressUseCase _generateAddressUseCase;
  final EcoDepositRepository _repository;

  StreamSubscription<dynamic>? _wsSubscription;
  Timer? _timeoutTimer;

  EcoDepositBloc(
    this._getCurrenciesUseCase,
    this._getTokensUseCase,
    this._generateAddressUseCase,
    this._repository,
  ) : super(const EcoDepositInitial()) {
    on<EcoDepositCurrenciesRequested>(_onCurrenciesRequested);
    on<EcoDepositTokensRequested>(_onTokensRequested);
    on<EcoDepositAddressRequested>(_onAddressRequested);
    on<EcoDepositMonitoringStarted>(_onMonitoringStarted);
    on<EcoDepositVerificationReceived>(_onVerificationReceived);
    on<EcoDepositAddressUnlocked>(_onAddressUnlocked);
    on<EcoDepositReset>(_onReset);
    on<EcoDepositRetryRequested>(_onRetryRequested);
    on<EcoDepositMonitoringStopped>(_onMonitoringStopped);
  }

  Future<void> _onCurrenciesRequested(
    EcoDepositCurrenciesRequested event,
    Emitter<EcoDepositState> emit,
  ) async {
    emit(const EcoDepositLoading(message: 'Loading ECO currencies...'));

    final result = await _getCurrenciesUseCase(NoParams());
    result.fold(
      (failure) => emit(EcoDepositError(
        failure: failure,
        context: 'Failed to load currencies',
      )),
      (currencies) {
        if (currencies.isEmpty) {
          emit(const EcoDepositError(
            failure: ValidationFailure('No ECO currencies available'),
            context: 'Currency loading',
          ));
        } else {
          emit(EcoCurrenciesLoaded(currencies: currencies));
        }
      },
    );
  }

  Future<void> _onTokensRequested(
    EcoDepositTokensRequested event,
    Emitter<EcoDepositState> emit,
  ) async {
    emit(const EcoDepositLoading(message: 'Loading ECO tokens...'));

    final result = await _getTokensUseCase(
      GetEcoTokensParams(currency: event.currency),
    );
    result.fold(
      (failure) => emit(EcoDepositError(
        failure: failure,
        context: 'Failed to load tokens for ${event.currency}',
      )),
      (tokens) {
        if (tokens.isEmpty) {
          emit(EcoDepositError(
            failure: const ValidationFailure(
                'No tokens available for this currency'),
            context: 'Token loading',
          ));
        } else {
          emit(EcoTokensLoaded(
            tokens: tokens,
            selectedCurrency: event.currency,
          ));
        }
      },
    );
  }

  Future<void> _onAddressRequested(
    EcoDepositAddressRequested event,
    Emitter<EcoDepositState> emit,
  ) async {
    emit(const EcoDepositLoading(message: 'Generating deposit address...'));

    final result = await _generateAddressUseCase(
      GenerateEcoAddressParams(
        currency: event.currency,
        chain: event.chain,
        contractType: event.contractType,
      ),
    );

    result.fold(
      (failure) => emit(EcoDepositError(
        failure: failure,
        context: 'Failed to generate ${event.contractType} address',
      )),
      (address) {
        emit(EcoAddressGenerated(
          address: address,
          selectedToken: event.token,
          isLocked: address.isLocked,
        ));

        // Auto-start monitoring after address generation
        add(EcoDepositMonitoringStarted(
          currency: event.currency,
          chain: event.chain,
          address: address.address,
          contractType: event.contractType,
        ));
      },
    );
  }

  Future<void> _onMonitoringStarted(
    EcoDepositMonitoringStarted event,
    Emitter<EcoDepositState> emit,
  ) async {
    try {
      // Determine timeout based on contract type
      final timeoutMinutes = _getTimeoutMinutes(event.contractType);

      emit(EcoDepositMonitoring(
        currency: event.currency,
        chain: event.chain,
        address: event.address,
        contractType: event.contractType,
        timeoutMinutes: timeoutMinutes,
        startTime: DateTime.now(),
      ));

      // Connect to WebSocket monitoring
      final wsStream = _repository.monitorEcoDeposit();
      _wsSubscription = wsStream.listen(
        (verification) {
          add(EcoDepositVerificationReceived(verification: verification));
        },
        onError: (error) {
          emit(EcoDepositError(
            failure: NetworkFailure(error.toString()),
            context: 'WebSocket monitoring error',
          ));
        },
      );

      // Start monitoring for this specific deposit
      _repository.startMonitoring(
        currency: event.currency,
        chain: event.chain,
        address: event.contractType == 'NO_PERMIT' ? event.address : null,
      );

      // Set timeout timer
      _timeoutTimer = Timer(Duration(minutes: timeoutMinutes), () {
        if (!isClosed) {
          emit(EcoDepositTimeout(
            contractType: event.contractType,
            timeoutMinutes: timeoutMinutes,
          ));
          _stopMonitoring();
        }
      });
    } catch (e) {
      emit(EcoDepositError(
        failure: ServerFailure(e.toString()),
        context: 'Failed to start monitoring',
      ));
    }
  }

  Future<void> _onVerificationReceived(
    EcoDepositVerificationReceived event,
    Emitter<EcoDepositState> emit,
  ) async {
    final verification = event.verification;

    if (verification.isSuccessful) {
      // Successful deposit verification
      _stopMonitoring();

      // If NO_PERMIT, unlock the address
      if (state is EcoDepositMonitoring) {
        final monitoringState = state as EcoDepositMonitoring;
        if (monitoringState.contractType == 'NO_PERMIT') {
          // Auto-unlock the address
          add(EcoDepositAddressUnlocked(address: monitoringState.address));
        }
      }

      emit(EcoDepositVerified(
        verification: verification,
        newBalance: verification.balance ?? 0.0,
      ));
    } else {
      // Error in verification
      emit(EcoDepositError(
        failure: ServerFailure(verification.message),
        context: 'Deposit verification failed',
      ));
    }
  }

  Future<void> _onAddressUnlocked(
    EcoDepositAddressUnlocked event,
    Emitter<EcoDepositState> emit,
  ) async {
    try {
      await _repository.unlockAddress(event.address);
      emit(EcoAddressUnlocked(address: event.address));
    } catch (e) {
      // Don't emit error for unlock failure, just log it
      dev.log('🔓 ECO_BLOC: Failed to unlock address ${event.address}: $e');
    }
  }

  void _onReset(EcoDepositReset event, Emitter<EcoDepositState> emit) {
    _stopMonitoring();
    emit(const EcoDepositInitial());
  }

  void _onRetryRequested(
    EcoDepositRetryRequested event,
    Emitter<EcoDepositState> emit,
  ) {
    _stopMonitoring();
    add(const EcoDepositCurrenciesRequested());
  }

  void _onMonitoringStopped(
    EcoDepositMonitoringStopped event,
    Emitter<EcoDepositState> emit,
  ) {
    _stopMonitoring();
    emit(const EcoDepositInitial());
  }

  void _stopMonitoring() {
    _wsSubscription?.cancel();
    _wsSubscription = null;
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _repository.stopMonitoring();
  }

  int _getTimeoutMinutes(String contractType) {
    switch (contractType.toUpperCase()) {
      case 'NO_PERMIT':
        return 2; // Shorter timeout due to address locking
      case 'PERMIT':
      case 'NATIVE':
        return 10; // Standard timeout
      default:
        return 5; // Default fallback
    }
  }

  @override
  Future<void> close() {
    _stopMonitoring();
    return super.close();
  }
}
