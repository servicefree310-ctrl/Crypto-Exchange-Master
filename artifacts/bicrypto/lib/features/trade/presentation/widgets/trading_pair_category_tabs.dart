import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';

class TradingPairCategoryTabs extends StatelessWidget {
  const TradingPairCategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  final List<String> categories;
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = category == selectedCategory;
            return _buildCategoryTab(context, category, isSelected);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(
      BuildContext context, String category, bool isSelected) {
    return GestureDetector(
      onTap: () => onCategoryChanged(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.priceUpColor.withValues(alpha: 0.2),
                    context.priceUpColor.withValues(alpha: 0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    context.inputBackground,
                    context.theme.scaffoldBackgroundColor,
                  ],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.priceUpColor.withValues(alpha: 0.4)
                : context.borderColor,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.priceUpColor.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_getCategoryIcon(category) != null) ...[
              Icon(
                _getCategoryIcon(category),
                size: 12,
                color: isSelected ? context.priceUpColor : context.textTertiary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              category.toUpperCase(),
              style: TextStyle(
                color: isSelected ? context.priceUpColor : context.textTertiary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                decoration: TextDecoration.none,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  IconData? _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'all':
        return Icons.apps;
      case 'favorites':
        return Icons.star;
      case 'recent':
        return Icons.history;
      default:
        return null;
    }
  }
}
