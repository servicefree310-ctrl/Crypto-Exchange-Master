import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/entities/announcement_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../datasources/notification_websocket_data_source.dart';
import '../models/notification_model.dart';

@Injectable(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final NotificationWebSocketDataSource _webSocketDataSource;

  const NotificationRepositoryImpl(
    this._remoteDataSource,
    this._webSocketDataSource,
  );

  @override
  Stream<List<NotificationEntity>> getNotificationsStream() {
    return _webSocketDataSource.notificationsStream.map((notifications) {
      return notifications.map((json) {
        if (json is Map<String, dynamic>) {
          return NotificationModel.fromJson(json);
        }
        // Fallback for unexpected data format
        return NotificationModel(
          id: json['id']?.toString() ?? '',
          userId: json['userId']?.toString() ?? '',
          relatedId: json['relatedId']?.toString(),
          title: json['title']?.toString() ?? '',
          type:
              NotificationType.fromString(json['type']?.toString() ?? 'system'),
          message: json['message']?.toString() ?? '',
          details: json['details']?.toString(),
          link: json['link']?.toString(),
          actions: null,
          read: json['read'] as bool? ?? false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
    });
  }

  @override
  Stream<List<AnnouncementEntity>> getAnnouncementsStream() {
    return _webSocketDataSource.announcementsStream.map((announcements) {
      return announcements.map((json) {
        if (json is Map<String, dynamic>) {
          return AnnouncementModel.fromJson(json);
        }
        // Fallback for unexpected data format
        return AnnouncementModel(
          id: json['id']?.toString() ?? '',
          type: AnnouncementType.fromString(
              json['type']?.toString() ?? 'GENERAL'),
          title: json['title']?.toString() ?? '',
          message: json['message']?.toString() ?? '',
          link: json['link']?.toString(),
          status: json['status'] as bool? ?? true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
    });
  }

  @override
  Future<Either<Failure, NotificationsWithStats>> getNotifications() async {
    try {
      final response = await _remoteDataSource.getNotifications();

      // Parse notifications
      final notificationsJson =
          response['notifications'] as List<dynamic>? ?? [];
      final notifications = notificationsJson
          .map((json) =>
              NotificationModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      // Parse stats
      final statsJson = response['stats'] as Map<String, dynamic>? ?? {};
      final stats = NotificationStatsModel.fromJson(statsJson);

      return Right(NotificationsWithStats(
        notifications: notifications,
        stats: stats,
      ));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(
      String notificationId) async {
    try {
      await _remoteDataSource.markNotificationAsRead(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationAsUnread(
      String notificationId) async {
    try {
      await _remoteDataSource.markNotificationAsUnread(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllNotificationsAsRead() async {
    try {
      await _remoteDataSource.markAllNotificationsAsRead();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(
      String notificationId) async {
    try {
      await _remoteDataSource.deleteNotification(notificationId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications() async {
    try {
      await _remoteDataSource.deleteAllNotifications();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> connectWebSocket(String userId) async {
    try {
      await _webSocketDataSource.connect(userId);
      return const Right(null);
    } catch (e) {
      return Left(NetworkFailure('Failed to connect to WebSocket: $e'));
    }
  }

  @override
  Future<void> disconnectWebSocket() async {
    await _webSocketDataSource.disconnect();
  }

  @override
  bool get isWebSocketConnected => _webSocketDataSource.isConnected;

  @override
  Stream<bool> get webSocketStatusStream =>
      _webSocketDataSource.connectionStatusStream;
}
