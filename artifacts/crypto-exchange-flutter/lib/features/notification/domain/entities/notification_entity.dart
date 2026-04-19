import 'package:equatable/equatable.dart';


/// Notification entity representing a user notification
class NotificationEntity extends Equatable {
  final String id;
  final String userId;
  final String? relatedId;
  final String title;
  final NotificationType type;
  final String message;
  final String? details;
  final String? link;
  final List<NotificationAction>? actions;
  final bool read;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const NotificationEntity({
    required this.id,
    required this.userId,
    this.relatedId,
    required this.title,
    required this.type,
    required this.message,
    this.details,
    this.link,
    this.actions,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        relatedId,
        title,
        type,
        message,
        details,
        link,
        actions,
        read,
        createdAt,
        updatedAt,
        deletedAt,
      ];

  NotificationEntity copyWith({
    String? id,
    String? userId,
    String? relatedId,
    String? title,
    NotificationType? type,
    String? message,
    String? details,
    String? link,
    List<NotificationAction>? actions,
    bool? read,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      relatedId: relatedId ?? this.relatedId,
      title: title ?? this.title,
      type: type ?? this.type,
      message: message ?? this.message,
      details: details ?? this.details,
      link: link ?? this.link,
      actions: actions ?? this.actions,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

// AnnouncementEntity moved to announcement_entity.dart

/// Notification types as defined in backend
enum NotificationType {
  investment,
  message,
  user,
  alert,
  system;

  static NotificationType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'investment':
        return NotificationType.investment;
      case 'message':
        return NotificationType.message;
      case 'user':
        return NotificationType.user;
      case 'alert':
        return NotificationType.alert;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }

  @override
  String toString() => name;
}

// AnnouncementType moved to announcement_entity.dart

/// Notification action for interactive notifications
class NotificationAction extends Equatable {
  final String label;
  final String? link;
  final bool? primary;

  const NotificationAction({
    required this.label,
    this.link,
    this.primary,
  });

  @override
  List<Object?> get props => [label, link, primary];

  factory NotificationAction.fromJson(Map<String, dynamic> json) {
    return NotificationAction(
      label: json['label'] as String,
      link: json['link'] as String?,
      primary: json['primary'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      if (link != null) 'link': link,
      if (primary != null) 'primary': primary,
    };
  }
}

/// Notification statistics from API response
class NotificationStats extends Equatable {
  final int total;
  final int unread;
  final NotificationTypeCounts types;
  final NotificationTrend trend;

  const NotificationStats({
    required this.total,
    required this.unread,
    required this.types,
    required this.trend,
  });

  @override
  List<Object> get props => [total, unread, types, trend];
}

/// Count by notification type
class NotificationTypeCounts extends Equatable {
  final int investment;
  final int message;
  final int alert;
  final int system;
  final int user;

  const NotificationTypeCounts({
    required this.investment,
    required this.message,
    required this.alert,
    required this.system,
    required this.user,
  });

  @override
  List<Object> get props => [investment, message, alert, system, user];
}

/// Notification trend information
class NotificationTrend extends Equatable {
  final double percentage;
  final bool increasing;

  const NotificationTrend({
    required this.percentage,
    required this.increasing,
  });

  @override
  List<Object> get props => [percentage, increasing];
}
