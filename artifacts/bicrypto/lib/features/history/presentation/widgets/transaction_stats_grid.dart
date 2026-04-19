import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionStatsGrid extends StatelessWidget {
  const TransactionStatsGrid({
    super.key,
    required this.transactions,
  });

  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats(transactions);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Total Amount',
                _formatAmount(stats['totalAmount']!),
                Icons.account_balance_wallet_rounded,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Fees',
                _formatAmount(stats['totalFees']!),
                Icons.payment_rounded,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Deposits',
                stats['depositCount']!.toInt().toString(),
                Icons.arrow_downward_rounded,
                Colors.green,
                subtitle: _formatAmount(stats['depositAmount']!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Withdrawals',
                stats['withdrawCount']!.toInt().toString(),
                Icons.arrow_upward_rounded,
                Colors.red,
                subtitle: _formatAmount(stats['withdrawAmount']!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Completed',
                '${stats['completedCount']!.toInt()}',
                Icons.check_circle_rounded,
                Colors.green,
                subtitle:
                    '${stats['completedPercentage']!.toStringAsFixed(1)}%',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Pending',
                '${stats['pendingCount']!.toInt()}',
                Icons.schedule_rounded,
                Colors.orange,
                subtitle: '${stats['pendingPercentage']!.toStringAsFixed(1)}%',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: context.h5.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.bodyS.copyWith(
              color: context.textSecondary,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: context.bodyXS.copyWith(
                color: context.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, double> _calculateStats(List<TransactionEntity> transactions) {
    double totalAmount = 0;
    double totalFees = 0;
    double depositAmount = 0;
    double withdrawAmount = 0;
    int depositCount = 0;
    int withdrawCount = 0;
    int completedCount = 0;
    int pendingCount = 0;

    for (final tx in transactions) {
      totalAmount += tx.amount;
      totalFees += tx.fee;

      if (tx.type == TransactionType.DEPOSIT) {
        depositCount++;
        depositAmount += tx.amount;
      } else if (tx.type == TransactionType.WITHDRAW) {
        withdrawCount++;
        withdrawAmount += tx.amount;
      }

      if (tx.status == TransactionStatus.COMPLETED) {
        completedCount++;
      } else if (tx.status == TransactionStatus.PENDING ||
          tx.status == TransactionStatus.PROCESSING) {
        pendingCount++;
      }
    }

    final total = transactions.length;
    final completedPercentage =
        total > 0 ? (completedCount / total) * 100 : 0.0;
    final pendingPercentage = total > 0 ? (pendingCount / total) * 100 : 0.0;

    return {
      'totalAmount': totalAmount,
      'totalFees': totalFees,
      'depositAmount': depositAmount,
      'withdrawAmount': withdrawAmount,
      'depositCount': depositCount.toDouble(),
      'withdrawCount': withdrawCount.toDouble(),
      'completedCount': completedCount.toDouble(),
      'pendingCount': pendingCount.toDouble(),
      'completedPercentage': completedPercentage,
      'pendingPercentage': pendingPercentage,
    };
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000000) {
      return '\$${(amount / 1000000000).toStringAsFixed(2)}B';
    } else if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(2)}K';
    } else {
      return '\$${amount.toStringAsFixed(2)}';
    }
  }
}
