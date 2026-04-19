import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../domain/entities/p2p_trade_entity.dart';

class ReleaseEscrowDialog extends StatefulWidget {
  final P2PTradeEntity trade;
  final VoidCallback onRelease;

  const ReleaseEscrowDialog({
    super.key,
    required this.trade,
    required this.onRelease,
  });

  @override
  State<ReleaseEscrowDialog> createState() => _ReleaseEscrowDialogState();
}

class _ReleaseEscrowDialogState extends State<ReleaseEscrowDialog> {
  bool _confirmed = false;
  bool _acknowledged = false;

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
              color: context.priceUpColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lock_open,
              color: context.priceUpColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Release Escrow',
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
                  _buildInfoRow('Amount to Release', '${widget.trade.amount} ${widget.trade.currency}'),
                  if (widget.trade.escrowFee != null && widget.trade.escrowFee! > 0) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow('Escrow Fee', '${widget.trade.escrowFee} ${widget.trade.currency}'),
                  ],
                  const SizedBox(height: 12),
                  _buildInfoRow('Buyer Receives', '${widget.trade.amount - (widget.trade.escrowFee ?? 0)} ${widget.trade.currency}'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Critical Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This action is irreversible! Funds will be immediately transferred to the buyer. Only release if you have received the full payment.',
                      style: context.bodyS.copyWith(
                        color: Colors.red,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Checklist
            Text(
              'Before releasing escrow, confirm:',
              style: context.bodyM.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            _buildCheckItem('I have received the full payment amount'),
            const SizedBox(height: 8),
            _buildCheckItem('The payment has been verified in my account'),
            const SizedBox(height: 8),
            _buildCheckItem('The payment method matches the agreed terms'),
            const SizedBox(height: 8),
            _buildCheckItem('I understand this action cannot be undone'),

            const SizedBox(height: 16),

            // Confirmation checkbox 1
            CheckboxListTile(
              value: _confirmed,
              onChanged: (value) {
                setState(() {
                  _confirmed = value ?? false;
                });
              },
              title: Text(
                'I confirm buyer has paid the full amount',
                style: context.bodyM.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: context.priceUpColor,
            ),

            // Confirmation checkbox 2
            CheckboxListTile(
              value: _acknowledged,
              onChanged: (value) {
                setState(() {
                  _acknowledged = value ?? false;
                });
              },
              title: Text(
                'I acknowledge this action is irreversible',
                style: context.bodyM.copyWith(
                  color: context.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: context.priceUpColor,
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
          onPressed: (_confirmed && _acknowledged)
              ? () {
                  Navigator.pop(context);
                  widget.onRelease();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.priceUpColor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: context.priceUpColor.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            'Release Funds',
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

  Widget _buildCheckItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 16,
          color: context.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.bodyS.copyWith(
              color: context.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
