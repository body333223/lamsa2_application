import 'package:flutter/material.dart';
import '../../../services/data_service.dart';
import '../../../services/auth_service.dart';

class ChatProvider extends ChangeNotifier {
  final DataService _dataService;
  final AuthService _authService;
  final String userId;
  bool _sending = false;

  List<Map<String, dynamic>> _messages = [];
  List<Map<String, dynamic>> get messages => _messages;

  bool get sending => _sending;

  ChatProvider(dynamic _, this._authService, this.userId) :
    _dataService = DataService() {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (userId.isEmpty) return;
    try {
      _messages = await _dataService.getMessages(userId);
      notifyListeners();
    } catch (_) {}
  }

  Future<void> markRead() async {
    // Messages are marked as read server-side on GET
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty || _sending || userId.isEmpty) return;

    _sending = true;
    notifyListeners();

    try {
      final userData = await _authService.getUserData();
      final userName = userData?['name'];

      await _dataService.sendMessage(
        userId: userId,
        text: text,
        isAdmin: false,
        userName: userName,
      );

      // Reload messages
      await _loadMessages();
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => _loadMessages();
}
