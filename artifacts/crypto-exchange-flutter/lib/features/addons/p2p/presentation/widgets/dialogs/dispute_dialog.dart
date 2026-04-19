import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../domain/entities/p2p_trade_entity.dart';

class DisputeDialog extends StatefulWidget {
  final P2PTradeEntity trade;
  final Function(String reason, String description) onDispute;

  const DisputeDialog({
    super.key,
    required this.trade,
    required this.onDispute,
  });

  @override
  State<DisputeDialog> createState() => _DisputeDialogState();
}

class _DisputeDialogState extends State<DisputeDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedReason;
  String? _errorText;

  final Map<String, String> _disputeReasons = {
    'PAYMENT_NOT_RECEIVED': 'Payment Not Received',
    'PAYMENT_INCORRECT_AMOUNT': 'Incorrect Payment Amount',
    'SELLER_UNRESPONSIVE': 'Seller is Unresponsive',
    'BUYER_UNRESPONSIVE': 'Buyer is Unresponsive',
    'FRAUDULENT_ACTIVITY': 'Suspected Fraud',
    'TERMS_VIOLATION': 'Terms Violation',
    'OTHER': 'Other',
  };

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isValid() {
    final description = _descriptionController.text.trim();
    return _selectedReason != null &&
           description.isNotEmpty &&
           description.length >= 20 &&
           description.length <= 1000;
  }

  void _handleDispute() {
    final description = _descriptionController.text.trim();

    if (description.length < 20) {
      setState(() {
        _errorText = 'Description must be at least 20 characters';
      });
      return;
    }

    if (description.length > 1000) {
      setState(() {
        _errorText = 'Description cannot exceed 1000 characters';
      });
      return;
    }

    Navigator.pop(context);
    widget.onDispute(_selectedReason!, description);
  }

  @override
  Widget build(BuildContext context) {
    final characterCount = _descriptionController.text.length;
    final isOverLimit = characterCount > 1000;

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
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.gavel,
              color: Colors.orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'File Dispute',
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

            // Info message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'A dispute will be reviewed by our support team. Provide as much detail as possible to help resolve the issue.',
                      style: context.bodyS.copyWith(
                        color: Colors.blue,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Dispute reason selection
            Text(
              'Dispute Reason *',
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
                'Select dispute reason',
                style: context.bodyM.copyWith(color: context.textTertiary),
              ),
              items: _disputeReasons.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(
                    entry.value,
                    style: context.bodyM.copyWith(color: context.textPrimary),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedReason = value;
                });
              },
              dropdownColor: context.cardBackground,
            ),

            const SizedBox(height: 16),

            // Detailed description
            Text(
              'Detailed Description *',
              style: context.bodyM.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 6,
              maxLength: 1000,
              decoration: InputDecoration(
                hintText: 'Describe the issue in detail (minimum 20 characters, maximum 1000)',
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
                counterText: '',
              ),
              style: context.bodyM.copyWith(color: context.textPrimary),
              onChanged: (value) {
                setState(() {
                  _errorText = null;
                });
              },
            ),

            const SizedBox(height: 8),

            // Character counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Minimum 20 characters',
                  style: context.bodyS.copyWith(
                    color: characterCount >= 20 ? context.priceUpColor : context.textTertiary,
                  ),
                ),
                Text(
                  '$characterCount / 1000',
                  style: context.bodyS.copyWith(
                    color: isOverLimit ? Colors.red : context.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'False disputes may result in account suspension. Only file a dispute if you have a legitimate issue.',
                      style: context.bodyS.copyWith(
                        color: Colors.orange,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: context.bodyM.copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isValid() && !isOverLimit ? _handleDispute : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.orange.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'File Dispute',
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
