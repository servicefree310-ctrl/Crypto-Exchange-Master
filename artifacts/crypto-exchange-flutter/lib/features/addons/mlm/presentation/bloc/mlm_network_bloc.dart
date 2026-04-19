import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_mlm_network_usecase.dart';
import '../../../../../core/usecases/usecase.dart';
import 'mlm_network_event.dart';
import 'mlm_network_state.dart';

@injectable
class MlmNetworkBloc extends Bloc<MlmNetworkEvent, MlmNetworkState> {
  MlmNetworkBloc(this._getNetworkUseCase) : super(const MlmNetworkInitial()) {
    on<MlmNetworkLoadRequested>(_onLoadRequested);
    on<MlmNetworkRefreshRequested>(_onRefreshRequested);
    on<MlmNetworkRetryRequested>(_onRetryRequested);
  }

  final GetMlmNetworkUseCase _getNetworkUseCase;

  Future<void> _onLoadRequested(
    MlmNetworkLoadRequested event,
    Emitter<MlmNetworkState> emit,
  ) async {
    // Don't reload if already loaded unless forced
    if (state is MlmNetworkLoaded && !event.forceRefresh) {
      return;
    }

    emit(const MlmNetworkLoading());

    final result = await _getNetworkUseCase(NoParams());

    result.fold(
      (failure) => emit(MlmNetworkError(failure: failure)),
      (network) => emit(MlmNetworkLoaded(network: network)),
    );
  }

  Future<void> _onRefreshRequested(
    MlmNetworkRefreshRequested event,
    Emitter<MlmNetworkState> emit,
  ) async {
    // Keep current data visible during refresh
    if (state is MlmNetworkLoaded) {
      final loadedState = state as MlmNetworkLoaded;
      emit(MlmNetworkRefreshing(currentNetwork: loadedState.network));
    } else {
      emit(const MlmNetworkLoading());
    }

    final result = await _getNetworkUseCase(NoParams());

    result.fold(
      (failure) {
        // If we were refreshing, preserve the previous data
        if (state is MlmNetworkRefreshing) {
          final refreshingState = state as MlmNetworkRefreshing;
          emit(MlmNetworkError(
            failure: failure,
            previousNetwork: refreshingState.currentNetwork,
          ));
        } else {
          emit(MlmNetworkError(failure: failure));
        }
      },
      (network) => emit(MlmNetworkLoaded(network: network)),
    );
  }

  Future<void> _onRetryRequested(
    MlmNetworkRetryRequested event,
    Emitter<MlmNetworkState> emit,
  ) async {
    emit(const MlmNetworkLoading());

    final result = await _getNetworkUseCase(NoParams());

    result.fold(
      (failure) => emit(MlmNetworkError(failure: failure)),
      (network) => emit(MlmNetworkLoaded(network: network)),
    );
  }
}
