import 'package:flutter/material.dart';
import '../../../../../../core/theme/global_theme_extensions.dart';

class P2PSellFilterBar extends StatelessWidget {
  const P2PSellFilterBar({
    super.key,
    required this.cryptoCurrencies,
    required this.fiatCurrencies,
    required this.paymentMethods,
    required this.currentTab,
    required this.onFiltersChanged,
  });

  final List<String> cryptoCurrencies;
  final List<String> fiatCurrencies;
  final List<String> paymentMethods;
  final int currentTab;
  final Function(Map<String, dynamic>) onFiltersChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: context.colors.surface,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.borderColor),
              ),
              child: const Text('Filter options coming soon'),
            ),
          ),
        ],
      ),
    );
  }
}
