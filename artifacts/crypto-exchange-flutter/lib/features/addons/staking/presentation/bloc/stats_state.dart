import 'package:equatable/equatable.dart';
import '../../domain/entities/staking_stats_entity.dart';

/// State for StatsBloc
abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class StatsInitial extends StatsState {
  const StatsInitial();
}

/// Loading state
class StatsLoading extends StatsState {
  const StatsLoading();
}

/// Loaded state with statistics data
class StatsLoaded extends StatsState {
  final StakingStatsEntity stats;

  const StatsLoaded({required this.stats});

  @override
  List<Object?> get props => [stats];
}

/// Error state
class StatsError extends StatsState {
  final String message;

  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}
