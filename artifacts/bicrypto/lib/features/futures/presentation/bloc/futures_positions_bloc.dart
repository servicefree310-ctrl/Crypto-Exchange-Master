import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/futures_position_entity.dart';
import '../../domain/usecases/get_futures_positions_usecase.dart';
import '../../domain/usecases/close_position_usecase.dart';

part 'futures_positions_event.dart';
part 'futures_positions_state.dart';

@injectable
class FuturesPositionsBloc
    extends Bloc<FuturesPositionsEvent, FuturesPositionsState> {
  FuturesPositionsBloc(
    this._getPositionsUseCase,
    this._closePositionUseCase,
  ) : super(const FuturesPositionsInitial()) {
    on<FuturesPositionsLoadRequested>(_onLoadRequested);
    on<FuturesPositionsRefreshRequested>(_onRefreshRequested);
    on<FuturesPositionCloseRequested>(_onCloseRequested);
  }

  final GetFuturesPositionsUseCase _getPositionsUseCase;
  final ClosePositionUseCase _closePositionUseCase;

  Future<void> _onLoadRequested(
    FuturesPositionsLoadRequested event,
    Emitter<FuturesPositionsState> emit,
  ) async {
    emit(const FuturesPositionsLoading());

    final params = GetFuturesPositionsParams(symbol: event.symbol);
    final result = await _getPositionsUseCase(params);

    result.fold(
      (failure) => emit(FuturesPositionsError(failure: failure)),
      (positions) => emit(FuturesPositionsLoaded(positions: positions)),
    );
  }

  Future<void> _onRefreshRequested(
    FuturesPositionsRefreshRequested event,
    Emitter<FuturesPositionsState> emit,
  ) async {
    final params = GetFuturesPositionsParams(symbol: event.symbol);
    final result = await _getPositionsUseCase(params);

    result.fold(
      (failure) => emit(FuturesPositionsError(failure: failure)),
      (positions) => emit(FuturesPositionsLoaded(positions: positions)),
    );
  }

  Future<void> _onCloseRequested(
    FuturesPositionCloseRequested event,
    Emitter<FuturesPositionsState> emit,
  ) async {
    // Keep current positions in state while closing
    if (state is FuturesPositionsLoaded) {
      final currentState = state as FuturesPositionsLoaded;

      // Show loading for the specific position
      emit(FuturesPositionsLoaded(
        positions: currentState.positions,
        closingPositionId: event.positionId,
      ));

      final closeParams = ClosePositionParams(
        positionId: event.positionId,
        symbol: event.symbol,
        side: event.side,
      );
      final closeResult = await _closePositionUseCase(closeParams);

      await closeResult.fold(
        (failure) async {
          // Show error but keep current state
          emit(FuturesPositionsLoaded(
            positions: currentState.positions,
            error: 'Failed to close position: ${failure.message}',
          ));
        },
        (closedPosition) async {
          // Reload positions to get updated list
          final params = GetFuturesPositionsParams(symbol: event.symbol);
          final result = await _getPositionsUseCase(params);

          result.fold(
            (failure) => emit(FuturesPositionsError(failure: failure)),
            (positions) => emit(FuturesPositionsLoaded(
              positions: positions,
              successMessage: 'Position closed successfully',
            )),
          );
        },
      );
    }
  }
}
