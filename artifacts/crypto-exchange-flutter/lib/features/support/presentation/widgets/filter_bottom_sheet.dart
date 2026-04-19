import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/support_ticket_entity.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  TicketStatus? _selectedStatus;
  TicketImportance? _selectedImportance;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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

          const SizedBox(height: 20),

          // Title
          Text(
            'Filter Tickets',
            style: context.h5.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 24),

          // Status Filter
          Text(
            'Status',
            style: context.h6.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildStatusChip(null, 'All'),
              ...TicketStatus.values.map(
                (status) => _buildStatusChip(status, status.name),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Priority Filter
          Text(
            'Priority',
            style: context.h6.copyWith(
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildImportanceChip(null, 'All'),
              ...TicketImportance.values.map(
                (importance) =>
                    _buildImportanceChip(importance, importance.name),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.textPrimary,
                    side: BorderSide(color: context.borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(TicketStatus? status, String label) {
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (status != null
                  ? _getStatusColor(status)
                  : context.colors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (status != null
                    ? _getStatusColor(status)
                    : context.colors.primary)
                : context.borderColor,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : context.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildImportanceChip(TicketImportance? importance, String label) {
    final isSelected = _selectedImportance == importance;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedImportance = importance;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (importance != null
                  ? _getImportanceColor(importance)
                  : const Color(0xFF6C5CE7))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (importance != null
                    ? _getImportanceColor(importance)
                    : const Color(0xFF6C5CE7))
                : Colors.white.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.pending:
        return Colors.orange;
      case TicketStatus.open:
        return Colors.blue;
      case TicketStatus.replied:
        return Colors.green;
      case TicketStatus.closed:
        return Colors.grey;
    }
  }

  Color _getImportanceColor(TicketImportance importance) {
    switch (importance) {
      case TicketImportance.low:
        return Colors.green;
      case TicketImportance.medium:
        return Colors.orange;
      case TicketImportance.high:
        return Colors.red;
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedImportance = null;
    });
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'status': _selectedStatus,
      'importance': _selectedImportance,
    });
  }
}
