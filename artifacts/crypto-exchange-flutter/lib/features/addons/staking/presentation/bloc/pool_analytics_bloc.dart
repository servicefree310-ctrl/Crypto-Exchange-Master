import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_pool_analytics_usecase.dart';
import 'pool_analytics_event.dart';
import 'pool_analytics_state.dart';

@injectable
class PoolAnalyticsBloc extends Bloc<PoolAnalyticsEvent, PoolAnalyticsState> {
  final GetPoolAnalyticsUseCase _getAnalytics;

  PoolAnalyticsBloc(this._getAnalytics) : super(const PoolAnalyticsInitial()) {
    on<LoadPoolAnalytics>(_onLoadAnalytics);
  }

  Future<void> _onLoadAnalytics(
      LoadPoolAnalytics event, Emitter<PoolAnalyticsState> emit) async {
    emit(const PoolAnalyticsLoading());
    final result = await _getAnalytics(
      GetPoolAnalyticsParams(
        poolId: event.poolId,
        timeframe: event.timeframe,
      ),
    );
    result.fold(
      (failure) => emit(PoolAnalyticsError(failure.message)),
      (analytics) => emit(PoolAnalyticsLoaded(analytics: analytics)),
    );
  }
}
