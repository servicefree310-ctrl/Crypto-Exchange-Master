import 'package:flutter/material.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';

class MarketTabBar extends StatelessWidget {
  const MarketTabBar({
    super.key,
    required this.tabs,
    this.onTap,
    this.currentIndex = 0,
    this.isCompact = true, // Default to compact mode
  });

  final List<MarketTab> tabs;
  final ValueChanged<int>? onTap;
  final int currentIndex;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isCompact ? 46 : 52,
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 20,
        vertical: isCompact ? 6 : 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(isCompact ? 14 : 16),
          border: Border.all(
            color: context.dividerColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: isCompact ? 6 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 4 : 6,
                  vertical: isCompact ? 3 : 4,
                ),
                child: Row(
                  children: List.generate(
                    tabs.length,
                    (index) => _buildTab(context, tabs[index], index),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, MarketTab tab, int index) {
    final isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap?.call(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 16,
          vertical: isCompact ? 8 : 10,
        ),
        margin: EdgeInsets.only(right: isCompact ? 2 : 4),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.dividerColor,
                    context.cardBackground,
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
          border: isSelected
              ? Border.all(
                  color: context.colors.primary,
                  width: 1,
                )
              : null,
          boxShadow: isSelected && !isCompact
              ? [
                  BoxShadow(
                    color: context.colors.primary.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: context.labelM.copyWith(
                color:
                    isSelected ? context.colors.primary : context.textSecondary,
                fontSize: isCompact ? 13 : 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: -0.3,
              ),
              child: Text(tab.title),
            ),
            if (tab.badge != null) ...[
              SizedBox(width: isCompact ? 6 : 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 6 : 8,
                  vertical: isCompact ? 2 : 3,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      tab.badgeColor ?? context.colors.primary,
                      (tab.badgeColor ?? context.colors.primary)
                          .withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
                  boxShadow: [
                    BoxShadow(
                      color: (tab.badgeColor ?? context.colors.primary)
                          .withValues(alpha: 0.15),
                      blurRadius: isCompact ? 3 : 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  tab.badge!,
                  style: context.labelS.copyWith(
                    color: context.colors.primary,
                    fontSize: isCompact ? 9 : 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MarketTab {
  const MarketTab({
    required this.title,
    this.badge,
    this.badgeColor,
  });

  final String title;
  final String? badge;
  final Color? badgeColor;
}
