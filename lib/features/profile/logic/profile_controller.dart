// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

/// Handles all business logic for the Profile feature:
/// fetching user data, bookings count, and favorites count.
class ProfileController {
  final AuthService authService;

  ProfileController({required this.authService});

  String get uid => authService.currentUser?.uid ?? '';

  bool get isGuest => uid.isEmpty;

  Future<Map<String, dynamic>?> getUserData() => authService.getUserData();

  Stream<QuerySnapshot> bookingsStream() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .snapshots();
  }

  Stream<QuerySnapshot> favoritesStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots();
  }

  Future<void> updateUserName(BuildContext context, String newName) async {
    await authService.updateUserName(newName);
  }

  Future<void> signOut() async {
    await authService.signOut();
  }
}
