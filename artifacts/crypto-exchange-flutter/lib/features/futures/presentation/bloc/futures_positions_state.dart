part of 'futures_positions_bloc.dart';

abstract class FuturesPositionsState extends Equatable {
  const FuturesPositionsState();

  @override
  List<Object?> get props => [];
}

class FuturesPositionsInitial extends FuturesPositionsState {
  const FuturesPositionsInitial();
}

class FuturesPositionsLoading extends FuturesPositionsState {
  const FuturesPositionsLoading();
}

class FuturesPositionsLoaded extends FuturesPositionsState {
  const FuturesPositionsLoaded({
    required this.positions,
    this.closingPositionId,
    this.error,
    this.successMessage,
  });

  final List<FuturesPositionEntity> positions;
  final String? closingPositionId;
  final String? error;
  final String? successMessage;

  @override
  List<Object?> get props =>
      [positions, closingPositionId, error, successMessage];
}

class FuturesPositionsError extends FuturesPositionsState {
  const FuturesPositionsError({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
