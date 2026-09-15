import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// User data model for authenticated user
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final String role;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.role = 'user',
  });

  String get uid => id;
  String get displayName => name;
  String get phoneNumber => phone;
  String? get photoURL => avatarUrl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'avatar_url': avatarUrl,
        'role': role,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'مستخدم لمسة',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }
}

/// Authentication service connected directly to the live Backend REST API.
class AuthService extends ChangeNotifier {
  static const String _userPrefsKey = 'cached_user_profile';
  bool isLoading = false;
  UserModel? _user;

  UserModel? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  String? get userId => _user?.id;

  // ── Init — restore session from token & backend ────────────
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUserStr = prefs.getString(_userPrefsKey);
      if (cachedUserStr != null && cachedUserStr.isNotEmpty) {
        final userMap = jsonDecode(cachedUserStr) as Map<String, dynamic>;
        _user = UserModel.fromJson(userMap);
        notifyListeners();
      }

      final token = await ApiService.getToken();
      if (token == null) return;

      try {
        final data = await ApiService.get('/auth/me', auth: true);
        if (data['user'] != null) {
          _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
          await _saveUserLocally(_user!);
          notifyListeners();
        }
      } catch (e) {
        debugPrint('Session refresh note: $e');
      }
    } catch (e) {
      debugPrint('AuthService init error: $e');
    }
  }

  // ── Helper: Save User to SharedPreferences ────────────────
  Future<void> _saveUserLocally(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userPrefsKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('Error saving user locally: $e');
    }
  }

  // ── Helper: Remove User from SharedPreferences ────────────
  Future<void> _clearUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userPrefsKey);
    } catch (e) {
      debugPrint('Error clearing user locally: $e');
    }
  }

  // ── Send Real OTP via Live Backend ────────────────────────
  Future<void> sendOtp({
    required String phoneNumber,
    required Function() onCodeSent,
    required Function(String error) onError,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await ApiService.post('/auth/send-otp', body: {'phone': phoneNumber});
      if (res['devCode'] != null) {
        debugPrint('🔑 [BACKEND OTP RECEIVED]: ${res['devCode']}');
      }
      onCodeSent();
    } catch (e) {
      onError(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Verify Real OTP via Live Backend ──────────────────────
  Future<void> verifyOtpAndSignIn({
    required String phone,
    required String otp,
    String? name,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.post('/auth/verify-otp', body: {
        'phone': phone,
        'code': otp.trim(),
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      });

      final token = data['token'] as String;
      await ApiService.setToken(token);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _saveUserLocally(_user!);
      notifyListeners();
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      await ApiService.post('/auth/logout', auth: true);
    } catch (_) {}

    await ApiService.clearToken();
    await _clearUserLocally();
    _user = null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async => logout();

  // ── Update Name ───────────────────────────────────────────
  Future<void> updateUserName(String newName) async {
    final name = newName.trim();
    if (name.isEmpty) throw 'الاسم لا يمكن أن يكون فارغاً';

    isLoading = true;
    notifyListeners();

    try {
      final data = await ApiService.put('/auth/me', body: {'name': name}, auth: true);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _saveUserLocally(_user!);
    } catch (e) {
      if (_user != null) {
        _user = UserModel(
          id: _user!.id,
          name: name,
          phone: _user!.phone,
          email: _user!.email,
          avatarUrl: _user!.avatarUrl,
          role: _user!.role,
        );
        await _saveUserLocally(_user!);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Update Photo ──────────────────────────────────────────
  Future<void> updateUserPhoto(String photoUrl) async {
    if (_user == null) return;
    _user = UserModel(
      id: _user!.id,
      name: _user!.name,
      phone: _user!.phone,
      email: _user!.email,
      avatarUrl: photoUrl,
      role: _user!.role,
    );
    await _saveUserLocally(_user!);
    notifyListeners();
  }

  // ── Get User Data ─────────────────────────────────────────
  Future<Map<String, dynamic>?> getUserData() async {
    if (_user == null) {
      return {'uid': '', 'name': 'زائر', 'email': '', 'phone': '', 'isLoggedIn': false};
    }
    return {
      'uid': _user!.id,
      'name': _user!.name,
      'email': _user!.email ?? '',
      'phone': _user!.phone,
      'isLoggedIn': true,
    };
  }

  // ── Refresh user from server ──────────────────────────────
  Future<void> refreshUser() async {
    try {
      final data = await ApiService.get('/auth/me', auth: true);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _saveUserLocally(_user!);
      notifyListeners();
    } catch (_) {}
  }
}
