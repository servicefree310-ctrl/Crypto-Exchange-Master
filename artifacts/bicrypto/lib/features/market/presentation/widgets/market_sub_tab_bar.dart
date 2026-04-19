import 'package:flutter/material.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';

class MarketSubTabBar extends StatelessWidget {
  const MarketSubTabBar({
    super.key,
    required this.tabs,
    this.onTap,
    this.currentIndex = 0,
  });

  final List<String> tabs;
  final ValueChanged<int>? onTap;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            tabs.length,
            (index) => _buildSubTab(context, tabs[index], index),
          ),
        ),
      ),
    );
  }

  Widget _buildSubTab(BuildContext context, String title, int index) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap?.call(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.cardBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(
                  color: context.dividerColor,
                  width: 0.5,
                ),
        ),
        child: Text(
          title,
          style: context.labelS.copyWith(
            color: isSelected ? context.colors.primary : context.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
