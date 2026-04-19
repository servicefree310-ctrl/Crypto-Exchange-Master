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
      create: (context) => getIt<MlmDashboardBloc>()
        ..add(const MlmDashboardLoadRequested()),
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
    return RefreshIndicator(
      onRefresh: () => _refreshData(context),
      color: context.priceUpColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Overview',
              style: context.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Conversion Rate',
                    '${dashboard.stats.conversionRate.toStringAsFixed(1)}%',
                    Icons.trending_up_rounded,
                    context.priceUpColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Growth Rate',
                    '${dashboard.stats.weeklyGrowth.toStringAsFixed(1)}%',
                    Icons.trending_up_rounded,
                    dashboard.stats.weeklyGrowth >= 0 ? context.priceUpColor : context.priceDownColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Referral Analytics',
              style: context.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    context,
                    'Total',
                    '${dashboard.stats.totalReferrals}',
                    Icons.people_rounded,
                    context.colors.primary,
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Earnings Analytics',
              style: context.h6.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              context,
              'Total Earnings',
              '\$${dashboard.stats.totalEarnings.toStringAsFixed(2)}',
              Icons.account_balance_wallet_rounded,
              context.priceUpColor,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
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
        ],
      ),
    );
  }

  Future<void> _refreshData(BuildContext context) async {
    context.read<MlmDashboardBloc>().add(
          const MlmDashboardRefreshRequested(),
        );
  }
}
