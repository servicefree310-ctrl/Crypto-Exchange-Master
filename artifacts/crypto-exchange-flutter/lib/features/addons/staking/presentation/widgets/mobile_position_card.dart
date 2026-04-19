import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';
import '../../domain/entities/staking_position_entity.dart';
import '../bloc/position_bloc.dart';
import '../bloc/position_event.dart';
import '../pages/position_detail_page.dart';

class MobilePositionCard extends StatelessWidget {
  final StakingPositionEntity position;

  const MobilePositionCard({
    super.key,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final canWithdraw = position.status == 'ACTIVE';
    final hasRewards = position.earningsUnclaimed > 0;
    final poolLabel = position.poolId.isEmpty
        ? 'Unknown'
        : (position.poolId.length > 8
            ? position.poolId.substring(0, 8)
            : position.poolId);

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PositionDetailPage(position: position),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getStatusColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getStatusIcon(),
                    color: _getStatusColor(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pool #$poolLabel',
                        style: context.labelL.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getStatusText(),
                        style: context.labelS.copyWith(
                          color: _getStatusColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${position.amount.toStringAsFixed(2)}',
                      style: context.labelL.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Staked',
                      style: context.labelS.copyWith(
                        color: context.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                _buildStat(
                  context,
                  'Total Earnings',
                  '\$${position.earningsTotal.toStringAsFixed(2)}',
                  icon: Icons.trending_up,
                  color: context.priceUpColor,
                ),
                const SizedBox(width: 12),
                _buildStat(
                  context,
                  'Unclaimed',
                  '\$${position.earningsUnclaimed.toStringAsFixed(2)}',
                  icon: Icons.account_balance_wallet,
                  color: context.warningColor,
                ),
                if (position.timeRemaining != null) ...[
                  const SizedBox(width: 12),
                  _buildStat(
                    context,
                    'Time Left',
                    '${position.timeRemaining}d',
                    icon: Icons.timer,
                    color: context.textSecondary,
                  ),
                ],
              ],
            ),

            // Actions
            if (canWithdraw || hasRewards) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  if (hasRewards)
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Claim Rewards',
                        Icons.card_giftcard,
                        context.priceUpColor,
                        () => context.read<PositionBloc>().add(
                              ClaimRewardsRequested(position.id),
                            ),
                      ),
                    ),
                  if (hasRewards && canWithdraw) const SizedBox(width: 8),
                  if (canWithdraw)
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Withdraw',
                        Icons.exit_to_app,
                        context.colors.primary,
                        () => context.read<PositionBloc>().add(
                              WithdrawRequested(position.id),
                            ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value, {
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: context.labelM.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    label,
                    style: context.labelS.copyWith(
                      color: context.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: context.labelM.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (position.status) {
      case 'ACTIVE':
        return Icons.lock_clock;
      case 'PENDING_WITHDRAWAL':
        return Icons.hourglass_bottom;
      case 'COMPLETED':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }

  String _getStatusText() {
    switch (position.status) {
      case 'ACTIVE':
        return 'Active';
      case 'PENDING_WITHDRAWAL':
        return 'Withdrawing';
      case 'COMPLETED':
        return 'Completed';
      default:
        return position.status;
    }
  }

  Color _getStatusColor(BuildContext context) {
    switch (position.status) {
      case 'ACTIVE':
        return context.priceUpColor;
      case 'PENDING_WITHDRAWAL':
        return context.warningColor;
      case 'COMPLETED':
        return context.textSecondary;
      default:
        return context.textTertiary;
    }
  }
}
