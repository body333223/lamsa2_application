import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_remote_datasource.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({ChatRemoteDataSource? remoteDataSource})
      : remoteDataSource = remoteDataSource ?? ChatRemoteDataSourceImpl();

  @override
  Future<List<Map<String, dynamic>>> getMessages() =>
      remoteDataSource.getMessages();

  @override
  Future<void> sendMessage({
    required String text,
    bool isAdmin = false,
    String? userName,
  }) =>
      remoteDataSource.sendMessage(
        text: text,
        isAdmin: isAdmin,
        userName: userName,
      );

  @override
  Future<void> createSupportRequest({
    required String userId,
    required String bookingId,
    required String message,
  }) =>
      remoteDataSource.createSupportRequest(
        userId: userId,
        bookingId: bookingId,
        message: message,
      );
}
