import 'package:equatable/equatable.dart';
import '../../domain/entities/pool_analytics_entity.dart';

abstract class PoolAnalyticsState extends Equatable {
  const PoolAnalyticsState();

  @override
  List<Object?> get props => [];
}

class PoolAnalyticsInitial extends PoolAnalyticsState {
  const PoolAnalyticsInitial();
}

class PoolAnalyticsLoading extends PoolAnalyticsState {
  const PoolAnalyticsLoading();
}

class PoolAnalyticsLoaded extends PoolAnalyticsState {
  final PoolAnalyticsEntity analytics;

  const PoolAnalyticsLoaded({required this.analytics});

  @override
  List<Object?> get props => [analytics];
}

class PoolAnalyticsError extends PoolAnalyticsState {
  final String message;

  const PoolAnalyticsError(this.message);

  @override
  List<Object?> get props => [message];
}
