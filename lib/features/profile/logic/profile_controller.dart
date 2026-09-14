import 'package:flutter/material.dart';
import '../../../models/booking_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/data_service.dart';

/// Handles all business logic for the Profile feature.
class ProfileController {
  final AuthService authService;
  final DataService _dataService;

  ProfileController({required this.authService}) : _dataService = DataService();

  String get uid => authService.userId ?? '';

  bool get isGuest => uid.isEmpty;

  Future<Map<String, dynamic>?> getUserData() => authService.getUserData();

  Future<List<BookingModel>> getBookings() async {
    if (uid.isEmpty) return [];
    return _dataService.getUserBookings();
  }

  Future<List<String>> getFavoriteIds() async {
    if (uid.isEmpty) return [];
    return _dataService.getFavoriteIds(uid);
  }

  Future<void> updateUserName(BuildContext context, String newName) async {
    await authService.updateUserName(newName);
  }

  Future<void> signOut() async {
    await authService.signOut();
  }
}
