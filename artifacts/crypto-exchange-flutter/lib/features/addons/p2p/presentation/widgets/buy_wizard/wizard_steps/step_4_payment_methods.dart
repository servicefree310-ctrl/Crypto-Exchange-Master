import 'package:flutter/material.dart';
import '../../../../../../../core/theme/global_theme_extensions.dart';

/// Step 4: Payment Methods Selection
class Step4PaymentMethods extends StatelessWidget {
  final Map<String, dynamic> formData;
  final List<Map<String, dynamic>> paymentMethods;
  final bool loading;
  final Function(String) onPaymentMethodToggle;

  const Step4PaymentMethods({
    super.key,
    required this.formData,
    required this.paymentMethods,
    required this.loading,
    required this.onPaymentMethodToggle,
  });

  @override
  Widget build(BuildContext context) {
    final selectedMethods = formData['paymentMethods'] as List<String>;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Select payment methods',
            style: context.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          if (loading)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = paymentMethods[index];
                  final isSelected = selectedMethods.contains(method['id']);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (_) => onPaymentMethodToggle(method['id']),
                      title: Text(method['name'] as String),
                      subtitle: Text(method['description'] as String? ?? ''),
                      secondary:
                          Icon(_getPaymentIcon(method['icon'] as String?)),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  IconData _getPaymentIcon(String? iconName) {
    switch (iconName) {
      case 'landmark':
        return Icons.account_balance;
      case 'credit-card':
        return Icons.credit_card;
      case 'smartphone':
        return Icons.smartphone;
      default:
        return Icons.payment;
    }
  }
}
