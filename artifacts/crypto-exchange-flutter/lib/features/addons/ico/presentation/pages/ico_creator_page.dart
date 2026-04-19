import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/injection/injection.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';
import 'package:mobile/features/addons/ico_creator/presentation/bloc/creator_bloc.dart';
import 'package:mobile/features/addons/ico_creator/presentation/bloc/creator_event.dart';
import 'package:mobile/features/addons/ico_creator/presentation/bloc/creator_state.dart';
import 'package:mobile/features/addons/ico_creator/domain/entities/creator_token_entity.dart';
import 'package:mobile/features/addons/ico_creator/presentation/bloc/stats_cubit.dart';
import 'package:mobile/features/addons/ico_creator/presentation/bloc/performance_cubit.dart';
import 'package:mobile/features/addons/ico_creator/presentation/pages/creator_analytics_page.dart';
import 'package:mobile/features/addons/ico_creator/presentation/pages/token_simulator_page.dart';
import 'package:mobile/features/addons/ico_creator/presentation/pages/creator_investors_page.dart';
import 'package:mobile/features/addons/ico_creator/domain/entities/creator_stats_entity.dart';
import 'ico_creator_launch_page.dart';
import '../widgets/animated_launch_fab.dart';

class IcoCreatorPage extends StatelessWidget {
  const IcoCreatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<CreatorBloc>()..add(const CreatorLoadDashboardRequested()),
        ),
        BlocProvider(
          create: (_) => getIt<StatsCubit>()..fetchStats(),
        ),
      ],
      child: const IcoCreatorView(),
    );
  }
}

class IcoCreatorView extends StatelessWidget {
  const IcoCreatorView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: () async {
          context
              .read<CreatorBloc>()
              .add(const CreatorLoadDashboardRequested());
          context.read<StatsCubit>().fetchStats();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: isDark ? const Color(0xFF0A0A0A) : Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                title: Text(
                  'Creator Hub',
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
                        context.colors.primary,
                        context.colors.primary.withValues(alpha: 0.6),
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
                            color: Colors.white.withValues(alpha: 0.1),
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
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      // Stats in header
                      Positioned(
                        bottom: 60,
                        left: 16,
                        right: 16,
                        child: BlocBuilder<StatsCubit, StatsState>(
                          builder: (context, state) {
                            if (state is StatsLoaded) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildHeaderStat(
                                    'Total Raised',
                                    '\$${_formatAmount(state.stats.totalRaised)}',
                                    Icons.attach_money,
                                  ),
                                  _buildHeaderStat(
                                    'Active',
                                    '${state.stats.activeOfferings}',
                                    Icons.rocket_launch,
                                  ),
                                  _buildHeaderStat(
                                    'Success Rate',
                                    '${_calculateSuccessRate(state.stats)}%',
                                    Icons.trending_up,
                                  ),
                                ],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.analytics_outlined,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider(
                              create: (_) => getIt<StatsCubit>()..fetchStats(),
                            ),
                            BlocProvider(
                              create: (_) => getIt<PerformanceCubit>(),
                            ),
                          ],
                          child: const CreatorAnalyticsPage(),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: BlocBuilder<CreatorBloc, CreatorState>(
                builder: (context, state) {
                  if (state is CreatorLoading) {
                    return _buildLoadingState();
                  }

                  if (state is CreatorError) {
                    return _buildErrorState(context, state.message);
                  }

                  if (state is CreatorDashboardLoaded) {
                    return _buildDashboardContent(context, state);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedLaunchFAB(
        extended: true,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: context.read<CreatorBloc>(),
                  ),
                ],
                child: const IcoCreatorLaunchPage(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.9),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, CreatorDashboardLoaded state) {
    final hasTokens = state.tokens.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          _buildQuickActions(context),

          const SizedBox(height: 24),

          // My Tokens Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Tokens',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (hasTokens)
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to all tokens
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (!hasTokens)
            _buildEmptyState(context)
          else
            ...state.tokens.take(3).map((token) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTokenCard(context, token),
                )),

          if (hasTokens) ...[
            const SizedBox(height: 24),

            // Recent Activity
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildRecentActivity(context),
          ],
        ],
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
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: context.colors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.add_circle,
                  label: 'Launch',
                  sublabel: 'New Token',
                  color: context.colors.primary,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                              value: context.read<CreatorBloc>(),
                            ),
                          ],
                          child: const IcoCreatorLaunchPage(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.calculate,
                  label: 'Simulator',
                  sublabel: 'Tokenomics',
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TokenSimulatorPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  icon: Icons.people,
                  label: 'Investors',
                  sublabel: 'Manage',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreatorInvestorsPage(),
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
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              sublabel,
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.6) : Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenCard(BuildContext context, CreatorTokenEntity token) {
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;
    final progress = token.targetAmount > 0
        ? (token.raisedAmount / token.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to token detail
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: token.icon.isNotEmpty
                            ? Image.network(
                                token.icon,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildTokenPlaceholder(token),
                              )
                            : _buildTokenPlaceholder(token),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title and info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            token.name,
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
                                token.symbol,
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
                                  token.blockchain,
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

                    // Status
                    _buildTokenStatusBadge(token.status),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress
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
                          '${(progress * 100).toStringAsFixed(1)}%',
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
                        value: progress,
                        backgroundColor:
                            isDark ? Colors.white10 : Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getStatusColor(token.status),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Raised: \$${_formatAmount(token.raisedAmount)}',
                          style: theme.textTheme.labelSmall,
                        ),
                        Text(
                          'Target: \$${_formatAmount(token.targetAmount)}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action buttons
                Row(
                  children: [
                    if (token.status == CreatorTokenStatus.active) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Edit token
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: View details
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('View'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTokenPlaceholder(CreatorTokenEntity token) {
    return Center(
      child: Text(
        token.symbol.substring(0, 2).toUpperCase(),
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildTokenStatusBadge(CreatorTokenStatus status) {
    final color = _getStatusColor(status);
    final text = _getStatusText(status);
    final icon = _getStatusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.rocket_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No Tokens Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Launch your first token to get started',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MultiBlocProvider(
                      providers: [
                        BlocProvider.value(
                          value: context.read<CreatorBloc>(),
                        ),
                      ],
                      child: const IcoCreatorLaunchPage(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Token'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    // TODO: Implement recent activity from real data
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            context.isDarkMode ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.isDarkMode
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.shade200,
        ),
      ),
      child: const Center(
        child: Text('No recent activity'),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<CreatorBloc>()
                    .add(const CreatorLoadDashboardRequested());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
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

  int _calculateSuccessRate(CreatorStatsEntity stats) {
    final total = stats.totalOfferings;
    if (total == 0) return 0;
    return ((stats.completedOfferings / total) * 100).round();
  }

  Color _getStatusColor(CreatorTokenStatus status) {
    switch (status) {
      case CreatorTokenStatus.draft:
        return Colors.grey;
      case CreatorTokenStatus.pending:
        return Colors.orange;
      case CreatorTokenStatus.active:
        return Colors.green;
      case CreatorTokenStatus.completed:
        return Colors.blue;
      case CreatorTokenStatus.rejected:
        return Colors.red;
    }
  }

  String _getStatusText(CreatorTokenStatus status) {
    switch (status) {
      case CreatorTokenStatus.draft:
        return 'DRAFT';
      case CreatorTokenStatus.pending:
        return 'PENDING';
      case CreatorTokenStatus.active:
        return 'ACTIVE';
      case CreatorTokenStatus.completed:
        return 'COMPLETED';
      case CreatorTokenStatus.rejected:
        return 'REJECTED';
    }
  }

  IconData _getStatusIcon(CreatorTokenStatus status) {
    switch (status) {
      case CreatorTokenStatus.draft:
        return Icons.edit;
      case CreatorTokenStatus.pending:
        return Icons.schedule;
      case CreatorTokenStatus.active:
        return Icons.check_circle;
      case CreatorTokenStatus.completed:
        return Icons.verified;
      case CreatorTokenStatus.rejected:
        return Icons.cancel;
    }
  }
}
