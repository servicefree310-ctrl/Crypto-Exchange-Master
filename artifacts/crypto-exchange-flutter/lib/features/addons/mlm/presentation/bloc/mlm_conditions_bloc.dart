import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_mlm_conditions_usecase.dart';
import 'mlm_conditions_event.dart';
import 'mlm_conditions_state.dart';

@injectable
class MlmConditionsBloc
    extends Bloc<MlmConditionsEvent, MlmConditionsState> {
  MlmConditionsBloc(this._getConditionsUseCase)
      : super(const MlmConditionsInitial()) {
    on<MlmConditionsLoadRequested>(_onLoadRequested);
    on<MlmConditionsRefreshRequested>(_onRefreshRequested);
    on<MlmConditionsRetryRequested>(_onRetryRequested);
  }

  final GetMlmConditionsUseCase _getConditionsUseCase;

  Future<void> _onLoadRequested(
    MlmConditionsLoadRequested event,
    Emitter<MlmConditionsState> emit,
  ) async {
    if (state is MlmConditionsLoaded && !event.forceRefresh) {
      return;
    }

    emit(const MlmConditionsLoading(message: 'Loading conditions...'));

    final result = await _getConditionsUseCase(const NoParams());

    result.fold(
      (failure) => emit(MlmConditionsError(failure: failure)),
      (conditions) => emit(MlmConditionsLoaded(
        conditions: conditions,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onRefreshRequested(
    MlmConditionsRefreshRequested event,
    Emitter<MlmConditionsState> emit,
  ) async {
    if (state is MlmConditionsLoaded) {
      final loadedState = state as MlmConditionsLoaded;
      emit(MlmConditionsRefreshing(
        currentConditions: loadedState.conditions,
      ));
    } else {
      emit(const MlmConditionsLoading(message: 'Refreshing conditions...'));
    }

    final result = await _getConditionsUseCase(const NoParams());

    result.fold(
      (failure) {
        if (state is MlmConditionsRefreshing) {
          final refreshingState = state as MlmConditionsRefreshing;
          emit(MlmConditionsError(
            failure: failure,
            previousConditions: refreshingState.currentConditions,
          ));
        } else {
          emit(MlmConditionsError(failure: failure));
        }
      },
      (conditions) => emit(MlmConditionsLoaded(
        conditions: conditions,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onRetryRequested(
    MlmConditionsRetryRequested event,
    Emitter<MlmConditionsState> emit,
  ) async {
    emit(const MlmConditionsLoading(message: 'Retrying...'));

    final result = await _getConditionsUseCase(const NoParams());

    result.fold(
      (failure) => emit(MlmConditionsError(failure: failure)),
      (conditions) => emit(MlmConditionsLoaded(
        conditions: conditions,
        lastUpdated: DateTime.now(),
      )),
    );
  }
}
