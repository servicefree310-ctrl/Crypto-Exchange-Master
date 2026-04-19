import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationFilterChips extends StatelessWidget {
  final Set<NotificationType> selectedFilters;
  final ValueChanged<Set<NotificationType>> onFiltersChanged;

  const NotificationFilterChips({
    super.key,
    required this.selectedFilters,
    required this.onFiltersChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter by Type',
            style: context.bodyS.copyWith(
              fontWeight: FontWeight.w500,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Clear All chip
                if (selectedFilters.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: const Text('Clear All'),
                      onPressed: () => onFiltersChanged({}),
                      backgroundColor: context.priceDownColor.withValues(alpha: 0.1),
                      side: BorderSide(
                          color: context.priceDownColor.withValues(alpha: 0.3)),
                      labelStyle: TextStyle(
                        color: context.priceDownColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // Type filter chips
                ...NotificationType.values.map((type) {
                  final isSelected = selectedFilters.contains(type);
                  final color = _getTypeColor(type);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTypeIcon(type),
                            size: 16,
                            color: isSelected ? Colors.white : color,
                          ),
                          const SizedBox(width: 6),
                          Text(_getTypeName(type)),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        final newFilters =
                            Set<NotificationType>.from(selectedFilters);
                        if (selected) {
                          newFilters.add(type);
                        } else {
                          newFilters.remove(type);
                        }
                        onFiltersChanged(newFilters);
                      },
                      backgroundColor: color.withValues(alpha: 0.1),
                      selectedColor: color,
                      checkmarkColor: Colors.white,
                      side: BorderSide(
                        color: isSelected ? color : color.withValues(alpha: 0.3),
                      ),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),
              ],
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
