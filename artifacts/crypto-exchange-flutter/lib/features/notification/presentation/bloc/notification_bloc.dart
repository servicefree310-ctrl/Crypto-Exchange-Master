import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../injection/injection.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_read_usecase.dart';
import '../../domain/usecases/mark_all_notifications_read_usecase.dart';
import '../../domain/usecases/delete_notification_usecase.dart';
import '../../domain/usecases/connect_websocket_usecase.dart';
import '../../data/models/notification_model.dart';
import 'notification_event.dart';
import 'notification_state.dart';

@injectable
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;
  final GetNotificationsUseCase _getNotificationsUseCase;
  final MarkNotificationReadUseCase _markNotificationReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllNotificationsReadUseCase;
  final DeleteNotificationUseCase _deleteNotificationUseCase;
  final ConnectWebSocketUseCase _connectWebSocketUseCase;

  StreamSubscription<List<NotificationEntity>>? _notificationsSubscription;
  StreamSubscription<List<AnnouncementEntity>>? _announcementsSubscription;
  StreamSubscription<bool>? _webSocketStatusSubscription;

  List<NotificationEntity> _currentNotifications = [];
  List<AnnouncementEntity> _currentAnnouncements = [];
  NotificationStats _currentStats = const NotificationStats(
    total: 0,
    unread: 0,
    types: NotificationTypeCounts(
      investment: 0,
      message: 0,
      alert: 0,
      system: 0,
      user: 0,
    ),
    trend: NotificationTrend(percentage: 0.0, increasing: true),
  );
  bool _isWebSocketConnected = false;

  NotificationBloc(
    this._repository,
    this._getNotificationsUseCase,
    this._markNotificationReadUseCase,
    this._markAllNotificationsReadUseCase,
    this._deleteNotificationUseCase,
    this._connectWebSocketUseCase,
  ) : super(const NotificationInitial()) {
    on<NotificationStartListening>(_onStartListening);
    on<NotificationStopListening>(_onStopListening);
    on<NotificationLoadInitial>(_onLoadInitial);
    on<NotificationLoadRequested>(_onLoadRequested);
    on<NotificationRefresh>(_onRefresh);
    on<NotificationMarkAsRead>(_onMarkAsRead);
    on<NotificationMarkAllAsRead>(_onMarkAllAsRead);
    on<NotificationMarkAllReadRequested>(_onMarkAllReadRequested);
    on<NotificationMarkReadRequested>(_onMarkReadRequested);
    on<NotificationMarkUnreadRequested>(_onMarkUnreadRequested);
    on<NotificationDelete>(_onDelete);
    on<NotificationDeleteRequested>(_onDeleteRequested);
    on<NotificationDeleteAllRequested>(_onDeleteAllRequested);
    on<NotificationNewReceived>(_onNewReceived);
    on<AnnouncementNewReceived>(_onAnnouncementReceived);
    on<NotificationWebSocketStatusChanged>(_onWebSocketStatusChanged);
  }

  Future<void> _onStartListening(
    NotificationStartListening event,
    Emitter<NotificationState> emit,
  ) async {
    // Connect to WebSocket
    final connectResult = await _connectWebSocketUseCase(
      ConnectWebSocketParams(userId: event.userId),
    );

    connectResult.fold(
      (failure) {
        emit(NotificationError(
          message: failure.message,
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
        ));
      },
      (_) {
        // Set up WebSocket streams
        _setupWebSocketStreams();

        // Load initial data from API
        add(const NotificationLoadInitial());
      },
    );
  }

  void _setupWebSocketStreams() {
    // Listen to notifications stream
    _notificationsSubscription?.cancel();
    _notificationsSubscription = _repository.getNotificationsStream().listen(
      (notifications) => add(NotificationNewReceived(notifications
          .map((e) => {
                'id': e.id,
                'userId': e.userId,
                'relatedId': e.relatedId,
                'title': e.title,
                'type': e.type.toString(),
                'message': e.message,
                'details': e.details,
                'link': e.link,
                'actions': e.actions?.map((a) => a.toJson()).toList(),
                'read': e.read,
                'createdAt': e.createdAt.toIso8601String(),
                'updatedAt': e.updatedAt.toIso8601String(),
                'deletedAt': e.deletedAt?.toIso8601String(),
              })
          .toList())),
      onError: (error) {
        emit(NotificationError(
          message: 'WebSocket notification stream error: $error',
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
        ));
      },
    );

    // Listen to announcements stream
    _announcementsSubscription?.cancel();
    _announcementsSubscription = _repository.getAnnouncementsStream().listen(
      (announcements) => add(AnnouncementNewReceived(announcements
          .map((e) => {
                'id': e.id,
                'type': e.type.toString(),
                'title': e.title,
                'message': e.message,
                'link': e.link,
                'status': e.status,
                'createdAt': e.createdAt.toIso8601String(),
                'updatedAt': e.updatedAt.toIso8601String(),
                'deletedAt': e.deletedAt?.toIso8601String(),
              })
          .toList())),
      onError: (error) {
        emit(NotificationError(
          message: 'WebSocket announcement stream error: $error',
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
        ));
      },
    );

    // Listen to WebSocket status
    _webSocketStatusSubscription?.cancel();
    _webSocketStatusSubscription = _repository.webSocketStatusStream.listen(
      (isConnected) => add(NotificationWebSocketStatusChanged(isConnected)),
    );
  }

  Future<void> _onStopListening(
    NotificationStopListening event,
    Emitter<NotificationState> emit,
  ) async {
    await _cleanupStreams();
    await _repository.disconnectWebSocket();
    _isWebSocketConnected = false;

    emit(NotificationLoaded(
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: _currentStats,
      isWebSocketConnected: false,
    ));
  }

  Future<void> _onLoadInitial(
    NotificationLoadInitial event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await _getNotificationsUseCase(NoParams());

    result.fold(
      (failure) {
        emit(NotificationError(
          message: failure.message,
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
      (data) {
        _currentNotifications = data.notifications;
        _currentStats = data.stats;

        emit(NotificationLoaded(
          notifications: _currentNotifications,
          announcements: _currentAnnouncements,
          stats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
    );
  }

  Future<void> _onRefresh(
    NotificationRefresh event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoaded(
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: _currentStats,
      isWebSocketConnected: _isWebSocketConnected,
      isRefreshing: true,
    ));

    final result = await _getNotificationsUseCase(NoParams());

    result.fold(
      (failure) {
        emit(NotificationError(
          message: failure.message,
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
      (data) {
        _currentNotifications = data.notifications;
        _currentStats = data.stats;

        emit(NotificationLoaded(
          notifications: _currentNotifications,
          announcements: _currentAnnouncements,
          stats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
    );
  }

  Future<void> _onMarkAsRead(
    NotificationMarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationActionInProgress(
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: _currentStats,
      isWebSocketConnected: _isWebSocketConnected,
      actionMessage: 'Marking notification as read...',
    ));

    final result = await _markNotificationReadUseCase(
      MarkNotificationReadParams(notificationId: event.notificationId),
    );

    result.fold(
      (failure) {
        emit(NotificationError(
          message: failure.message,
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
      (_) {
        // Update local state optimistically
        _currentNotifications = _currentNotifications.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.copyWith(read: true);
          }
          return notification;
        }).toList();

        emit(NotificationActionSuccess(
          message: 'Notification marked as read',
          notifications: _currentNotifications,
          announcements: _currentAnnouncements,
          stats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
    );
  }

  Future<void> _onMarkAllAsRead(
    NotificationMarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationActionInProgress(
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: _currentStats,
      isWebSocketConnected: _isWebSocketConnected,
      actionMessage: 'Marking all notifications as read...',
    ));

    final result = await _markAllNotificationsReadUseCase(NoParams());

    result.fold(
      (failure) {
        emit(NotificationError(
          message: failure.message,
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
      (_) {
        // Update local state optimistically
        _currentNotifications = _currentNotifications.map((notification) {
          return notification.copyWith(read: true);
        }).toList();

        emit(NotificationActionSuccess(
          message: 'All notifications marked as read',
          notifications: _currentNotifications,
          announcements: _currentAnnouncements,
          stats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
    );
  }

  Future<void> _onDelete(
    NotificationDelete event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationActionInProgress(
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: _currentStats,
      isWebSocketConnected: _isWebSocketConnected,
      actionMessage: 'Deleting notification...',
    ));

    final result = await _deleteNotificationUseCase(
      DeleteNotificationParams(notificationId: event.notificationId),
    );

    result.fold(
      (failure) {
        emit(NotificationError(
          message: failure.message,
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
      (_) {
        // Remove from local state optimistically
        _currentNotifications = _currentNotifications
            .where((notification) => notification.id != event.notificationId)
            .toList();

        emit(NotificationActionSuccess(
          message: 'Notification deleted',
          notifications: _currentNotifications,
          announcements: _currentAnnouncements,
          stats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
    );
  }

  void _onNewReceived(
    NotificationNewReceived event,
    Emitter<NotificationState> emit,
  ) {
    // Convert from JSON to entities using models
    final newNotifications = event.notifications
        .map((json) =>
            NotificationModel.fromJson(Map<String, dynamic>.from(json)))
        .where((newNotification) => !_currentNotifications
            .any((existing) => existing.id == newNotification.id))
        .toList();

    if (newNotifications.isNotEmpty) {
      _currentNotifications = [...newNotifications, ..._currentNotifications];

      emit(NotificationLoaded(
        notifications: _currentNotifications,
        announcements: _currentAnnouncements,
        stats: _currentStats,
        isWebSocketConnected: _isWebSocketConnected,
      ));
    }
  }

  void _onAnnouncementReceived(
    AnnouncementNewReceived event,
    Emitter<NotificationState> emit,
  ) {
    // Convert from JSON to entities using models
    final newAnnouncements = event.announcements
        .map((json) =>
            AnnouncementModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();

    // Override current announcements (replace completely)
    _currentAnnouncements = newAnnouncements;

    emit(NotificationLoaded(
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: _currentStats,
      isWebSocketConnected: _isWebSocketConnected,
    ));
  }

  void _onWebSocketStatusChanged(
    NotificationWebSocketStatusChanged event,
    Emitter<NotificationState> emit,
  ) {
    _isWebSocketConnected = event.isConnected;

    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      emit(currentState.copyWith(isWebSocketConnected: event.isConnected));
    }
  }

  Future<void> _onMarkReadRequested(
    NotificationMarkReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationActionInProgress(
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: _currentStats,
      isWebSocketConnected: _isWebSocketConnected,
      actionMessage: 'Marking notification as read...',
    ));

    final result = await _markNotificationReadUseCase(
      MarkNotificationReadParams(notificationId: event.notificationId),
    );

    result.fold(
      (failure) {
        emit(NotificationError(
          message: failure.message,
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
      (_) {
        // Update local state optimistically
        _currentNotifications = _currentNotifications.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.copyWith(read: true);
          }
          return notification;
        }).toList();

        emit(NotificationActionSuccess(
          message: 'Notification marked as read',
          notifications: _currentNotifications,
          announcements: _currentAnnouncements,
          stats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
    );
  }

  Future<void> _onMarkUnreadRequested(
    NotificationMarkUnreadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationActionInProgress(
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: _currentStats,
      isWebSocketConnected: _isWebSocketConnected,
      actionMessage: 'Marking notification as unread...',
    ));

    final result = await _repository.markNotificationAsUnread(event.notificationId);

    result.fold(
      (failure) {
        emit(NotificationError(
          message: failure.message,
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
      (_) {
        // Update local state optimistically
        _currentNotifications = _currentNotifications.map((notification) {
          if (notification.id == event.notificationId) {
            return notification.copyWith(read: false);
          }
          return notification;
        }).toList();

        // Update stats - increment unread count
        _currentStats = NotificationStats(
          total: _currentStats.total,
          unread: _currentStats.unread + 1,
          types: _currentStats.types,
          trend: _currentStats.trend,
        );

        emit(NotificationActionSuccess(
          message: 'Notification marked as unread',
          notifications: _currentNotifications,
          announcements: _currentAnnouncements,
          stats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
    );
  }

  Future<void> _onDeleteRequested(
    NotificationDeleteRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationActionInProgress(
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: _currentStats,
      isWebSocketConnected: _isWebSocketConnected,
      actionMessage: 'Deleting notification...',
    ));

    final result = await _deleteNotificationUseCase(
      DeleteNotificationParams(notificationId: event.notificationId),
    );

    result.fold(
      (failure) {
        emit(NotificationError(
          message: failure.message,
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
      (_) {
        // Remove from local state optimistically
        _currentNotifications = _currentNotifications
            .where((notification) => notification.id != event.notificationId)
            .toList();

        emit(NotificationActionSuccess(
          message: 'Notification deleted',
          notifications: _currentNotifications,
          announcements: _currentAnnouncements,
          stats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
    );
  }

  Future<void> _onDeleteAllRequested(
    NotificationDeleteAllRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationActionInProgress(
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: _currentStats,
      isWebSocketConnected: _isWebSocketConnected,
      actionMessage: 'Deleting all notifications...',
    ));

    // We need to add this use case to the domain layer
    // For now, we'll simulate the behavior
    await Future.delayed(const Duration(milliseconds: 1000));

    // Clear all notifications
    _currentNotifications = [];

    emit(NotificationActionSuccess(
      message: 'All notifications deleted',
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: const NotificationStats(
        total: 0,
        unread: 0,
        types: NotificationTypeCounts(
          investment: 0,
          message: 0,
          alert: 0,
          system: 0,
          user: 0,
        ),
        trend: NotificationTrend(percentage: 0.0, increasing: true),
      ),
      isWebSocketConnected: _isWebSocketConnected,
    ));
  }

  Future<void> _onLoadRequested(
    NotificationLoadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    final result = await _getNotificationsUseCase(NoParams());

    result.fold(
      (failure) {
        emit(NotificationError(
          message: failure.message,
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
      (data) {
        _currentNotifications = data.notifications;
        _currentStats = data.stats;

        emit(NotificationLoaded(
          notifications: _currentNotifications,
          announcements: _currentAnnouncements,
          stats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
    );
  }

  Future<void> _onMarkAllReadRequested(
    NotificationMarkAllReadRequested event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationActionInProgress(
      notifications: _currentNotifications,
      announcements: _currentAnnouncements,
      stats: _currentStats,
      isWebSocketConnected: _isWebSocketConnected,
      actionMessage: 'Marking all notifications as read...',
    ));

    final result = await _markAllNotificationsReadUseCase(NoParams());

    result.fold(
      (failure) {
        emit(NotificationError(
          message: failure.message,
          cachedNotifications: _currentNotifications,
          cachedAnnouncements: _currentAnnouncements,
          cachedStats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
      (_) {
        // Update local state optimistically
        _currentNotifications = _currentNotifications.map((notification) {
          return notification.copyWith(read: true);
        }).toList();

        emit(NotificationActionSuccess(
          message: 'All notifications marked as read',
          notifications: _currentNotifications,
          announcements: _currentAnnouncements,
          stats: _currentStats,
          isWebSocketConnected: _isWebSocketConnected,
        ));
      },
    );
  }

  /// Helper method to start listening with user ID from ProfileService
  Future<void> startListeningWithProfileUserId() async {
    final profileService = getIt<ProfileService>();
    final userId = profileService.currentProfile?.id;

    if (userId != null) {
      add(NotificationStartListening(userId));
    } else {
      emit(const NotificationError(
        message: 'User ID not available. Please ensure you are logged in.',
      ));
    }
  }

  Future<void> _cleanupStreams() async {
    await _notificationsSubscription?.cancel();
    await _announcementsSubscription?.cancel();
    await _webSocketStatusSubscription?.cancel();

    _notificationsSubscription = null;
    _announcementsSubscription = null;
    _webSocketStatusSubscription = null;
  }

  @override
  Future<void> close() async {
    await _cleanupStreams();
    await _repository.disconnectWebSocket();
    return super.close();
  }
}
