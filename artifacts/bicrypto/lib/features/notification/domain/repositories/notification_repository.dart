import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification_entity.dart';
import '../entities/announcement_entity.dart';

abstract class NotificationRepository {
  /// Get notifications from WebSocket stream
  Stream<List<NotificationEntity>> getNotificationsStream();

  /// Get announcements from WebSocket stream
  Stream<List<AnnouncementEntity>> getAnnouncementsStream();

  /// Get notifications with stats from API (for initial load/refresh)
  Future<Either<Failure, NotificationsWithStats>> getNotifications();

  /// Mark notification as read
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId);

  /// Mark notification as unread
  Future<Either<Failure, void>> markNotificationAsUnread(String notificationId);

  /// Mark all notifications as read
  Future<Either<Failure, void>> markAllNotificationsAsRead();

  /// Delete notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Delete all notifications
  Future<Either<Failure, void>> deleteAllNotifications();

  /// Connect to WebSocket for real-time updates
  Future<Either<Failure, void>> connectWebSocket(String userId);

  /// Disconnect from WebSocket
  Future<void> disconnectWebSocket();

  /// Check WebSocket connection status
  bool get isWebSocketConnected;

  /// WebSocket connection status stream
  Stream<bool> get webSocketStatusStream;
}

/// Response model for notifications with statistics
class NotificationsWithStats {
  final List<NotificationEntity> notifications;
  final NotificationStats stats;

  const NotificationsWithStats({
    required this.notifications,
    required this.stats,
  });
}
