import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/transaction_entity.dart';
import '../widgets/transaction_analytics_card.dart';
import '../widgets/transaction_stats_grid.dart';
import '../widgets/transaction_type_chart.dart';

class TransactionAnalyticsPage extends StatelessWidget {
  const TransactionAnalyticsPage({
    super.key,
    required this.transactions,
  });

  final List<TransactionEntity> transactions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.cardBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shadowColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: context.background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: context.textPrimary,
            size: 18,
          ),
        ),
      ),
      title: Text(
        'Transaction Analytics',
        style: context.h6.copyWith(
          fontWeight: FontWeight.w600,
          color: context.textPrimary,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: context.borderColor.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: context.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No data available for analytics',
              style: context.bodyL.copyWith(
                color: context.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Summary
          _buildQuickSummary(context),
          const SizedBox(height: 20),

          // Transaction Stats Grid
          TransactionStatsGrid(transactions: transactions),
          const SizedBox(height: 20),

          // Status Distribution Chart
          TransactionAnalyticsCard(
            title: 'Status Distribution',
            child: TransactionTypeChart(
              transactions: transactions,
              chartType: ChartType.status,
            ),
          ),
          const SizedBox(height: 20),

          // Type Distribution Chart
          TransactionAnalyticsCard(
            title: 'Transaction Types',
            child: TransactionTypeChart(
              transactions: transactions,
              chartType: ChartType.type,
            ),
          ),
          const SizedBox(height: 20),

          // Recent Activity Summary
          _buildRecentActivitySummary(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuickSummary(BuildContext context) {
    final totalAmount = transactions.fold<double>(
      0,
      (sum, tx) => sum + tx.amount,
    );
    final completedCount = transactions
        .where((tx) => tx.status == TransactionStatus.COMPLETED)
        .length;
    final pendingCount = transactions
        .where((tx) => tx.status == TransactionStatus.PENDING)
        .length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.colors.primary.withValues(alpha: 0.1),
            context.colors.primary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Overview',
            style: context.bodyL.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildQuickStatItem(
                context,
                'Total',
                transactions.length.toString(),
                Icons.receipt_long_rounded,
              ),
              _buildQuickStatItem(
                context,
                'Completed',
                completedCount.toString(),
                Icons.check_circle_rounded,
              ),
              _buildQuickStatItem(
                context,
                'Pending',
                pendingCount.toString(),
                Icons.schedule_rounded,
              ),
              _buildQuickStatItem(
                context,
                'Volume',
                _formatCompactAmount(totalAmount),
                Icons.account_balance_wallet_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: context.colors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: context.bodyL.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        Text(
          label,
          style: context.bodyS.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivitySummary(BuildContext context) {
    final recentTransactions = transactions.take(5).toList();

    return TransactionAnalyticsCard(
      title: 'Recent Activity',
      child: Column(
        children: recentTransactions
            .map((tx) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: _buildMiniTransactionItem(context, tx),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMiniTransactionItem(
      BuildContext context, TransactionEntity transaction) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _getTransactionColor(transaction).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getTransactionIcon(transaction),
            color: _getTransactionColor(transaction),
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.displayTitle,
                style: context.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.textPrimary,
                ),
              ),
              Text(
                _formatDate(transaction.createdAt),
                style: context.bodyXS.copyWith(
                  color: context.textTertiary,
                ),
              ),
            ],
          ),
        ),
        Text(
          '${_formatAmount(transaction.amount)} ${transaction.walletCurrency}',
          style: context.bodyS.copyWith(
            fontWeight: FontWeight.w600,
            color: _getAmountColor(context, transaction),
          ),
        ),
      ],
    );
  }

  IconData _getTransactionIcon(TransactionEntity transaction) {
    switch (transaction.type) {
      case TransactionType.DEPOSIT:
        return Icons.arrow_downward_rounded;
      case TransactionType.WITHDRAW:
        return Icons.arrow_upward_rounded;
      case TransactionType.TRANSFER:
      case TransactionType.INCOMING_TRANSFER:
      case TransactionType.OUTGOING_TRANSFER:
        return Icons.swap_horiz_rounded;
      case TransactionType.TRADE:
      case TransactionType.SPOT_ORDER:
      case TransactionType.FUTURES_ORDER:
        return Icons.trending_up_rounded;
      case TransactionType.STAKING_REWARD:
      case TransactionType.STAKING_STAKE:
        return Icons.savings_rounded;
      case TransactionType.BONUS:
      case TransactionType.REFERRAL_REWARD:
        return Icons.card_giftcard_rounded;
      case TransactionType.FEE:
        return Icons.payment_rounded;
      case TransactionType.AI_INVESTMENT:
        return Icons.psychology_rounded;
      case TransactionType.P2P_TRADE:
        return Icons.people_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  Color _getTransactionColor(TransactionEntity transaction) {
    switch (transaction.type) {
      case TransactionType.DEPOSIT:
      case TransactionType.INCOMING_TRANSFER:
      case TransactionType.STAKING_REWARD:
      case TransactionType.BONUS:
      case TransactionType.REFERRAL_REWARD:
        return Colors.green;
      case TransactionType.WITHDRAW:
      case TransactionType.OUTGOING_TRANSFER:
      case TransactionType.FEE:
        return Colors.red;
      case TransactionType.TRADE:
      case TransactionType.SPOT_ORDER:
      case TransactionType.FUTURES_ORDER:
        return Colors.blue;
      case TransactionType.STAKING_STAKE:
        return Colors.purple;
      case TransactionType.AI_INVESTMENT:
        return Colors.indigo;
      case TransactionType.P2P_TRADE:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getAmountColor(BuildContext context, TransactionEntity transaction) {
    if (transaction.isDeposit ||
        transaction.type == TransactionType.INCOMING_TRANSFER ||
        transaction.type == TransactionType.STAKING_REWARD ||
        transaction.type == TransactionType.BONUS ||
        transaction.type == TransactionType.REFERRAL_REWARD) {
      return context.priceUpColor;
    } else if (transaction.isWithdraw ||
        transaction.type == TransactionType.OUTGOING_TRANSFER ||
        transaction.type == TransactionType.FEE) {
      return context.priceDownColor;
    }
    return context.textPrimary;
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else if (amount < 0.01) {
      return amount.toStringAsFixed(8);
    } else {
      return amount.toStringAsFixed(4);
    }
  }

  String _formatCompactAmount(double amount) {
    if (amount >= 1000000000) {
      return '\$${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '\$${amount.toStringAsFixed(0)}';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
