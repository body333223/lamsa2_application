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

/// Authentication service — supports offline/mock and JWT + REST API.
class AuthService extends ChangeNotifier {
  static const String _userPrefsKey = 'cached_user_profile';
  bool isLoading = false;
  UserModel? _user;

  UserModel? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  String? get userId => _user?.id;

  // ── Init — restore session ────────────────────────────────
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
      } catch (_) {
        // Backend offline or token invalid - keep cached user for offline mode
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

  // ── Send OTP ──────────────────────────────────────────────
  Future<void> sendOtp({
    required String phoneNumber,
    required Function() onCodeSent,
    required Function(String error) onError,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      // Try backend if available
      try {
        await ApiService.post('/auth/send-otp', body: {'phone': phoneNumber});
      } catch (_) {
        // Backend offline - simulate delay for mock OTP
        await Future.delayed(const Duration(milliseconds: 300));
      }
      onCodeSent();
    } catch (e) {
      onError(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Verify OTP ────────────────────────────────────────────
  Future<void> verifyOtpAndSignIn({
    required String phone,
    required String otp,
    String? name,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      // Try backend first if available
      try {
        final data = await ApiService.post('/auth/verify-otp', body: {
          'phone': phone,
          'code': otp,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
        });

        final token = data['token'] as String;
        await ApiService.setToken(token);
        _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        await _saveUserLocally(_user!);
        return;
      } catch (_) {
        // Backend is offline / unreachable: Fallback to Mock Auth
      }

      // Offline Mock Sign-In logic
      await Future.delayed(const Duration(milliseconds: 400));
      final cleanDigits = phone.replaceAll(RegExp(r'\D'), '');
      final generatedId = 'user_${cleanDigits.isNotEmpty ? cleanDigits : DateTime.now().millisecondsSinceEpoch}';
      final displayName = (name != null && name.trim().isNotEmpty) ? name.trim() : 'مستخدم لمسة';

      final mockUser = UserModel(
        id: generatedId,
        name: displayName,
        phone: phone,
        role: 'user',
      );

      final mockToken = 'mock_jwt_token_${DateTime.now().millisecondsSinceEpoch}';
      await ApiService.setToken(mockToken);
      await _saveUserLocally(mockUser);

      _user = mockUser;
    } catch (e) {
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Quick Demo Login ──────────────────────────────────────
  Future<void> loginAsGuestOrDemo({String phone = '+966500000000', String name = 'عميلة لمسة'}) async {
    await verifyOtpAndSignIn(phone: phone, otp: '123456', name: name);
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      await ApiService.post('/auth/logout', auth: true);
    } catch (_) {
      // Ignore network errors on logout
    } finally {
      await ApiService.clearToken();
      await _clearUserLocally();
      _user = null;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async => logout();

  // ── Update Name ───────────────────────────────────────────
  Future<void> updateUserName(String newName) async {
    final name = newName.trim();
    if (name.isEmpty) throw 'الاسم لا يمكن أن يكون فارغاً';

    isLoading = true;
    notifyListeners();

    try {
      try {
        final data = await ApiService.put('/auth/me', body: {'name': name}, auth: true);
        _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      } catch (_) {
        // Backend offline: update locally
        if (_user != null) {
          _user = UserModel(
            id: _user!.id,
            name: name,
            phone: _user!.phone,
            email: _user!.email,
            avatarUrl: _user!.avatarUrl,
            role: _user!.role,
          );
        }
      }
      if (_user != null) {
        await _saveUserLocally(_user!);
      }
    } catch (e) {
      rethrow;
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
