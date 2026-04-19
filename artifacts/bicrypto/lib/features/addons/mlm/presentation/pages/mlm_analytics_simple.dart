import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/widgets/loading_widget.dart';
import '../../../../../core/widgets/error_widget.dart' as core;
import '../../../../../injection/injection.dart';
import '../../domain/entities/mlm_dashboard_entity.dart';
import '../bloc/mlm_dashboard_bloc.dart';
import '../bloc/mlm_dashboard_event.dart';
import '../bloc/mlm_dashboard_state.dart';

class MlmAnalyticsPage extends StatelessWidget {
  const MlmAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<MlmDashboardBloc>()..add(const MlmDashboardLoadRequested()),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: context.cardBackground,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'MLM Analytics',
            style: context.h6.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _showPeriodSelector(context),
              icon: Icon(
                Icons.tune_rounded,
                color: context.textSecondary,
              ),
              tooltip: 'Filter by period',
            ),
            IconButton(
              onPressed: () => _refreshData(context),
              icon: Icon(
                Icons.refresh_rounded,
                color: context.textSecondary,
              ),
              tooltip: 'Refresh data',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocConsumer<MlmDashboardBloc, MlmDashboardState>(
          listener: (context, state) {
            if (state is MlmDashboardError && state.previousDashboard == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: context.priceDownColor,
                  action: SnackBarAction(
                    label: 'Retry',
                    textColor: Colors.white,
                    onPressed: () => context.read<MlmDashboardBloc>().add(
                          const MlmDashboardRetryRequested(),
                        ),
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is MlmDashboardLoading) {
              return const Center(child: LoadingWidget());
            }

            if (state is MlmDashboardError && state.previousDashboard == null) {
              return Center(
                child: core.ErrorWidget(
                  message: state.errorMessage,
                  onRetry: () => context.read<MlmDashboardBloc>().add(
                        const MlmDashboardRetryRequested(),
                      ),
                ),
              );
            }

            final dashboard = _getDashboardFromState(state);
            if (dashboard == null) {
              return const Center(child: LoadingWidget());
            }

            return _buildAnalyticsContent(context, dashboard, state);
          },
        ),
      ),
    );
  }

  MlmDashboardEntity? _getDashboardFromState(MlmDashboardState state) {
    if (state is MlmDashboardLoaded) return state.dashboard;
    if (state is MlmDashboardRefreshing) return state.currentDashboard;
    if (state is MlmDashboardError) return state.previousDashboard;
    return null;
  }

  Widget _buildAnalyticsContent(
    BuildContext context,
    MlmDashboardEntity dashboard,
    MlmDashboardState state,
  ) {
    final isRefreshing = state is MlmDashboardRefreshing;

    return RefreshIndicator(
      onRefresh: () => _refreshData(context),
      color: context.priceUpColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Refresh indicator
            if (isRefreshing)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.priceUpColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.priceUpColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Refreshing analytics...',
                      style: context.labelM.copyWith(
                        color: context.priceUpColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

            // Performance Overview
            _buildSectionHeader(context, 'Performance Overview'),
            _buildPerformanceMetrics(context, dashboard),
            const SizedBox(height: 24),

            // Referral Analytics
            _buildSectionHeader(context, 'Referral Analytics'),
            _buildReferralMetrics(context, dashboard),
            const SizedBox(height: 24),

            // Earnings Analytics
            _buildSectionHeader(context, 'Earnings Analytics'),
            _buildEarningsMetrics(context, dashboard),
            const SizedBox(height: 24),

            // Network Analytics
            _buildSectionHeader(context, 'Network Analytics'),
            _buildNetworkMetrics(context, dashboard),
            const SizedBox(height: 24),

            // Data Insights
            _buildSectionHeader(context, 'Insights'),
            _buildInsights(context, dashboard),
            const SizedBox(height: 100), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: context.h6.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(
      BuildContext context, MlmDashboardEntity dashboard) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Conversion Rate',
            '${dashboard.stats.conversionRate.toStringAsFixed(1)}%',
            Icons.trending_up_rounded,
            context.priceUpColor,
            subtitle: 'Referral success rate',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'Growth Rate',
            '${dashboard.stats.weeklyGrowth.toStringAsFixed(1)}%',
            dashboard.stats.weeklyGrowth >= 0
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            dashboard.stats.weeklyGrowth >= 0
                ? context.priceUpColor
                : context.priceDownColor,
            subtitle: 'Weekly growth',
          ),
        ),
      ],
    );
  }

  Widget _buildReferralMetrics(
      BuildContext context, MlmDashboardEntity dashboard) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Total Referrals',
            '${dashboard.stats.totalReferrals}',
            Icons.people_rounded,
            context.colors.primary,
            subtitle: 'All time',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'Active',
            '${dashboard.stats.activeReferrals}',
            Icons.check_circle_rounded,
            context.priceUpColor,
            subtitle: 'Active referrals',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'Pending',
            '${dashboard.stats.pendingReferrals}',
            Icons.schedule_rounded,
            context.warningColor,
            subtitle: 'Awaiting approval',
          ),
        ),
      ],
    );
  }

  Widget _buildEarningsMetrics(
      BuildContext context, MlmDashboardEntity dashboard) {
    final chartDataCount = dashboard.earningsChart.length;
    final avgEarnings = chartDataCount > 0
        ? dashboard.earningsChart.map((e) => e.value).reduce((a, b) => a + b) /
            chartDataCount
        : 0.0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total Earnings',
                '\$${dashboard.stats.totalEarnings.toStringAsFixed(2)}',
                Icons.account_balance_wallet_rounded,
                context.priceUpColor,
                subtitle: 'All time earnings',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Avg. Monthly',
                '\$${avgEarnings.toStringAsFixed(2)}',
                Icons.timeline_rounded,
                context.warningColor,
                subtitle: 'Monthly average',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEarningsChart(context, dashboard.earningsChart),
      ],
    );
  }

  Widget _buildNetworkMetrics(
      BuildContext context, MlmDashboardEntity dashboard) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            'Network Size',
            '${dashboard.networkSummary.totalNetworkSize}',
            Icons.account_tree_rounded,
            context.colors.primary,
            subtitle: 'Total members',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'Active Members',
            '${dashboard.networkSummary.activeMembers}',
            Icons.groups_rounded,
            context.priceUpColor,
            subtitle: 'Active in network',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'Network Depth',
            '${dashboard.networkSummary.networkDepth}',
            Icons.layers_rounded,
            context.warningColor,
            subtitle: 'Max levels',
          ),
        ),
      ],
    );
  }

  Widget _buildInsights(BuildContext context, MlmDashboardEntity dashboard) {
    final insights = _generateInsights(dashboard);

    return Column(
      children: insights
          .map((insight) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      insight['icon'] as IconData,
                      color: insight['color'] as Color,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insight['title'] as String,
                            style: context.bodyM
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insight['description'] as String,
                            style: context.labelS
                                .copyWith(color: context.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  List<Map<String, dynamic>> _generateInsights(MlmDashboardEntity dashboard) {
    final insights = <Map<String, dynamic>>[];

    // Conversion rate insight
    if (dashboard.stats.conversionRate > 15) {
      insights.add({
        'icon': Icons.star_rounded,
        'color': Colors.amber,
        'title': 'Excellent Conversion Rate',
        'description':
            'Your ${dashboard.stats.conversionRate.toStringAsFixed(1)}% conversion rate is above average',
      });
    } else if (dashboard.stats.conversionRate < 5) {
      insights.add({
        'icon': Icons.info_rounded,
        'color': Colors.blue,
        'title': 'Improve Conversion Rate',
        'description':
            'Consider strategies to improve your ${dashboard.stats.conversionRate.toStringAsFixed(1)}% conversion rate',
      });
    }

    // Growth insight
    if (dashboard.stats.weeklyGrowth > 10) {
      insights.add({
        'icon': Icons.trending_up_rounded,
        'color': Colors.green,
        'title': 'Strong Growth',
        'description':
            'Your network is growing at ${dashboard.stats.weeklyGrowth.toStringAsFixed(1)}% weekly',
      });
    } else if (dashboard.stats.weeklyGrowth < 0) {
      insights.add({
        'icon': Icons.trending_down_rounded,
        'color': Colors.red,
        'title': 'Negative Growth',
        'description':
            'Your network declined by ${dashboard.stats.weeklyGrowth.abs().toStringAsFixed(1)}% this week',
      });
    }

    // Network size insight
    if (dashboard.networkSummary.totalNetworkSize > 100) {
      insights.add({
        'icon': Icons.emoji_events_rounded,
        'color': Colors.orange,
        'title': 'Large Network',
        'description':
            'You have built a substantial network of ${dashboard.networkSummary.totalNetworkSize} members',
      });
    }

    // Add default insight if none generated
    if (insights.isEmpty) {
      insights.add({
        'icon': Icons.analytics_rounded,
        'color': Colors.blue,
        'title': 'Keep Growing',
        'description':
            'Continue building your network and engaging with referrals',
      });
    }

    return insights;
  }

  Widget _buildEarningsChart(
      BuildContext context, List<MlmChartDataEntity> data) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: data.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart_rounded,
                    size: 32,
                    color: context.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No earnings data available',
                    style: context.bodyM.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data
                  .take(6)
                  .map((item) => _buildChartBar(context, item, data))
                  .toList(),
            ),
    );
  }

  Widget _buildChartBar(BuildContext context, MlmChartDataEntity item,
      List<MlmChartDataEntity> allData) {
    final maxValue =
        allData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final height = maxValue > 0 ? (item.value / maxValue) * 80 : 4.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 20,
          height: height.clamp(4.0, 80.0),
          decoration: BoxDecoration(
            color: context.priceUpColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.period.length > 2
              ? item.period.substring(item.period.length - 2)
              : item.period,
          style: context.labelS.copyWith(
            color: context.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: context.labelM.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.h5.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.labelS.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _refreshData(BuildContext context) async {
    context.read<MlmDashboardBloc>().add(
          const MlmDashboardRefreshRequested(),
        );
  }

  void _showPeriodSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Analytics Period',
              style: context.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...['1m', '3m', '6m', '1y'].map((period) => _buildPeriodTile(
                  context,
                  period,
                  _getPeriodName(period),
                  _getPeriodDescription(period),
                )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTile(
      BuildContext context, String period, String name, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.priceUpColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.schedule_rounded,
            color: context.priceUpColor,
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: context.bodyM.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          description,
          style: context.labelS.copyWith(color: context.textSecondary),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          Navigator.pop(context);
          context.read<MlmDashboardBloc>().add(
                MlmDashboardPeriodChanged(period: period),
              );
        },
      ),
    );
  }

  String _getPeriodName(String period) {
    switch (period) {
      case '1m':
        return 'Last Month';
      case '3m':
        return 'Last 3 Months';
      case '6m':
        return 'Last 6 Months';
      case '1y':
        return 'Last Year';
      default:
        return 'Last 6 Months';
    }
  }

  String _getPeriodDescription(String period) {
    switch (period) {
      case '1m':
        return 'Analyze recent performance';
      case '3m':
        return 'Quarter overview';
      case '6m':
        return 'Semi-annual analysis';
      case '1y':
        return 'Annual performance review';
      default:
        return 'Default period';
    }
  }
}
