import 'package:flutter/material.dart';
import 'package:mobile/core/theme/global_theme_extensions.dart';

class MarketPromoBanner extends StatelessWidget {
  const MarketPromoBanner({
    super.key,
    this.title =
        'Stay on top of the markets! Add a floating window or widget for easy, real-time tracking.',
    this.actionText = 'Set',
    this.onActionTap,
    this.onDismiss,
    this.backgroundColor,
  });

  final String title;
  final String actionText;
  final VoidCallback? onActionTap;
  final VoidCallback? onDismiss;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: context.labelS.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onActionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.colors.primary,
                  width: 0.5,
                ),
              ),
              child: Text(
                actionText,
                style: context.labelS.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
