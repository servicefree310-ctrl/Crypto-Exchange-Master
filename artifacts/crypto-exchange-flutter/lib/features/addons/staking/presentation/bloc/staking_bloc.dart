import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_staking_pools_usecase.dart';
import 'staking_event.dart';
import 'staking_state.dart';

@singleton
class StakingBloc extends Bloc<StakingEvent, StakingState> {
  final GetStakingPoolsUseCase _getPoolsUseCase;
  bool _isLoadingInProgress = false;
  DateTime? _lastLoadTime;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  StakingBloc(this._getPoolsUseCase) : super(StakingInitial()) {
    on<LoadStakingData>(_onLoadData);
  }

  Future<void> _onLoadData(
    LoadStakingData event,
    Emitter<StakingState> emit,
  ) async {
    final now = DateTime.now();

    if (_isLoadingInProgress) {
      dev.log('🚫 STAKING_BLOC: Blocked duplicate call - already loading');
      return;
    }

    if (!event.forceRefresh &&
        _lastLoadTime != null &&
        now.difference(_lastLoadTime!) < _debounceDelay) {
      dev.log('🚫 STAKING_BLOC: Blocked rapid call - debouncing');
      return;
    }

    dev.log('✅ STAKING_BLOC: Proceeding with API call');
    _isLoadingInProgress = true;
    _lastLoadTime = now;

    emit(StakingLoading());

    try {
      final params = GetStakingPoolsParams(
        status: event.status,
        minApr: event.minApr,
        maxApr: event.maxApr,
        token: event.token,
      );
      final result = await _getPoolsUseCase(params);
      result.fold(
        (failure) => emit(StakingError(failure.message)),
        (pools) => emit(StakingLoaded(pools: pools)),
      );
    } finally {
      _isLoadingInProgress = false;
    }
  }
}
