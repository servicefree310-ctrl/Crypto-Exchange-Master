part of 'stats_cubit.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {
  const StatsInitial();
}

class StatsLoading extends StatsState {
  const StatsLoading();
}

class StatsLoaded extends StatsState {
  const StatsLoaded(this.stats);

  final CreatorStatsEntity stats;

  @override
  List<Object?> get props => [stats];
}

class StatsError extends StatsState {
  const StatsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
