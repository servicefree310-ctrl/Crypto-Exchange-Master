import 'package:flutter/material.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';
import '../../domain/entities/staking_stats_entity.dart';

class MobileStatsCard extends StatelessWidget {
  final StakingStatsEntity stats;

  const MobileStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: context.isDarkMode
              ? [
                  context.colors.primary.withValues(alpha: 0.2),
                  context.colors.primary.withValues(alpha: 0.05),
                ]
              : [
                  context.colors.primary.withValues(alpha: 0.1),
                  context.colors.primary.withValues(alpha: 0.03),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Main stats row
          Row(
            children: [
              _buildMainStat(
                context,
                '\$${_formatAmount(stats.totalStaked)}',
                'Total Value Locked',
                Icons.lock,
              ),
              Container(
                width: 1,
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: context.borderColor,
              ),
              _buildMainStat(
                context,
                '${stats.avgApr.toStringAsFixed(1)}%',
                'Average APR',
                Icons.trending_up,
                valueColor: context.priceUpColor,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Secondary stats
          Row(
            children: [
              _buildSecondaryStat(
                context,
                _formatCount(stats.activeUsers),
                'Active Users',
                Icons.people,
              ),
              const SizedBox(width: 12),
              _buildSecondaryStat(
                context,
                '\$${_formatAmount(stats.totalRewards)}',
                'Total Rewards',
                Icons.card_giftcard,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStat(
    BuildContext context,
    String value,
    String label,
    IconData icon, {
    Color? valueColor,
  }) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: context.colors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: context.h5.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
                Text(
                  label,
                  style: context.labelS.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: context.textSecondary,
            ),
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

  String _formatAmount(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}
