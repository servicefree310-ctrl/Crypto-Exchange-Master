import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/manage_fullscreen_state_usecase.dart';

// Events
abstract class FullscreenEvent extends Equatable {
  const FullscreenEvent();

  @override
  List<Object> get props => [];
}

class FullscreenStateInitialized extends FullscreenEvent {
  const FullscreenStateInitialized({
    this.initialTradingPanel = true,
    this.initialOrderBook = false,
    this.initialTradingInfo = false,
  });

  final bool initialTradingPanel;
  final bool initialOrderBook;
  final bool initialTradingInfo;

  @override
  List<Object> get props =>
      [initialTradingPanel, initialOrderBook, initialTradingInfo];
}

class FullscreenTradingPanelToggled extends FullscreenEvent {
  const FullscreenTradingPanelToggled();
}

class FullscreenOrderBookToggled extends FullscreenEvent {
  const FullscreenOrderBookToggled();
}

class FullscreenTradingInfoToggled extends FullscreenEvent {
  const FullscreenTradingInfoToggled();
}

// States
abstract class FullscreenBlocState extends Equatable {
  const FullscreenBlocState();

  @override
  List<Object> get props => [];
}

class FullscreenInitial extends FullscreenBlocState {
  const FullscreenInitial();
}

class FullscreenLoaded extends FullscreenBlocState {
  const FullscreenLoaded({required this.fullscreenState});

  final FullscreenState fullscreenState;

  @override
  List<Object> get props => [fullscreenState];
}

class FullscreenError extends FullscreenBlocState {
  const FullscreenError({required this.failure});

  final Failure failure;

  @override
  List<Object> get props => [failure];
}

@injectable
class FullscreenBloc extends Bloc<FullscreenEvent, FullscreenBlocState> {
  FullscreenBloc(this._manageFullscreenStateUseCase)
      : super(const FullscreenInitial()) {
    on<FullscreenTradingPanelToggled>(_onTradingPanelToggled);
    on<FullscreenOrderBookToggled>(_onOrderBookToggled);
    on<FullscreenTradingInfoToggled>(_onTradingInfoToggled);
    on<FullscreenStateInitialized>(_onStateInitialized);
  }

  final ManageFullscreenStateUseCase _manageFullscreenStateUseCase;

  Future<void> _onStateInitialized(
    FullscreenStateInitialized event,
    Emitter<FullscreenBlocState> emit,
  ) async {
    emit(FullscreenLoaded(
      fullscreenState: FullscreenState(
        showTradingPanel: event.initialTradingPanel,
        showOrderBook: event.initialOrderBook,
        showTradingInfo: event.initialTradingInfo,
      ),
    ));
  }

  Future<void> _onTradingPanelToggled(
    FullscreenTradingPanelToggled event,
    Emitter<FullscreenBlocState> emit,
  ) async {
    if (state is FullscreenLoaded) {
      final currentState = (state as FullscreenLoaded).fullscreenState;

      final result = await _manageFullscreenStateUseCase(ManageFullscreenParams(
        currentState: currentState,
        showTradingPanel: !currentState.showTradingPanel,
      ));

      result.fold(
        (failure) => emit(FullscreenError(failure: failure)),
        (newState) => emit(FullscreenLoaded(fullscreenState: newState)),
      );
    }
  }

  Future<void> _onOrderBookToggled(
    FullscreenOrderBookToggled event,
    Emitter<FullscreenBlocState> emit,
  ) async {
    if (state is FullscreenLoaded) {
      final currentState = (state as FullscreenLoaded).fullscreenState;

      final result = await _manageFullscreenStateUseCase(ManageFullscreenParams(
        currentState: currentState,
        showOrderBook: !currentState.showOrderBook,
      ));

      result.fold(
        (failure) => emit(FullscreenError(failure: failure)),
        (newState) => emit(FullscreenLoaded(fullscreenState: newState)),
      );
    }
  }

  Future<void> _onTradingInfoToggled(
    FullscreenTradingInfoToggled event,
    Emitter<FullscreenBlocState> emit,
  ) async {
    if (state is FullscreenLoaded) {
      final currentState = (state as FullscreenLoaded).fullscreenState;

      final result = await _manageFullscreenStateUseCase(ManageFullscreenParams(
        currentState: currentState,
        showTradingInfo: !currentState.showTradingInfo,
      ));

      result.fold(
        (failure) => emit(FullscreenError(failure: failure)),
        (newState) => emit(FullscreenLoaded(fullscreenState: newState)),
      );
    }
  }
}
