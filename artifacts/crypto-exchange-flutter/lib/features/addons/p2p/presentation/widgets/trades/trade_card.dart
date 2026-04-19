import 'package:flutter/material.dart';
import '../../../domain/entities/p2p_trade_entity.dart';

class TradeCard extends StatelessWidget {
  const TradeCard({
    super.key,
    required this.trade,
    required this.onTap,
    required this.onAction,
  });

  final P2PTradeEntity trade;
  final VoidCallback onTap;
  final Function(String action) onAction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2C2C2E)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row - counterparty and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF24CE85).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          _getCounterpartyInitial(),
                          style: const TextStyle(
                            color: Color(0xFF24CE85),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCounterpartyName(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          _getTradeTypeText(),
                          style: TextStyle(
                            color: trade.isBuyTrade
                                ? const Color(0xFF24CE85)
                                : const Color(0xFFFF453A),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _buildStatusBadge(),
              ],
            ),

            const SizedBox(height: 12),

            // Trade details
            Row(
              children: [
                Expanded(
                  child: _TradeDetailItem(
                    label: 'Amount',
                    value:
                        '${trade.amount.toStringAsFixed(4)} ${trade.currency}',
                  ),
                ),
                Expanded(
                  child: _TradeDetailItem(
                    label: 'Price',
                    value: '\$${trade.price.toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _TradeDetailItem(
                    label: 'Total',
                    value: '\$${trade.fiatAmount.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _TradeDetailItem(
                    label: 'Payment',
                    value: trade.paymentMethod ?? 'N/A',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress indicator for active trades
            if (trade.status == P2PTradeStatus.inProgress ||
                trade.status == P2PTradeStatus.paymentSent) ...[
              _buildProgressIndicator(),
              const SizedBox(height: 12),
            ],

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (trade.status) {
      case P2PTradeStatus.pending:
        backgroundColor = const Color(0xFFFF9500).withValues(alpha: 0.2);
        textColor = const Color(0xFFFF9500);
        statusText = 'Pending';
        break;
      case P2PTradeStatus.inProgress:
        backgroundColor = const Color(0xFF007AFF).withValues(alpha: 0.2);
        textColor = const Color(0xFF007AFF);
        statusText = 'In Progress';
        break;
      case P2PTradeStatus.paymentSent:
        backgroundColor = const Color(0xFF5856D6).withValues(alpha: 0.2);
        textColor = const Color(0xFF5856D6);
        statusText = 'Payment Sent';
        break;
      case P2PTradeStatus.completed:
        backgroundColor = const Color(0xFF24CE85).withValues(alpha: 0.2);
        textColor = const Color(0xFF24CE85);
        statusText = 'Completed';
        break;
      case P2PTradeStatus.cancelled:
        backgroundColor = const Color(0xFF8E8E93).withValues(alpha: 0.2);
        textColor = const Color(0xFF8E8E93);
        statusText = 'Cancelled';
        break;
      case P2PTradeStatus.disputed:
        backgroundColor = const Color(0xFFFF453A).withValues(alpha: 0.2);
        textColor = const Color(0xFFFF453A);
        statusText = 'Disputed';
        break;
      case P2PTradeStatus.expired:
        backgroundColor = const Color(0xFF8E8E93).withValues(alpha: 0.2);
        textColor = const Color(0xFF8E8E93);
        statusText = 'Expired';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    double progress;
    String progressText;

    switch (trade.status) {
      case P2PTradeStatus.pending:
        progress = 0.25;
        progressText = 'Trade Created';
        break;
      case P2PTradeStatus.inProgress:
        progress = 0.5;
        progressText = 'Awaiting Payment';
        break;
      case P2PTradeStatus.paymentSent:
        progress = 0.75;
        progressText = 'Payment Confirmation';
        break;
      case P2PTradeStatus.completed:
        progress = 1.0;
        progressText = 'Completed';
        break;
      default:
        progress = 0.0;
        progressText = 'Unknown';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              progressText,
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: Color(0xFF8E8E93),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: const Color(0xFF2C2C2E),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF24CE85)),
          minHeight: 3,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    List<Widget> buttons = [];

    // Add action buttons based on trade status
    switch (trade.status) {
      case P2PTradeStatus.pending:
        if (trade.isBuyTrade) {
          buttons.add(_ActionButton(
            text: 'Confirm Payment',
            color: const Color(0xFF24CE85),
            onPressed: () => onAction('confirm'),
          ));
        }
        buttons.add(_ActionButton(
          text: 'Cancel',
          color: const Color(0xFF8E8E93),
          onPressed: () => onAction('cancel'),
        ));
        break;

      case P2PTradeStatus.inProgress:
        if (trade.isSellTrade) {
          buttons.add(_ActionButton(
            text: 'Release',
            color: const Color(0xFF24CE85),
            onPressed: () => onAction('release'),
          ));
        }
        buttons.add(_ActionButton(
          text: 'Dispute',
          color: const Color(0xFFFF453A),
          onPressed: () => onAction('dispute'),
        ));
        break;

      case P2PTradeStatus.paymentSent:
        buttons.add(_ActionButton(
          text: 'Chat',
          color: const Color(0xFF007AFF),
          onPressed: () => onAction('chat'),
        ));
        buttons.add(_ActionButton(
          text: 'Dispute',
          color: const Color(0xFFFF453A),
          onPressed: () => onAction('dispute'),
        ));
        break;

      default:
        // For completed, cancelled, disputed trades
        buttons.add(_ActionButton(
          text: 'View Details',
          color: const Color(0xFF8E8E93),
          onPressed: onTap,
        ));
    }

    // Always add chat button for active trades
    if (trade.isActive && trade.status != P2PTradeStatus.paymentSent) {
      buttons.insert(
          0,
          _ActionButton(
            text: 'Chat',
            color: const Color(0xFF007AFF),
            onPressed: () => onAction('chat'),
          ));
    }

    return Row(
      children: buttons
          .map((button) => Expanded(child: button))
          .expand((widget) => [widget, const SizedBox(width: 8)])
          .toList()
        ..removeLast(), // Remove last spacing
    );
  }

  String _getCounterpartyName() {
    // TODO: Get from trade.buyer or trade.seller based on user role
    return 'Trader${trade.id.substring(0, 4)}';
  }

  String _getCounterpartyInitial() {
    return _getCounterpartyName().substring(0, 1).toUpperCase();
  }

  String _getTradeTypeText() {
    return trade.isBuyTrade
        ? 'Buying ${trade.currency}'
        : 'Selling ${trade.currency}';
  }
}

class _TradeDetailItem extends StatelessWidget {
  const _TradeDetailItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8E8E93),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  final String text;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.2),
        foregroundColor: color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        minimumSize: const Size(0, 32),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
