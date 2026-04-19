import 'package:equatable/equatable.dart';
import '../../domain/entities/staking_pool_entity.dart';

abstract class StakingState extends Equatable {
  const StakingState();

  @override
  List<Object?> get props => [];
}

class StakingInitial extends StakingState {}

class StakingLoading extends StakingState {}

class StakingLoaded extends StakingState {
  final List<StakingPoolEntity> pools;

  const StakingLoaded({required this.pools});

  @override
  List<Object?> get props => [pools];
}

class StakingError extends StakingState {
  final String message;

  const StakingError(this.message);

  @override
  List<Object?> get props => [message];
}
