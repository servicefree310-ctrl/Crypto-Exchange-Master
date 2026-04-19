import 'package:equatable/equatable.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/mlm_landing_entity.dart';

abstract class MlmLandingState extends Equatable {
  const MlmLandingState();

  @override
  List<Object?> get props => [];
}

class MlmLandingInitial extends MlmLandingState {
  const MlmLandingInitial();
}

class MlmLandingLoading extends MlmLandingState {
  const MlmLandingLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class MlmLandingLoaded extends MlmLandingState {
  const MlmLandingLoaded({
    required this.landing,
    this.lastUpdated,
  });

  final MlmLandingEntity landing;
  final DateTime? lastUpdated;

  @override
  List<Object?> get props => [landing, lastUpdated];

  MlmLandingLoaded copyWith({
    MlmLandingEntity? landing,
    DateTime? lastUpdated,
  }) {
    return MlmLandingLoaded(
      landing: landing ?? this.landing,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class MlmLandingRefreshing extends MlmLandingState {
  const MlmLandingRefreshing({
    required this.currentLanding,
  });

  final MlmLandingEntity currentLanding;

  @override
  List<Object?> get props => [currentLanding];
}

class MlmLandingError extends MlmLandingState {
  const MlmLandingError({
    required this.failure,
    this.previousLanding,
  });

  final Failure failure;
  final MlmLandingEntity? previousLanding;

  @override
  List<Object?> get props => [failure, previousLanding];

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
