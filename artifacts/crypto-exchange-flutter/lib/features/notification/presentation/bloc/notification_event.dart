import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Start listening to real-time notifications via WebSocket
class NotificationStartListening extends NotificationEvent {
  final String userId;

  const NotificationStartListening(this.userId);

  @override
  List<Object> get props => [userId];
}

/// Stop listening to real-time notifications
class NotificationStopListening extends NotificationEvent {
  const NotificationStopListening();
}

/// Load initial notifications from API
class NotificationLoadInitial extends NotificationEvent {
  const NotificationLoadInitial();
}

/// Load notifications (alias for consistency with new page)
class NotificationLoadRequested extends NotificationEvent {
  const NotificationLoadRequested();
}

/// Refresh notifications from API
class NotificationRefresh extends NotificationEvent {
  const NotificationRefresh();
}

/// Mark specific notification as read
class NotificationMarkAsRead extends NotificationEvent {
  final String notificationId;

  const NotificationMarkAsRead(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

/// Mark all notifications as read
class NotificationMarkAllAsRead extends NotificationEvent {
  const NotificationMarkAllAsRead();
}

/// Mark all notifications as read (alias for consistency)
class NotificationMarkAllReadRequested extends NotificationEvent {
  const NotificationMarkAllReadRequested();
}

/// Mark specific notification as read (new naming)
class NotificationMarkReadRequested extends NotificationEvent {
  final String notificationId;

  const NotificationMarkReadRequested(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

/// Mark specific notification as unread
class NotificationMarkUnreadRequested extends NotificationEvent {
  final String notificationId;

  const NotificationMarkUnreadRequested(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

/// Delete specific notification (new naming)
class NotificationDeleteRequested extends NotificationEvent {
  final String notificationId;

  const NotificationDeleteRequested(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

/// Delete all notifications
class NotificationDeleteAllRequested extends NotificationEvent {
  const NotificationDeleteAllRequested();
}

/// Delete specific notification
class NotificationDelete extends NotificationEvent {
  final String notificationId;

  const NotificationDelete(this.notificationId);

  @override
  List<Object> get props => [notificationId];
}

/// Internal event when new notifications arrive via WebSocket
class NotificationNewReceived extends NotificationEvent {
  final List<dynamic> notifications;

  const NotificationNewReceived(this.notifications);

  @override
  List<Object> get props => [notifications];
}

/// Internal event when new announcements arrive via WebSocket
class AnnouncementNewReceived extends NotificationEvent {
  final List<dynamic> announcements;

  const AnnouncementNewReceived(this.announcements);

  @override
  List<Object> get props => [announcements];
}

/// WebSocket connection status changed
class NotificationWebSocketStatusChanged extends NotificationEvent {
  final bool isConnected;

  const NotificationWebSocketStatusChanged(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}
