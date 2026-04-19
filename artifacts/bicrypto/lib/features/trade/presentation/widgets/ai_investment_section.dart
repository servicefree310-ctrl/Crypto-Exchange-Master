import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../domain/entities/ai_investment_plan_entity.dart';
import '../../domain/entities/ai_investment_entity.dart';
import '../bloc/ai_investment_bloc.dart';
import '../bloc/ai_investment_event.dart';
import '../bloc/ai_investment_state.dart';
import 'ai_investment_plan_card.dart';
import 'ai_investment_card.dart';

class AiInvestmentSection extends StatefulWidget {
  const AiInvestmentSection({super.key});

  @override
  State<AiInvestmentSection> createState() => _AiInvestmentSectionState();
}

class _AiInvestmentSectionState extends State<AiInvestmentSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AiInvestmentBloc>()
        ..add(const AiInvestmentPlansLoadRequested())
        ..add(const AiInvestmentUserInvestmentsLoadRequested()),
      child: BlocBuilder<AiInvestmentBloc, AiInvestmentState>(
        builder: (context, state) {
          return Container(
            decoration: BoxDecoration(
              color: context.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.borderColor,
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                // Header with loading indicator
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: context.borderColor,
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_graph_rounded,
                        size: 20,
                        color: context.colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'AI Investment',
                        style: context.h6,
                      ),
                      const Spacer(),
                      if (state is AiInvestmentLoading)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              context.colors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: context.inputBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: context.textSecondary,
                    labelStyle: context.labelM.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelStyle: context.labelM,
                    tabs: const [
                      Tab(text: 'Available Plans'),
                      Tab(text: 'My Investments'),
                    ],
                  ),
                ),

                // Tab Content
                SizedBox(
                  height: 300, // Fixed height for compact display
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Available Plans Tab
                      _buildPlansTab(context, state),
                      // My Investments Tab
                      _buildInvestmentsTab(context, state),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlansTab(BuildContext context, AiInvestmentState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AiInvestmentBloc>().add(
              const AiInvestmentPlansLoadRequested(),
            );
      },
      child: _buildPlansContent(context, state),
    );
  }

  Widget _buildPlansContent(BuildContext context, AiInvestmentState state) {
    if (state is AiInvestmentError) {
      return _buildErrorState(
        context,
        title: 'Connection Error',
        message: state.failure.message,
        onRefresh: () {
          context.read<AiInvestmentBloc>().add(
                const AiInvestmentPlansLoadRequested(),
              );
        },
      );
    }

    if (state is AiInvestmentPlansLoaded) {
      if (state.plans.isEmpty) {
        return _buildEmptyPlansState(context);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.plans.length,
        itemBuilder: (context, index) {
          final plan = state.plans[index];
          return AiInvestmentPlanCard(
            plan: plan,
            onTap: () => _showInvestmentDialog(context, plan),
          );
        },
      );
    }

    if (state is AiInvestmentDashboardState) {
      if (state.plans.isEmpty) {
        return _buildEmptyPlansState(context);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.plans.length,
        itemBuilder: (context, index) {
          final plan = state.plans[index];
          return AiInvestmentPlanCard(
            plan: plan,
            onTap: () => _showInvestmentDialog(context, plan),
          );
        },
      );
    }

    return _buildEmptyPlansState(context);
  }

  Widget _buildInvestmentsTab(BuildContext context, AiInvestmentState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AiInvestmentBloc>().add(
              const AiInvestmentUserInvestmentsLoadRequested(),
            );
      },
      child: _buildInvestmentsContent(context, state),
    );
  }

  Widget _buildInvestmentsContent(
      BuildContext context, AiInvestmentState state) {
    if (state is AiInvestmentError) {
      return _buildErrorState(
        context,
        title: 'Connection Error',
        message: state.failure.message,
        onRefresh: () {
          context.read<AiInvestmentBloc>().add(
                const AiInvestmentUserInvestmentsLoadRequested(),
              );
        },
      );
    }

    if (state is AiInvestmentUserInvestmentsLoaded) {
      if (state.investments.isEmpty) {
        return _buildEmptyInvestmentsState(context);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.investments.length,
        itemBuilder: (context, index) {
          final investment = state.investments[index];
          return AiInvestmentCard(
            investment: investment,
            onTap: () => _showInvestmentDetails(context, investment),
          );
        },
      );
    }

    if (state is AiInvestmentDashboardState) {
      if (state.userInvestments.isEmpty) {
        return _buildEmptyInvestmentsState(context);
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.userInvestments.length,
        itemBuilder: (context, index) {
          final investment = state.userInvestments[index];
          return AiInvestmentCard(
            investment: investment,
            onTap: () => _showInvestmentDetails(context, investment),
          );
        },
      );
    }

    return _buildEmptyInvestmentsState(context);
  }

  Widget _buildErrorState(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onRefresh,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Error container matching v5 style
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.errorContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colors.error.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 24,
                  color: context.colors.error,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: context.labelL.copyWith(
                    color: context.colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: context.bodyS.copyWith(
                    color: context.colors.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Pull down to refresh',
            style: context.bodyS.copyWith(
              color: context.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlansState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state container matching v5 amber style exactly
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.isDarkMode
                  ? Colors.amber.withValues(alpha: 0.1)
                  : const Color(0xFFFEF3C7), // v5 amber-50
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.isDarkMode
                    ? Colors.amber.withValues(alpha: 0.3)
                    : const Color(0xFFF59E0B).withValues(alpha: 0.3), // v5 amber-200
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 24,
                  color: context.isDarkMode
                      ? Colors.amber.shade400
                      : const Color(0xFFD97706), // v5 amber-600
                ),
                const SizedBox(height: 8),
                Text(
                  'No investment plans are currently available.',
                  style: context.labelL.copyWith(
                    color: context.isDarkMode
                        ? Colors.amber.shade400
                        : const Color(0xFFD97706), // v5 amber-600
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Please check back later or contact support.',
                  style: context.bodyS.copyWith(
                    color: context.isDarkMode
                        ? Colors.amber.shade400.withValues(alpha: 0.8)
                        : const Color(0xFFB45309), // v5 amber-700
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInvestmentsState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.trending_up_outlined,
            size: 48,
            color: context.textTertiary,
          ),
          const SizedBox(height: 12),
          Text(
            'No investments yet',
            style: context.h6.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your AI investment journey by selecting a plan from the Available Plans tab.',
            style: context.bodyS.copyWith(
              color: context.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showInvestmentDialog(
      BuildContext context, AiInvestmentPlanEntity plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Invest in ${plan.title}'),
        content: Text('Investment dialog for ${plan.title} coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showInvestmentDetails(
      BuildContext context, AiInvestmentEntity investment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Investment Details'),
        content: Text('Details for investment ${investment.id} coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
