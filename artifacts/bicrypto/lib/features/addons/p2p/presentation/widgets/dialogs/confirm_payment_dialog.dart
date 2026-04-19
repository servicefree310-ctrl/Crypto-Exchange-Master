import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../domain/entities/p2p_trade_entity.dart';

class ConfirmPaymentDialog extends StatefulWidget {
  final P2PTradeEntity trade;
  final VoidCallback onConfirm;

  const ConfirmPaymentDialog({
    super.key,
    required this.trade,
    required this.onConfirm,
  });

  @override
  State<ConfirmPaymentDialog> createState() => _ConfirmPaymentDialogState();
}

class _ConfirmPaymentDialogState extends State<ConfirmPaymentDialog> {
  final TextEditingController _referenceController = TextEditingController();
  bool _confirmed = false;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
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
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.payment,
              color: context.colors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Confirm Payment',
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
                  _buildInfoRow('Amount', '${widget.trade.amount} ${widget.trade.currency}'),
                  const SizedBox(height: 12),
                  _buildInfoRow('Payment Method', widget.trade.paymentMethod ?? 'N/A'),
                  if (widget.trade.paymentDetails != null && widget.trade.paymentDetails!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow('Account', widget.trade.paymentDetails!['accountNumber'] ?? widget.trade.paymentDetails!['accountInfo'] ?? 'N/A'),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Warning message
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
                      'Only confirm if you have sent the full payment to the seller. False confirmation may result in account suspension.',
                      style: context.bodyS.copyWith(
                        color: Colors.orange,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Payment Reference (Optional)
            Text(
              'Payment Reference (Optional)',
              style: context.bodyM.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                hintText: 'e.g., Transaction ID',
                hintStyle: context.bodyM.copyWith(
                  color: context.textTertiary,
                ),
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
              ),
              style: context.bodyM.copyWith(color: context.textPrimary),
            ),

            const SizedBox(height: 16),

            // Confirmation checkbox
            CheckboxListTile(
              value: _confirmed,
              onChanged: (value) {
                setState(() {
                  _confirmed = value ?? false;
                });
              },
              title: Text(
                'I have sent the full payment',
                style: context.bodyM.copyWith(
                  color: context.textPrimary,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: context.colors.primary,
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
          onPressed: _confirmed
              ? () {
                  Navigator.pop(context);
                  widget.onConfirm();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.onPrimary,
            disabledBackgroundColor: context.colors.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Confirm Payment',
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
}
