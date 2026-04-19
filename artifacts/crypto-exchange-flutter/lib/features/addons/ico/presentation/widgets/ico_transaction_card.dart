import 'package:flutter/material.dart';

import '../../domain/entities/ico_portfolio_entity.dart';

class IcoTransactionCard extends StatelessWidget {
  const IcoTransactionCard({super.key, required this.transaction, this.onTap});

  final IcoTransactionEntity transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color statusColor;
    switch (transaction.status) {
      case IcoTransactionStatus.pending:
        statusColor = Colors.orange;
      case IcoTransactionStatus.verification:
        statusColor = Colors.blue;
      case IcoTransactionStatus.released:
        statusColor = Colors.green;
      case IcoTransactionStatus.rejected:
        statusColor = Colors.red;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(transaction.offeringIcon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.offeringName,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${transaction.amount.toStringAsFixed(2)} ${transaction.offeringSymbol} @ ${transaction.price.toStringAsFixed(2)}',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(transaction.createdAt),
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    transaction.totalCost.toStringAsFixed(2),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.statusText,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: statusColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
