import 'package:equatable/equatable.dart';

abstract class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

/// Trigger loading of staking statistics
class LoadStakingStats extends StatsEvent {
  final bool forceRefresh;

  const LoadStakingStats({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}
