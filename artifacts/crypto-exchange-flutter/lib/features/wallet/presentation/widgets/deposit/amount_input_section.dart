import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';
import '../../../domain/entities/deposit_gateway_entity.dart';

class AmountInputSection extends StatefulWidget {
  final String currency;
  final double? amount;
  final bool showCustomFields;
  final DepositGatewayEntity? gateway;
  final Function(double?) onAmountChanged;
  final Function(Map<String, dynamic>) onCustomFieldsChanged;

  const AmountInputSection({
    super.key,
    required this.currency,
    required this.amount,
    required this.onAmountChanged,
    required this.onCustomFieldsChanged,
    this.showCustomFields = true,
    this.gateway,
  });

  @override
  State<AmountInputSection> createState() => _AmountInputSectionState();
}

class _AmountInputSectionState extends State<AmountInputSection>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  final Map<String, TextEditingController> _customFieldControllers = {};
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Sample custom fields for FIAT deposits
  final List<Map<String, dynamic>> _customFields = [
    {
      'key': 'transactionId',
      'label': 'Transaction ID',
      'hint': 'Enter your transaction ID',
      'required': true,
      'type': 'text',
      'icon': Icons.tag_rounded,
    },
    {
      'key': 'senderName',
      'label': 'Sender Name',
      'hint': 'Name on the sending account',
      'required': true,
      'type': 'text',
      'icon': Icons.person_outline_rounded,
    },
    {
      'key': 'bankName',
      'label': 'Bank Name',
      'hint': 'Name of your bank',
      'required': false,
      'type': 'text',
      'icon': Icons.account_balance_rounded,
    },
    {
      'key': 'notes',
      'label': 'Additional Notes',
      'hint': 'Any additional information',
      'required': false,
      'type': 'textarea',
      'icon': Icons.notes_rounded,
    },
  ];

  // Default fees (fallback if gateway not provided)
  double get _fixedFee => widget.gateway?.fixedFee ?? 5.0;
  double get _percentageFee => widget.gateway?.percentageFee ?? 2.5;
  double get _minAmount => widget.gateway?.minAmount ?? 10.0;
  double get _maxAmount => widget.gateway?.maxAmount ?? 10000.0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    ));

    _animationController.forward();

    if (widget.amount != null) {
      _amountController.text = widget.amount!.toString();
    }

    // Initialize custom field controllers
    for (final field in _customFields) {
      _customFieldControllers[field['key']] = TextEditingController();
    }

    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    for (final controller in _customFieldControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onAmountChanged() {
    final text = _amountController.text;
    if (text.isEmpty) {
      widget.onAmountChanged(null);
      return;
    }

    final amount = double.tryParse(text);
    widget.onAmountChanged(amount);
  }

  void _onCustomFieldChanged() {
    final Map<String, dynamic> customFields = {};
    for (final field in _customFields) {
      final key = field['key'] as String;
      final controller = _customFieldControllers[key];
      if (controller != null && controller.text.isNotEmpty) {
        customFields[key] = controller.text;
      }
    }
    widget.onCustomFieldsChanged(customFields);
  }

  double get _totalFee {
    if (widget.amount == null || widget.amount! <= 0) return 0.0;
    return _fixedFee + (widget.amount! * _percentageFee / 100);
  }

  double get _totalAmount {
    if (widget.amount == null || widget.amount! <= 0) return 0.0;
    return widget.amount! + _totalFee;
  }

  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CAD':
        return 'C\$';
      case 'AUD':
        return 'A\$';
      case 'CHF':
        return 'Fr';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'KRW':
        return '₩';
      case 'AED':
        return 'د.إ';
      case 'ZAR':
        return 'R';
      default:
        return currency.substring(0, 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Input Section
            FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildAmountInputCard(),
              ),
            ),
            const SizedBox(height: 20),

            // Fee Breakdown Card
            if (widget.amount != null && widget.amount! > 0) ...[
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _fadeAnimation.value)),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: _buildFeeBreakdownCard(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // Custom Fields Section (only for non-Stripe methods)
            if (widget.showCustomFields)
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildCustomFieldsCard(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInputCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.cardBackground,
            context.cardBackground.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: context.colors.onSurface.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.colors.primary,
                      context.colors.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.monetization_on_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deposit Amount',
                      style: context.h6.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter the amount to deposit in ${widget.currency}',
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

          // Amount Input Field with Enhanced Design
          Container(
            decoration: BoxDecoration(
              color: context.borderColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.borderColor.withValues(alpha: 0.2),
              ),
            ),
            child: TextFormField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: context.h4.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                filled: false,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: context.colors.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: context.priceDownColor,
                    width: 2,
                  ),
                ),
                prefixIcon: Container(
                  padding: const EdgeInsets.only(left: 20, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getCurrencySymbol(widget.currency),
                        style: context.h4.copyWith(
                          color: context.colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                hintText: '0.00',
                hintStyle: context.h4.copyWith(
                  color: context.textTertiary,
                  fontWeight: FontWeight.w300,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                errorStyle: context.bodyS.copyWith(
                  color: context.priceDownColor,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null) {
                  return 'Please enter a valid amount';
                }
                if (amount < _minAmount) {
                  return 'Minimum amount is ${_getCurrencySymbol(widget.currency)}${_minAmount.toStringAsFixed(2)}';
                }
                if (amount > _maxAmount) {
                  return 'Maximum amount is ${_getCurrencySymbol(widget.currency)}${_maxAmount.toStringAsFixed(2)}';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 16),

          // Limits Info with Modern Style
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.colors.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: context.colors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Limits: ${_getCurrencySymbol(widget.currency)}${_minAmount.toStringAsFixed(0)} - ${_getCurrencySymbol(widget.currency)}${_maxAmount.toStringAsFixed(0)}',
                  style: context.bodyS.copyWith(
                    color: context.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.priceUpColor.withValues(alpha: 0.05),
            context.priceUpColor.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.priceUpColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.priceUpColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: context.priceUpColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fee Breakdown',
                      style: context.bodyL.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Review fees and total amount',
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Fee Details with Modern Design
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.borderColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildFeeRow('Deposit Amount', widget.amount!),
                const SizedBox(height: 12),
                _buildFeeRow('Fixed Fee', _fixedFee, isSubItem: true),
                const SizedBox(height: 12),
                _buildFeeRow('Percentage Fee ($_percentageFee%)',
                    widget.amount! * _percentageFee / 100,
                    isSubItem: true),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.borderColor.withValues(alpha: 0.1),
                        context.borderColor.withValues(alpha: 0.3),
                        context.borderColor.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildFeeRow('Total Amount', _totalAmount, isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(String label, double amount,
      {bool isTotal = false, bool isSubItem = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (isSubItem) const SizedBox(width: 16),
            Text(
              label,
              style: context.bodyM.copyWith(
                color: isTotal ? context.textPrimary : context.textSecondary,
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
        Text(
          '${_getCurrencySymbol(widget.currency)}${amount.toStringAsFixed(2)}',
          style: context.bodyL.copyWith(
            color: isTotal ? context.priceUpColor : context.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomFieldsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.cardBackground,
            context.cardBackground.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      context.warningColor,
                      context.warningColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.assignment_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Information',
                      style: context.bodyL.copyWith(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Please provide required transaction details',
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

          // Custom Fields with Staggered Animation
          ..._customFields.asMap().entries.map((entry) {
            final index = entry.key;
            final field = entry.value;
            return AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                final delay = index * 0.1;
                final progress = (_fadeAnimation.value - delay).clamp(0.0, 1.0);
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - progress)),
                  child: Opacity(
                    opacity: progress,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildCustomField(field),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomField(Map<String, dynamic> field) {
    final controller = _customFieldControllers[field['key']]!;
    final isRequired = field['required'] as bool;
    final isTextArea = field['type'] == 'textarea';
    final icon = field['icon'] as IconData? ?? Icons.text_fields_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: context.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              field['label'] as String,
              style: context.bodyM.copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: context.bodyM.copyWith(
                  color: context.priceDownColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: context.borderColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.borderColor.withValues(alpha: 0.2),
            ),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: isTextArea ? 3 : 1,
            style: context.bodyM.copyWith(
              color: context.textPrimary,
            ),
            decoration: InputDecoration(
              filled: false,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: context.colors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: context.priceDownColor,
                  width: 2,
                ),
              ),
              hintText: field['hint'] as String,
              hintStyle: context.bodyM.copyWith(
                color: context.textTertiary,
              ),
              contentPadding: const EdgeInsets.all(16),
              errorStyle: context.bodyS.copyWith(
                color: context.priceDownColor,
              ),
            ),
            validator: (value) {
              if (isRequired && (value == null || value.isEmpty)) {
                return '${field['label']} is required';
              }
              return null;
            },
            onChanged: (_) => _onCustomFieldChanged(),
          ),
        ),
      ],
    );
  }
}
