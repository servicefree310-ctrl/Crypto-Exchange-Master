import 'package:flutter/material.dart';
import '../../domain/entities/support_ticket_entity.dart';

class TicketHeader extends StatelessWidget implements PreferredSizeWidget {
  const TicketHeader({super.key, required this.ticket, required this.onBack});

  final SupportTicketEntity ticket;
  final VoidCallback onBack;

  Color _statusColor(TicketStatus status) {
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

  Color _importanceColor(TicketImportance importance) {
    switch (importance) {
      case TicketImportance.low:
        return Colors.green;
      case TicketImportance.medium:
        return Colors.orange;
      case TicketImportance.high:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1F2937), Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back arrow
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(32),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          // Ticket subject + badges
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _badge(ticket.status.name.toUpperCase(),
                        _statusColor(ticket.status)),
                    const SizedBox(width: 6),
                    _badge(ticket.importance.name.toUpperCase(),
                        _importanceColor(ticket.importance)),
                    const SizedBox(width: 6),
                    Text(
                      '#${ticket.id.substring(0, 6)}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7), fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}
