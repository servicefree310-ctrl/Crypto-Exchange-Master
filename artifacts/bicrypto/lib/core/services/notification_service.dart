import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
  deposit,
  withdrawal,
  transfer,
  trading,
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;
  final bool isRead;
  final Duration? autoHideDuration;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.data,
    this.isRead = false,
    this.autoHideDuration,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? timestamp,
    Map<String, dynamic>? data,
    bool? isRead,
    Duration? autoHideDuration,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      autoHideDuration: autoHideDuration ?? this.autoHideDuration,
    );
  }

  Color get color {
    switch (type) {
      case NotificationType.success:
      case NotificationType.deposit:
        return Colors.green;
      case NotificationType.error:
        return Colors.red;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.info:
        return Colors.blue;
      case NotificationType.withdrawal:
        return Colors.orange;
      case NotificationType.transfer:
        return Colors.purple;
      case NotificationType.trading:
        return Colors.teal;
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
      case NotificationType.deposit:
        return Icons.arrow_downward;
      case NotificationType.withdrawal:
        return Icons.arrow_upward;
      case NotificationType.transfer:
        return Icons.swap_horiz;
      case NotificationType.trading:
        return Icons.trending_up;
    }
  }
}

enum NotificationPriority {
  LOW,
  DEFAULT,
  HIGH,
  MAX,
}

enum NotificationCategory {
  GENERAL,
  WALLET,
  TRADING,
  SECURITY,
  SYSTEM,
}

@injectable
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  int _notificationIdCounter = 1000;

  // Notification settings
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _walletNotificationsEnabled = true;
  bool _tradingNotificationsEnabled = true;
  bool _securityNotificationsEnabled = true;
  bool _systemNotificationsEnabled = true;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    dev.log('🔵 NOTIFICATION: Initializing notification service');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _requestPermissions();
    _isInitialized = true;

    dev.log('🔵 NOTIFICATION: Service initialized successfully');
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    dev.log('🔵 NOTIFICATION: Tapped - ${response.id}: ${response.payload}');
    // TODO: Handle navigation based on notification type
  }

  /// Show a general notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.DEFAULT,
    NotificationCategory category = NotificationCategory.GENERAL,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_shouldShowNotification(category)) {
      dev.log('🔸 NOTIFICATION: Category $category disabled, skipping');
      return;
    }

    final notificationId = _getNextNotificationId();

    await _notifications.show(
      notificationId,
      title,
      body,
      _getNotificationDetails(priority, category),
      payload: payload,
    );

    dev.log('🔵 NOTIFICATION: Shown - $title');
  }

  /// Show wallet-related notification
  Future<void> showWalletNotification({
    required String title,
    required String body,
    String? walletId,
    String? currency,
    double? amount,
  }) async {
    if (!_walletNotificationsEnabled) return;

    final payload = walletId != null ? 'wallet:$walletId' : null;

    await showNotification(
      title: title,
      body: body,
      payload: payload,
      priority: NotificationPriority.HIGH,
      category: NotificationCategory.WALLET,
    );
  }

  /// Show balance update notification
  Future<void> showBalanceUpdateNotification({
    required String currency,
    required double newBalance,
    required double previousBalance,
    String? walletId,
  }) async {
    final change = newBalance - previousBalance;
    final changeText = change >= 0
        ? '+${change.toStringAsFixed(8)}'
        : change.toStringAsFixed(8);

    await showWalletNotification(
      title: '$currency Balance Updated',
      body:
          'New balance: ${newBalance.toStringAsFixed(8)} $currency ($changeText)',
      walletId: walletId,
      currency: currency,
      amount: newBalance,
    );
  }

  /// Show security notification
  Future<void> showSecurityNotification({
    required String title,
    required String body,
    String? action,
  }) async {
    if (!_securityNotificationsEnabled) return;

    await showNotification(
      title: title,
      body: body,
      payload: action != null ? 'security:$action' : null,
      priority: NotificationPriority.MAX,
      category: NotificationCategory.SECURITY,
    );
  }

  /// Show system notification
  Future<void> showSystemNotification({
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.DEFAULT,
  }) async {
    if (!_systemNotificationsEnabled) return;

    await showNotification(
      title: title,
      body: body,
      priority: priority,
      category: NotificationCategory.SYSTEM,
    );
  }

  /// Cancel notification by ID
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    dev.log('🔵 NOTIFICATION: Cancelled notification $id');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    dev.log('🔵 NOTIFICATION: Cancelled all notifications');
  }

  /// Get notification details based on priority and category
  NotificationDetails _getNotificationDetails(
    NotificationPriority priority,
    NotificationCategory category,
  ) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _getChannelId(category),
        _getChannelName(category),
        channelDescription: _getChannelDescription(category),
        importance: _getAndroidImportance(priority),
        priority: _getAndroidPriority(priority),
        enableVibration: _vibrationEnabled,
        playSound: _soundEnabled,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: _soundEnabled,
        threadIdentifier: _getChannelId(category),
      ),
    );
  }

  /// Get next notification ID
  int _getNextNotificationId() {
    return _notificationIdCounter++;
  }

  /// Check if notification should be shown based on category
  bool _shouldShowNotification(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.WALLET:
        return _walletNotificationsEnabled;
      case NotificationCategory.TRADING:
        return _tradingNotificationsEnabled;
      case NotificationCategory.SECURITY:
        return _securityNotificationsEnabled;
      case NotificationCategory.SYSTEM:
        return _systemNotificationsEnabled;
      case NotificationCategory.GENERAL:
        return true;
    }
  }

  /// Get channel ID for category
  String _getChannelId(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.WALLET:
        return 'wallet_notifications';
      case NotificationCategory.TRADING:
        return 'trading_notifications';
      case NotificationCategory.SECURITY:
        return 'security_notifications';
      case NotificationCategory.SYSTEM:
        return 'system_notifications';
      case NotificationCategory.GENERAL:
        return 'general_notifications';
    }
  }

  /// Get channel name for category
  String _getChannelName(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.WALLET:
        return 'Wallet Notifications';
      case NotificationCategory.TRADING:
        return 'Trading Notifications';
      case NotificationCategory.SECURITY:
        return 'Security Notifications';
      case NotificationCategory.SYSTEM:
        return 'System Notifications';
      case NotificationCategory.GENERAL:
        return 'General Notifications';
    }
  }

  /// Get channel description for category
  String _getChannelDescription(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.WALLET:
        return 'Notifications about wallet balance changes and transactions';
      case NotificationCategory.TRADING:
        return 'Notifications about trading activities and market updates';
      case NotificationCategory.SECURITY:
        return 'Important security alerts and account access notifications';
      case NotificationCategory.SYSTEM:
        return 'System maintenance and general app notifications';
      case NotificationCategory.GENERAL:
        return 'General application notifications';
    }
  }

  /// Get Android importance level
  Importance _getAndroidImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.LOW:
        return Importance.low;
      case NotificationPriority.DEFAULT:
        return Importance.defaultImportance;
      case NotificationPriority.HIGH:
        return Importance.high;
      case NotificationPriority.MAX:
        return Importance.max;
    }
  }

  /// Get Android priority level
  Priority _getAndroidPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.LOW:
        return Priority.low;
      case NotificationPriority.DEFAULT:
        return Priority.defaultPriority;
      case NotificationPriority.HIGH:
        return Priority.high;
      case NotificationPriority.MAX:
        return Priority.max;
    }
  }

  // Getters and setters for notification settings
  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool value) => _soundEnabled = value;

  bool get vibrationEnabled => _vibrationEnabled;
  set vibrationEnabled(bool value) => _vibrationEnabled = value;

  bool get walletNotificationsEnabled => _walletNotificationsEnabled;
  set walletNotificationsEnabled(bool value) =>
      _walletNotificationsEnabled = value;

  bool get tradingNotificationsEnabled => _tradingNotificationsEnabled;
  set tradingNotificationsEnabled(bool value) =>
      _tradingNotificationsEnabled = value;

  bool get securityNotificationsEnabled => _securityNotificationsEnabled;
  set securityNotificationsEnabled(bool value) =>
      _securityNotificationsEnabled = value;

  bool get systemNotificationsEnabled => _systemNotificationsEnabled;
  set systemNotificationsEnabled(bool value) =>
      _systemNotificationsEnabled = value;

  /// Get all notification settings
  Map<String, dynamic> getSettings() {
    return {
      'soundEnabled': _soundEnabled,
      'vibrationEnabled': _vibrationEnabled,
      'walletNotificationsEnabled': _walletNotificationsEnabled,
      'tradingNotificationsEnabled': _tradingNotificationsEnabled,
      'securityNotificationsEnabled': _securityNotificationsEnabled,
      'systemNotificationsEnabled': _systemNotificationsEnabled,
    };
  }

  /// Update notification settings
  void updateSettings(Map<String, dynamic> settings) {
    _soundEnabled = settings['soundEnabled'] ?? _soundEnabled;
    _vibrationEnabled = settings['vibrationEnabled'] ?? _vibrationEnabled;
    _walletNotificationsEnabled =
        settings['walletNotificationsEnabled'] ?? _walletNotificationsEnabled;
    _tradingNotificationsEnabled =
        settings['tradingNotificationsEnabled'] ?? _tradingNotificationsEnabled;
    _securityNotificationsEnabled = settings['securityNotificationsEnabled'] ??
        _securityNotificationsEnabled;
    _systemNotificationsEnabled =
        settings['systemNotificationsEnabled'] ?? _systemNotificationsEnabled;

    dev.log('🔵 NOTIFICATION: Settings updated');
  }
}

class _NotificationOverlay extends StatefulWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _NotificationOverlay({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<_NotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: widget.onTap,
                onPanUpdate: (details) {
                  if (details.delta.dy < -10) {
                    _dismiss();
                  }
                },
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.notification.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.notification.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            widget.notification.icon,
                            color: widget.notification.color,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.notification.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.notification.message,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: _dismiss,
                          icon: Icon(
                            Icons.close,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          constraints: BoxConstraints(),
                          padding: EdgeInsets.all(4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
