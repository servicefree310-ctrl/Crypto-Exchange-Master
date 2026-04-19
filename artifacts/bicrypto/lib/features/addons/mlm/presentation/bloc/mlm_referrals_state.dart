import 'package:equatable/equatable.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/mlm_referral_entity.dart';

abstract class MlmReferralsState extends Equatable {
  const MlmReferralsState();

  @override
  List<Object?> get props => [];
}

class MlmReferralsInitial extends MlmReferralsState {
  const MlmReferralsInitial();
}

class MlmReferralsLoading extends MlmReferralsState {
  const MlmReferralsLoading({
    this.message,
    this.page = 1,
  });

  final String? message;
  final int page;

  @override
  List<Object?> get props => [message, page];
}

class MlmReferralsLoaded extends MlmReferralsState {
  const MlmReferralsLoaded({
    required this.referrals,
    required this.currentPage,
    required this.hasReachedMax,
    this.totalCount,
    this.lastUpdated,
  });

  final List<MlmReferralEntity> referrals;
  final int currentPage;
  final bool hasReachedMax;
  final int? totalCount;
  final DateTime? lastUpdated;

  @override
  List<Object?> get props => [
        referrals,
        currentPage,
        hasReachedMax,
        totalCount,
        lastUpdated,
      ];

  MlmReferralsLoaded copyWith({
    List<MlmReferralEntity>? referrals,
    int? currentPage,
    bool? hasReachedMax,
    int? totalCount,
    DateTime? lastUpdated,
  }) {
    return MlmReferralsLoaded(
      referrals: referrals ?? this.referrals,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class MlmReferralsLoadingMore extends MlmReferralsState {
  const MlmReferralsLoadingMore({
    required this.currentReferrals,
    required this.currentPage,
  });

  final List<MlmReferralEntity> currentReferrals;
  final int currentPage;

  @override
  List<Object?> get props => [currentReferrals, currentPage];
}

class MlmReferralsRefreshing extends MlmReferralsState {
  const MlmReferralsRefreshing({
    required this.currentReferrals,
  });

  final List<MlmReferralEntity> currentReferrals;

  @override
  List<Object?> get props => [currentReferrals];
}

class MlmReferralDetailLoading extends MlmReferralsState {
  const MlmReferralDetailLoading({
    required this.referralId,
    this.currentReferrals,
  });

  final String referralId;
  final List<MlmReferralEntity>? currentReferrals;

  @override
  List<Object?> get props => [referralId, currentReferrals];
}

class MlmReferralDetailLoaded extends MlmReferralsState {
  const MlmReferralDetailLoaded({
    required this.referral,
    this.currentReferrals,
  });

  final MlmReferralEntity referral;
  final List<MlmReferralEntity>? currentReferrals;

  @override
  List<Object?> get props => [referral, currentReferrals];
}

class MlmReferralAnalysisLoading extends MlmReferralsState {
  const MlmReferralAnalysisLoading({
    required this.referralId,
    this.currentReferrals,
  });

  final String referralId;
  final List<MlmReferralEntity>? currentReferrals;

  @override
  List<Object?> get props => [referralId, currentReferrals];
}

class MlmReferralAnalysisCompleted extends MlmReferralsState {
  const MlmReferralAnalysisCompleted({
    required this.referralId,
    required this.analysisResult,
    this.currentReferrals,
  });

  final String referralId;
  final Map<String, dynamic> analysisResult;
  final List<MlmReferralEntity>? currentReferrals;

  @override
  List<Object?> get props => [referralId, analysisResult, currentReferrals];
}

class MlmReferralsError extends MlmReferralsState {
  const MlmReferralsError({
    required this.failure,
    this.previousReferrals,
    this.page = 1,
  });

  final Failure failure;
  final List<MlmReferralEntity>? previousReferrals;
  final int page;

  @override
  List<Object?> get props => [failure, previousReferrals, page];

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
