import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/withdraw_method_entity.dart';
import '../bloc/withdraw_bloc.dart';
import '../bloc/withdraw_event.dart';

class WithdrawAmountInputWidget extends StatefulWidget {
  final String walletType;
  final String currency;
  final double availableBalance;
  final WithdrawMethodEntity selectedMethod;
  final String amount;
  final double withdrawAmount;
  final double fee;
  final double netAmount;
  final bool isValidAmount;
  final String? errorMessage;

  const WithdrawAmountInputWidget({
    super.key,
    required this.walletType,
    required this.currency,
    required this.availableBalance,
    required this.selectedMethod,
    required this.amount,
    required this.withdrawAmount,
    required this.fee,
    required this.netAmount,
    required this.isValidAmount,
    this.errorMessage,
  });

  @override
  State<WithdrawAmountInputWidget> createState() =>
      _WithdrawAmountInputWidgetState();
}

class _WithdrawAmountInputWidgetState extends State<WithdrawAmountInputWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _amountController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.amount);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.read<WithdrawBloc>().add(
                        const PreviousStepRequested(),
                      ),
                  child: Icon(
                    Icons.arrow_back_ios_rounded,
                    color: context.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Withdrawal Amount',
                        style: context.h6.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.selectedMethod.title} • ${widget.currency}',
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Balance Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    context.colors.primary.withValues(alpha: 0.05),
                    context.colors.primary.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available Balance',
                        style: context.bodyS.copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.availableBalance.toStringAsFixed(8)} ${widget.currency}',
                        style: context.bodyL.copyWith(
                          fontWeight: FontWeight.w700,
                          color: context.colors.primary,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      final maxAmount = _calculateMaxWithdrawAmount();
                      final formatted = _formatAmount(maxAmount);
                      _amountController.text = formatted;
                      context.read<WithdrawBloc>().add(
                            WithdrawAmountChanged(
                              amount: formatted,
                            ),
                          );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Max',
                      style: context.bodyM.copyWith(
                        color: context.colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Amount Input
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter Amount',
                  style: context.bodyL.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.errorMessage != null
                          ? context.priceDownColor
                          : widget.isValidAmount && widget.amount.isNotEmpty
                              ? context.priceUpColor
                              : context.borderColor.withValues(alpha: 0.3),
                      width: widget.errorMessage != null ||
                              (widget.isValidAmount && widget.amount.isNotEmpty)
                          ? 2
                          : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          style: context.h5.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            hintStyle: context.h5.copyWith(
                              color: context.textTertiary,
                              fontWeight: FontWeight.w700,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          onChanged: (value) {
                            context.read<WithdrawBloc>().add(
                                  WithdrawAmountChanged(amount: value),
                                );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(alpha: 0.1),
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: Text(
                          widget.currency,
                          style: context.bodyL.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 16,
                        color: context.priceDownColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.errorMessage!,
                        style: context.bodyS.copyWith(
                          color: context.priceDownColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            // Fee Breakdown
            if (widget.withdrawAmount > 0) ...[
              const SizedBox(height: 24),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.borderColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    _buildFeeRow(
                      context,
                      'Withdrawal Amount',
                      '${widget.withdrawAmount.toStringAsFixed(8)} ${widget.currency}',
                    ),
                    const SizedBox(height: 12),
                    _buildFeeRow(
                      context,
                      'Network Fee',
                      '${widget.fee.toStringAsFixed(8)} ${widget.currency}',
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 1,
                      color: context.borderColor.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 12),
                    _buildFeeRow(
                      context,
                      'You Will Receive',
                      '${widget.netAmount.toStringAsFixed(8)} ${widget.currency}',
                      isBold: true,
                      color: context.priceUpColor,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.isValidAmount
                    ? () {
                        HapticFeedback.mediumImpact();
                        _showConfirmationDialog(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: widget.isValidAmount ? 2 : 0,
                ),
                child: Text(
                  'Confirm Withdrawal',
                  style: context.buttonText(color: Colors.white).copyWith(
                        fontSize: 16,
                      ),
                ),
              ),
            ),

            // Warning
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.warningColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.warningColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: context.warningColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please double-check all withdrawal details. Transactions cannot be reversed.',
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
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
    );
  }

  Widget _buildFeeRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlighted = false,
    bool isBold = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.bodyM.copyWith(
            color: isHighlighted ? context.textSecondary : context.textPrimary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: context.bodyM.copyWith(
            color: color ??
                (isHighlighted ? context.textSecondary : context.textPrimary),
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  double _calculateMaxWithdrawAmount() {
    final fixedFee = widget.selectedMethod.fixedFee ?? 0.0;
    final percentageFee = widget.selectedMethod.percentageFee ?? 0.0;

    switch (widget.walletType) {
      case 'FIAT':
        return widget.availableBalance;
      case 'SPOT':
        // Spot deduction is amount + internal percentage fee.
        final denominator = 1 + (percentageFee / 100);
        if (denominator <= 0) return 0;
        return widget.availableBalance / denominator;
      case 'ECO':
      default:
        // Eco deduction is amount + method fee estimate.
        final denominator = 1 + (percentageFee / 100);
        if (denominator <= 0) return 0;
        return (widget.availableBalance - fixedFee) / denominator;
    }
  }

  String _formatAmount(double amount) {
    final safeAmount = amount.isFinite ? amount : 0.0;
    final nonNegative = safeAmount < 0 ? 0.0 : safeAmount;
    return nonNegative.toStringAsFixed(8).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: context.warningColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: context.warningColor,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Confirm Withdrawal',
                style: context.h6.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to withdraw ${widget.withdrawAmount.toStringAsFixed(8)} ${widget.currency}?',
                style: context.bodyM.copyWith(
                  color: context.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: context.borderColor.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: context.buttonText(
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        context.read<WithdrawBloc>().add(
                              const WithdrawSubmitted(),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Confirm',
                        style: context.buttonText(color: Colors.white),
                      ),
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
}
