import 'package:flutter/material.dart';
import '../../domain/entities/mlm_reward_entity.dart';
import '../../../../../core/constants/api_constants.dart';

class MlmRewardCard extends StatelessWidget {
  final MlmRewardEntity reward;
  final VoidCallback? onClaim;
  final bool isLoading;

  const MlmRewardCard({
    super.key,
    required this.reward,
    this.onClaim,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getTypeColor(reward.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getTypeIcon(reward.type),
                    color: _getTypeColor(reward.type),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeName(reward.type),
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reward.description ?? 'Referral reward',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${reward.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: _getTypeColor(reward.type),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(reward.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        reward.status.name.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _getStatusColor(reward.status),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(reward.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
                const Spacer(),
                if (onClaim != null)
                  ElevatedButton(
                    onPressed: isLoading ? null : onClaim,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0ECE7A),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Claim',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(MlmRewardType type) {
    switch (type) {
      case MlmRewardType.referral:
        return Icons.person_add;
      case MlmRewardType.commission:
        return Icons.trending_up;
      case MlmRewardType.bonus:
        return Icons.card_giftcard;
      case MlmRewardType.levelBonus:
        return Icons.emoji_events;
      case MlmRewardType.percentage:
        return Icons.percent;
      case MlmRewardType.fixed:
        return Icons.money;
      case MlmRewardType.tiered:
        return Icons.layers;
    }
  }

  Color _getTypeColor(MlmRewardType type) {
    switch (type) {
      case MlmRewardType.referral:
        return const Color(0xFF0ECE7A); // green
      case MlmRewardType.commission:
        return const Color(0xFF1890FF); // blue
      case MlmRewardType.bonus:
        return const Color(0xFFF39C12); // orange
      case MlmRewardType.levelBonus:
        return const Color(0xFF8B5CF6); // purple
      case MlmRewardType.percentage:
        return const Color(0xFF10B981); // emerald
      case MlmRewardType.fixed:
        return const Color(0xFF3B82F6); // blue
      case MlmRewardType.tiered:
        return const Color(0xFF8B5CF6); // purple
    }
  }

  String _getTypeName(MlmRewardType type) {
    switch (type) {
      case MlmRewardType.referral:
        return 'Referral Reward';
      case MlmRewardType.commission:
        return 'Commission';
      case MlmRewardType.bonus:
        return 'Bonus';
      case MlmRewardType.levelBonus:
        return 'Level Bonus';
      case MlmRewardType.percentage:
        return 'Percentage Reward';
      case MlmRewardType.fixed:
        return 'Fixed Reward';
      case MlmRewardType.tiered:
        return 'Tiered Reward';
    }
  }

  Color _getStatusColor(MlmRewardStatus status) {
    switch (status) {
      case MlmRewardStatus.pending:
        return const Color(0xFFF39C12); // orange
      case MlmRewardStatus.approved:
        return const Color(0xFF0ECE7A); // green
      case MlmRewardStatus.claimed:
        return const Color(0xFF1890FF); // blue
      case MlmRewardStatus.rejected:
        return const Color(0xFFFF5A5F); // red
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
