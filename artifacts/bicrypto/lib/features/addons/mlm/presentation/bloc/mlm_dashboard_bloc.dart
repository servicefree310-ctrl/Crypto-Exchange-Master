import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_mlm_dashboard_usecase.dart';
import 'mlm_dashboard_event.dart';
import 'mlm_dashboard_state.dart';

@injectable
class MlmDashboardBloc extends Bloc<MlmDashboardEvent, MlmDashboardState> {
  MlmDashboardBloc(this._getDashboardUseCase)
      : super(const MlmDashboardInitial()) {
    on<MlmDashboardLoadRequested>(_onLoadRequested);
    on<MlmDashboardRefreshRequested>(_onRefreshRequested);
    on<MlmDashboardPeriodChanged>(_onPeriodChanged);
    on<MlmDashboardRetryRequested>(_onRetryRequested);
  }

  final GetMlmDashboardUseCase _getDashboardUseCase;

  Future<void> _onLoadRequested(
    MlmDashboardLoadRequested event,
    Emitter<MlmDashboardState> emit,
  ) async {
    // Don't reload if already loaded with same period and not forced refresh
    if (state is MlmDashboardLoaded && !event.forceRefresh) {
      final loadedState = state as MlmDashboardLoaded;
      if (loadedState.period == event.period) {
        return;
      }
    }

    emit(MlmDashboardLoading(
      message: 'Loading dashboard data...',
      period: event.period,
    ));

    final params = GetMlmDashboardParams(period: event.period);
    final result = await _getDashboardUseCase(params);

    result.fold(
      (failure) => emit(MlmDashboardError(
        failure: failure,
        period: event.period,
      )),
      (dashboard) => emit(MlmDashboardLoaded(
        dashboard: dashboard,
        period: event.period,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onRefreshRequested(
    MlmDashboardRefreshRequested event,
    Emitter<MlmDashboardState> emit,
  ) async {
    // Keep current data visible during refresh
    if (state is MlmDashboardLoaded) {
      final loadedState = state as MlmDashboardLoaded;
      emit(MlmDashboardRefreshing(
        currentDashboard: loadedState.dashboard,
        period: event.period,
      ));
    } else {
      emit(MlmDashboardLoading(
        message: 'Refreshing dashboard...',
        period: event.period,
      ));
    }

    final params = GetMlmDashboardParams(period: event.period);
    final result = await _getDashboardUseCase(params);

    result.fold(
      (failure) {
        // If we were refreshing, preserve the previous data
        if (state is MlmDashboardRefreshing) {
          final refreshingState = state as MlmDashboardRefreshing;
          emit(MlmDashboardError(
            failure: failure,
            period: event.period,
            previousDashboard: refreshingState.currentDashboard,
          ));
        } else {
          emit(MlmDashboardError(
            failure: failure,
            period: event.period,
          ));
        }
      },
      (dashboard) => emit(MlmDashboardLoaded(
        dashboard: dashboard,
        period: event.period,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onPeriodChanged(
    MlmDashboardPeriodChanged event,
    Emitter<MlmDashboardState> emit,
  ) async {
    // Load data for new period
    emit(MlmDashboardLoading(
      message: 'Loading ${event.period} data...',
      period: event.period,
    ));

    final params = GetMlmDashboardParams(period: event.period);
    final result = await _getDashboardUseCase(params);

    result.fold(
      (failure) => emit(MlmDashboardError(
        failure: failure,
        period: event.period,
      )),
      (dashboard) => emit(MlmDashboardLoaded(
        dashboard: dashboard,
        period: event.period,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onRetryRequested(
    MlmDashboardRetryRequested event,
    Emitter<MlmDashboardState> emit,
  ) async {
    emit(MlmDashboardLoading(
      message: 'Retrying...',
      period: event.period,
    ));

    final params = GetMlmDashboardParams(period: event.period);
    final result = await _getDashboardUseCase(params);

    result.fold(
      (failure) => emit(MlmDashboardError(
        failure: failure,
        period: event.period,
      )),
      (dashboard) => emit(MlmDashboardLoaded(
        dashboard: dashboard,
        period: event.period,
        lastUpdated: DateTime.now(),
      )),
    );
  }
}
