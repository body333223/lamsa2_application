import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'auth_service.dart';

class ChatNotificationService extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final AuthService _authService;
  StreamSubscription? _subscription;

  ChatNotificationService(this._firestoreService, this._authService) {
    _authService.addListener(_handleAuthChange);
    _handleAuthChange();
  }

  void _handleAuthChange() {
    final userId = _authService.currentUser?.uid;
    if (userId != null) {
      _startListening(userId);
      FirebaseMessaging.instance.getToken().then((token) {
        if (token != null) _firestoreService.updateToken(userId, token);
      });
    } else {
      _stopListening();
    }
  }

  StreamSubscription? _broadcastSubscription;

  void _startListening(String userId) {
    _subscription?.cancel();
    _broadcastSubscription?.cancel();

    // FCM push handles all notifications.
    // Firestore listener is only for real-time chat UI updates,
    // NOT for showing notifications (that caused duplicates).
  }

  void _stopListening() {
    _subscription?.cancel();
    _broadcastSubscription?.cancel();
    _subscription = null;
    _broadcastSubscription = null;
  }


  @override
  void dispose() {
    _authService.removeListener(_handleAuthChange);
    _stopListening();
    super.dispose();
  }
}
