abstract class ChatRepository {
  Future<List<Map<String, dynamic>>> getMessages();
  Future<void> sendMessage({required String text, bool isAdmin = false, String? userName});
  Future<void> createSupportRequest({required String userId, required String bookingId, required String message});
}
