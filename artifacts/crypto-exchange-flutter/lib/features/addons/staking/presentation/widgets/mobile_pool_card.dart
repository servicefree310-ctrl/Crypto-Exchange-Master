import 'package:flutter/material.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';
import '../../domain/entities/staking_pool_entity.dart';

class MobilePoolCard extends StatelessWidget {
  final StakingPoolEntity pool;
  final VoidCallback? onTap;

  const MobilePoolCard({
    super.key,
    required this.pool,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = pool.status == 'ACTIVE';
    final isComingSoon = pool.status == 'COMING_SOON';

    return InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: pool.isPromoted
                ? context.colors.primary.withValues(alpha: 0.3)
                : context.borderColor,
            width: pool.isPromoted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Pool Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: pool.icon != null
                      ? Image.network(
                          pool.icon!,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.token,
                            color: context.colors.primary,
                          ),
                        )
                      : Icon(
                          Icons.token,
                          color: context.colors.primary,
                        ),
                ),
                const SizedBox(width: 12),

                // Pool Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pool.name,
                              style: context.labelL.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (pool.isPromoted)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'FEATURED',
                                style: context.labelS.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pool.symbol,
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // APR Display
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${pool.apr.toStringAsFixed(1)}%',
                      style: context.h5.copyWith(
                        color: context.priceUpColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'APR',
                      style: context.labelS.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.priceUpColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Active',
                          style: context.labelS.copyWith(
                            color: context.priceUpColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Stats Row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.isDarkMode
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildStat(
                    context,
                    'Min Stake',
                    _formatAmount(pool.minStake),
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    context,
                    'Lock Period',
                    '${pool.lockPeriod} days',
                  ),
                  const SizedBox(width: 16),
                  _buildStat(
                    context,
                    'TVL',
                    _formatAmount(pool.tvl),
                  ),
                ],
              ),
            ),

            if (!isActive) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isComingSoon
                      ? context.warningColor.withValues(alpha: 0.1)
                      : context.textTertiary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isComingSoon ? Icons.schedule : Icons.block,
                      size: 16,
                      color: isComingSoon
                          ? context.warningColor
                          : context.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isComingSoon ? 'Coming Soon' : 'Inactive',
                      style: context.labelM.copyWith(
                        color: isComingSoon
                            ? context.warningColor
                            : context.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (pool.description != null && pool.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                pool.description!,
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (isActive && onTap != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View details',
                    style: context.labelM.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: context.colors.primary,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.labelS.copyWith(
              color: context.textTertiary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: context.labelM.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }
}
