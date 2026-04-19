import 'package:flutter/material.dart';
// ignore_for_file: deprecated_member_use
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/widgets/error_widget.dart' as core_error;
import '../../../../../core/widgets/loading_widget.dart';
import '../bloc/mlm_bloc.dart';
import '../widgets/mlm_reward_card.dart';

class MlmRewardsPage extends StatelessWidget {
  const MlmRewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<MlmRewardsBloc>()
        ..add(const MlmRewardsLoadRequested()),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          title: Text(
            'My Rewards',
            style: context.h5,
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: context.colors.surface,
          foregroundColor: context.textPrimary,
          actions: [
            IconButton(
              onPressed: () => _showFilterDialog(context),
              icon: Icon(
                Icons.filter_list_rounded,
                color: context.textSecondary,
              ),
              tooltip: 'Filter rewards',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocConsumer<MlmRewardsBloc, MlmRewardsState>(
          listener: (context, state) {
            if (state is MlmRewardClaimSuccess) {
              _showSuccessSnackBar(context, state.message);
            } else if (state is MlmRewardsError && state.isClaimError) {
              _showErrorSnackBar(context, state.errorMessage);
            }
          },
          builder: (context, state) {
            if (state is MlmRewardsLoading && state is! MlmRewardsRefreshing) {
              return const LoadingWidget(message: 'Loading rewards...');
            } else if (state is MlmRewardsLoaded ||
                state is MlmRewardsRefreshing ||
                state is MlmRewardsLoadingMore) {
              final rewards = _getRewardsFromState(state);
              return _buildRewardsList(context, rewards, state);
            } else if (state is MlmRewardsError) {
              if (state.previousRewards != null) {
                return _buildRewardsList(
                    context, state.previousRewards!, state);
              }
              return core_error.ErrorWidget(
                message: state.errorMessage,
                onRetry: () => context.read<MlmRewardsBloc>().add(
                      MlmRewardsRetryRequested(page: state.page),
                    ),
              );
            } else if (state is MlmRewardClaimLoading ||
                state is MlmRewardDetailLoading) {
              final currentRewards = _getCurrentRewards(state);
              if (currentRewards != null) {
                return _buildRewardsList(context, currentRewards, state);
              }
              return const LoadingWidget(message: 'Processing...');
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  List<dynamic> _getRewardsFromState(MlmRewardsState state) {
    if (state is MlmRewardsLoaded) return state.rewards;
    if (state is MlmRewardsRefreshing) return state.currentRewards;
    if (state is MlmRewardsLoadingMore) return state.currentRewards;
    return [];
  }

  List<dynamic>? _getCurrentRewards(MlmRewardsState state) {
    if (state is MlmRewardClaimLoading) return state.currentRewards;
    if (state is MlmRewardDetailLoading) return state.currentRewards;
    return null;
  }

  Widget _buildRewardsList(
      BuildContext context, List<dynamic> rewards, MlmRewardsState state) {
    if (rewards.isEmpty) {
      return _buildEmptyState(context);
    }

    final totalRewards = _calculateTotalRewards(rewards);
    final claimableRewards = _calculateClaimableRewards(rewards);
    final hasReachedMax =
        state is MlmRewardsLoaded ? state.hasReachedMax : true;
    final isRefreshing = state is MlmRewardsRefreshing;
    final isLoadingMore = state is MlmRewardsLoadingMore;

    return Column(
      children: [
        // Summary Card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            children: [
              if (isRefreshing)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: context.priceUpColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Refreshing...',
                        style: context.labelS.copyWith(
                          color: context.priceUpColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      'Total Earned',
                      '\$${totalRewards.toStringAsFixed(2)}',
                      Icons.account_balance_wallet_rounded,
                      context.priceUpColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryItem(
                      context,
                      'Claimable',
                      '\$${claimableRewards.toStringAsFixed(2)}',
                      Icons.monetization_on_rounded,
                      context.warningColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Rewards List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<MlmRewardsBloc>().add(
                    const MlmRewardsRefreshRequested(),
                  );
            },
            color: context.priceUpColor,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: rewards.length + (hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= rewards.length) {
                  // Load more indicator
                  if (!isLoadingMore) {
                    final currentPage =
                        state is MlmRewardsLoaded ? state.currentPage : 1;
                    context.read<MlmRewardsBloc>().add(
                          MlmRewardsLoadMoreRequested(
                              nextPage: currentPage + 1),
                        );
                  }
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final reward = rewards[index];
                final isClaimLoading = state is MlmRewardClaimLoading &&
                    state.rewardId == reward.id;

                return MlmRewardCard(
                  reward: reward,
                  isLoading: isClaimLoading,
                  onClaim: _canClaimReward(reward) && !isClaimLoading
                      ? () => _showClaimDialog(context, reward)
                      : null,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: context.labelM.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: context.h6.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_giftcard_outlined,
                size: 64,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Rewards Yet',
              style: context.h5.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start referring friends and completing\nactivities to earn rewards!',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.priceUpColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.people_rounded),
              label: const Text('Start Referring'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Filter Rewards',
              style: context.h6,
            ),
            const SizedBox(height: 20),
            _buildFilterOption(context, 'All Rewards', true),
            _buildFilterOption(context, 'Claimable Only', false),
            _buildFilterOption(context, 'Claimed', false),
            _buildFilterOption(context, 'Pending Approval', false),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: context.labelM.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: Apply filter
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.priceUpColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, String title, bool selected) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: context.bodyM.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      leading: Radio<bool>(
        value: true,
        groupValue: selected,
        onChanged: (value) {},
        activeColor: context.priceUpColor,
      ),
    );
  }

  void _showClaimDialog(BuildContext context, dynamic reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Claim Reward',
          style: context.h6,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.priceUpColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    color: context.priceUpColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reward Amount',
                          style: context.labelS.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${reward.amount?.toStringAsFixed(2) ?? '0.00'}',
                          style: context.h6.copyWith(
                            color: context.priceUpColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to claim this reward? Once claimed, it will be added to your wallet balance.',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: context.labelM.copyWith(color: context.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<MlmRewardsBloc>().add(
                    MlmRewardClaimRequested(rewardId: reward.id),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: context.priceUpColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Claim'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: context.priceUpColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: context.priceDownColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  bool _canClaimReward(dynamic reward) {
    try {
      final statusName = reward.status?.name ?? reward.status?.toString() ?? '';
      return statusName.toLowerCase() == 'pending' ||
          statusName.toLowerCase() == 'approved';
    } catch (e) {
      return false;
    }
  }

  double _calculateTotalRewards(List<dynamic> rewards) {
    return rewards.fold(0.0, (sum, reward) {
      try {
        return sum + (reward.amount?.toDouble() ?? 0.0);
      } catch (e) {
        return sum;
      }
    });
  }

  double _calculateClaimableRewards(List<dynamic> rewards) {
    return rewards.where((reward) => _canClaimReward(reward)).fold(0.0,
        (sum, reward) {
      try {
        return sum + (reward.amount?.toDouble() ?? 0.0);
      } catch (e) {
        return sum;
      }
    });
  }
}
