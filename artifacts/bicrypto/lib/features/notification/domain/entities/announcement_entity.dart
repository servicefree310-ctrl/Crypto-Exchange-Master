import 'package:equatable/equatable.dart';

/// Announcement entity representing a system announcement
class AnnouncementEntity extends Equatable {
  final String id;
  final AnnouncementType type;
  final String title;
  final String message;
  final String? link;
  final bool status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const AnnouncementEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.link,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        link,
        status,
        createdAt,
        updatedAt,
        deletedAt,
      ];

  AnnouncementEntity copyWith({
    String? id,
    AnnouncementType? type,
    String? title,
    String? message,
    String? link,
    bool? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return AnnouncementEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      link: link ?? this.link,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}

/// Announcement types as defined in backend
enum AnnouncementType {
  general,
  event,
  update;

  static AnnouncementType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'GENERAL':
        return AnnouncementType.general;
      case 'EVENT':
        return AnnouncementType.event;
      case 'UPDATE':
        return AnnouncementType.update;
      default:
        return AnnouncementType.general;
    }
  }

  String toBackendString() {
    switch (this) {
      case AnnouncementType.general:
        return 'GENERAL';
      case AnnouncementType.event:
        return 'EVENT';
      case AnnouncementType.update:
        return 'UPDATE';
    }
  }

  @override
  String toString() => toBackendString();
}
