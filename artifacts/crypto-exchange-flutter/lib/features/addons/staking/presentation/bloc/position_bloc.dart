import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_user_positions_usecase.dart';
import '../../domain/usecases/withdraw_usecase.dart';
import '../../domain/usecases/claim_rewards_usecase.dart';
import 'position_event.dart';
import 'position_state.dart';

@singleton
class PositionBloc extends Bloc<PositionEvent, PositionState> {
  final GetUserPositionsUseCase _getPositionsUseCase;
  final WithdrawUseCase _withdrawUseCase;
  final ClaimRewardsUseCase _claimRewardsUseCase;
  bool _isLoadingInProgress = false;
  DateTime? _lastLoadTime;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  PositionBloc(
    this._getPositionsUseCase,
    this._withdrawUseCase,
    this._claimRewardsUseCase,
  ) : super(const PositionInitial()) {
    on<LoadUserPositions>(_onLoadUserPositions);
    on<WithdrawRequested>(_onWithdrawRequested);
    on<ClaimRewardsRequested>(_onClaimRewardsRequested);
  }

  Future<void> _onLoadUserPositions(
    LoadUserPositions event,
    Emitter<PositionState> emit,
  ) async {
    final now = DateTime.now();

    if (_isLoadingInProgress) {
      dev.log('🚫 POSITION_BLOC: Blocked duplicate call - already loading');
      return;
    }

    if (!event.forceRefresh &&
        _lastLoadTime != null &&
        now.difference(_lastLoadTime!) < _debounceDelay) {
      dev.log('🚫 POSITION_BLOC: Blocked rapid call - debouncing');
      return;
    }

    dev.log('✅ POSITION_BLOC: Proceeding with API call');
    _isLoadingInProgress = true;
    _lastLoadTime = now;

    emit(const PositionLoading());

    try {
      final result = await _getPositionsUseCase(
        GetUserPositionsParams(
          poolId: event.poolId,
          status: event.status,
        ),
      );
      result.fold(
        (failure) => emit(PositionError(failure.message)),
        (positions) => emit(PositionLoaded(positions: positions)),
      );
    } finally {
      _isLoadingInProgress = false;
    }
  }

  Future<void> _onWithdrawRequested(
    WithdrawRequested event,
    Emitter<PositionState> emit,
  ) async {
    emit(const PositionLoading());
    final result = await _withdrawUseCase(
      WithdrawParams(positionId: event.positionId),
    );
    result.fold(
      (failure) => emit(PositionError(failure.message)),
      (position) {
        // Reload positions after successful withdrawal
        add(const LoadUserPositions(forceRefresh: true));
      },
    );
  }

  Future<void> _onClaimRewardsRequested(
    ClaimRewardsRequested event,
    Emitter<PositionState> emit,
  ) async {
    emit(const PositionLoading());
    final result = await _claimRewardsUseCase(
      ClaimRewardsParams(positionId: event.positionId),
    );
    result.fold(
      (failure) => emit(PositionError(failure.message)),
      (position) {
        // Reload positions after successful claim
        add(const LoadUserPositions(forceRefresh: true));
      },
    );
  }
}
