import 'package:flutter/material.dart';
import '../../../../../../../core/theme/global_theme_extensions.dart';

/// Step 5: Additional Preferences
class Step5Preferences extends StatelessWidget {
  final Map<String, dynamic> formData;
  final List<Map<String, dynamic>> locations;
  final Map<String, bool> loading;
  final Function(String, dynamic) onChanged;

  const Step5Preferences({
    super.key,
    required this.formData,
    required this.locations,
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
            'Additional preferences',
            style: context.h5.copyWith(
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(height: 32),

          // Price preference
          _buildPreferenceSection(
            context,
            'Price Preference',
            [
              {'value': 'best', 'label': 'Best Price'},
              {'value': 'market', 'label': 'Market Price'},
              {'value': 'average', 'label': 'Average Price'},
              {'value': 'flexible', 'label': 'Flexible'},
            ],
            formData['pricePreference'],
            (value) => onChanged('pricePreference', value),
          ),

          const SizedBox(height: 24),

          // Trader preference
          _buildPreferenceSection(
            context,
            'Trader Preference',
            [
              {'value': 'any', 'label': 'Any Trader'},
              {'value': 'verified', 'label': 'Verified Only'},
              {'value': 'experienced', 'label': 'Experienced'},
              {'value': 'trusted', 'label': 'Trusted'},
            ],
            formData['traderPreference'],
            (value) => onChanged('traderPreference', value),
          ),

          const SizedBox(height: 24),

          // Location
          DropdownButtonFormField<String>(
            value: formData['location'] == 'any' ? 'any' : formData['location'],
            decoration: const InputDecoration(
              labelText: 'Location',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: 'any',
                child: Text('Any Location'),
              ),
              ...locations.map((location) => DropdownMenuItem<String>(
                    value: location['country'] as String,
                    child: Text(location['country'] as String),
                  )),
            ],
            onChanged: (value) => onChanged('location', value ?? 'any'),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPreferenceSection(
    BuildContext context,
    String title,
    List<Map<String, String>> options,
    String currentValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.bodyL.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = currentValue == option['value'];
            return ChoiceChip(
              label: Text(option['label']!),
              selected: isSelected,
              onSelected: (_) => onChanged(option['value']!),
            );
          }).toList(),
        ),
      ],
    );
  }
}
