import 'package:equatable/equatable.dart';

abstract class PoolAnalyticsEvent extends Equatable {
  const PoolAnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load analytics for a pool
class LoadPoolAnalytics extends PoolAnalyticsEvent {
  final String poolId;
  final String timeframe;

  const LoadPoolAnalytics({required this.poolId, this.timeframe = 'month'});

  @override
  List<Object?> get props => [poolId, timeframe];
}
