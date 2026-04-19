import 'dart:convert';

import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/announcement_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.userId,
    super.relatedId,
    required super.title,
    required super.type,
    required super.message,
    super.details,
    super.link,
    super.actions,
    required super.read,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Parse dates safely
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();
    DateTime? deletedAt;

    try {
      createdAt = DateTime.parse(json['createdAt'] as String);
      updatedAt = DateTime.parse(json['updatedAt'] as String);
      if (json['deletedAt'] != null) {
        deletedAt = DateTime.parse(json['deletedAt'] as String);
      }
    } catch (e) {
      // Use default values on parsing error
    }

    // Parse notification type
    NotificationType type = NotificationType.fromString(
      json['type'] as String? ?? 'system',
    );

    // Parse actions if present
    List<NotificationAction>? actions;
    if (json['actions'] != null) {
      try {
        if (json['actions'] is String) {
          final actionsJson = jsonDecode(json['actions'] as String);
          if (actionsJson is List) {
            actions = actionsJson
                .map((action) => NotificationAction.fromJson(
                    Map<String, dynamic>.from(action)))
                .toList();
          }
        } else if (json['actions'] is List) {
          actions = (json['actions'] as List)
              .map((action) => NotificationAction.fromJson(
                  Map<String, dynamic>.from(action)))
              .toList();
        }
      } catch (e) {
        // Failed to parse actions, leave as null
      }
    }

    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      relatedId: json['relatedId'] as String?,
      title: json['title'] as String? ?? '',
      type: type,
      message: json['message'] as String? ?? '',
      details: json['details'] as String?,
      link: json['link'] as String?,
      actions: actions,
      read: json['read'] as bool? ?? false,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      if (relatedId != null) 'relatedId': relatedId,
      'title': title,
      'type': type.toString(),
      'message': message,
      if (details != null) 'details': details,
      if (link != null) 'link': link,
      if (actions != null) 'actions': actions!.map((a) => a.toJson()).toList(),
      'read': read,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
    };
  }
}

class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.type,
    required super.title,
    required super.message,
    super.link,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    // Parse dates safely
    DateTime createdAt = DateTime.now();
    DateTime updatedAt = DateTime.now();
    DateTime? deletedAt;

    try {
      createdAt = DateTime.parse(json['createdAt'] as String);
      updatedAt = DateTime.parse(json['updatedAt'] as String);
      if (json['deletedAt'] != null) {
        deletedAt = DateTime.parse(json['deletedAt'] as String);
      }
    } catch (e) {
      // Use default values on parsing error
    }

    // Parse announcement type
    AnnouncementType type = AnnouncementType.fromString(
      json['type'] as String? ?? 'GENERAL',
    );

    return AnnouncementModel(
      id: json['id'] as String,
      type: type,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      link: json['link'] as String?,
      status: json['status'] as bool? ?? true,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: deletedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'message': message,
      if (link != null) 'link': link,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (deletedAt != null) 'deletedAt': deletedAt!.toIso8601String(),
    };
  }
}

class NotificationStatsModel extends NotificationStats {
  const NotificationStatsModel({
    required super.total,
    required super.unread,
    required super.types,
    required super.trend,
  });

  factory NotificationStatsModel.fromJson(Map<String, dynamic> json) {
    return NotificationStatsModel(
      total: json['total'] as int? ?? 0,
      unread: json['unread'] as int? ?? 0,
      types: NotificationTypeCountsModel.fromJson(
        Map<String, dynamic>.from(json['types'] as Map? ?? {}),
      ),
      trend: NotificationTrendModel.fromJson(
        Map<String, dynamic>.from(json['trend'] as Map? ?? {}),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'unread': unread,
      'types': (types as NotificationTypeCountsModel).toJson(),
      'trend': (trend as NotificationTrendModel).toJson(),
    };
  }
}

class NotificationTypeCountsModel extends NotificationTypeCounts {
  const NotificationTypeCountsModel({
    required super.investment,
    required super.message,
    required super.alert,
    required super.system,
    required super.user,
  });

  factory NotificationTypeCountsModel.fromJson(Map<String, dynamic> json) {
    return NotificationTypeCountsModel(
      investment: json['investment'] as int? ?? 0,
      message: json['message'] as int? ?? 0,
      alert: json['alert'] as int? ?? 0,
      system: json['system'] as int? ?? 0,
      user: json['user'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'investment': investment,
      'message': message,
      'alert': alert,
      'system': system,
      'user': user,
    };
  }
}

class NotificationTrendModel extends NotificationTrend {
  const NotificationTrendModel({
    required super.percentage,
    required super.increasing,
  });

  factory NotificationTrendModel.fromJson(Map<String, dynamic> json) {
    return NotificationTrendModel(
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      increasing: json['increasing'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'increasing': increasing,
    };
  }
}
