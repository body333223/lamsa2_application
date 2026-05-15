import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'firestore_service.dart';
import 'auth_service.dart';
import '../core/widgets/whatsapp_notification_ui.dart';
import '../main.dart' show shownNotifications;

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

    final startTime = DateTime.now();

    // 1. Private Chat Listener
    _subscription = FirebaseFirestore.instance
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .snapshots()
        .listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          // ignore: unnecessary_cast
          final data = change.doc.data() as Map<String, dynamic>?;
          if (data == null) continue;
          final isAdmin = data['isAdmin'] == true;
          final text = data['text']?.toString() ?? '';
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

          if (isAdmin) {
            bool isNew = createdAt != null
                ? createdAt
                    .isAfter(startTime.subtract(const Duration(seconds: 10)))
                : true;
            if (isNew) {
              _showInAppNotification(text, title: 'رسالة جديدة من الدعم');
            }
          }
        }
      }
    });

    // الإشعارات بتوصل عبر FCM push — مش محتاجين listener تاني هنا
    // ده بيمنع تكرار الإشعار مرتين
  }

  void _stopListening() {
    _subscription?.cancel();
    _broadcastSubscription?.cancel();
    _subscription = null;
    _broadcastSubscription = null;
  }

  void _showInAppNotification(String message, {String title = 'تنبيه جديد'}) {
    // Deduplicate with the global set from main.dart
    final contentKey = '${title}_$message';
    if (shownNotifications.contains(contentKey)) {
      return; // Already shown by FCM onMessage listener
    }
    shownNotifications.add(contentKey);

    Future.delayed(const Duration(seconds: 30), () {
      shownNotifications.remove(contentKey);
    });

    showOverlayNotification(
      (context) {
        return WhatsAppNotificationUI(
          title: title,
          message: message,
          onTap: () {
            OverlaySupportEntry.of(context)?.dismiss();
          },
        );
      },
      duration: const Duration(seconds: 5),
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.removeListener(_handleAuthChange);
    _stopListening();
    super.dispose();
  }
}
