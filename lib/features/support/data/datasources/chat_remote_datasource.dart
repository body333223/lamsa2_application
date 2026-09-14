import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class ChatRemoteDataSource {
  Future<List<Map<String, dynamic>>> getMessages();
  Future<void> sendMessage({required String text, bool isAdmin = false, String? userName});
  Future<void> createSupportRequest({required String userId, required String bookingId, required String message});
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  @override
  Future<List<Map<String, dynamic>>> getMessages() async {
    final data = await ApiClient.get(ApiEndpoints.chatMessages, auth: true);
    final list = data['messages'] as List<dynamic>? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> sendMessage({
    required String text,
    bool isAdmin = false,
    String? userName,
  }) async {
    await ApiClient.post(
      ApiEndpoints.sendMessage,
      auth: true,
      body: {
        'text': text,
        'is_admin': isAdmin,
        if (userName != null) 'user_name': userName,
      },
    );
  }

  @override
  Future<void> createSupportRequest({
    required String userId,
    required String bookingId,
    required String message,
  }) async {
    try {
      await ApiClient.post(
        ApiEndpoints.supportRequest,
        auth: true,
        body: {
          'user_id': userId,
          'booking_id': bookingId,
          'message': message,
        },
      );
    } catch (_) {}
  }
}
