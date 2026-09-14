import 'package:flutter/foundation.dart';
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'مستخدم',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String? ?? 'user',
    );
  }
}

/// Authentication service — JWT + REST API based.
/// Replaces FirebaseAuth entirely.
class AuthService extends ChangeNotifier {
  bool isLoading = false;
  UserModel? _user;

  UserModel? get currentUser => _user;
  bool get isLoggedIn => _user != null;
  String? get userId => _user?.id;

  // ── Init — restore session ────────────────────────────────
  Future<void> init() async {
    final token = await ApiService.getToken();
    if (token == null) return;

    try {
      final data = await ApiService.get('/auth/me', auth: true);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      notifyListeners();
    } catch (_) {
      // Token invalid/expired — clear it
      await ApiService.clearToken();
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
      await ApiService.post('/auth/send-otp', body: {'phone': phoneNumber});
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
      final data = await ApiService.post('/auth/verify-otp', body: {
        'phone': phone,
        'code': otp,
        if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      });

      final token = data['token'] as String;
      await ApiService.setToken(token);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
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
    } catch (_) {
      // Ignore errors — we always clear locally
    } finally {
      await ApiService.clearToken();
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
      final data = await ApiService.put('/auth/me', body: {'name': name}, auth: true);
      _user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
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
      notifyListeners();
    } catch (_) {}
  }
}
