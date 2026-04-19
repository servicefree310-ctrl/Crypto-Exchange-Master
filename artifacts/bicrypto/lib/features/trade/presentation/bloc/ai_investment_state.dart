import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/ai_investment_plan_entity.dart';
import '../../domain/entities/ai_investment_entity.dart';

abstract class AiInvestmentState extends Equatable {
  const AiInvestmentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AiInvestmentInitial extends AiInvestmentState {
  const AiInvestmentInitial();
}

/// Loading state
class AiInvestmentLoading extends AiInvestmentState {
  const AiInvestmentLoading();
}

/// Plans loaded state
class AiInvestmentPlansLoaded extends AiInvestmentState {
  const AiInvestmentPlansLoaded({
    required this.plans,
  });

  final List<AiInvestmentPlanEntity> plans;

  @override
  List<Object?> get props => [plans];
}

/// User investments loaded state
class AiInvestmentUserInvestmentsLoaded extends AiInvestmentState {
  const AiInvestmentUserInvestmentsLoaded({
    required this.investments,
  });

  final List<AiInvestmentEntity> investments;

  @override
  List<Object?> get props => [investments];
}

/// Investment created state
class AiInvestmentCreated extends AiInvestmentState {
  const AiInvestmentCreated({
    required this.investment,
  });

  final AiInvestmentEntity investment;

  @override
  List<Object?> get props => [investment];
}

/// Investment cancelled state
class AiInvestmentCancelled extends AiInvestmentState {
  const AiInvestmentCancelled({
    required this.investmentId,
  });

  final String investmentId;

  @override
  List<Object?> get props => [investmentId];
}

/// Error state
class AiInvestmentError extends AiInvestmentState {
  const AiInvestmentError({
    required this.failure,
  });

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Combined state for dashboard display
class AiInvestmentDashboardState extends AiInvestmentState {
  const AiInvestmentDashboardState({
    required this.plans,
    required this.userInvestments,
    required this.isLoading,
    this.error,
  });

  final List<AiInvestmentPlanEntity> plans;
  final List<AiInvestmentEntity> userInvestments;
  final bool isLoading;
  final Failure? error;

  @override
  List<Object?> get props => [plans, userInvestments, isLoading, error];

  AiInvestmentDashboardState copyWith({
    List<AiInvestmentPlanEntity>? plans,
    List<AiInvestmentEntity>? userInvestments,
    bool? isLoading,
    Failure? error,
  }) {
    return AiInvestmentDashboardState(
      plans: plans ?? this.plans,
      userInvestments: userInvestments ?? this.userInvestments,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
