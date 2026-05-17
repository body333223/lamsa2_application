// ignore_for_file: body_might_complete_normally_nullable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lamsa/models/service_model.dart' show ServiceModel;

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =====================================================
  // 👤 USERS
  // =====================================================

  Future<void> createUserIfNotExists({
    required String userId,
    required String name,
    required String email,
  }) async {
    final doc = _db.collection('users').doc(userId);

    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'role': 'user',
      });
    }
  }

  Future<void> updateToken(String userId, String? token) async {
    if (token == null) return;
    await _db.collection('users').doc(userId).set({
      'fcmToken': token,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    return doc.data();
  }

  Future<void> updateUserData({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    await _db.collection('users').doc(userId).update(data);
  }

  // =====================================================
  // 📦 BOOKINGS SYSTEM
  // =====================================================

  Future<String> createBooking({
    required String userId,
    required String serviceName,
    required String date,
    required String time,
    required double price,
    required String status,
    String serviceImageUrl = '',
    String location = '',
    String clientName = '',
    String clientPhone = '',
    double? latitude,
    double? longitude,
  }) async {
    final doc = await _db.collection('bookings').add({
      'userId': userId,
      'serviceName': serviceName,
      'date': date,
      'time': time,
      'price': price,
      'status': 'pending_payment',
      'paymentStatus': 'pending',
      'serviceImageUrl': serviceImageUrl,
      'location': location,
      'clientName': clientName,
      'clientPhone': clientPhone,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Stream<QuerySnapshot> getUserBookings(String userId) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': status,
    });
    // Cloud Function onBookingStatusChange handles the push notification
  }

  Future<void> confirmPayment(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'confirmed',
      'paymentStatus': 'paid',
    });
    // Cloud Function onBookingStatusChange handles the push notification
  }

  Future<void> requestCancelBooking(String bookingId) async {
    await _db.collection('bookings').doc(bookingId).update({
      'status': 'cancel_requested',
    });
  }

  // =====================================================
  // ❤️ FAVORITES SYSTEM
  // =====================================================

  /// Toggle favorite status for a service.
  /// Stores as: users/{userId}/favorites/{serviceId}
  Future<void> toggleFavorite(String userId, String serviceId) async {
    final ref = _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(serviceId);

    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'serviceId': serviceId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Check if a service is favorited by user.
  Future<bool> isFavorite(String userId, String serviceId) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(serviceId)
        .get();
    return doc.exists;
  }

  /// Stream of all favorite service IDs for a user.
  Stream<List<String>> getFavoriteIds(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.id).toList());
  }

  /// Stream of favorite services (full ServiceModel data).
  Stream<List<ServiceModel>> getFavoriteServices(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .asyncMap((favSnap) async {
      if (favSnap.docs.isEmpty) return <ServiceModel>[];

      final ids = favSnap.docs.map((d) => d.id).toList();
      // Firestore 'whereIn' supports max 30 items
      final chunks = <List<String>>[];
      for (var i = 0; i < ids.length; i += 30) {
        chunks.add(ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30));
      }

      final services = <ServiceModel>[];
      for (final chunk in chunks) {
        final snap = await _db
            .collection('services')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        services.addAll(snap.docs.map((d) => ServiceModel.fromFirestore(d)));
      }
      return services;
    });
  }

  // =====================================================
  // 💬 CHAT SYSTEM (SUPPORT)
  // =====================================================

  Stream<QuerySnapshot> getMessages(String userId) {
    return _db
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String userId,
    required String text,
    required bool isAdmin,
    String? userName,
  }) async {
    final batch = _db.batch();

    // 1. Add message to subcollection
    final msgRef =
        _db.collection('chats').doc(userId).collection('messages').doc();
    batch.set(msgRef, {
      'text': text,
      'isAdmin': isAdmin,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // 2. Update thread metadata in parent document
    final threadRef = _db.collection('chats').doc(userId);
    batch.set(
        threadRef,
        {
          'userId': userId,
          'userName': userName ?? 'مستخدم',
          'lastMessage': text,
          'lastMessageTime': FieldValue.serverTimestamp(),
          'unreadByUser': isAdmin ? FieldValue.increment(1) : 0,
          'unreadByAdmin': isAdmin ? 0 : FieldValue.increment(1),
        },
        SetOptions(merge: true));

    await batch.commit();

    if (isAdmin) {
      await sendNotification(
        title: 'رسالة جديدة من الدعم الفني',
        body: text,
        userId: userId,
      );
    }
  }

  Future<void> markMessagesAsRead(String userId) async {
    final snapshot =
        await _db.collection('chats').doc(userId).collection('messages').get();

    for (final doc in snapshot.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  // =====================================================
  // 🔔 NOTIFICATIONS SYSTEM
  // =====================================================

  /// جلب إشعارات المستخدم من الـ subcollection الخاصة بيه
  Stream<QuerySnapshot> getNotifications(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// إرسال إشعار — يحفظ في subcollection المستخدم فقط
  /// الـ Cloud Function هتتفعل من الـ subcollection وتبعت الـ push
  Future<void> sendNotification({
    required String title,
    required String body,
    String userId = "all",
    String target = "all",
  }) async {
    final notifData = {
      'title': title,
      'body': body,
      'target': target,
      'sentAt': FieldValue.serverTimestamp(),
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'source': 'app', // Prevents Cloud Function from re-sending push
    };

    // حفظ في subcollection المستخدم فقط (الـ Cloud Function تتفعل منها)
    if (userId != 'all') {
      await _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add(notifData);
    } else {
      // إشعار عام — يبعت لـ topic 'all' (الـ Cloud Function تستخدم target)
      await _db.collection('notifications').add(notifData);
    }
  }

  /// Mark notification as read in user's subcollection
  Future<void> markNotificationAsRead(String notifId, {String? userId}) async {
    // Try the old collection for backward compatibility
    try {
      await _db.collection('notifications').doc(notifId).update({
        'isRead': true,
      });
    } catch (_) {}

    // Mark in user subcollection
    if (userId != null) {
      try {
        await _db
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notifId)
            .update({'isRead': true});
      } catch (_) {}
    }
  }

  /// Send notification to the booking owner when status changes
  Future<void> sendBookingStatusNotification({
    required String bookingId,
    required String newStatus,
  }) async {
    try {
      final bookingDoc = await _db.collection('bookings').doc(bookingId).get();
      if (!bookingDoc.exists) return;

      final data = bookingDoc.data()!;
      final bookingUserId = data['userId'] as String? ?? '';
      final serviceName = data['serviceName'] as String? ?? '';

      if (bookingUserId.isEmpty) return;

      String title;
      String body;

      switch (newStatus) {
        case 'confirmed':
          title = 'تم تأكيد حجزك ✓';
          body = 'حجزك لخدمة $serviceName تم تأكيده بنجاح';
          break;
        case 'cancelled':
          title = 'تم إلغاء الحجز';
          body = 'حجزك لخدمة $serviceName تم إلغاؤه';
          break;
        case 'completed':
          title = 'تم إكمال الخدمة ✨';
          body = 'نتمنى إنك استمتعتي بخدمة $serviceName';
          break;
        default:
          title = 'تحديث على حجزك';
          body = 'حالة حجزك لخدمة $serviceName تغيّرت';
      }

      await sendNotification(
        title: title,
        body: body,
        userId: bookingUserId,
      );
    } catch (e) {
      debugPrint("Error sending booking notification: $e");
    }
  }

  // =====================================================
  // ⭐ REVIEWS
  // =====================================================

  Future<void> addReview({
    required String userId,
    required String text,
    required double rating,
  }) async {
    await _db.collection('reviews').add({
      'userId': userId,
      'text': text,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getReviews() {
    return _db
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // =====================================================
  // 🧠 SUPPORT REQUESTS
  // =====================================================

  Future<void> createSupportRequest({
    required String userId,
    required String bookingId,
    required String message,
  }) async {
    await _db.collection('support_requests').add({
      'userId': userId,
      'bookingId': bookingId,
      'message': message,
      'status': 'open',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getSupportRequests(String userId) {
    return _db
        .collection('support_requests')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<List<String>> getCategories() {
    return _db.collection('categories').snapshots().map(
          (snap) => snap.docs.map((doc) => doc['name'] as String).toList(),
        );
  }

  // =====================================================
  // 🔍 SEARCH SERVICES
  // =====================================================

  Future<List<ServiceModel>> searchServices(
      String query, String selectedCategory) async {
    Query q = _db.collection('services');
    if (selectedCategory.isNotEmpty && selectedCategory != 'الكل') {
      q = q.where('category', isEqualTo: selectedCategory);
    }
    final snap = await q.get();
    final all =
        snap.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList();
    if (query.isEmpty) return all;
    final lower = query.toLowerCase();
    return all
        .where((s) =>
            s.name.toLowerCase().contains(lower) ||
            s.description.toLowerCase().contains(lower))
        .toList();
  }

  // =====================================================
  // 🛎️ SERVICES
  // =====================================================

  Stream<List<ServiceModel>> getPopularServices() {
    return _db
        .collection('services')
        .where('isPopular', isEqualTo: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ServiceModel.fromFirestore(doc)).toList());
  }
}
