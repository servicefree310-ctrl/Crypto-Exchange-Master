// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/widgets/error_widget.dart' as core_error;
import '../../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/mlm_condition_entity.dart';
import '../bloc/mlm_bloc.dart';

class MlmConditionsPage extends StatefulWidget {
  const MlmConditionsPage({super.key});

  @override
  State<MlmConditionsPage> createState() => _MlmConditionsPageState();
}

class _MlmConditionsPageState extends State<MlmConditionsPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Percentage', 'Fixed'];

  List<MlmConditionEntity> _applyFilter(List<MlmConditionEntity> conditions) {
    switch (_selectedFilter) {
      case 'Percentage':
        return conditions
            .where((c) => c.rewardType == MlmRewardType.percentage)
            .toList();
      case 'Fixed':
        return conditions
            .where((c) => c.rewardType == MlmRewardType.fixed)
            .toList();
      default:
        return conditions;
    }
  }

  IconData _iconForCondition(MlmConditionEntity condition) {
    final title = condition.title.toLowerCase();
    if (title.contains('deposit')) return Icons.account_balance_wallet_rounded;
    if (title.contains('trade')) return Icons.trending_up_rounded;
    if (title.contains('staking') || title.contains('stake')) {
      return Icons.lock_rounded;
    }
    if (title.contains('p2p')) return Icons.swap_horiz_rounded;
    if (title.contains('ico')) return Icons.rocket_launch_rounded;
    switch (condition.rewardType) {
      case MlmRewardType.percentage:
        return Icons.percent_rounded;
      case MlmRewardType.fixed:
        return Icons.attach_money_rounded;
      case MlmRewardType.tiered:
        return Icons.layers_rounded;
      case MlmRewardType.referral:
        return Icons.people_rounded;
      case MlmRewardType.commission:
        return Icons.monetization_on_rounded;
      case MlmRewardType.bonus:
        return Icons.card_giftcard_rounded;
      case MlmRewardType.levelBonus:
        return Icons.leaderboard_rounded;
    }
  }

  String _rewardTypeLabel(MlmRewardType type) {
    switch (type) {
      case MlmRewardType.percentage:
        return 'PERCENTAGE';
      case MlmRewardType.fixed:
        return 'FIXED';
      case MlmRewardType.tiered:
        return 'TIERED';
      case MlmRewardType.referral:
        return 'REFERRAL';
      case MlmRewardType.commission:
        return 'COMMISSION';
      case MlmRewardType.bonus:
        return 'BONUS';
      case MlmRewardType.levelBonus:
        return 'LEVEL BONUS';
    }
  }

  String _walletTypeLabel(MlmRewardWalletType type) {
    switch (type) {
      case MlmRewardWalletType.spot:
        return 'SPOT';
      case MlmRewardWalletType.eco:
        return 'ECO';
      case MlmRewardWalletType.futures:
        return 'FUTURES';
    }
  }

  String _formatReward(MlmConditionEntity condition) {
    if (condition.rewardType == MlmRewardType.percentage) {
      return '${condition.reward.toStringAsFixed(1)}%';
    }
    return '${condition.reward.toStringAsFixed(2)} ${condition.rewardCurrency}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<MlmConditionsBloc>()
        ..add(const MlmConditionsLoadRequested()),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          title: Text(
            'Reward Conditions',
            style: context.h5,
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: context.colors.surface,
          foregroundColor: context.textPrimary,
        ),
        body: BlocBuilder<MlmConditionsBloc, MlmConditionsState>(
          builder: (context, state) {
            if (state is MlmConditionsLoading) {
              return const LoadingWidget(message: 'Loading conditions...');
            }

            if (state is MlmConditionsLoaded ||
                state is MlmConditionsRefreshing) {
              final conditions = state is MlmConditionsLoaded
                  ? state.conditions
                  : (state as MlmConditionsRefreshing).currentConditions;
              return _buildContent(context, conditions, state);
            }

            if (state is MlmConditionsError) {
              if (state.previousConditions != null) {
                return _buildContent(
                    context, state.previousConditions!, state);
              }
              return core_error.ErrorWidget(
                message: state.errorMessage,
                onRetry: () => context
                    .read<MlmConditionsBloc>()
                    .add(const MlmConditionsRetryRequested()),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<MlmConditionEntity> allConditions,
    MlmConditionsState state,
  ) {
    final isRefreshing = state is MlmConditionsRefreshing;
    final filtered = _applyFilter(allConditions);

    return Column(
      children: [
        // Filter tabs
        Container(
          color: context.colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: _filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.priceUpColor
                          : context.inputBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? context.priceUpColor
                            : context.borderColor,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: context.labelS.copyWith(
                        color: isSelected
                            ? Colors.white
                            : context.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        if (isRefreshing)
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: context.priceUpColor.withValues(alpha: 0.08),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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

        // List
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(context)
              : RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<MlmConditionsBloc>()
                        .add(const MlmConditionsRefreshRequested());
                  },
                  color: context.priceUpColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildConditionCard(context, filtered[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildConditionCard(
      BuildContext context, MlmConditionEntity condition) {
    final icon = _iconForCondition(condition);
    final rewardLabel = _formatReward(condition);

    return GestureDetector(
      onTap: () => _showDetailSheet(context, condition),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.priceUpColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: context.priceUpColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            condition.title,
                            style: context.bodyM.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Active indicator
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: condition.isActive
                                ? context.priceUpColor
                                : context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      condition.description,
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Reward amount
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.priceUpColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            rewardLabel,
                            style: context.labelS.copyWith(
                              color: context.priceUpColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Reward type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.warningColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _rewardTypeLabel(condition.rewardType),
                            style: context.labelS.copyWith(
                              color: context.warningColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        if (condition.rewardWalletType != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.inputBackground,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: Text(
                              _walletTypeLabel(condition.rewardWalletType!),
                              style: context.labelS.copyWith(
                                color: context.textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                color: context.inputBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.rule_outlined,
                size: 64,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Conditions Found',
              style: context.h5.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _selectedFilter == 'All'
                  ? 'There are no reward conditions available at this time.'
                  : 'No "$_selectedFilter" conditions found. Try a different filter.',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedFilter != 'All') ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() => _selectedFilter = 'All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.priceUpColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Show All'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, MlmConditionEntity condition) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Icon + Title
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: context.priceUpColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _iconForCondition(condition),
                      color: context.priceUpColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          condition.title,
                          style: context.h6.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: condition.isActive
                                    ? context.priceUpColor
                                    : context.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              condition.isActive ? 'Active' : 'Inactive',
                              style: context.labelS.copyWith(
                                color: condition.isActive
                                    ? context.priceUpColor
                                    : context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                'Description',
                style: context.labelS.copyWith(
                  color: context.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                condition.description,
                style: context.bodyM.copyWith(
                  color: context.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // Reward box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.priceUpColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: context.priceUpColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: context.priceUpColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reward',
                          style: context.labelS.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatReward(condition),
                          style: context.h5.copyWith(
                            color: context.priceUpColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: context.warningColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _rewardTypeLabel(condition.rewardType),
                        style: context.labelS.copyWith(
                          color: context.warningColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Details grid
              _buildDetailRow(
                context,
                'Currency',
                condition.rewardCurrency,
                Icons.currency_exchange_rounded,
              ),
              if (condition.rewardWalletType != null)
                _buildDetailRow(
                  context,
                  'Wallet Type',
                  _walletTypeLabel(condition.rewardWalletType!),
                  Icons.account_balance_wallet_rounded,
                ),
              if (condition.rewardChain != null &&
                  condition.rewardChain!.isNotEmpty)
                _buildDetailRow(
                  context,
                  'Chain',
                  condition.rewardChain!,
                  Icons.link_rounded,
                ),
              _buildDetailRow(
                context,
                'Created',
                _formatDate(condition.createdAt),
                Icons.calendar_today_rounded,
              ),
              if (condition.updatedAt != null)
                _buildDetailRow(
                  context,
                  'Last Updated',
                  _formatDate(condition.updatedAt!),
                  Icons.update_rounded,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.textSecondary),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: context.bodyS.copyWith(color: context.textSecondary),
          ),
          Expanded(
            child: Text(
              value,
              style: context.bodyS.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
