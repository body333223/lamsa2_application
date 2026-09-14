import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<Map<String, dynamic>>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}

class NotificationsRemoteDataSourceImpl implements NotificationsRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final data = await ApiClient.get(ApiEndpoints.notifications, auth: true);
    final list = data['notifications'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await ApiClient.patch(ApiEndpoints.markNotificationRead(notificationId), auth: true);
  }

  @override
  Future<void> markAllAsRead() async {
    await ApiClient.patch(ApiEndpoints.markAllNotificationsRead, auth: true);
  }
}
