import 'package:flutter/material.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/mlm_dashboard_entity.dart';

class MlmStatsCard extends StatelessWidget {
  final MlmDashboardEntity dashboard;

  const MlmStatsCard({
    super.key,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final stats = dashboard.stats;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.borderColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.dashboard_rounded,
                    color: context.priceUpColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Performance Overview',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                if (stats.weeklyGrowth != 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: stats.weeklyGrowth > 0
                          ? context.priceUpColor.withValues(alpha: 0.1)
                          : context.priceDownColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: stats.weeklyGrowth > 0
                            ? context.priceUpColor.withValues(alpha: 0.3)
                            : context.priceDownColor.withValues(alpha: 0.3),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          stats.weeklyGrowth > 0
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          color: stats.weeklyGrowth > 0
                              ? context.priceUpColor
                              : context.priceDownColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${stats.weeklyGrowth > 0 ? '+' : ''}${stats.weeklyGrowth.toStringAsFixed(1)}%',
                          style: context.labelS.copyWith(
                            color: stats.weeklyGrowth > 0
                                ? context.priceUpColor
                                : context.priceDownColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Stats Grid
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _CompactStatItem(
                        label: 'Total Referrals',
                        value: stats.totalReferrals.toString(),
                        icon: Icons.people_rounded,
                        color: context.priceUpColor,
                        subtitle: 'All time',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactStatItem(
                        label: 'Active Now',
                        value: stats.activeReferrals.toString(),
                        icon: Icons.trending_up_rounded,
                        color: context.colors.primary,
                        subtitle: 'This month',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _CompactStatItem(
                        label: 'Total Earnings',
                        value: '\$${stats.totalEarnings.toStringAsFixed(2)}',
                        icon: Icons.account_balance_wallet_rounded,
                        color: context.warningColor,
                        subtitle: 'Lifetime',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactStatItem(
                        label: 'Conversion',
                        value: '${stats.conversionRate.toStringAsFixed(1)}%',
                        icon: Icons.insights_rounded,
                        color: context.colors.secondary,
                        subtitle: 'Success rate',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStatItem extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _CompactStatItem({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: context.labelS.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.h5.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: context.labelS.copyWith(
              color: context.textTertiary,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
