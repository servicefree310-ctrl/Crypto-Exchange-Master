import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../domain/entities/ico_offering_entity.dart';
import '../../../../../core/theme/global_theme_extensions.dart';

class IcoCard extends StatelessWidget {
  const IcoCard({
    super.key,
    required this.offering,
    this.onTap,
    this.showProgress = true,
    this.isCompact = false,
  });

  final IcoOfferingEntity offering;
  final VoidCallback? onTap;
  final bool showProgress;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          context.colors.primary.withValues(alpha: 0.2),
                          context.colors.primary.withValues(alpha: 0.05),
                        ]
                      : [
                          context.colors.primary.withValues(alpha: 0.08),
                          context.colors.primary.withValues(alpha: 0.02),
                        ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: offering.icon.endsWith('.svg')
                              ? SvgPicture.network(
                                  offering.icon,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  placeholderBuilder: (_) =>
                                      _buildIconPlaceholder(),
                                )
                              : Image.network(
                                  offering.icon,
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildIconPlaceholder(),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title and Symbol
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              offering.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  offering.symbol,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white10
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    offering.blockchain,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      _buildStatusBadge(context),
                    ],
                  ),
                  if (!isCompact) ...[
                    const SizedBox(height: 12),
                    Text(
                      offering.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Price and Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'Token Price',
                          '\$${offering.tokenPrice.toStringAsFixed(4)}',
                          Icons.monetization_on_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatItem(
                          context,
                          'Target',
                          '\$${_formatAmount(offering.targetAmount)}',
                          Icons.flag_outlined,
                        ),
                      ),
                    ],
                  ),

                  if (showProgress) ...[
                    const SizedBox(height: 16),

                    // Progress Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${offering.progressPercentage.toStringAsFixed(1)}%',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: offering.progressPercentage / 100,
                            backgroundColor:
                                isDark ? Colors.white10 : Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              offering.progressPercentage >= 100
                                  ? Colors.green
                                  : context.colors.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Raised: \$${_formatAmount(offering.raisedAmount)}',
                              style: theme.textTheme.labelSmall,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 12,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${offering.daysRemaining}d left',
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Bottom Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${offering.participants}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'investors',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (offering.priceChange != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: offering.priceChange! >= 0
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                offering.priceChange! >= 0
                                    ? Icons.trending_up
                                    : Icons.trending_down,
                                size: 14,
                                color: offering.priceChange! >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${offering.priceChange! >= 0 ? '+' : ''}${offering.priceChange!.toStringAsFixed(2)}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: offering.priceChange! >= 0
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.currency_bitcoin,
        size: 24,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    switch (offering.status) {
      case IcoOfferingStatus.active:
        badgeColor = Colors.green;
        statusText = 'LIVE';
        statusIcon = Icons.circle;
        break;
      case IcoOfferingStatus.upcoming:
        badgeColor = Colors.orange;
        statusText = 'SOON';
        statusIcon = Icons.schedule;
        break;
      case IcoOfferingStatus.success:
        badgeColor = Colors.blue;
        statusText = 'SUCCESS';
        statusIcon = Icons.check_circle;
        break;
      case IcoOfferingStatus.failed:
        badgeColor = Colors.red;
        statusText = 'FAILED';
        statusIcon = Icons.cancel;
        break;
      case IcoOfferingStatus.pending:
        badgeColor = Colors.grey;
        statusText = 'PENDING';
        statusIcon = Icons.hourglass_empty;
        break;
      case IcoOfferingStatus.rejected:
        badgeColor = Colors.red.shade800;
        statusText = 'REJECTED';
        statusIcon = Icons.block;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 12,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
