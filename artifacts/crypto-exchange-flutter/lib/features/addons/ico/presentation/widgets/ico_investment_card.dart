import 'package:flutter/material.dart';
import '../../domain/entities/ico_portfolio_entity.dart';
import '../../../../../core/theme/global_theme_extensions.dart';

class IcoInvestmentCard extends StatelessWidget {
  const IcoInvestmentCard({
    super.key,
    required this.investment,
    this.onTap,
    this.compact = false,
  });

  final IcoInvestmentEntity investment;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    final isProfitable = investment.profitLoss >= 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(compact ? 12 : 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
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
                // Icon
                Container(
                  width: compact ? 36 : 44,
                  height: compact ? 36 : 44,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      investment.offeringIcon,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.currency_bitcoin,
                        size: compact ? 20 : 24,
                        color: context.colors.primary,
                      ),
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
                        investment.offeringName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 14 : 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            investment.offeringSymbol,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(context),
                        ],
                      ),
                    ],
                  ),
                ),

                // Profit/Loss Indicator
                if (!compact)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isProfitable
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isProfitable
                              ? Icons.trending_up
                              : Icons.trending_down,
                          size: 12,
                          color: isProfitable ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${investment.profitLossPercentage >= 0 ? '+' : ''}${investment.profitLossPercentage.toStringAsFixed(1)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isProfitable ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            if (!compact) ...[
              const SizedBox(height: 16),

              // Investment Stats
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Amount',
                      '${investment.tokenAmount.toStringAsFixed(2)} ${investment.offeringSymbol}',
                      Icons.account_balance_wallet_outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      context,
                      'Value',
                      '\$${_formatAmount(investment.currentValue)}',
                      Icons.monetization_on_outlined,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Additional Info
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      'Invested',
                      '\$${_formatAmount(investment.investedAmount)}',
                    ),
                  ),
                  if (investment.profitLoss != 0)
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        'P&L',
                        '\$${_formatAmount(investment.profitLoss.abs())}',
                        isProfitable ? Colors.green : Colors.red,
                      ),
                    ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 8),

              // Compact stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${investment.tokenAmount.toStringAsFixed(2)} ${investment.offeringSymbol}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Invested: \$${_formatAmount(investment.investedAmount)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${_formatAmount(investment.currentValue)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isProfitable)
                        Text(
                          '+\$${_formatAmount(investment.profitLoss)}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          '-\$${_formatAmount(investment.profitLoss.abs())}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color badgeColor;
    String statusText;
    IconData statusIcon;

    switch (investment.status) {
      case IcoTransactionStatus.pending:
        badgeColor = Colors.orange;
        statusText = 'PENDING';
        statusIcon = Icons.schedule;
        break;
      case IcoTransactionStatus.verification:
        badgeColor = Colors.blue;
        statusText = 'VERIFYING';
        statusIcon = Icons.verified_user;
        break;
      case IcoTransactionStatus.released:
        badgeColor = Colors.green;
        statusText = 'RELEASED';
        statusIcon = Icons.check_circle;
        break;
      case IcoTransactionStatus.rejected:
        badgeColor = Colors.red;
        statusText = 'REJECTED';
        statusIcon = Icons.cancel;
        break;
      default:
        badgeColor = Colors.grey;
        statusText = 'UNKNOWN';
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 10,
            color: badgeColor,
          ),
          const SizedBox(width: 3),
          Text(
            statusText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
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
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200,
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

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value, [
    Color? valueColor,
  ]) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}
