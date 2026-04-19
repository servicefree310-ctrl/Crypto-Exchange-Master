import 'package:equatable/equatable.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/mlm_dashboard_entity.dart';

abstract class MlmDashboardState extends Equatable {
  const MlmDashboardState();

  @override
  List<Object?> get props => [];
}

class MlmDashboardInitial extends MlmDashboardState {
  const MlmDashboardInitial();
}

class MlmDashboardLoading extends MlmDashboardState {
  const MlmDashboardLoading({
    this.message,
    this.period = '6m',
  });

  final String? message;
  final String period;

  @override
  List<Object?> get props => [message, period];
}

class MlmDashboardLoaded extends MlmDashboardState {
  const MlmDashboardLoaded({
    required this.dashboard,
    required this.period,
    this.lastUpdated,
  });

  final MlmDashboardEntity dashboard;
  final String period;
  final DateTime? lastUpdated;

  @override
  List<Object?> get props => [dashboard, period, lastUpdated];

  MlmDashboardLoaded copyWith({
    MlmDashboardEntity? dashboard,
    String? period,
    DateTime? lastUpdated,
  }) {
    return MlmDashboardLoaded(
      dashboard: dashboard ?? this.dashboard,
      period: period ?? this.period,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class MlmDashboardRefreshing extends MlmDashboardState {
  const MlmDashboardRefreshing({
    required this.currentDashboard,
    required this.period,
  });

  final MlmDashboardEntity currentDashboard;
  final String period;

  @override
  List<Object?> get props => [currentDashboard, period];
}

class MlmDashboardError extends MlmDashboardState {
  const MlmDashboardError({
    required this.failure,
    this.period = '6m',
    this.previousDashboard,
  });

  final Failure failure;
  final String period;
  final MlmDashboardEntity? previousDashboard;

  @override
  List<Object?> get props => [failure, period, previousDashboard];

  String get errorMessage {
    if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network and try again.';
    } else if (failure is ServerFailure) {
      return 'Server error occurred. Please try again later.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is UnauthorizedFailure) {
      return 'Session expired. Please login again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
