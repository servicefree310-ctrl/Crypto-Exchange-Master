import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_mlm_landing_usecase.dart';
import 'mlm_landing_event.dart';
import 'mlm_landing_state.dart';

@injectable
class MlmLandingBloc extends Bloc<MlmLandingEvent, MlmLandingState> {
  MlmLandingBloc(this._getLandingUseCase) : super(const MlmLandingInitial()) {
    on<MlmLandingLoadRequested>(_onLoadRequested);
    on<MlmLandingRefreshRequested>(_onRefreshRequested);
    on<MlmLandingRetryRequested>(_onRetryRequested);
  }

  final GetMlmLandingUseCase _getLandingUseCase;

  Future<void> _onLoadRequested(
    MlmLandingLoadRequested event,
    Emitter<MlmLandingState> emit,
  ) async {
    if (state is MlmLandingLoaded) return;

    emit(const MlmLandingLoading(message: 'Loading affiliate program...'));

    final result = await _getLandingUseCase();

    result.fold(
      (failure) => emit(MlmLandingError(failure: failure)),
      (landing) => emit(MlmLandingLoaded(
        landing: landing,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onRefreshRequested(
    MlmLandingRefreshRequested event,
    Emitter<MlmLandingState> emit,
  ) async {
    if (state is MlmLandingLoaded) {
      final loadedState = state as MlmLandingLoaded;
      emit(MlmLandingRefreshing(currentLanding: loadedState.landing));
    } else {
      emit(const MlmLandingLoading(message: 'Refreshing...'));
    }

    final result = await _getLandingUseCase();

    result.fold(
      (failure) {
        if (state is MlmLandingRefreshing) {
          final refreshingState = state as MlmLandingRefreshing;
          emit(MlmLandingError(
            failure: failure,
            previousLanding: refreshingState.currentLanding,
          ));
        } else {
          emit(MlmLandingError(failure: failure));
        }
      },
      (landing) => emit(MlmLandingLoaded(
        landing: landing,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onRetryRequested(
    MlmLandingRetryRequested event,
    Emitter<MlmLandingState> emit,
  ) async {
    emit(const MlmLandingLoading(message: 'Retrying...'));

    final result = await _getLandingUseCase();

    result.fold(
      (failure) => emit(MlmLandingError(failure: failure)),
      (landing) => emit(MlmLandingLoaded(
        landing: landing,
        lastUpdated: DateTime.now(),
      )),
    );
  }
}
