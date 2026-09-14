import 'package:flutter/material.dart';
import '../../../models/service_model.dart';
import '../data/home_repository.dart';

/// State management controller for the Home feature.
/// Uses Future-based loading (REST API) instead of Firestore streams.
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
  List<ServiceModel> _services = [];
  List<ServiceModel> get services => _services;
  bool isLoadingServices = false;
  String? servicesError;

  Future<void> loadServices({String? category}) async {
    isLoadingServices = true;
    servicesError = null;
    notifyListeners();
    try {
      _services = await _repository.getServices(category: category);
    } catch (e) {
      servicesError = e.toString();
    } finally {
      isLoadingServices = false;
      notifyListeners();
    }
  }

  // ── Popular Services ───────────────────────────────────
  List<ServiceModel> _popularServices = [];
  List<ServiceModel> get popularServices => _popularServices;
  bool isLoadingPopular = false;

  Future<void> loadPopularServices() async {
    isLoadingPopular = true;
    notifyListeners();
    try {
      _popularServices = await _repository.getPopularServices();
    } catch (_) {}
    isLoadingPopular = false;
    notifyListeners();
  }

  // ── Sliders ────────────────────────────────────────────
  List<Map<String, dynamic>> _sliders = [];
  List<Map<String, dynamic>> get sliders => _sliders;

  Future<void> loadSliders() async {
    try {
      _sliders = await _repository.getSliders();
      notifyListeners();
    } catch (_) {}
  }

  // ── Categories ─────────────────────────────────────────
  List<String> _categories = [];
  List<String> get categories => _categories;

  Future<void> loadCategories() async {
    try {
      _categories = await _repository.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  // ── Load All Home Data ─────────────────────────────────
  Future<void> loadAll() async {
    await Future.wait([
      loadPopularServices(),
      loadSliders(),
      loadCategories(),
      loadServices(),
    ]);
  }

  // ── User Greeting ──────────────────────────────────────
  String? _userName;
  String? get userName => _userName;
  bool isLoadingUser = false;

  Future<void> loadUserData(String userId) async {
    isLoadingUser = true;
    notifyListeners();
    try {
      final data = await _repository.getUserData(userId);
      _userName = data?['name'] as String?;
    } catch (_) {
      _userName = null;
    }
    isLoadingUser = false;
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
