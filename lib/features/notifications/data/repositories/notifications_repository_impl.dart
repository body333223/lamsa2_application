import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({NotificationsRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? NotificationsRemoteDataSourceImpl();

  @override
  Future<List<Map<String, dynamic>>> getNotifications() =>
      remoteDataSource.getNotifications();

  @override
  Future<void> markAsRead(String notificationId) =>
      remoteDataSource.markAsRead(notificationId);

  @override
  Future<void> markAllAsRead() =>
      remoteDataSource.markAllAsRead();
}
