import 'package:equatable/equatable.dart';

abstract class MlmRewardsEvent extends Equatable {
  const MlmRewardsEvent();

  @override
  List<Object?> get props => [];
}

class MlmRewardsLoadRequested extends MlmRewardsEvent {
  const MlmRewardsLoadRequested({
    this.page = 1,
    this.perPage = 10,
    this.sortField,
    this.sortOrder,
    this.forceRefresh = false,
  });

  final int page;
  final int perPage;
  final String? sortField;
  final String? sortOrder;
  final bool forceRefresh;

  @override
  List<Object?> get props =>
      [page, perPage, sortField, sortOrder, forceRefresh];
}

class MlmRewardsRefreshRequested extends MlmRewardsEvent {
  const MlmRewardsRefreshRequested({
    this.perPage = 10,
    this.sortField,
    this.sortOrder,
  });

  final int perPage;
  final String? sortField;
  final String? sortOrder;

  @override
  List<Object?> get props => [perPage, sortField, sortOrder];
}

class MlmRewardsLoadMoreRequested extends MlmRewardsEvent {
  const MlmRewardsLoadMoreRequested({
    required this.nextPage,
    this.perPage = 10,
    this.sortField,
    this.sortOrder,
  });

  final int nextPage;
  final int perPage;
  final String? sortField;
  final String? sortOrder;

  @override
  List<Object?> get props => [nextPage, perPage, sortField, sortOrder];
}

class MlmRewardClaimRequested extends MlmRewardsEvent {
  const MlmRewardClaimRequested({
    required this.rewardId,
  });

  final String rewardId;

  @override
  List<Object?> get props => [rewardId];
}

class MlmRewardDetailRequested extends MlmRewardsEvent {
  const MlmRewardDetailRequested({
    required this.rewardId,
  });

  final String rewardId;

  @override
  List<Object?> get props => [rewardId];
}

class MlmRewardsSortChanged extends MlmRewardsEvent {
  const MlmRewardsSortChanged({
    this.sortField,
    this.sortOrder,
    this.perPage = 10,
  });

  final String? sortField;
  final String? sortOrder;
  final int perPage;

  @override
  List<Object?> get props => [sortField, sortOrder, perPage];
}

class MlmRewardsRetryRequested extends MlmRewardsEvent {
  const MlmRewardsRetryRequested({
    this.page = 1,
    this.perPage = 10,
    this.sortField,
    this.sortOrder,
  });

  final int page;
  final int perPage;
  final String? sortField;
  final String? sortOrder;

  @override
  List<Object?> get props => [page, perPage, sortField, sortOrder];
}
