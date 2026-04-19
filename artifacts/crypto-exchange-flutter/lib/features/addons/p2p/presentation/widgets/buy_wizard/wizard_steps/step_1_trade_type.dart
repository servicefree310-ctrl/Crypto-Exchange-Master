import 'package:flutter/material.dart';
import '../../../../../../../core/theme/global_theme_extensions.dart';

/// Step 1: Trade Type Selection
/// Matches v5 step 1 - "What would you like to do?"
class Step1TradeType extends StatelessWidget {
  final Map<String, dynamic> formData;
  final Function(String, dynamic) onChanged;

  const Step1TradeType({
    super.key,
    required this.formData,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Title
          Text(
            'What would you like to do?',
            style: context.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),

          const SizedBox(height: 32),

          // Trade type selection
          Row(
            children: [
              Expanded(
                child: _buildTradeTypeCard(
                  context: context,
                  value: 'buy',
                  title: 'Buy Cryptocurrency',
                  subtitle: 'I want to buy crypto with my local currency',
                  icon: Icons.shopping_cart_outlined,
                  isSelected: formData['tradeType'] == 'buy',
                  color: context.buyColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTradeTypeCard(
                  context: context,
                  value: 'sell',
                  title: 'Sell Cryptocurrency',
                  subtitle: 'I want to sell crypto for local currency',
                  icon: Icons.attach_money_outlined,
                  isSelected: formData['tradeType'] == 'sell',
                  color: context.sellColor,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Info message
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.buyColor.withValues(alpha: 0.05),
              border: Border.all(
                color: context.buyColor.withValues(alpha: 0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: context.buyColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We\'ll guide you through a few questions to find the perfect trading offers for you.',
                    style: context.bodyS.copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeTypeCard({
    required BuildContext context,
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => onChanged('tradeType', value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : context.cardBackground,
          border: Border.all(
            color: isSelected ? color : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          children: [
            // Icon container
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: context.bodyL.copyWith(
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              style: context.bodyS.copyWith(
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
