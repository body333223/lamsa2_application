import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/firestore_service.dart';
import '../../../services/auth_service.dart';

class ChatProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  final String userId;
  bool _sending = false;

  ChatProvider(this._firestoreService, this._authService, this.userId);

  bool get sending => _sending;

  Stream<QuerySnapshot> get messagesStream =>
      _firestoreService.getMessages(userId);

  Future<void> markRead() async {
    if (userId.isEmpty) return;
    await _firestoreService.markMessagesAsRead(userId);
  }

  Future<void> sendMessage(String text) async {
    if (text.isEmpty || _sending || userId.isEmpty) return;

    _sending = true;
    notifyListeners();

    try {
      final userData = await _authService.getUserData();
      final userName = userData?['name'];

      await _firestoreService.sendMessage(
        userId: userId,
        text: text,
        isAdmin: false,
        userName: userName,
      );
    } finally {
      _sending = false;
      notifyListeners();
    }
  }
}
