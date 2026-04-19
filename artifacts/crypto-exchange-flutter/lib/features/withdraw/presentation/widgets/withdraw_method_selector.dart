import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/global_theme_extensions.dart';
import '../../domain/entities/withdraw_method_entity.dart';
import '../bloc/withdraw_bloc.dart';
import '../bloc/withdraw_event.dart';

class WithdrawMethodSelectorWidget extends StatelessWidget {
  final String walletType;
  final String currency;
  final double availableBalance;
  final List<WithdrawMethodEntity> methods;
  final String? selectedMethodId;
  final WithdrawMethodEntity? selectedMethod;
  final Map<String, dynamic> customFieldValues;

  const WithdrawMethodSelectorWidget({
    super.key,
    required this.walletType,
    required this.currency,
    required this.availableBalance,
    required this.methods,
    this.selectedMethodId,
    this.selectedMethod,
    required this.customFieldValues,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      'Withdrawal Method',
                      style: context.h6.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          currency,
                          style: context.bodyM.copyWith(
                            color: context.colors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• Balance: ${availableBalance.toStringAsFixed(8)}',
                          style: context.bodyS.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Method Selection
          Text(
            'Select Method',
            style: context.bodyL.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Method Cards
          ...methods.map((method) => _buildMethodCard(context, method)),

          // Custom Fields (if method selected)
          if (selectedMethod != null) ...[
            const SizedBox(height: 24),
            _buildCustomFields(context),
          ],

          // Continue Button
          if (selectedMethod != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canContinue()
                    ? () {
                        HapticFeedback.lightImpact();
                        context.read<WithdrawBloc>().add(
                              const NextStepRequested(),
                            );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Continue to Amount',
                  style: context.buttonText(color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMethodCard(BuildContext context, WithdrawMethodEntity method) {
    final isSelected = selectedMethodId == method.id;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<WithdrawBloc>().add(
              WithdrawMethodSelected(methodId: method.id),
            );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? context.colors.primary
                : context.borderColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? context.colors.primary.withValues(alpha: 0.1)
                  : context.isDarkMode
                      ? Colors.black.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Method Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getMethodIcon(method),
                    color: context.colors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Method Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        method.title,
                        style: context.bodyL.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (method.network != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Network: ${method.network}',
                          style: context.bodyS.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Selection Indicator
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
              ],
            ),

            // Fee Information
            if (method.fixedFee != null || method.percentageFee != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (method.fixedFee != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fixed Fee:',
                            style: context.bodyS.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                          Text(
                            '${method.fixedFee} $currency',
                            style: context.bodyS.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    if (method.percentageFee != null) ...[
                      if (method.fixedFee != null) const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Percentage Fee:',
                            style: context.bodyS.copyWith(
                              color: context.textSecondary,
                            ),
                          ),
                          Text(
                            '${method.percentageFee}%',
                            style: context.bodyS.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],

            // Limits
            if (method.minAmount != null || method.maxAmount != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (method.minAmount != null) ...[
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: context.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Min: ${method.minAmount} $currency',
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                  if (method.minAmount != null && method.maxAmount != null)
                    const SizedBox(width: 12),
                  if (method.maxAmount != null)
                    Text(
                      'Max: ${method.maxAmount} $currency',
                      style: context.bodyS.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomFields(BuildContext context) {
    if (selectedMethod?.customFields == null ||
        selectedMethod!.customFields!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Information',
          style: context.bodyL.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ...selectedMethod!.customFields!.map((field) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCustomField(context, field),
          );
        }),
      ],
    );
  }

  Widget _buildCustomField(BuildContext context, CustomFieldEntity field) {
    final currentValue = customFieldValues[field.name];

    if (field.type == 'select' && field.options != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.title,
            style: context.bodyM.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.borderColor.withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButtonFormField<String>(
              value: currentValue,
              decoration: InputDecoration(
                hintText: field.placeholder ?? 'Select ${field.title}',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: field.options!.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  context.read<WithdrawBloc>().add(
                        CustomFieldChanged(
                          fieldName: field.name,
                          value: value,
                        ),
                      );
                }
              },
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              field.title,
              style: context.bodyM.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (field.required) ...[
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
        const SizedBox(height: 8),
        TextFormField(
          initialValue: currentValue?.toString() ?? field.defaultValue,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Enter ${field.title}',
            filled: true,
            fillColor: context.colors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.borderColor.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.borderColor.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: context.colors.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: (value) {
            context.read<WithdrawBloc>().add(
                  CustomFieldChanged(
                    fieldName: field.name,
                    value: value,
                  ),
                );
          },
        ),
      ],
    );
  }

  IconData _getMethodIcon(WithdrawMethodEntity method) {
    if (walletType == 'FIAT') {
      return Icons.account_balance_rounded;
    } else if (method.network != null) {
      return Icons.lan_rounded;
    } else {
      return Icons.send_rounded;
    }
  }

  bool _canContinue() {
    if (selectedMethod == null) return false;

    // Check if all required fields are filled
    if (selectedMethod!.customFields != null) {
      for (final field in selectedMethod!.customFields!) {
        if (field.required && !customFieldValues.containsKey(field.name)) {
          return false;
        }
        if (field.required &&
            customFieldValues[field.name]?.toString().isEmpty == true) {
          return false;
        }
      }
    }

    return true;
  }
}
