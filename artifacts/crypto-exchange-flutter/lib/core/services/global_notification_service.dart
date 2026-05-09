import 'dart:async';
import 'dart:developer' as developer;

import 'package:injectable/injectable.dart';

import '../../features/notification/data/datasources/notification_websocket_data_source.dart';
import '../../features/notification/data/models/notification_model.dart';
import '../../features/notification/domain/entities/notification_entity.dart';
import '../../features/notification/domain/entities/announcement_entity.dart';
import '../../features/profile/data/services/profile_service.dart';

@singleton
class GlobalNotificationService {
  GlobalNotificationService(
    this._webSocketDataSource,
    this._profileService,
  ) {
    _initializeService();
  }

  final NotificationWebSocketDataSource _webSocketDataSource;
  final ProfileService _profileService;

  final _notificationsController =
      StreamController<List<NotificationEntity>>.broadcast();
  final _announcementsController =
      StreamController<List<AnnouncementEntity>>.broadcast();
  final _unreadCountController = StreamController<int>.broadcast();

  StreamSubscription? _profileSubscription;
  StreamSubscription? _notificationSubscription;
  StreamSubscription? _announcementSubscription;

  List<NotificationEntity> _cachedNotifications = [];
  List<AnnouncementEntity> _cachedAnnouncements = [];
  int _unreadCount = 0;

  // Public streams
  Stream<List<NotificationEntity>> get notificationsStream =>
      _notificationsController.stream;
  Stream<List<AnnouncementEntity>> get announcementsStream =>
      _announcementsController.stream;
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  // Getters
  List<NotificationEntity> get cachedNotifications => _cachedNotifications;
  List<AnnouncementEntity> get cachedAnnouncements => _cachedAnnouncements;
  int get unreadCount => _unreadCount;
  bool get isConnected => _webSocketDataSource.isConnected;

  void _initializeService() {
    // Listen to profile changes to manage WebSocket connection
    _profileSubscription = _profileService.profileStream.listen((profile) {
      if (profile?.id != null) {
        _connectWebSocket(profile!.id);
      } else {
        _disconnectWebSocket();
      }
    });

    // If already logged in, connect immediately
    final currentProfile = _profileService.currentProfile;
    if (currentProfile?.id != null) {
      _connectWebSocket(currentProfile!.id);
    }
  }

  Future<void> _connectWebSocket(String userId) async {
    try {
      await _webSocketDataSource.connect(userId);

      // Listen to notifications
      _notificationSubscription?.cancel();
      _notificationSubscription = _webSocketDataSource.notificationsStream
          .listen(_handleNewNotifications);

      // Listen to announcements
      _announcementSubscription?.cancel();
      _announcementSubscription = _webSocketDataSource.announcementsStream
          .listen(_handleNewAnnouncements);

      developer.log('Global notification service connected',
          name: 'GlobalNotificationService');
    } catch (e) {
      developer.log('Failed to connect global notification service: $e',
          name: 'GlobalNotificationService', level: 1000);
    }
  }

  Future<void> _disconnectWebSocket() async {
    await _webSocketDataSource.disconnect();
    await _notificationSubscription?.cancel();
    await _announcementSubscription?.cancel();
    _notificationSubscription = null;
    _announcementSubscription = null;

    // Clear cached data
    _cachedNotifications.clear();
    _cachedAnnouncements.clear();
    _unreadCount = 0;
    if (!_notificationsController.isClosed) _notificationsController.add([]);
    if (!_announcementsController.isClosed) _announcementsController.add([]);
    if (!_unreadCountController.isClosed) _unreadCountController.add(0);

    developer.log('Global notification service disconnected',
        name: 'GlobalNotificationService');
  }

  void _handleNewNotifications(List<dynamic> data) {
    try {
      final notifications = <NotificationEntity>[];
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          try {
            final model = NotificationModel.fromJson(item);
            notifications.add(model);
          } catch (e) {
            developer.log('Failed to parse notification: $e',
                name: 'GlobalNotificationService', level: 900);
          }
        }
      }

      if (notifications.isNotEmpty) {
        // Add to cached notifications (prepend new ones)
        _cachedNotifications.insertAll(0, notifications);

        // Keep only last 100 notifications to prevent memory issues
        if (_cachedNotifications.length > 100) {
          _cachedNotifications = _cachedNotifications.take(100).toList();
        }

        // Update unread count
        _updateUnreadCount();

        // Emit updated notifications
        if (!_notificationsController.isClosed) {
          _notificationsController.add(List.from(_cachedNotifications));
        }

        developer.log('Received ${notifications.length} new notifications',
            name: 'GlobalNotificationService');
      }
    } catch (e) {
      developer.log('Failed to handle new notifications: $e',
          name: 'GlobalNotificationService', level: 900);
    }
  }

  void _handleNewAnnouncements(List<dynamic> data) {
    try {
      final announcements = <AnnouncementEntity>[];
      for (final item in data) {
        if (item is Map<String, dynamic>) {
          try {
            final model = AnnouncementModel.fromJson(item);
            announcements.add(model);
          } catch (e) {
            developer.log('Failed to parse announcement: $e',
                name: 'GlobalNotificationService', level: 900);
          }
        }
      }

      // Override cached announcements (replace completely)
      _cachedAnnouncements = announcements;

      // Emit updated announcements
      if (!_announcementsController.isClosed) {
        _announcementsController.add(List.from(_cachedAnnouncements));
      }

      developer.log(
          'Received ${announcements.length} announcements (cache replaced)',
          name: 'GlobalNotificationService');
    } catch (e) {
      developer.log('Failed to handle new announcements: $e',
          name: 'GlobalNotificationService', level: 900);
    }
  }

  void _updateUnreadCount() {
    _unreadCount = _cachedNotifications.where((n) => !n.read).length;
    if (!_unreadCountController.isClosed) {
      _unreadCountController.add(_unreadCount);
    }
  }

  // Mark notification as read
  void markNotificationAsRead(String notificationId) {
    final index = _cachedNotifications
        .indexWhere((notification) => notification.id == notificationId);
    if (index != -1 && !_cachedNotifications[index].read) {
      _cachedNotifications[index] = _cachedNotifications[index].copyWith(
        read: true,
      );
      _updateUnreadCount();
      if (!_notificationsController.isClosed) {
        _notificationsController.add(List.from(_cachedNotifications));
      }
    }
  }

  // Mark all notifications as read
  void markAllNotificationsAsRead() {
    _cachedNotifications = _cachedNotifications
        .map((notification) => notification.copyWith(read: true))
        .toList();
    _updateUnreadCount();
    if (!_notificationsController.isClosed) {
      _notificationsController.add(List.from(_cachedNotifications));
    }
  }

  // Remove notification
  void removeNotification(String notificationId) {
    _cachedNotifications
        .removeWhere((notification) => notification.id == notificationId);
    _updateUnreadCount();
    if (!_notificationsController.isClosed) {
      _notificationsController.add(List.from(_cachedNotifications));
    }
  }

  @disposeMethod
  void dispose() {
    _profileSubscription?.cancel();
    _notificationSubscription?.cancel();
    _announcementSubscription?.cancel();
    _webSocketDataSource.dispose();
    _notificationsController.close();
    _announcementsController.close();
    _unreadCountController.close();
  }
}
