import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationStatsCard extends StatelessWidget {
  final int totalCount;
  final int unreadCount;
  final Map<NotificationType, int> typeCounts;

  const NotificationStatsCard({
    super.key,
    required this.totalCount,
    required this.unreadCount,
    required this.typeCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Summary',
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Overview Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Total',
                  value: totalCount,
                  icon: Icons.notifications,
                  color: context.textSecondary,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  label: 'Unread',
                  value: unreadCount,
                  icon: Icons.mark_email_unread,
                  color: context.priceUpColor,
                ),
              ),
            ],
          ),

          if (typeCounts.values.any((count) => count > 0)) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            Text(
              'By Type',
              style: context.bodyS.copyWith(
                fontWeight: FontWeight.w500,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // Type Breakdown
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: typeCounts.entries
                  .where((entry) => entry.value > 0)
                  .map((entry) =>
                      _buildTypeChip(context, entry.key, entry.value))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: context.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: context.labelS.copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(
      BuildContext context, NotificationType type, int count) {
    final color = _getTypeColor(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getTypeIcon(type),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            _getTypeName(type),
            style: context.labelS.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.investment:
        return Icons.trending_up;
      case NotificationType.message:
        return Icons.message;
      case NotificationType.user:
        return Icons.person;
      case NotificationType.alert:
        return Icons.warning;
      case NotificationType.system:
        return Icons.settings;
    }
  }

  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.investment:
        return Colors.green;
      case NotificationType.message:
        return Colors.blue;
      case NotificationType.user:
        return Colors.purple;
      case NotificationType.alert:
        return Colors.orange;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  String _getTypeName(NotificationType type) {
    switch (type) {
      case NotificationType.investment:
        return 'Investment';
      case NotificationType.message:
        return 'Message';
      case NotificationType.user:
        return 'User';
      case NotificationType.alert:
        return 'Alert';
      case NotificationType.system:
        return 'System';
    }
  }
}
