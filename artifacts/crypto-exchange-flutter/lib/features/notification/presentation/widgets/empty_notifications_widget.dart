import 'package:flutter/material.dart';

import '../../../../core/theme/global_theme_extensions.dart';

class EmptyNotificationsWidget extends StatelessWidget {
  const EmptyNotificationsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: context.textSecondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 60,
                color: context.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'No notifications yet',
              style: context.textTheme.titleMedium?.copyWith(
                color: context.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'You\'ll see important updates and alerts here when they arrive',
              style: context.bodyS.copyWith(
                color: context.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Decorative elements
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDecorativeIcon(context, Icons.trending_up, Colors.green),
                const SizedBox(width: 16),
                _buildDecorativeIcon(context, Icons.message, Colors.blue),
                const SizedBox(width: 16),
                _buildDecorativeIcon(context, Icons.warning, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeIcon(
      BuildContext context, IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color.withValues(alpha: 0.5),
        size: 20,
      ),
    );
  }
}
