import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../../../../../core/widgets/error_widget.dart' as core_error;
import '../../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/mlm_landing_entity.dart';
import '../../domain/entities/mlm_condition_entity.dart';
import '../bloc/mlm_bloc.dart';
import 'mlm_dashboard_page.dart';

class MlmLandingPage extends StatelessWidget {
  const MlmLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GetIt.instance<MlmLandingBloc>()
        ..add(const MlmLandingLoadRequested()),
      child: Scaffold(
        backgroundColor: context.colors.surface,
        appBar: AppBar(
          title: Text(
            'Affiliate Program',
            style: context.h5.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: context.colors.surface,
          foregroundColor: context.textPrimary,
        ),
        body: BlocBuilder<MlmLandingBloc, MlmLandingState>(
          builder: (context, state) {
            if (state is MlmLandingLoading) {
              return const Center(child: LoadingWidget());
            }

            if (state is MlmLandingError) {
              if (state.previousLanding != null) {
                return _buildContent(context, state.previousLanding!);
              }
              return core_error.ErrorWidget(
                message: state.errorMessage,
                onRetry: () => context
                    .read<MlmLandingBloc>()
                    .add(const MlmLandingRetryRequested()),
              );
            }

            if (state is MlmLandingLoaded) {
              return _buildContent(context, state.landing);
            }

            if (state is MlmLandingRefreshing) {
              return _buildContent(context, state.currentLanding);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MlmLandingEntity landing) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MlmLandingBloc>().add(const MlmLandingRefreshRequested());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            _buildHeroSection(context),
            const SizedBox(height: 24),

            // Stats Section
            _buildStatsSection(context, landing.stats),
            const SizedBox(height: 24),

            // Conditions Section
            if (landing.conditions.isNotEmpty) ...[
              _buildSectionHeader(context, 'Reward Conditions',
                  Icons.star_rounded, context.warningColor),
              const SizedBox(height: 12),
              _buildConditionsSection(context, landing.conditions),
              const SizedBox(height: 24),
            ],

            // Top Affiliates Section
            if (landing.topAffiliates.isNotEmpty) ...[
              _buildSectionHeader(context, 'Top Affiliates',
                  Icons.emoji_events_rounded, context.warningColor),
              const SizedBox(height: 12),
              _buildTopAffiliatesSection(context, landing.topAffiliates),
              const SizedBox(height: 24),
            ],

            // Recent Activity Section
            if (landing.recentActivity.isNotEmpty) ...[
              _buildSectionHeader(context, 'Recent Activity',
                  Icons.timeline_rounded, context.colors.primary),
              const SizedBox(height: 12),
              _buildRecentActivitySection(context, landing.recentActivity),
              const SizedBox(height: 24),
            ],

            // CTA Button
            _buildCtaSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.primary,
            context.colors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            color: Colors.white.withValues(alpha: 0.9),
            size: 40,
          ),
          const SizedBox(height: 16),
          Text(
            'Turn Your Network\nInto Passive Income',
            style: context.h5.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Earn rewards by referring friends to our platform. Share, grow, and earn together.',
            style: context.bodyM.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, MlmLandingStatsEntity stats) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Affiliates',
                stats.totalAffiliates.toString(),
                Icons.people_alt_rounded,
                context.colors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Paid Out',
                '\$${stats.totalPaidOut.toStringAsFixed(0)}',
                Icons.payments_rounded,
                context.priceUpColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Avg Monthly',
                '\$${stats.avgMonthlyEarnings.toStringAsFixed(0)}',
                Icons.trending_up_rounded,
                context.warningColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Success Rate',
                '${stats.successRate.toStringAsFixed(1)}%',
                Icons.check_circle_rounded,
                context.priceUpColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.h6.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.labelS.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: context.h6.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionsSection(
      BuildContext context, List<MlmConditionEntity> conditions) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: conditions.length > 8 ? 8 : conditions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final condition = conditions[index];
          return _buildConditionCard(context, condition);
        },
      ),
    );
  }

  Widget _buildConditionCard(
      BuildContext context, MlmConditionEntity condition) {
    final isPercentage = condition.rewardType == MlmRewardType.percentage;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            condition.title,
            style: context.bodyS.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            isPercentage
                ? '${condition.reward.toStringAsFixed(1)}%'
                : '${condition.reward.toStringAsFixed(2)} ${condition.rewardCurrency}',
            style: context.h6.copyWith(
              fontWeight: FontWeight.w800,
              color: context.priceUpColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color:
                  (isPercentage ? context.colors.primary : context.warningColor)
                      .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isPercentage ? 'PERCENTAGE' : 'FIXED',
              style: context.labelS.copyWith(
                color: isPercentage
                    ? context.colors.primary
                    : context.warningColor,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAffiliatesSection(
      BuildContext context, List<MlmTopAffiliateEntity> affiliates) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: affiliates.length > 5 ? 5 : affiliates.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: context.borderColor.withValues(alpha: 0.4),
        ),
        itemBuilder: (context, index) {
          final affiliate = affiliates[index];
          return _buildAffiliateRow(context, affiliate);
        },
      ),
    );
  }

  Widget _buildAffiliateRow(
      BuildContext context, MlmTopAffiliateEntity affiliate) {
    final rankColors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };
    final rankColor = rankColors[affiliate.rank] ?? context.textSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '#${affiliate.rank}',
              style: context.labelS.copyWith(
                color: rankColor,
                fontWeight: FontWeight.w800,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: context.colors.primary.withValues(alpha: 0.1),
            backgroundImage: affiliate.avatar != null
                ? NetworkImage(affiliate.avatar!)
                : null,
            child: affiliate.avatar == null
                ? Text(
                    affiliate.displayName.isNotEmpty
                        ? affiliate.displayName[0].toUpperCase()
                        : '?',
                    style: context.bodyS.copyWith(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  affiliate.displayName,
                  style: context.bodyS.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${affiliate.rewardCount} rewards · ${affiliate.joinedAgo}',
                  style: context.labelS.copyWith(
                    color: context.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${affiliate.totalEarnings.toStringAsFixed(2)}',
            style: context.bodyS.copyWith(
              fontWeight: FontWeight.w700,
              color: context.priceUpColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(
      BuildContext context, List<MlmActivityEntity> activities) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length > 5 ? 5 : activities.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: context.borderColor.withValues(alpha: 0.4),
        ),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.monetization_on_rounded,
                    color: context.priceUpColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.conditionType,
                        style: context.bodyS.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        activity.timeAgo,
                        style: context.labelS.copyWith(
                          color: context.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '+${activity.amount.toStringAsFixed(2)} ${activity.currency}',
                  style: context.bodyS.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.priceUpColor,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCtaSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MlmDashboardPage()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: context.priceUpColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          'Go to Dashboard',
          style: context.bodyM.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
