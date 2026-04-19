import 'package:flutter/material.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';

class MarketFilterChips extends StatelessWidget {
  const MarketFilterChips({
    super.key,
    required this.filters,
    this.onFilterTap,
    this.selectedIndex = 0,
    this.showDropdown = false,
    this.isCompact = true, // Default to compact mode
  });

  final List<MarketFilter> filters;
  final ValueChanged<int>? onFilterTap;
  final int selectedIndex;
  final bool showDropdown;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? 32 : 40, // Further reduced height in compact mode
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 20,
        vertical: isCompact ? 2 : 4, // Minimal vertical margin
      ),
      child: Container(
        width: double.infinity, // Ensure full width
        alignment: Alignment.centerLeft, // Align content to left
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 6 : 8,
            vertical: isCompact ? 2 : 3, // Minimal vertical padding
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start, // Align row to start
            mainAxisSize: MainAxisSize.min, // Don't expand row
            children: List.generate(
              filters.length,
              (index) => _buildFilterChip(context, filters[index], index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
      BuildContext context, MarketFilter filter, int index) {
    final isSelected = index == selectedIndex;
    final hasDropdown = filter.value == 'dropdown';

    return GestureDetector(
      onTap: () => onFilterTap?.call(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 10 : 14,
          vertical: isCompact ? 5 : 7, // Reduced vertical padding
        ),
        margin: EdgeInsets.only(right: isCompact ? 4 : 6),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.colors.primary.withValues(alpha: 0.2),
                    context.colors.primary.withValues(alpha: 0.15),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.cardBackground,
                    context.cardBackground.withValues(alpha: 0.95),
                  ],
                ),
          borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
          border: Border.all(
            color: isSelected
                ? context.colors.primary.withValues(alpha: 0.6)
                : context.dividerColor,
            width: isSelected ? 1 : 0.8, // Thinner border for more compact look
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.15),
                    blurRadius: isCompact ? 4 : 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : isCompact
                  ? [] // No shadow in compact mode for non-selected items
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: context.labelS.copyWith(
                color:
                    isSelected ? context.colors.primary : context.textSecondary,
                fontSize: isCompact ? 11 : 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: -0.2,
              ),
              child: Text(filter.title),
            ),
            if (hasDropdown) ...[
              SizedBox(width: isCompact ? 3 : 6),
              AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: 0, // Could be animated based on dropdown state
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isSelected
                      ? context.colors.primary
                      : context.textSecondary,
                  size: isCompact ? 14 : 18,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MarketFilter {
  const MarketFilter({
    required this.title,
    this.value,
  });

  final String title;
  final String? value;
}
