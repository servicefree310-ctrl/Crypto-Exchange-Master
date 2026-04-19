import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_spot_currencies_usecase.dart';
import '../../domain/usecases/get_spot_networks_usecase.dart';
import '../../domain/usecases/generate_spot_deposit_address_usecase.dart';
import '../../domain/usecases/create_spot_deposit_usecase.dart';
import '../../domain/usecases/verify_spot_deposit_usecase.dart';
import 'spot_deposit_event.dart';
import 'spot_deposit_state.dart';

@injectable
class SpotDepositBloc extends Bloc<SpotDepositEvent, SpotDepositState> {
  SpotDepositBloc(
    this._getSpotCurrenciesUseCase,
    this._getSpotNetworksUseCase,
    this._generateSpotDepositAddressUseCase,
    this._createSpotDepositUseCase,
    this._verifySpotDepositUseCase,
  ) : super(const SpotDepositInitial()) {
    on<SpotCurrenciesRequested>(_onSpotCurrenciesRequested);
    on<SpotNetworksRequested>(_onSpotNetworksRequested);
    on<SpotDepositAddressRequested>(_onSpotDepositAddressRequested);
    on<SpotDepositCreated>(_onSpotDepositCreated);
    on<SpotDepositVerificationStarted>(_onSpotDepositVerificationStarted);
    on<SpotDepositVerificationStopped>(_onSpotDepositVerificationStopped);
    on<SpotDepositReset>(_onSpotDepositReset);
  }

  final GetSpotCurrenciesUseCase _getSpotCurrenciesUseCase;
  final GetSpotNetworksUseCase _getSpotNetworksUseCase;
  final GenerateSpotDepositAddressUseCase _generateSpotDepositAddressUseCase;
  final CreateSpotDepositUseCase _createSpotDepositUseCase;
  final VerifySpotDepositUseCase _verifySpotDepositUseCase;

  StreamSubscription? _verificationSubscription;

  @override
  Future<void> close() {
    _verificationSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSpotCurrenciesRequested(
    SpotCurrenciesRequested event,
    Emitter<SpotDepositState> emit,
  ) async {
    dev.log('📱 SPOT_BLOC: Loading currencies...');
    emit(const SpotDepositLoading());

    final result = await _getSpotCurrenciesUseCase(NoParams());
    result.fold(
      (failure) {
        dev.log('❌ SPOT_BLOC: Currency load failed - ${failure.message}');
        emit(SpotDepositError(failure));
      },
      (currencies) {
        dev.log('✅ SPOT_BLOC: Loaded ${currencies.length} currencies');
        emit(SpotCurrenciesLoaded(currencies));
      },
    );
  }

  Future<void> _onSpotNetworksRequested(
    SpotNetworksRequested event,
    Emitter<SpotDepositState> emit,
  ) async {
    dev.log('📱 SPOT_BLOC: Loading networks for ${event.currency}...');
    emit(const SpotDepositLoading());

    final result = await _getSpotNetworksUseCase(
      GetSpotNetworksParams(currency: event.currency),
    );
    result.fold(
      (failure) {
        dev.log(
            '❌ SPOT_BLOC: No networks found for ${event.currency} - ${failure.message}');
        emit(SpotDepositError(failure));
      },
      (networks) {
        dev.log(
            '✅ SPOT_BLOC: Loaded ${networks.length} networks for ${event.currency}');
        emit(SpotNetworksLoaded(networks));
      },
    );
  }

  Future<void> _onSpotDepositAddressRequested(
    SpotDepositAddressRequested event,
    Emitter<SpotDepositState> emit,
  ) async {
    emit(const SpotDepositLoading());

    final result = await _generateSpotDepositAddressUseCase(
      GenerateSpotDepositAddressParams(
        currency: event.currency,
        network: event.network,
      ),
    );
    result.fold(
      (failure) => emit(SpotDepositError(failure)),
      (address) => emit(SpotDepositAddressGenerated(address)),
    );
  }

  Future<void> _onSpotDepositCreated(
    SpotDepositCreated event,
    Emitter<SpotDepositState> emit,
  ) async {
    dev.log(
        '📱 SPOT_BLOC: Creating deposit - ${event.currency}/${event.chain} - ${event.transactionHash}');
    dev.log('📱 SPOT_BLOC: Current state before creation: ${state.runtimeType}');

    // Prevent multiple simultaneous deposit creations
    if (state is SpotDepositLoading) {
      dev.log('🛑 SPOT_BLOC: Already processing a request, ignoring duplicate');
      return;
    }

    emit(const SpotDepositLoading());

    final result = await _createSpotDepositUseCase(
      CreateSpotDepositParams(
        currency: event.currency,
        chain: event.chain,
        transactionHash: event.transactionHash,
      ),
    );
    result.fold(
      (failure) {
        dev.log('❌ SPOT_BLOC: Deposit creation failed - ${failure.message}');
        emit(SpotDepositError(failure));
      },
      (transaction) {
        dev.log('✅ SPOT_BLOC: Deposit created - ID: ${transaction.id}');
        emit(SpotDepositTransactionCreated(transaction));
      },
    );
  }

  void _onSpotDepositVerificationStarted(
    SpotDepositVerificationStarted event,
    Emitter<SpotDepositState> emit,
  ) {
    emit(SpotDepositVerifying(event.transactionId, 'Starting verification...'));

    _verificationSubscription?.cancel();
    _verificationSubscription = _verifySpotDepositUseCase(
      VerifySpotDepositParams(transactionId: event.transactionId),
    ).listen(
      (result) {
        if (result.isCompleted) {
          emit(SpotDepositVerified(result));
          _verificationSubscription?.cancel();
        } else if (result.isError) {
          emit(SpotDepositNetworkError(result.message));
        } else {
          emit(SpotDepositVerifying(
            event.transactionId,
            result.message,
          ));
        }
      },
      onError: (error) {
        emit(SpotDepositNetworkError('Verification failed: $error'));
        _verificationSubscription?.cancel();
      },
    );
  }

  void _onSpotDepositVerificationStopped(
    SpotDepositVerificationStopped event,
    Emitter<SpotDepositState> emit,
  ) {
    _verificationSubscription?.cancel();
    emit(const SpotDepositInitial());
  }

  void _onSpotDepositReset(
    SpotDepositReset event,
    Emitter<SpotDepositState> emit,
  ) {
    _verificationSubscription?.cancel();
    emit(const SpotDepositInitial());
  }
}
