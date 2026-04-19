import 'package:flutter/material.dart';
import '../../../../../../../core/theme/global_theme_extensions.dart';

/// Step 3: Cryptocurrency and Amount Selection
class Step3CryptoAmount extends StatelessWidget {
  final Map<String, dynamic> formData;
  final List<Map<String, dynamic>> currencies;
  final Map<String, bool> loading;
  final Function(String, dynamic) onChanged;

  const Step3CryptoAmount({
    super.key,
    required this.formData,
    required this.currencies,
    required this.loading,
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
          Text(
            'Select cryptocurrency and amount',
            style: context.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 32),

          // Cryptocurrency dropdown
          DropdownButtonFormField<String>(
            initialValue: formData['cryptocurrency']?.isNotEmpty == true
                ? formData['cryptocurrency']
                : null,
            decoration: const InputDecoration(
              labelText: 'Cryptocurrency',
              border: OutlineInputBorder(),
            ),
            items: currencies
                .map((crypto) => DropdownMenuItem<String>(
                      value: crypto['value'] as String,
                      child: Text(crypto['label'] as String),
                    ))
                .toList(),
            onChanged: (value) => onChanged('cryptocurrency', value ?? ''),
          ),

          const SizedBox(height: 24),

          // Amount input
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) => onChanged('amount', value),
            initialValue: formData['amount'],
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
