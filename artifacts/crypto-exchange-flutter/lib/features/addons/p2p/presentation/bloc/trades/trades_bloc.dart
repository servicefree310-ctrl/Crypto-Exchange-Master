import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

import 'trades_event.dart';
import 'trades_state.dart';
import '../../../domain/usecases/trades/get_trades_usecase.dart';
import '../../../../../../../core/errors/failures.dart';

@injectable
class TradesBloc extends Bloc<TradesEvent, TradesState> {
  TradesBloc(this._getTradesUseCase) : super(const TradesInitial()) {
    on<TradesRequested>(_onRequested);
    on<TradesLoadMoreRequested>(_onLoadMore);
    on<TradesFilterChanged>(_onFilterChanged);
  }

  final GetTradesUseCase _getTradesUseCase;

  // Keep track of current pagination/filter state
  String? _currentStatusFilter;
  int _currentOffset = 0;
  static const _pageSize = 20;
  bool _hasMore = true;

  Future<void> _onRequested(
    TradesRequested event,
    Emitter<TradesState> emit,
  ) async {
    if (event.refresh) {
      _currentOffset = 0;
      _hasMore = true;
      emit(const TradesLoading(isRefresh: true));
    } else {
      emit(const TradesLoading());
    }

    final params = GetTradesParams(
      status: _currentStatusFilter,
      limit: _pageSize,
      offset: _currentOffset,
      includeStats: true,
      includeActivity: true,
    );

    final result = await _getTradesUseCase(params);

    result.fold<FutureOr<void>>(
      (Failure failure) async => emit(TradesError(failure)),
      (P2PTradesResponse response) async {
        _currentOffset += _pageSize;
        // If we didn't get enough items for at least one category, assume no further pages.
        final totalFetched = response.activeTrades.length +
            response.pendingTrades.length +
            response.completedTrades.length +
            response.disputedTrades.length;
        _hasMore = totalFetched >= _pageSize;
        emit(TradesLoaded(response, canLoadMore: _hasMore));
      },
    );
  }

  Future<void> _onLoadMore(
    TradesLoadMoreRequested event,
    Emitter<TradesState> emit,
  ) async {
    if (!_hasMore || state is! TradesLoaded) return;

    final currentState = state as TradesLoaded;
    // Emit loading with current data (for list append loading indicator)
    emit(TradesLoaded(currentState.response, canLoadMore: false));

    final params = GetTradesParams(
      status: _currentStatusFilter,
      limit: _pageSize,
      offset: _currentOffset,
      includeStats: false,
      includeActivity: false,
    );

    final result = await _getTradesUseCase(params);
    result.fold<FutureOr<void>>(
      (failure) async {
        // Keep previous data but expose error via separate mechanism
        emit(TradesLoaded(currentState.response, canLoadMore: false));
      },
      (response) async {
        // Merge lists (simplified: just append active/pending/completed/disputed etc.)
        final merged = _mergeResponses(currentState.response, response);
        _currentOffset += _pageSize;
        final totalFetched = response.activeTrades.length +
            response.pendingTrades.length +
            response.completedTrades.length +
            response.disputedTrades.length;
        _hasMore = totalFetched >= _pageSize;
        emit(TradesLoaded(merged, canLoadMore: _hasMore));
      },
    );
  }

  Future<void> _onFilterChanged(
    TradesFilterChanged event,
    Emitter<TradesState> emit,
  ) async {
    _currentStatusFilter = event.status;
    add(const TradesRequested());
  }

  // Merge additional paginated response into existing one (simplified)
  P2PTradesResponse _mergeResponses(
    P2PTradesResponse existing,
    P2PTradesResponse next,
  ) {
    return P2PTradesResponse(
      tradeStats: existing.tradeStats,
      recentActivity: existing.recentActivity,
      activeTrades: existing.activeTrades + next.activeTrades,
      pendingTrades: existing.pendingTrades + next.pendingTrades,
      completedTrades: existing.completedTrades + next.completedTrades,
      disputedTrades: existing.disputedTrades + next.disputedTrades,
    );
  }
}
