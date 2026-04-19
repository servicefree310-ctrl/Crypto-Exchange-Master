import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/global_theme_extensions.dart';
import '../pages/mlm_referrals_page.dart';
import '../pages/mlm_rewards_page.dart';
import '../pages/mlm_analytics_page.dart';
import '../bloc/mlm_dashboard_bloc.dart';
import '../bloc/mlm_dashboard_state.dart';
import '../bloc/mlm_rewards_bloc.dart';
import '../bloc/mlm_rewards_state.dart';
import '../../../../../core/constants/api_constants.dart';

class MlmQuickActions extends StatelessWidget {
  const MlmQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.6),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.flash_on_rounded,
                    color: context.colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Quick Actions',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),

          // Actions Grid
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: BlocBuilder<MlmDashboardBloc, MlmDashboardState>(
                    builder: (context, dashboardState) {
                      String referralCount = '';
                      if (dashboardState is MlmDashboardLoaded) {
                        final count =
                            dashboardState.dashboard.stats.totalReferrals;
                        // Only show count if it's a reasonable number and > 0
                        if (count > 0 && count <= 99) {
                          referralCount = count.toString();
                        } else if (count > 99) {
                          referralCount = '99+';
                        }
                      } else if (dashboardState is MlmDashboardRefreshing) {
                        final count = dashboardState
                            .currentDashboard.stats.totalReferrals;
                        if (count > 0 && count <= 99) {
                          referralCount = count.toString();
                        } else if (count > 99) {
                          referralCount = '99+';
                        }
                      }

                      return _CompactActionButton(
                        icon: Icons.people_alt_rounded,
                        label: 'Referrals',
                        count: referralCount,
                        color: context.priceUpColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MlmReferralsPage()),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: BlocBuilder<MlmRewardsBloc, MlmRewardsState>(
                    builder: (context, rewardsState) {
                      String rewardCount = '';
                      if (rewardsState is MlmRewardsLoaded) {
                        // Count unclaimed rewards
                        final unclaimedRewards = rewardsState.rewards
                            .where((reward) =>
                                reward.status == MlmRewardStatus.pending)
                            .length;
                        if (unclaimedRewards > 0 && unclaimedRewards <= 99) {
                          rewardCount = unclaimedRewards.toString();
                        } else if (unclaimedRewards > 99) {
                          rewardCount = '99+';
                        }
                      }

                      return _CompactActionButton(
                        icon: Icons.card_giftcard_rounded,
                        label: 'Rewards',
                        count: rewardCount,
                        color: context.warningColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MlmRewardsPage()),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CompactActionButton(
                    icon: Icons.share_rounded,
                    label: 'Share',
                    count: '',
                    color: context.colors.primary,
                    onTap: () => _showShareDialog(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _CompactActionButton(
                    icon: Icons.analytics_rounded,
                    label: 'Analytics',
                    count: '',
                    color: context.colors.secondary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MlmAnalyticsPage()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getUserReferralLink(BuildContext context) {
    final baseUrl = ApiConstants.baseUrl;
    try {
      final dashboardState = context.read<MlmDashboardBloc>().state;
      String userId = '';
      if (dashboardState is MlmDashboardLoaded) {
        userId = dashboardState.dashboard.userProfile.id;
      } else if (dashboardState is MlmDashboardRefreshing) {
        userId = dashboardState.currentDashboard.userProfile.id;
      }
      if (userId.isNotEmpty) {
        return '$baseUrl/register?ref=$userId';
      }
    } catch (_) {}
    return '$baseUrl/register';
  }

  void _showShareDialog(BuildContext context) {
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
              'Invite friends and earn rewards when they join ${AppConstants.appName}!',
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
                    child: Builder(builder: (context) {
                      final referralLink = _getUserReferralLink(context);
                      return Text(
                        referralLink,
                        style: context.bodyS.copyWith(
                          fontFamily: 'monospace',
                          color: context.textPrimary,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: context.priceUpColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () async {
                        final link = _getUserReferralLink(context);
                        await Clipboard.setData(ClipboardData(text: link));
                        if (context.mounted) {
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
                        }
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
}

class _CompactActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String count;
  final Color color;
  final VoidCallback onTap;

  const _CompactActionButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 20,
                    ),
                  ),
                  if (count.isNotEmpty)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count,
                          style: context.labelS.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: context.labelS.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
