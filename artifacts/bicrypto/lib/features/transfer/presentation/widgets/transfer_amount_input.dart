import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../bloc/transfer_bloc.dart';
import '../bloc/transfer_event.dart';

class TransferAmountInputWidget extends StatefulWidget {
  final String transferType;
  final String sourceCurrency;
  final String? destinationCurrency;
  final double availableBalance;
  final double amount;
  final double transferFee;
  final double receiveAmount;
  final bool isReadyToSubmit;

  const TransferAmountInputWidget({
    super.key,
    required this.transferType,
    required this.sourceCurrency,
    this.destinationCurrency,
    required this.availableBalance,
    required this.amount,
    required this.transferFee,
    required this.receiveAmount,
    required this.isReadyToSubmit,
  });

  @override
  State<TransferAmountInputWidget> createState() =>
      _TransferAmountInputWidgetState();
}

class _TransferAmountInputWidgetState extends State<TransferAmountInputWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _amountController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double _amount = 0.0;
  double _fee = 0.0;
  double _total = 0.0;
  bool _isValidAmount = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.amount > 0 ? widget.amount.toString() : '',
    );

    // Initialize with widget values
    _amount = widget.amount;
    _calculateFees();
    _validateAmount();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String value) {
    setState(() {
      _amount = double.tryParse(value) ?? 0.0;
      _calculateFees();
      _validateAmount();
    });

    if (_isValidAmount) {
      context.read<TransferBloc>().add(TransferAmountChanged(amount: _amount));
    }
  }

  void _calculateFees() {
    // Client transfer has 1% fee, minimum 0.01
    if (widget.transferType == 'client') {
      _fee = (_amount * 0.01).clamp(0.01, double.infinity);
    } else {
      _fee = 0.0;
    }
    _total = _amount + _fee;
  }

  void _validateAmount() {
    _errorMessage = null;
    _isValidAmount = false;

    if (_amount <= 0) {
      _errorMessage = 'Please enter a valid amount';
    } else if (_total > widget.availableBalance) {
      _errorMessage = 'Insufficient balance (including fees)';
    } else if (_amount < 0.01) {
      _errorMessage = 'Minimum transfer amount is 0.01';
    } else {
      _isValidAmount = true;
    }
  }

  String _getSourceWalletName() {
    // This would ideally come from state, but for now we'll derive it
    return widget.sourceCurrency.toUpperCase();
  }

  String _getDestinationWalletName() {
    return widget.destinationCurrency?.toUpperCase() ??
        widget.sourceCurrency.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = widget.sourceCurrency.toUpperCase();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Transfer Amount',
                style: context.h5.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'How much do you want to transfer?',
                style: context.bodyS.copyWith(
                  color: context.textSecondary,
                ),
              ),
              const SizedBox(height: 20),

              // Transfer Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary.withValues(alpha: 0.1),
                      context.colors.primary.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: context.colors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow(
                      'From',
                      _getSourceWalletName(),
                      context,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 1,
                      color: context.borderColor.withValues(alpha: 0.2),
                    ),
                    const SizedBox(height: 10),
                    _buildSummaryRow(
                      'To',
                      widget.transferType == 'wallet'
                          ? _getDestinationWalletName()
                          : 'Another User',
                      context,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Amount Input Section
              Container(
                decoration: BoxDecoration(
                  color: context.isDarkMode
                      ? context.colors.surface
                      : context.colors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _errorMessage != null
                        ? context.priceDownColor.withValues(alpha: 0.5)
                        : _isValidAmount
                            ? context.priceUpColor.withValues(alpha: 0.5)
                            : context.borderColor.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: context.colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              currencySymbol,
                              style: context.labelL.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _amountController,
                              onChanged: _onAmountChanged,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,8}'),
                                ),
                              ],
                              style: context.h4.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: '0.00',
                                hintStyle: context.h4.copyWith(
                                  color: context.textTertiary,
                                  fontWeight: FontWeight.w600,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Available Balance
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: context.isDarkMode
                            ? context.colors.surfaceContainerHighest.withValues(alpha: 0.5)
                            : context.colors.surface,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Balance',
                            style: context.labelM.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                          Text(
                            '${widget.availableBalance.toStringAsFixed(8)} $currencySymbol',
                            style: context.labelM.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Error Message
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: context.priceDownColor,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _errorMessage!,
                      style: context.labelS.copyWith(
                        color: context.priceDownColor,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),

              // Fee Breakdown
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _amount > 0 ? null : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _amount > 0 ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.isDarkMode
                          ? context.colors.surface.withValues(alpha: 0.5)
                          : context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.borderColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildFeeRow('Transfer Amount', _amount, currencySymbol,
                            context),
                        if (_fee > 0) ...[
                          const SizedBox(height: 8),
                          _buildFeeRow('Transfer Fee (1%)', _fee,
                              currencySymbol, context,
                              isSubtle: true),
                          const SizedBox(height: 8),
                          Container(
                            height: 1,
                            color: context.borderColor.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 8),
                          _buildFeeRow('Total', _total, currencySymbol, context,
                              isBold: true),
                        ],
                        if (widget.destinationCurrency != null &&
                            widget.destinationCurrency !=
                                widget.sourceCurrency) ...[
                          const SizedBox(height: 8),
                          Container(
                            height: 1,
                            color: context.borderColor.withValues(alpha: 0.2),
                          ),
                          const SizedBox(height: 8),
                          _buildFeeRow(
                            'You will receive',
                            widget.receiveAmount,
                            widget.destinationCurrency!.toUpperCase(),
                            context,
                            isBold: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<TransferBloc>().add(const TransferReset());
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.textPrimary,
                        side: BorderSide(
                          color: context.borderColor.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: context.labelL.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isValidAmount && _amount > 0
                          ? () {
                              HapticFeedback.mediumImpact();
                              context
                                  .read<TransferBloc>()
                                  .add(const TransferSubmitted());
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        disabledBackgroundColor:
                            context.colors.onSurface.withValues(alpha: 0.12),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Confirm Transfer',
                        style: context.labelL.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.labelM.copyWith(
            color: context.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: context.labelM.copyWith(
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeRow(
    String label,
    double amount,
    String currency,
    BuildContext context, {
    bool isSubtle = false,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: context.labelM.copyWith(
            color: isSubtle ? context.textTertiary : context.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(8)} $currency',
          style: context.labelM.copyWith(
            color: isBold ? context.textPrimary : context.textSecondary,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
