import 'package:flutter/material.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({
    super.key,
    required this.transaction,
    this.onTap,
  });

  final TransactionEntity transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: context.borderColor.withValues(alpha: 0.1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Transaction Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getTransactionColor(transaction).withValues(alpha: 0.1),
                      _getTransactionColor(transaction).withValues(alpha: 0.05),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTransactionIcon(transaction),
                  color: _getTransactionColor(transaction),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Transaction Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.displayTitle,
                            style: context.bodyM.copyWith(
                              fontWeight: FontWeight.w600,
                              color: context.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(context, transaction),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: context.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(transaction.createdAt),
                          style: context.bodyS.copyWith(
                            color: context.textTertiary,
                          ),
                        ),
                        if (transaction.walletType != null) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: context.background,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              transaction.walletType!.name,
                              style: context.bodyXS.copyWith(
                                color: context.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (transaction.isDeposit ||
                          transaction.type == TransactionType.INCOMING_TRANSFER)
                        Text(
                          '+',
                          style: context.bodyL.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _getAmountColor(context, transaction),
                          ),
                        )
                      else if (transaction.isWithdraw ||
                          transaction.type == TransactionType.OUTGOING_TRANSFER)
                        Text(
                          '-',
                          style: context.bodyL.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _getAmountColor(context, transaction),
                          ),
                        ),
                      Text(
                        _formatAmount(transaction.amount),
                        style: context.bodyL.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _getAmountColor(context, transaction),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.walletCurrency,
                    style: context.bodyS.copyWith(
                      color: context.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(
      BuildContext context, TransactionEntity transaction) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(transaction).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(transaction).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getStatusColor(transaction),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            transaction.statusDisplayText,
            style: context.bodyXS.copyWith(
              color: _getStatusColor(transaction),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
        return Icons.show_chart_rounded;
      case TransactionType.STAKING_REWARD:
      case TransactionType.STAKING_STAKE:
        return Icons.savings_rounded;
      case TransactionType.BONUS:
      case TransactionType.REFERRAL_REWARD:
        return Icons.card_giftcard_rounded;
      case TransactionType.FEE:
        return Icons.receipt_rounded;
      case TransactionType.AI_INVESTMENT:
        return Icons.psychology_rounded;
      case TransactionType.P2P_TRADE:
        return Icons.people_rounded;
      default:
        return Icons.monetization_on_rounded;
    }
  }

  Color _getTransactionColor(TransactionEntity transaction) {
    switch (transaction.type) {
      case TransactionType.DEPOSIT:
      case TransactionType.INCOMING_TRANSFER:
      case TransactionType.STAKING_REWARD:
      case TransactionType.BONUS:
      case TransactionType.REFERRAL_REWARD:
        return const Color(0xFF22C55E); // Green
      case TransactionType.WITHDRAW:
      case TransactionType.OUTGOING_TRANSFER:
      case TransactionType.FEE:
        return const Color(0xFFEF4444); // Red
      case TransactionType.TRADE:
      case TransactionType.SPOT_ORDER:
      case TransactionType.FUTURES_ORDER:
        return const Color(0xFF3B82F6); // Blue
      case TransactionType.STAKING_STAKE:
        return const Color(0xFF8B5CF6); // Purple
      case TransactionType.AI_INVESTMENT:
        return const Color(0xFF6366F1); // Indigo
      case TransactionType.P2P_TRADE:
        return const Color(0xFFF59E0B); // Amber
      default:
        return const Color(0xFF6B7280); // Gray
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

  Color _getStatusColor(TransactionEntity transaction) {
    switch (transaction.status) {
      case TransactionStatus.COMPLETED:
        return const Color(0xFF22C55E); // Green
      case TransactionStatus.PENDING:
      case TransactionStatus.PROCESSING:
        return const Color(0xFFF59E0B); // Amber
      case TransactionStatus.FAILED:
      case TransactionStatus.REJECTED:
      case TransactionStatus.CANCELLED:
        return const Color(0xFFEF4444); // Red
      case TransactionStatus.EXPIRED:
        return const Color(0xFF6B7280); // Gray
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(2)}K';
    } else if (amount < 0.01) {
      return amount.toStringAsFixed(6);
    } else {
      return amount.toStringAsFixed(4);
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
