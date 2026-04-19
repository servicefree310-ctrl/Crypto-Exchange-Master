import 'package:injectable/injectable.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/dio_client.dart';

abstract class NotificationRemoteDataSource {
  Future<Map<String, dynamic>> getNotifications();
  Future<void> markNotificationAsRead(String notificationId);
  Future<void> markNotificationAsUnread(String notificationId);
  Future<void> markAllNotificationsAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> deleteAllNotifications();
}

@Injectable(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient _dioClient;

  const NotificationRemoteDataSourceImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _dioClient.get(ApiConstants.notifications);

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to fetch notifications: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      final response = await _dioClient
          .post('${ApiConstants.notifications}/$notificationId/read');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to mark notification as read: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markNotificationAsUnread(String notificationId) async {
    try {
      final response = await _dioClient
          .post('${ApiConstants.notifications}/$notificationId/unread');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to mark notification as unread: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> markAllNotificationsAsRead() async {
    try {
      final response =
          await _dioClient.post('${ApiConstants.notifications}/mark-all-read');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to mark all notifications as read: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await _dioClient
          .delete('${ApiConstants.notifications}/$notificationId');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete notification: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAllNotifications() async {
    try {
      final response = await _dioClient.delete(ApiConstants.notifications);

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete all notifications: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
