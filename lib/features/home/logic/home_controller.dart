import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../data/home_repository.dart';

/// State management controller for the Home feature.
/// Manages bottom navigation, services stream, sliders, and user greeting.
class HomeController extends ChangeNotifier {
  final HomeRepository _repository;

  HomeController({HomeRepository? repository})
      : _repository = repository ?? HomeRepository();

  // ── Bottom Navigation ──────────────────────────────────
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  // ── Services ───────────────────────────────────────────
  Stream<List<ServiceModel>> get servicesStream => _repository.getServices();

  Stream<List<ServiceModel>> get popularServicesStream =>
      _repository.getPopularServices();

  // ── Sliders / Promo Banners ────────────────────────────
  Stream<QuerySnapshot> get slidersStream => _repository.getActiveSliders();

  // ── Categories ─────────────────────────────────────────
  Stream<List<String>> get categoriesStream => _repository.getCategories();

  // ── User Greeting ──────────────────────────────────────
  String? _userName;
  String? get userName => _userName;
  bool _isLoadingUser = false;
  bool get isLoadingUser => _isLoadingUser;

  Future<void> loadUserData(String userId) async {
    _isLoadingUser = true;
    notifyListeners();

    try {
      final data = await _repository.getUserData(userId);
      _userName = data?['name'] as String?;
    } catch (_) {
      _userName = null;
    }

    _isLoadingUser = false;
    notifyListeners();
  }

  /// Returns a time-based greeting.
  String getGreeting({required bool isArabic}) {
    final h = DateTime.now().hour;
    if (isArabic) {
      if (h < 12) return 'صباح الجمال ☀️';
      if (h < 18) return 'مساء الأنوثة 🌸';
      return 'مساء النور ✨';
    } else {
      if (h < 12) return 'Good morning ☀️';
      if (h < 18) return 'Good afternoon 🌸';
      return 'Good evening ✨';
    }
  }
}
