import 'package:flutter/material.dart';

class IcoActionButtons extends StatelessWidget {
  const IcoActionButtons({
    super.key,
    this.onBrowseIcos,
    this.onViewPortfolio,
    this.onViewTransactions,
    this.onCreateToken,
    this.compact = false,
  });

  final VoidCallback? onBrowseIcos;
  final VoidCallback? onViewPortfolio;
  final VoidCallback? onViewTransactions;
  final VoidCallback? onCreateToken;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(compact ? 8 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact)
            Text(
              'Quick Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          if (!compact) const SizedBox(height: 16),
          if (compact)
            // Compact: Single row with 4 buttons
            Row(
              children: [
                Expanded(
                  child: _buildCompactActionButton(
                    context,
                    'Browse',
                    Icons.search,
                    const Color(0xFF6366F1),
                    onBrowseIcos,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactActionButton(
                    context,
                    'Portfolio',
                    Icons.account_balance_wallet,
                    const Color(0xFF10B981),
                    onViewPortfolio,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactActionButton(
                    context,
                    'History',
                    Icons.history,
                    const Color(0xFF3B82F6),
                    onViewTransactions,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildCompactActionButton(
                    context,
                    'Create',
                    Icons.rocket_launch,
                    const Color(0xFFEF4444),
                    onCreateToken,
                  ),
                ),
              ],
            )
          else
            // Full: Two rows with detailed buttons
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Browse ICOs',
                        'Discover new investment opportunities',
                        Icons.search,
                        const Color(0xFF6366F1),
                        onBrowseIcos,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'My Portfolio',
                        'Track your investments',
                        Icons.account_balance_wallet,
                        const Color(0xFF10B981),
                        onViewPortfolio,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Transactions',
                        'View investment history',
                        Icons.history,
                        const Color(0xFF3B82F6),
                        onViewTransactions,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        'Create ICO',
                        'Launch your own token',
                        Icons.rocket_launch,
                        const Color(0xFFEF4444),
                        onCreateToken,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Subtitle
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),

              const SizedBox(height: 4),

              // Title
              Text(
                title,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
