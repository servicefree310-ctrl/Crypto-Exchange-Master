import 'package:flutter/material.dart';
import '../../domain/entities/ico_portfolio_entity.dart';
import '../../../../../core/theme/global_theme_extensions.dart';

class PortfolioOverviewCard extends StatelessWidget {
  const PortfolioOverviewCard({
    super.key,
    required this.portfolio,
    this.onTap,
    this.compact = false,
  });

  final IcoPortfolioEntity portfolio;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    final isProfit = portfolio.totalProfitLoss >= 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    context.colors.primary.withValues(alpha: 0.3),
                    context.colors.primary.withValues(alpha: 0.1),
                  ]
                : [
                    context.colors.primary.withValues(alpha: 0.15),
                    context.colors.primary.withValues(alpha: 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.colors.primary.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: context.colors.primary.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        compact ? 'Portfolio' : 'My ICO Portfolio',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isDark ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Total value across all investments',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(compact ? 8 : 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: context.colors.primary,
                      size: compact ? 20 : 24,
                    ),
                  ),
                ],
              ),

              SizedBox(height: compact ? 16 : 20),

              // Total Value
              Text(
                '\$${_formatAmount(portfolio.releasedValue)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: compact ? 24 : 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),

              const SizedBox(height: 8),

              // P&L Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isProfit
                          ? Colors.green.withValues(alpha: 0.15)
                          : Colors.red.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isProfit ? Icons.trending_up : Icons.trending_down,
                          size: 14,
                          color: isProfit ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isProfit ? '+' : ''}\$${_formatAmount(portfolio.totalProfitLoss.abs())}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isProfit ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '(${portfolio.profitLossPercentage >= 0 ? '+' : ''}${portfolio.profitLossPercentage.toStringAsFixed(1)}%)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isProfit ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: compact ? 16 : 20),

              // Stats Grid
              if (compact)
                Row(
                  children: [
                    Expanded(
                      child: _buildCompactStat(
                        context,
                        'Invested',
                        '\$${_formatAmount(portfolio.totalInvested)}',
                        Icons.account_balance,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    Expanded(
                      child: _buildCompactStat(
                        context,
                        'Active',
                        portfolio.activeInvestments.toString(),
                        Icons.rocket_launch,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05),
                    ),
                    Expanded(
                      child: _buildCompactStat(
                        context,
                        'Pending',
                        '\$${_formatAmount(portfolio.pendingInvested)}',
                        Icons.schedule,
                      ),
                    ),
                  ],
                )
              else
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    _buildFullStat(
                      context,
                      'Total Invested',
                      '\$${_formatAmount(portfolio.totalInvested)}',
                      Icons.account_balance,
                      Colors.blue,
                    ),
                    _buildFullStat(
                      context,
                      'Active ICOs',
                      portfolio.activeInvestments.toString(),
                      Icons.rocket_launch,
                      Colors.green,
                    ),
                    _buildFullStat(
                      context,
                      'Pending',
                      '\$${_formatAmount(portfolio.pendingInvested)}',
                      Icons.schedule,
                      Colors.orange,
                    ),
                    _buildFullStat(
                      context,
                      'Released',
                      '\$${_formatAmount(portfolio.releasedValue)}',
                      Icons.check_circle,
                      Colors.purple,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isDark
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.black.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.6)
                  : Colors.black.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
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
      return amount.toStringAsFixed(2);
    }
  }
}
