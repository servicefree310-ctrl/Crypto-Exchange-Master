import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../domain/entities/p2p_trade_entity.dart';

class CancelTradeDialog extends StatefulWidget {
  final P2PTradeEntity trade;
  final Function(String reason) onCancel;

  const CancelTradeDialog({
    super.key,
    required this.trade,
    required this.onCancel,
  });

  @override
  State<CancelTradeDialog> createState() => _CancelTradeDialogState();
}

class _CancelTradeDialogState extends State<CancelTradeDialog> {
  final TextEditingController _reasonController = TextEditingController();
  String? _selectedReason;
  String? _errorText;

  final List<String> _cancellationReasons = [
    'Changed my mind',
    'Found a better offer',
    'Seller is unresponsive',
    'Buyer is unresponsive',
    'Payment method issue',
    'Price changed significantly',
    'Personal emergency',
    'Other',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  bool _isValid() {
    final reason = _reasonController.text.trim();
    return _selectedReason != null && reason.isNotEmpty && reason.length >= 10;
  }

  void _handleCancel() {
    final reason = _reasonController.text.trim();

    if (reason.length < 10) {
      setState(() {
        _errorText = 'Reason must be at least 10 characters';
      });
      return;
    }

    Navigator.pop(context);
    widget.onCancel('$_selectedReason: $reason');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: context.cardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.cancel_outlined,
              color: Colors.red,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cancel Trade',
              style: context.h6.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trade Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.inputBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.borderColor),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Trade ID', '#${widget.trade.id.substring(0, 8)}'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Amount', '${widget.trade.amount} ${widget.trade.currency}'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Status', _getStatusText(widget.trade.status)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Warning message
            if (widget.trade.status == P2PTradeStatus.paymentSent)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'As a buyer, you cannot cancel after confirming payment. Please open a dispute instead if there is an issue.',
                        style: context.bodyS.copyWith(
                          color: Colors.red,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Reason selection
            Text(
              'Cancellation Reason',
              style: context.bodyM.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedReason,
              decoration: InputDecoration(
                filled: true,
                fillColor: context.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              hint: Text(
                'Select a reason',
                style: context.bodyM.copyWith(color: context.textTertiary),
              ),
              items: _cancellationReasons.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(
                    reason,
                    style: context.bodyM.copyWith(color: context.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                  _errorText = null;
                });
              },
              dropdownColor: context.cardBackground,
            ),

            const SizedBox(height: 16),

            // Detailed reason
            Text(
              'Detailed Explanation',
              style: context.bodyM.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Please provide more details (minimum 10 characters)',
                hintStyle: context.bodyM.copyWith(
                  color: context.textTertiary,
                ),
                errorText: _errorText,
                filled: true,
                fillColor: context.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.primary, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
              style: context.bodyM.copyWith(color: context.textPrimary),
              onChanged: (value) {
                setState(() {
                  _errorText = null;
                });
              },
            ),

            const SizedBox(height: 8),

            // Info text
            Text(
              'Note: Cancelling this trade may affect your reputation score.',
              style: context.bodyS.copyWith(
                color: context.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Go Back',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isValid() ? _handleCancel : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.red.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Cancel Trade',
            style: context.bodyM.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.bodyS.copyWith(
            color: context.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: context.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: context.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _getStatusText(P2PTradeStatus status) {
    switch (status) {
      case P2PTradeStatus.pending:
        return 'Pending';
      case P2PTradeStatus.inProgress:
        return 'In Progress';
      case P2PTradeStatus.paymentSent:
        return 'Payment Sent';
      case P2PTradeStatus.completed:
        return 'Completed';
      case P2PTradeStatus.cancelled:
        return 'Cancelled';
      case P2PTradeStatus.disputed:
        return 'Disputed';
      case P2PTradeStatus.expired:
        return 'Expired';
    }
  }
}
