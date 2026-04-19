import 'package:flutter/material.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/mlm_dashboard_entity.dart';
import '../pages/mlm_network_tree_page.dart';

class MlmNetworkOverview extends StatelessWidget {
  final MlmNetworkSummaryEntity networkSummary;

  const MlmNetworkOverview({
    super.key,
    required this.networkSummary,
  });

  @override
  Widget build(BuildContext context) {
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
                    color: context.colors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.account_tree_rounded,
                    color: context.colors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Network Overview',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showNetworkDetail(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.colors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.colors.secondary.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: 14,
                            color: context.colors.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'View Tree',
                            style: context.labelS.copyWith(
                              color: context.colors.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Network Metrics
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _CompactNetworkMetric(
                        label: 'Total Members',
                        value: networkSummary.totalMembers.toString(),
                        icon: Icons.people_rounded,
                        color: context.priceUpColor,
                        subtitle: 'All levels',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactNetworkMetric(
                        label: 'Active',
                        value: networkSummary.activeMembers.toString(),
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
                      child: _CompactNetworkMetric(
                        label: 'Max Depth',
                        value: networkSummary.maxDepth.toString(),
                        icon: Icons.layers_rounded,
                        color: context.warningColor,
                        subtitle: 'Levels deep',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactNetworkMetric(
                        label: 'Volume',
                        value: '\$${_formatVolume(networkSummary.totalVolume)}',
                        icon: Icons.trending_up_rounded,
                        color: context.colors.secondary,
                        subtitle: 'Total value',
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

  String _formatVolume(double volume) {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    } else {
      return volume.toStringAsFixed(0);
    }
  }

  void _showNetworkDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MlmNetworkTreePage(
          networkSummary: networkSummary,
        ),
      ),
    );
  }
}

class _CompactNetworkMetric extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _CompactNetworkMetric({
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
