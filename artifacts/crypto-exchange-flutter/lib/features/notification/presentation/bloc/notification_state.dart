import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/announcement_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state when BLoC is first created
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Loading initial notifications from API
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Successfully loaded notifications with stats
class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final List<AnnouncementEntity> announcements;
  final NotificationStats stats;
  final bool isWebSocketConnected;
  final bool isRefreshing;

  const NotificationLoaded({
    required this.notifications,
    required this.announcements,
    required this.stats,
    required this.isWebSocketConnected,
    this.isRefreshing = false,
  });

  @override
  List<Object> get props => [
        notifications,
        announcements,
        stats,
        isWebSocketConnected,
        isRefreshing,
      ];

  NotificationLoaded copyWith({
    List<NotificationEntity>? notifications,
    List<AnnouncementEntity>? announcements,
    NotificationStats? stats,
    bool? isWebSocketConnected,
    bool? isRefreshing,
  }) {
    return NotificationLoaded(
      notifications: notifications ?? this.notifications,
      announcements: announcements ?? this.announcements,
      stats: stats ?? this.stats,
      isWebSocketConnected: isWebSocketConnected ?? this.isWebSocketConnected,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Error state with optional cached data
class NotificationError extends NotificationState {
  final String message;
  final List<NotificationEntity>? cachedNotifications;
  final List<AnnouncementEntity>? cachedAnnouncements;
  final NotificationStats? cachedStats;
  final bool isWebSocketConnected;

  const NotificationError({
    required this.message,
    this.cachedNotifications,
    this.cachedAnnouncements,
    this.cachedStats,
    this.isWebSocketConnected = false,
  });

  @override
  List<Object?> get props => [
        message,
        cachedNotifications,
        cachedAnnouncements,
        cachedStats,
        isWebSocketConnected,
      ];
}

/// Success state for actions like mark as read, delete, etc.
class NotificationActionSuccess extends NotificationState {
  final String message;
  final List<NotificationEntity> notifications;
  final List<AnnouncementEntity> announcements;
  final NotificationStats stats;
  final bool isWebSocketConnected;

  const NotificationActionSuccess({
    required this.message,
    required this.notifications,
    required this.announcements,
    required this.stats,
    required this.isWebSocketConnected,
  });

  @override
  List<Object> get props => [
        message,
        notifications,
        announcements,
        stats,
        isWebSocketConnected,
      ];
}

/// Action in progress (marking as read, deleting, etc.)
class NotificationActionInProgress extends NotificationState {
  final List<NotificationEntity> notifications;
  final List<AnnouncementEntity> announcements;
  final NotificationStats stats;
  final bool isWebSocketConnected;
  final String? actionMessage;

  const NotificationActionInProgress({
    required this.notifications,
    required this.announcements,
    required this.stats,
    required this.isWebSocketConnected,
    this.actionMessage,
  });

  @override
  List<Object?> get props => [
        notifications,
        announcements,
        stats,
        isWebSocketConnected,
        actionMessage,
      ];
}
