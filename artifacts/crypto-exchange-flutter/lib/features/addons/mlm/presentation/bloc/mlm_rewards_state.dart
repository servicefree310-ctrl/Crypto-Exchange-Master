import 'package:equatable/equatable.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/mlm_reward_entity.dart';

abstract class MlmRewardsState extends Equatable {
  const MlmRewardsState();

  @override
  List<Object?> get props => [];
}

class MlmRewardsInitial extends MlmRewardsState {
  const MlmRewardsInitial();
}

class MlmRewardsLoading extends MlmRewardsState {
  const MlmRewardsLoading({
    this.message,
    this.page = 1,
  });

  final String? message;
  final int page;

  @override
  List<Object?> get props => [message, page];
}

class MlmRewardsLoaded extends MlmRewardsState {
  const MlmRewardsLoaded({
    required this.rewards,
    required this.currentPage,
    required this.hasReachedMax,
    this.totalCount,
    this.sortField,
    this.sortOrder,
    this.lastUpdated,
  });

  final List<MlmRewardEntity> rewards;
  final int currentPage;
  final bool hasReachedMax;
  final int? totalCount;
  final String? sortField;
  final String? sortOrder;
  final DateTime? lastUpdated;

  @override
  List<Object?> get props => [
        rewards,
        currentPage,
        hasReachedMax,
        totalCount,
        sortField,
        sortOrder,
        lastUpdated,
      ];

  MlmRewardsLoaded copyWith({
    List<MlmRewardEntity>? rewards,
    int? currentPage,
    bool? hasReachedMax,
    int? totalCount,
    String? sortField,
    String? sortOrder,
    DateTime? lastUpdated,
  }) {
    return MlmRewardsLoaded(
      rewards: rewards ?? this.rewards,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalCount: totalCount ?? this.totalCount,
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class MlmRewardsLoadingMore extends MlmRewardsState {
  const MlmRewardsLoadingMore({
    required this.currentRewards,
    required this.currentPage,
  });

  final List<MlmRewardEntity> currentRewards;
  final int currentPage;

  @override
  List<Object?> get props => [currentRewards, currentPage];
}

class MlmRewardsRefreshing extends MlmRewardsState {
  const MlmRewardsRefreshing({
    required this.currentRewards,
  });

  final List<MlmRewardEntity> currentRewards;

  @override
  List<Object?> get props => [currentRewards];
}

class MlmRewardClaimLoading extends MlmRewardsState {
  const MlmRewardClaimLoading({
    required this.rewardId,
    this.currentRewards,
  });

  final String rewardId;
  final List<MlmRewardEntity>? currentRewards;

  @override
  List<Object?> get props => [rewardId, currentRewards];
}

class MlmRewardClaimSuccess extends MlmRewardsState {
  const MlmRewardClaimSuccess({
    required this.rewardId,
    required this.message,
    this.updatedReward,
    this.currentRewards,
  });

  final String rewardId;
  final String message;
  final MlmRewardEntity? updatedReward;
  final List<MlmRewardEntity>? currentRewards;

  @override
  List<Object?> get props => [rewardId, message, updatedReward, currentRewards];
}

class MlmRewardDetailLoading extends MlmRewardsState {
  const MlmRewardDetailLoading({
    required this.rewardId,
    this.currentRewards,
  });

  final String rewardId;
  final List<MlmRewardEntity>? currentRewards;

  @override
  List<Object?> get props => [rewardId, currentRewards];
}

class MlmRewardDetailLoaded extends MlmRewardsState {
  const MlmRewardDetailLoaded({
    required this.reward,
    this.currentRewards,
  });

  final MlmRewardEntity reward;
  final List<MlmRewardEntity>? currentRewards;

  @override
  List<Object?> get props => [reward, currentRewards];
}

class MlmRewardsError extends MlmRewardsState {
  const MlmRewardsError({
    required this.failure,
    this.previousRewards,
    this.page = 1,
    this.isClaimError = false,
    this.rewardId,
  });

  final Failure failure;
  final List<MlmRewardEntity>? previousRewards;
  final int page;
  final bool isClaimError;
  final String? rewardId;

  @override
  List<Object?> get props => [
        failure,
        previousRewards,
        page,
        isClaimError,
        rewardId,
      ];

  String get errorMessage {
    if (failure is NetworkFailure) {
      return 'No internet connection. Please check your network and try again.';
    } else if (failure is ServerFailure) {
      return isClaimError
          ? 'Failed to claim reward. Please try again later.'
          : 'Server error occurred. Please try again later.';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is UnauthorizedFailure) {
      return 'Session expired. Please login again.';
    } else {
      return isClaimError
          ? 'Reward claim failed. Please try again.'
          : 'An unexpected error occurred. Please try again.';
    }
  }
}
