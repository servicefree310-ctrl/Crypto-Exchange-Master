import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/theme/app_themes.dart';

import '../bloc/ico_bloc.dart';
import '../bloc/ico_event.dart';
import '../bloc/ico_state.dart';
import '../widgets/ico_card.dart';
import '../widgets/portfolio_overview_card.dart';
import '../widgets/ico_loading_state.dart';
import '../widgets/ico_error_state.dart';
import '../../domain/entities/ico_offering_entity.dart';
import '../../domain/entities/ico_portfolio_entity.dart'
    show IcoTransactionEntity, IcoTransactionStatus;
import 'ico_creator_page.dart';
import 'ico_browse_page.dart';
import 'ico_portfolio_page.dart';
import 'ico_transactions_page.dart';
import 'ico_detail_page.dart';

final sl = GetIt.instance;

class IcoDashboardPage extends StatelessWidget {
  const IcoDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<IcoBloc>()..add(const IcoLoadDashboardDataRequested()),
      child: const _IcoDashboardView(),
    );
  }
}

class _IcoDashboardView extends StatelessWidget {
  const _IcoDashboardView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<IcoBloc>().add(const IcoRefreshRequested());
          // Wait for state to update
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: context.colors.surface,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Text(
                  'ICO Hub',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        context.colors.primary.withValues(alpha: 0.1),
                        context.colors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -30,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.primary.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () {
                    // TODO: Implement notifications
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: BlocBuilder<IcoBloc, IcoState>(
                builder: (context, state) {
                  if (state is IcoLoading) {
                    return const IcoLoadingState();
                  }

                  if (state is IcoError) {
                    return IcoErrorState(
                      message: state.message,
                      onRetry: () => context.read<IcoBloc>().add(
                            const IcoLoadDashboardDataRequested(),
                          ),
                    );
                  }

                  if (state is IcoDashboardLoaded) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Portfolio Overview
                          PortfolioOverviewCard(
                            portfolio: state.portfolio,
                            compact: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const IcoPortfolioPage(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Quick Actions
                          _buildQuickActions(context),

                          const SizedBox(height: 24),

                          // Featured ICOs
                          _buildSectionHeader(
                            context,
                            'Featured ICOs',
                            onViewAll: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const IcoBrowsePage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          if (state.featuredOfferings.isEmpty)
                            _buildEmptyState(context)
                          else
                            ...state.featuredOfferings.map(
                              (offering) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: IcoCard(
                                  offering: offering,
                                  isCompact: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => IcoDetailPage(
                                          offeringId: offering.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                          if (state.featuredOfferings.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const IcoBrowsePage(),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('View All ICOs'),
                              ),
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Recent Transactions
                          if (state.recentTransactions.isNotEmpty) ...[
                            _buildSectionHeader(
                              context,
                              'Recent Activity',
                              onViewAll: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const IcoTransactionsPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            ...state.recentTransactions.take(3).map(
                                  (transaction) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _buildTransactionItem(
                                      context,
                                      transaction,
                                    ),
                                  ),
                                ),
                          ],
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.search,
                  label: 'Browse',
                  color: AppThemes.infoColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IcoBrowsePage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.account_balance_wallet,
                  label: 'Portfolio',
                  color: context.priceUpColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IcoPortfolioPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.history,
                  label: 'History',
                  color: context.orangeAccent,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IcoTransactionsPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.rocket_launch,
                  label: 'Create',
                  color: context.colors.tertiary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IcoCreatorPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    VoidCallback? onViewAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Row(
              children: [
                Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: context.colors.primary,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.rocket_launch_outlined,
              size: 48,
              color: context.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Featured ICOs',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new opportunities',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textTertiary,
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const IcoBrowsePage(),
                  ),
                );
              },
              child: const Text('Browse All ICOs'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    IcoTransactionEntity transaction,
  ) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    Color statusColor;
    IconData statusIcon;

    switch (transaction.status) {
      case IcoTransactionStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case IcoTransactionStatus.verification:
        statusColor = Colors.blue;
        statusIcon = Icons.verified_user;
        break;
      case IcoTransactionStatus.released:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case IcoTransactionStatus.rejected:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.offeringName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${transaction.amount.toStringAsFixed(2)} ${transaction.offeringSymbol}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${transaction.totalCost.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                transaction.statusText,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper extension for formatting
extension IcoStatusExtension on IcoOfferingStatus {
  String get displayName {
    switch (this) {
      case IcoOfferingStatus.active:
        return 'Active';
      case IcoOfferingStatus.upcoming:
        return 'Upcoming';
      case IcoOfferingStatus.pending:
        return 'Pending';
      case IcoOfferingStatus.success:
        return 'Successful';
      case IcoOfferingStatus.failed:
        return 'Failed';
      case IcoOfferingStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case IcoOfferingStatus.active:
        return Colors.green;
      case IcoOfferingStatus.upcoming:
        return Colors.blue;
      case IcoOfferingStatus.pending:
        return Colors.orange;
      case IcoOfferingStatus.success:
        return Colors.green.shade700;
      case IcoOfferingStatus.failed:
        return Colors.red;
      case IcoOfferingStatus.rejected:
        return Colors.red.shade700;
    }
  }
}

extension IcoTokenTypeExtension on IcoTokenType {
  String get displayName {
    switch (this) {
      case IcoTokenType.utility:
        return 'Utility';
      case IcoTokenType.security:
        return 'Security';
      case IcoTokenType.governance:
        return 'Governance';
      case IcoTokenType.payment:
        return 'Payment';
    }
  }

  IconData get icon {
    switch (this) {
      case IcoTokenType.utility:
        return Icons.build_circle;
      case IcoTokenType.security:
        return Icons.security;
      case IcoTokenType.governance:
        return Icons.how_to_vote;
      case IcoTokenType.payment:
        return Icons.payment;
    }
  }
}
