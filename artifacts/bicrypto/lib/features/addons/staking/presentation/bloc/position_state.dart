import 'package:equatable/equatable.dart';
import '../../domain/entities/staking_position_entity.dart';

abstract class PositionState extends Equatable {
  const PositionState();

  @override
  List<Object?> get props => [];
}

class PositionInitial extends PositionState {
  const PositionInitial();
}

class PositionLoading extends PositionState {
  const PositionLoading();
}

class PositionLoaded extends PositionState {
  final List<StakingPositionEntity> positions;

  const PositionLoaded({required this.positions});

  @override
  List<Object?> get props => [positions];
}

class PositionError extends PositionState {
  final String message;

  const PositionError(this.message);

  @override
  List<Object?> get props => [message];
}
