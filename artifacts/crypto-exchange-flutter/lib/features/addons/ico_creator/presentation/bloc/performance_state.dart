part of 'performance_cubit.dart';

abstract class PerformanceState extends Equatable {
  const PerformanceState();
  @override
  List<Object?> get props => [];
}

class PerformanceInitial extends PerformanceState {
  const PerformanceInitial();
}

class PerformanceLoading extends PerformanceState {
  const PerformanceLoading();
}

class PerformanceLoaded extends PerformanceState {
  const PerformanceLoaded(this.range, this.data);

  final String range;
  final List<ChartPointEntity> data;

  @override
  List<Object?> get props => [range, data];
}

class PerformanceError extends PerformanceState {
  const PerformanceError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
