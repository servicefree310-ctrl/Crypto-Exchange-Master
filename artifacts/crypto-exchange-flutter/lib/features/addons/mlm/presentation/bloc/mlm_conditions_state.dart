import 'package:equatable/equatable.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/mlm_condition_entity.dart';

abstract class MlmConditionsState extends Equatable {
  const MlmConditionsState();

  @override
  List<Object?> get props => [];
}

class MlmConditionsInitial extends MlmConditionsState {
  const MlmConditionsInitial();
}

class MlmConditionsLoading extends MlmConditionsState {
  const MlmConditionsLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

class MlmConditionsLoaded extends MlmConditionsState {
  const MlmConditionsLoaded({
    required this.conditions,
    this.lastUpdated,
  });

  final List<MlmConditionEntity> conditions;
  final DateTime? lastUpdated;

  @override
  List<Object?> get props => [conditions, lastUpdated];
}

class MlmConditionsRefreshing extends MlmConditionsState {
  const MlmConditionsRefreshing({
    required this.currentConditions,
  });

  final List<MlmConditionEntity> currentConditions;

  @override
  List<Object?> get props => [currentConditions];
}

class MlmConditionsError extends MlmConditionsState {
  const MlmConditionsError({
    required this.failure,
    this.previousConditions,
  });

  final Failure failure;
  final List<MlmConditionEntity>? previousConditions;

  @override
  List<Object?> get props => [failure, previousConditions];

  String get errorMessage {
    if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network and try again.';
    } else if (failure is ServerFailure) {
      return 'Server error occurred. Please try again later.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}
