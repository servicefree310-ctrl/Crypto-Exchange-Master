import 'package:equatable/equatable.dart';

abstract class MlmDashboardEvent extends Equatable {
  const MlmDashboardEvent();

  @override
  List<Object?> get props => [];
}

class MlmDashboardLoadRequested extends MlmDashboardEvent {
  const MlmDashboardLoadRequested({
    this.period = '6m',
    this.forceRefresh = false,
  });

  final String period;
  final bool forceRefresh;

  @override
  List<Object?> get props => [period, forceRefresh];
}

class MlmDashboardRefreshRequested extends MlmDashboardEvent {
  const MlmDashboardRefreshRequested({
    this.period = '6m',
  });

  final String period;

  @override
  List<Object?> get props => [period];
}

class MlmDashboardPeriodChanged extends MlmDashboardEvent {
  const MlmDashboardPeriodChanged({
    required this.period,
  });

  final String period;

  @override
  List<Object?> get props => [period];
}

class MlmDashboardRetryRequested extends MlmDashboardEvent {
  const MlmDashboardRetryRequested({
    this.period = '6m',
  });

  final String period;

  @override
  List<Object?> get props => [period];
}
