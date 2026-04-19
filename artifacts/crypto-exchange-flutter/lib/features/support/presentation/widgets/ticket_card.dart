import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/support_ticket_entity.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
  });

  final SupportTicketEntity ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.cardBackground,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor(ticket.type),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTypeIcon(ticket.type),
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTypeDisplayName(ticket.type),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(ticket.status),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ticket.status.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Priority Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getImportanceColor(ticket.importance),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      ticket.importance.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Ticket ID
                  Text(
                    '#${ticket.id.substring(0, 8)}',
                    style: TextStyle(
                      color: context.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Subject
              Text(
                ticket.subject,
                style: context.h6.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Last Message Preview
              if (ticket.messages.isNotEmpty)
                Text(
                  ticket.messages.last.text,
                  style: context.bodyM.copyWith(
                    color: context.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: context.textTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(ticket.updatedAt),
                    style: TextStyle(
                      color: context.textTertiary,
                      fontSize: 12,
                    ),
                  ),

                  const Spacer(),

                  // Message Count
                  if (ticket.messages.isNotEmpty) ...[
                    Icon(
                      Icons.message,
                      size: 14,
                      color: context.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${ticket.messages.length}',
                      style: TextStyle(
                        color: context.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ],
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

  Color _getTypeColor(TicketType type) {
    switch (type) {
      case TicketType.live:
        return const Color(0xFF10B981); // Green for live chat
      case TicketType.ticket:
        return const Color(0xFF3B82F6); // Blue for tickets
    }
  }

  IconData _getTypeIcon(TicketType type) {
    switch (type) {
      case TicketType.live:
        return Icons.chat_bubble_outline;
      case TicketType.ticket:
        return Icons.support_agent;
    }
  }

  String _getTypeDisplayName(TicketType type) {
    switch (type) {
      case TicketType.live:
        return 'LIVE CHAT';
      case TicketType.ticket:
        return 'TICKET';
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
