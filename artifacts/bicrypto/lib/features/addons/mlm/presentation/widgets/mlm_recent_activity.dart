import 'package:flutter/material.dart';
import '../../domain/entities/mlm_dashboard_entity.dart';
import '../../../../../core/theme/global_theme_extensions.dart';

class MlmRecentActivity extends StatelessWidget {
  const MlmRecentActivity({
    super.key,
    required this.dashboard,
  });

  final MlmDashboardEntity dashboard;

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
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: context.borderColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: context.colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent Activity',
                  style: context.h6.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showAllActivity(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: context.colors.primary.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: 14,
                            color: context.colors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'View All',
                            style: context.labelS.copyWith(
                              color: context.colors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Activity Items
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: _buildActivityItems(context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildActivityItems(BuildContext context) {
    final activities = <_ActivityData>[];

    // Add recent referrals as activities
    for (final referral in dashboard.recentReferrals.take(3)) {
      activities.add(_ActivityData(
        icon: Icons.person_add_rounded,
        title: 'New referral joined',
        subtitle:
            '${referral.referred.firstName} ${referral.referred.lastName} joined your network',
        time: _formatTimeAgo(referral.createdAt),
        amount: referral.earnings != null
            ? '+\$${referral.earnings!.toStringAsFixed(2)}'
            : '',
        color: context.priceUpColor,
        date: referral.createdAt,
        type: 'referral',
      ));
    }

    // Add recent rewards as activities
    for (final reward in dashboard.recentRewards.take(3)) {
      activities.add(_ActivityData(
        icon: reward.isClaimed
            ? Icons.check_circle_rounded
            : Icons.card_giftcard_rounded,
        title: reward.isClaimed ? 'Reward claimed' : 'Reward earned',
        subtitle: reward.description ?? _getRewardTypeDescription(reward.type),
        time: _formatTimeAgo(reward.createdAt),
        amount: '+\$${reward.amount.toStringAsFixed(2)}',
        color: reward.isClaimed ? context.priceUpColor : context.warningColor,
        date: reward.createdAt,
        type: 'reward',
      ));
    }

    // Sort by date (most recent first) and take top 5
    activities.sort((a, b) => b.date.compareTo(a.date));
    final recentActivities = activities.take(5).toList();

    if (recentActivities.isEmpty) {
      return [_buildEmptyState(context)];
    }

    return recentActivities.map((activity) {
      return _ActivityItem(
        icon: activity.icon,
        title: activity.title,
        subtitle: activity.subtitle,
        time: activity.time,
        amount: activity.amount,
        color: activity.color,
      );
    }).toList();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.history_rounded,
            size: 48,
            color: context.textSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No recent activity',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Start referring friends to see activity here',
            style: context.labelS.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String _getRewardTypeDescription(dynamic rewardType) {
    final typeStr = rewardType.toString().split('.').last;
    switch (typeStr) {
      case 'REFERRAL':
        return 'Referral commission earned';
      case 'LEVEL':
        return 'Level commission earned';
      case 'BONUS':
        return 'Bonus reward earned';
      case 'ACHIEVEMENT':
        return 'Achievement bonus unlocked';
      default:
        return 'Reward earned';
    }
  }

  void _showAllActivity(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: context.colors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Activity History',
                      style: context.h5.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete timeline of your MLM activities',
                  style: context.bodyM.copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 250,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.borderColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.history_rounded,
                          size: 48,
                          color: context.colors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Detailed Activity History',
                        style: context.h6.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: context.warningColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: context.warningColor.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: context.labelS.copyWith(
                            color: context.warningColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Advanced activity filtering and\ndetailed transaction history',
                        style: context.bodyM.copyWith(
                          color: context.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final String amount;
  final Color color;
  final DateTime date;
  final String type;

  const _ActivityData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.amount,
    required this.color,
    required this.date,
    required this.type,
  });
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final String amount;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.bodyM.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: context.labelS.copyWith(
                    color: context.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (amount.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              amount,
              style: context.labelM.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
