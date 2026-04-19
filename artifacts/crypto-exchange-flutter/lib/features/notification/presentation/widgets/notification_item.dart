import 'package:flutter/material.dart';
// ignore_for_file: unchecked_use_of_nullable_value
import 'package:intl/intl.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onMarkAsUnread;
  final VoidCallback onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onMarkAsUnread,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: notification.read
            ? context.colors.surface
            : context.colors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.read
              ? context.borderColor
              : context.colors.primary.withValues(alpha: 0.2),
          width: notification.read ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Dismissible(
        key: Key(notification.id),
        background: _buildSwipeBackground(context, isLeft: true),
        secondaryBackground: _buildSwipeBackground(context, isLeft: false),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            // Mark as read/unread
            if (notification.read) {
              onMarkAsUnread();
            } else {
              onMarkAsRead();
            }
            return false; // Don't dismiss
          } else {
            // Delete
            return await _showDeleteConfirmation(context);
          }
        },
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:
                            _getTypeColor(notification.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getTypeIcon(notification.type),
                        color: _getTypeColor(notification.type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: context.textTheme.titleMedium.copyWith(
                                    fontWeight: notification.read
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!notification.read)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: context.colors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: context.bodyS.copyWith(
                              color: context.textSecondary,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (notification.details != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              notification.details!,
                              style: context.labelS.copyWith(
                                color: context.textTertiary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Footer
                Row(
                  children: [
                    // Type Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            _getTypeColor(notification.type).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color:
                              _getTypeColor(notification.type).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _getTypeName(notification.type),
                        style: context.textTheme.labelSmall.copyWith(
                          color: _getTypeColor(notification.type),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Time
                    Text(
                      _formatTime(notification.createdAt),
                      style: context.textTheme.labelSmall.copyWith(
                        color: context.textTertiary,
                      ),
                    ),

                    // Actions Menu
                    const SizedBox(width: 8),
                    _buildActionsMenu(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    if (isLeft) {
      // Read/Unread action
      return Container(
        decoration: BoxDecoration(
          color: notification.read ? Colors.orange : Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  notification.read
                      ? Icons.mark_email_unread
                      : Icons.mark_email_read,
                  color: Colors.white,
                ),
                const SizedBox(height: 4),
                Text(
                  notification.read ? 'Unread' : 'Read',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Delete action
      return Container(
        decoration: BoxDecoration(
          color: context.priceDownColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
                SizedBox(height: 4),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildActionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: context.textTertiary,
        size: 18,
      ),
      onSelected: (value) {
        switch (value) {
          case 'read':
            onMarkAsRead();
            break;
          case 'unread':
            onMarkAsUnread();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        if (!notification.read)
          PopupMenuItem<String>(
            value: 'read',
            child: Row(
              children: [
                const Icon(Icons.mark_email_read, size: 18),
                const SizedBox(width: 8),
                const Text('Mark as read'),
              ],
            ),
          ),
        if (notification.read)
          PopupMenuItem<String>(
            value: 'unread',
            child: Row(
              children: [
                const Icon(Icons.mark_email_unread, size: 18),
                const SizedBox(width: 8),
                const Text('Mark as unread'),
              ],
            ),
          ),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, size: 18, color: context.priceDownColor),
              const SizedBox(width: 8),
              Text(
                'Delete',
                style: TextStyle(color: context.priceDownColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text(
                'Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  'Delete',
                  style: TextStyle(color: context.priceDownColor),
                ),
              ),
            ],
          ),
        ) ??
        false;
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

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
