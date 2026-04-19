import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/global_theme_extensions.dart';

class MaintenanceBanner extends StatelessWidget {
  const MaintenanceBanner({
    super.key,
    this.message = 'Server maintenance in progress',
    this.onClose,
  });

  final String message;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.warningColor.withValues(alpha: 0.1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: context.warningColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.alertTriangle,
              size: 16,
              color: context.warningColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: context.bodyS.copyWith(
                  color: context.warningColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onClose != null)
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 16,
                  color: context.warningColor,
                ),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 24,
                  minHeight: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
