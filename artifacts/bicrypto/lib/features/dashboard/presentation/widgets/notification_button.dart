import 'package:flutter/material.dart';

import '../../../../core/services/global_notification_service.dart';
import '../../../../core/theme/global_theme_extensions.dart';
import '../../../../injection/injection.dart';
import '../../../notification/presentation/pages/notifications_page.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final globalNotificationService = getIt<GlobalNotificationService>();

    return StreamBuilder<int>(
      stream: globalNotificationService.unreadCountStream,
      initialData: globalNotificationService.unreadCount,
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;

        return _buildNotificationButton(context, unreadCount);
      },
    );
  }

  Widget _buildNotificationButton(BuildContext context, int count) {
    final size = context.isSmallScreen ? 32.0 : 36.0;

    return GestureDetector(
      onTap: () => _openNotifications(context),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.inputBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: context.borderColor.withValues(alpha: 0.5),
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_outlined,
                color: context.textSecondary,
                size: context.isSmallScreen ? 16.0 : 18.0,
              ),
            ),
            if (count > 0)
              Positioned(
                right: 0,
                top: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  width: context.isSmallScreen ? 14.0 : 16.0,
                  height: context.isSmallScreen ? 14.0 : 16.0,
                  decoration: BoxDecoration(
                    color: context.priceDownColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.priceDownColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: context.labelS.copyWith(
                        color: Colors.white,
                        fontSize: context.isSmallScreen ? 7.0 : 8.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationsPage(),
      ),
    );
  }
}
