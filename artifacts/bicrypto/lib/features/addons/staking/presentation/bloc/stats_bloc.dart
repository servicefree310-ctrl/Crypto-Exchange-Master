import 'dart:developer' as dev;

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:mobile/core/usecases/usecase.dart';
import '../../domain/usecases/get_staking_stats_usecase.dart';
import 'stats_event.dart';
import 'stats_state.dart';

/// Bloc to manage staking statistics overview
@singleton
class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final GetStakingStatsUseCase _getStatsUseCase;
  bool _isLoadingInProgress = false;
  DateTime? _lastLoadTime;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  StatsBloc(this._getStatsUseCase) : super(const StatsInitial()) {
    on<LoadStakingStats>(_onLoadStakingStats);
  }

  Future<void> _onLoadStakingStats(
    LoadStakingStats event,
    Emitter<StatsState> emit,
  ) async {
    final now = DateTime.now();

    if (_isLoadingInProgress) {
      dev.log('🚫 STATS_BLOC: Blocked duplicate call - already loading');
      return;
    }

    if (!event.forceRefresh &&
        _lastLoadTime != null &&
        now.difference(_lastLoadTime!) < _debounceDelay) {
      dev.log('🚫 STATS_BLOC: Blocked rapid call - debouncing');
      return;
    }

    dev.log('✅ STATS_BLOC: Proceeding with API call');
    _isLoadingInProgress = true;
    _lastLoadTime = now;

    emit(const StatsLoading());

    try {
      final result = await _getStatsUseCase(NoParams());
      result.fold(
        (failure) => emit(StatsError(failure.message)),
        (stats) => emit(StatsLoaded(stats: stats)),
      );
    } finally {
      _isLoadingInProgress = false;
    }
  }
}
