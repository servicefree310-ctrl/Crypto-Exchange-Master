import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/widgets/error_widget.dart' as core_error;
import '../../../../../core/widgets/loading_widget.dart';
import '../bloc/mlm_bloc.dart';
import '../widgets/mlm_stats_card.dart';
import '../widgets/mlm_earnings_chart.dart';
import '../widgets/mlm_recent_activity.dart';
import '../widgets/mlm_quick_actions.dart';
import '../widgets/mlm_network_overview.dart';
import 'mlm_referrals_page.dart';
import 'mlm_rewards_page.dart';

class MlmDashboardPage extends StatelessWidget {
  const MlmDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => GetIt.instance<MlmDashboardBloc>()
            ..add(const MlmDashboardLoadRequested()),
        ),
        BlocProvider(
          create: (context) => GetIt.instance<MlmReferralsBloc>()
            ..add(const MlmReferralsLoadRequested(perPage: 5)),
        ),
        BlocProvider(
          create: (context) => GetIt.instance<MlmRewardsBloc>()
            ..add(const MlmRewardsLoadRequested(perPage: 5)),
        ),
      ],
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          title: Text(
            'MLM Dashboard',
            style: context.h5.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 1,
          backgroundColor: context.cardBackground,
          surfaceTintColor: Colors.transparent,
          foregroundColor: context.textPrimary,
          actions: [
            BlocBuilder<MlmDashboardBloc, MlmDashboardState>(
              builder: (context, state) {
                final currentPeriod = state is MlmDashboardLoaded
                    ? state.period
                    : state is MlmDashboardError
                        ? state.period
                        : '6m';

                return Container(
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  child: Material(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () => _showPeriodSelector(context),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 16,
                              color: context.priceUpColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getPeriodName(currentPeriod),
                              style: context.labelM.copyWith(
                                color: context.priceUpColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: context.priceUpColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => _refreshAll(context),
          color: context.priceUpColor,
          backgroundColor: context.cardBackground,
          strokeWidth: 2.5,
          child: BlocListener<MlmDashboardBloc, MlmDashboardState>(
            listener: (context, state) {
              if (state is MlmDashboardError &&
                  state.previousDashboard == null) {
                _showErrorSnackBar(context, state.errorMessage);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions Row
                  const MlmQuickActions(),
                  const SizedBox(height: 20),

                  // Stats Overview
                  BlocBuilder<MlmDashboardBloc, MlmDashboardState>(
                    builder: (context, state) {
                      if (state is MlmDashboardLoading &&
                          state is! MlmDashboardRefreshing) {
                        return _buildStatsLoading();
                      } else if (state is MlmDashboardLoaded ||
                          state is MlmDashboardRefreshing) {
                        final dashboard = state is MlmDashboardLoaded
                            ? state.dashboard
                            : (state as MlmDashboardRefreshing)
                                .currentDashboard;
                        return MlmStatsCard(dashboard: dashboard);
                      } else if (state is MlmDashboardError) {
                        if (state.previousDashboard != null) {
                          // Show previous data with error indicator
                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      context.priceDownColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_rounded,
                                      color: context.priceDownColor,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Failed to refresh. Showing cached data.',
                                        style: context.labelS.copyWith(
                                          color: context.priceDownColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              MlmStatsCard(dashboard: state.previousDashboard!),
                            ],
                          );
                        }
                        return _buildErrorCard(context, state);
                      }
                      return _buildStatsLoading();
                    },
                  ),
                  const SizedBox(height: 20),

                  // Network Overview
                  BlocBuilder<MlmDashboardBloc, MlmDashboardState>(
                    builder: (context, state) {
                      if (state is MlmDashboardLoaded ||
                          state is MlmDashboardRefreshing) {
                        final dashboard = state is MlmDashboardLoaded
                            ? state.dashboard
                            : (state as MlmDashboardRefreshing)
                                .currentDashboard;
                        return MlmNetworkOverview(
                          networkSummary: dashboard.networkSummary,
                        );
                      } else if (state is MlmDashboardError &&
                          state.previousDashboard != null) {
                        return MlmNetworkOverview(
                          networkSummary:
                              state.previousDashboard!.networkSummary,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 20),

                  // Earnings Chart
                  BlocBuilder<MlmDashboardBloc, MlmDashboardState>(
                    builder: (context, state) {
                      if (state is MlmDashboardLoaded ||
                          state is MlmDashboardRefreshing) {
                        final dashboard = state is MlmDashboardLoaded
                            ? state.dashboard
                            : (state as MlmDashboardRefreshing)
                                .currentDashboard;
                        return MlmEarningsChart(
                          earningsChart: dashboard.earningsChart,
                          period:
                              state is MlmDashboardLoaded ? state.period : '6m',
                        );
                      } else if (state is MlmDashboardError &&
                          state.previousDashboard != null) {
                        return MlmEarningsChart(
                          earningsChart: state.previousDashboard!.earningsChart,
                          period: state.period,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 20),

                  // Recent Activity
                  BlocBuilder<MlmDashboardBloc, MlmDashboardState>(
                    builder: (context, state) {
                      if (state is MlmDashboardLoaded ||
                          state is MlmDashboardRefreshing) {
                        final dashboard = state is MlmDashboardLoaded
                            ? state.dashboard
                            : (state as MlmDashboardRefreshing)
                                .currentDashboard;
                        return MlmRecentActivity(dashboard: dashboard);
                      } else if (state is MlmDashboardError &&
                          state.previousDashboard != null) {
                        return MlmRecentActivity(
                            dashboard: state.previousDashboard!);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 100), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.borderColor,
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showQuickMenu(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard_customize_rounded,
                      size: 18,
                      color: context.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Actions',
                      style: context.labelM.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsLoading() {
    return const LoadingWidget(
      message: 'Loading dashboard...',
    );
  }

  Widget _buildErrorCard(BuildContext context, MlmDashboardError state) {
    return core_error.ErrorWidget(
      message: state.errorMessage,
      onRetry: () => context.read<MlmDashboardBloc>().add(
            MlmDashboardRetryRequested(period: state.period),
          ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: context.priceDownColor,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _refreshAll(BuildContext context) async {
    final futures = [
      Future(() => context.read<MlmDashboardBloc>().add(
            const MlmDashboardRefreshRequested(),
          )),
      Future(() => context.read<MlmReferralsBloc>().add(
            const MlmReferralsRefreshRequested(),
          )),
      Future(() => context.read<MlmRewardsBloc>().add(
            const MlmRewardsRefreshRequested(),
          )),
    ];

    await Future.wait(futures);
  }

  void _showPeriodSelector(BuildContext context) {
    final dashboardBloc = context.read<MlmDashboardBloc>();
    final currentState = dashboardBloc.state;
    final currentPeriod = currentState is MlmDashboardLoaded
        ? currentState.period
        : currentState is MlmDashboardError
            ? currentState.period
            : '6m';

    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  color: context.priceUpColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Analytics Period',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Choose the time range for your MLM analytics',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Period options
            ...['1m', '3m', '6m', '1y'].map((period) => _buildPeriodTile(
                  modalContext,
                  dashboardBloc,
                  period,
                  _getPeriodName(period),
                  _getPeriodDescription(period),
                  isSelected: period == currentPeriod,
                )),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTile(
    BuildContext context,
    MlmDashboardBloc dashboardBloc,
    String period,
    String name,
    String description, {
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? context.priceUpColor : context.borderColor,
          width: isSelected ? 1.5 : 0.5,
        ),
        color: isSelected
            ? context.priceUpColor.withValues(alpha: 0.05)
            : Colors.transparent,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? context.priceUpColor.withValues(alpha: 0.15)
                : context.priceUpColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isSelected
                ? Icons.radio_button_checked_rounded
                : Icons.schedule_rounded,
            color: context.priceUpColor,
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: context.bodyM.copyWith(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? context.priceUpColor : context.textPrimary,
          ),
        ),
        subtitle: Text(
          description,
          style: context.labelS.copyWith(
            color: context.textSecondary,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle_rounded,
                color: context.priceUpColor,
                size: 20,
              )
            : null,
        onTap: () {
          Navigator.pop(context);
          dashboardBloc.add(
            MlmDashboardPeriodChanged(period: period),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showQuickMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Row(
              children: [
                Icon(
                  Icons.dashboard_customize_rounded,
                  color: context.priceUpColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Quick Actions',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Access your MLM features quickly',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _buildActionTile(
              modalContext,
              Icons.people_rounded,
              'View All Referrals',
              'Manage your referral network',
              modalContext.priceUpColor,
              () {
                Navigator.pop(modalContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MlmReferralsPage(),
                  ),
                );
              },
            ),
            _buildActionTile(
              modalContext,
              Icons.card_giftcard_rounded,
              'View All Rewards',
              'Check and claim your rewards',
              modalContext.warningColor,
              () {
                Navigator.pop(modalContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MlmRewardsPage(),
                  ),
                );
              },
            ),
            _buildActionTile(
              modalContext,
              Icons.share_rounded,
              'Share Referral Link',
              'Invite friends and earn more',
              modalContext.colors.primary,
              () {
                Navigator.pop(modalContext);
                _shareReferralLink(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.5,
        ),
        color: color.withValues(alpha: 0.03),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: context.bodyM.copyWith(
            fontWeight: FontWeight.w700,
            color: context.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: context.labelS.copyWith(
            color: context.textSecondary,
            height: 1.4,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.arrow_forward_ios_rounded,
            color: color,
            size: 12,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  String _getUserReferralLink(BuildContext context) {
    final baseUrl = ApiConstants.baseUrl;
    final dashboardState = context.read<MlmDashboardBloc>().state;
    String userId = '';
    if (dashboardState is MlmDashboardLoaded) {
      userId = dashboardState.dashboard.userProfile.id;
    } else if (dashboardState is MlmDashboardRefreshing) {
      userId = dashboardState.currentDashboard.userProfile.id;
    }
    return '$baseUrl/register?ref=$userId';
  }

  void _shareReferralLink(BuildContext context) {
    final referralLink = _getUserReferralLink(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.priceUpColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.share_rounded,
                color: context.priceUpColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Share Referral Link',
              style: context.h6.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invite friends and earn rewards when they join!',
              style: context.bodyM.copyWith(
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      referralLink,
                      style: context.bodyS.copyWith(
                        fontFamily: 'monospace',
                        color: context.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () async {
                        await Clipboard.setData(ClipboardData(text: referralLink));
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Referral link copied!'),
                            backgroundColor: context.priceUpColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.copy_rounded,
                          color: context.priceUpColor,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: context.labelM.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPeriodName(String period) {
    switch (period) {
      case '1m':
        return '1 Month';
      case '3m':
        return '3 Months';
      case '6m':
        return '6 Months';
      case '1y':
        return '1 Year';
      default:
        return period;
    }
  }

  String _getPeriodDescription(String period) {
    switch (period) {
      case '1m':
        return 'View last 30 days performance';
      case '3m':
        return 'View last 3 months performance';
      case '6m':
        return 'View last 6 months performance';
      case '1y':
        return 'View last year performance';
      default:
        return 'View performance data';
    }
  }
}
