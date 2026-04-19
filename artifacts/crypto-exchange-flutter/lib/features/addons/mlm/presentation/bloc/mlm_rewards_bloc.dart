import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/errors/failures.dart';
import '../../domain/entities/mlm_reward_entity.dart';
import '../../domain/repositories/mlm_repository.dart';
import '../../domain/usecases/get_mlm_rewards_usecase.dart';
import '../../domain/usecases/claim_mlm_reward_usecase.dart';
import 'mlm_rewards_event.dart';
import 'mlm_rewards_state.dart';

@injectable
class MlmRewardsBloc extends Bloc<MlmRewardsEvent, MlmRewardsState> {
  MlmRewardsBloc(this._getRewardsUseCase, this._claimRewardUseCase, this._repository)
      : super(const MlmRewardsInitial()) {
    on<MlmRewardsLoadRequested>(_onLoadRequested);
    on<MlmRewardsRefreshRequested>(_onRefreshRequested);
    on<MlmRewardsLoadMoreRequested>(_onLoadMoreRequested);
    on<MlmRewardClaimRequested>(_onClaimRequested);
    on<MlmRewardDetailRequested>(_onDetailRequested);
    on<MlmRewardsSortChanged>(_onSortChanged);
    on<MlmRewardsRetryRequested>(_onRetryRequested);
  }

  final GetMlmRewardsUseCase _getRewardsUseCase;
  final ClaimMlmRewardUseCase _claimRewardUseCase;
  final MlmRepository _repository;

  Future<void> _onLoadRequested(
    MlmRewardsLoadRequested event,
    Emitter<MlmRewardsState> emit,
  ) async {
    // Don't reload if already loaded first page and not forced refresh
    if (state is MlmRewardsLoaded && event.page == 1 && !event.forceRefresh) {
      return;
    }

    emit(MlmRewardsLoading(
      message: 'Loading rewards...',
      page: event.page,
    ));

    final params = GetMlmRewardsParams(
      page: event.page,
      perPage: event.perPage,
      sortField: event.sortField,
      sortOrder: event.sortOrder,
    );
    final result = await _getRewardsUseCase(params);

    result.fold(
      (failure) => emit(MlmRewardsError(
        failure: failure,
        page: event.page,
      )),
      (rewards) => emit(MlmRewardsLoaded(
        rewards: rewards,
        currentPage: event.page,
        hasReachedMax: rewards.length < event.perPage,
        sortField: event.sortField,
        sortOrder: event.sortOrder,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onRefreshRequested(
    MlmRewardsRefreshRequested event,
    Emitter<MlmRewardsState> emit,
  ) async {
    // Keep current data visible during refresh
    if (state is MlmRewardsLoaded) {
      final loadedState = state as MlmRewardsLoaded;
      emit(MlmRewardsRefreshing(
        currentRewards: loadedState.rewards,
      ));
    } else {
      emit(const MlmRewardsLoading(
        message: 'Refreshing rewards...',
      ));
    }

    final params = GetMlmRewardsParams(
      page: 1,
      perPage: event.perPage,
      sortField: event.sortField,
      sortOrder: event.sortOrder,
    );
    final result = await _getRewardsUseCase(params);

    result.fold(
      (failure) {
        // If we were refreshing, preserve the previous data
        if (state is MlmRewardsRefreshing) {
          final refreshingState = state as MlmRewardsRefreshing;
          emit(MlmRewardsError(
            failure: failure,
            previousRewards: refreshingState.currentRewards,
            page: 1,
          ));
        } else {
          emit(MlmRewardsError(
            failure: failure,
            page: 1,
          ));
        }
      },
      (rewards) => emit(MlmRewardsLoaded(
        rewards: rewards,
        currentPage: 1,
        hasReachedMax: rewards.length < event.perPage,
        sortField: event.sortField,
        sortOrder: event.sortOrder,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onLoadMoreRequested(
    MlmRewardsLoadMoreRequested event,
    Emitter<MlmRewardsState> emit,
  ) async {
    if (state is! MlmRewardsLoaded) return;

    final loadedState = state as MlmRewardsLoaded;

    // Don't load more if already at max
    if (loadedState.hasReachedMax) return;

    emit(MlmRewardsLoadingMore(
      currentRewards: loadedState.rewards,
      currentPage: loadedState.currentPage,
    ));

    final params = GetMlmRewardsParams(
      page: event.nextPage,
      perPage: event.perPage,
      sortField: event.sortField,
      sortOrder: event.sortOrder,
    );
    final result = await _getRewardsUseCase(params);

    result.fold(
      (failure) => emit(MlmRewardsError(
        failure: failure,
        previousRewards: loadedState.rewards,
        page: event.nextPage,
      )),
      (newRewards) {
        final allRewards = [...loadedState.rewards, ...newRewards];
        emit(MlmRewardsLoaded(
          rewards: allRewards,
          currentPage: event.nextPage,
          hasReachedMax: newRewards.length < event.perPage,
          totalCount: loadedState.totalCount,
          sortField: loadedState.sortField,
          sortOrder: loadedState.sortOrder,
          lastUpdated: DateTime.now(),
        ));
      },
    );
  }

  Future<void> _onClaimRequested(
    MlmRewardClaimRequested event,
    Emitter<MlmRewardsState> emit,
  ) async {
    List<MlmRewardEntity>? currentRewards;
    if (state is MlmRewardsLoaded) {
      currentRewards = (state as MlmRewardsLoaded).rewards;
    }

    emit(MlmRewardClaimLoading(
      rewardId: event.rewardId,
      currentRewards: currentRewards,
    ));

    // Execute claim reward use case
    final params = ClaimMlmRewardParams(rewardId: event.rewardId);
    final result = await _claimRewardUseCase(params);

    result.fold(
      (failure) => emit(MlmRewardsError(
        failure: failure,
        previousRewards: currentRewards,
        isClaimError: true,
        rewardId: event.rewardId,
      )),
      (response) {
        emit(MlmRewardClaimSuccess(
          rewardId: event.rewardId,
          message: response['message'] ?? 'Reward claimed successfully!',
          currentRewards: currentRewards,
        ));

        // Optionally refresh rewards after claim
        add(const MlmRewardsRefreshRequested());
      },
    );
  }

  Future<void> _onDetailRequested(
    MlmRewardDetailRequested event,
    Emitter<MlmRewardsState> emit,
  ) async {
    List<MlmRewardEntity>? currentRewards;
    if (state is MlmRewardsLoaded) {
      currentRewards = (state as MlmRewardsLoaded).rewards;
    }

    emit(MlmRewardDetailLoading(
      rewardId: event.rewardId,
      currentRewards: currentRewards,
    ));

    // Find reward in current list first
    if (currentRewards != null) {
      try {
        final reward = currentRewards.firstWhere(
          (r) => r.id == event.rewardId,
        );
        emit(MlmRewardDetailLoaded(
          reward: reward,
          currentRewards: currentRewards,
        ));
        return;
      } catch (e) {
        // Not found in current list, try API
      }
    }

    // Fetch from API when not found locally
    final result = await _repository.getRewardById(event.rewardId);
    result.fold(
      (failure) => emit(MlmRewardsError(
        failure: failure,
        previousRewards: currentRewards,
      )),
      (reward) => emit(MlmRewardDetailLoaded(
        reward: reward,
        currentRewards: currentRewards,
      )),
    );
  }

  Future<void> _onSortChanged(
    MlmRewardsSortChanged event,
    Emitter<MlmRewardsState> emit,
  ) async {
    emit(MlmRewardsLoading(
      message: 'Applying sort...',
      page: 1,
    ));

    final params = GetMlmRewardsParams(
      page: 1,
      perPage: event.perPage,
      sortField: event.sortField,
      sortOrder: event.sortOrder,
    );
    final result = await _getRewardsUseCase(params);

    result.fold(
      (failure) => emit(MlmRewardsError(
        failure: failure,
        page: 1,
      )),
      (rewards) => emit(MlmRewardsLoaded(
        rewards: rewards,
        currentPage: 1,
        hasReachedMax: rewards.length < event.perPage,
        sortField: event.sortField,
        sortOrder: event.sortOrder,
        lastUpdated: DateTime.now(),
      )),
    );
  }

  Future<void> _onRetryRequested(
    MlmRewardsRetryRequested event,
    Emitter<MlmRewardsState> emit,
  ) async {
    emit(MlmRewardsLoading(
      message: 'Retrying...',
      page: event.page,
    ));

    final params = GetMlmRewardsParams(
      page: event.page,
      perPage: event.perPage,
      sortField: event.sortField,
      sortOrder: event.sortOrder,
    );
    final result = await _getRewardsUseCase(params);

    result.fold(
      (failure) => emit(MlmRewardsError(
        failure: failure,
        page: event.page,
      )),
      (rewards) => emit(MlmRewardsLoaded(
        rewards: rewards,
        currentPage: event.page,
        hasReachedMax: rewards.length < event.perPage,
        sortField: event.sortField,
        sortOrder: event.sortOrder,
        lastUpdated: DateTime.now(),
      )),
    );
  }
}
