import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isLoading = false;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Email/Password ────────────────────────────────────

  Future<void> loginWithEmailPassword(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (_) {
      throw 'حدث خطأ غير متوقع أثناء تسجيل الدخول';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerWithEmailPassword(
    String email,
    String password, {
    String? name,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (name != null && name.trim().isNotEmpty) {
        await credential.user?.updateDisplayName(name.trim());
        await credential.user?.reload();
      }
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (_) {
      throw 'حدث خطأ غير متوقع أثناء إنشاء الحساب';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Google Sign-In ────────────────────────────────────

  Future<void> signInWithGoogle() async {
    isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // المستخدم ألغى عملية تسجيل الدخول
        isLoading = false;
        notifyListeners();
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      throw 'حدث خطأ أثناء تسجيل الدخول بـ Google';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Apple Sign-In ─────────────────────────────────────

  Future<void> signInWithApple() async {
    isLoading = true;
    notifyListeners();

    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final nonce = _sha256ofString(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      // Apple only provides name on first sign-in, so save it
      if (appleCredential.givenName != null) {
        final displayName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (displayName.isNotEmpty) {
          await userCredential.user?.updateDisplayName(displayName);
          await userCredential.user?.reload();
        }
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        // المستخدم ألغى
        isLoading = false;
        notifyListeners();
        return;
      }
      throw 'حدث خطأ أثناء تسجيل الدخول بـ Apple';
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (e) {
      throw 'حدث خطأ أثناء تسجيل الدخول بـ Apple';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Phone Auth ──────────────────────────────────────────

  String? _verificationId;
  int? _resendToken;

  String? get verificationId => _verificationId;

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerified,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          if (onAutoVerified != null) {
            onAutoVerified(credential);
          } else {
            await _auth.signInWithCredential(credential);
            isLoading = false;
            notifyListeners();
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading = false;
          notifyListeners();
          onError(_mapPhoneAuthError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          isLoading = false;
          notifyListeners();
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      isLoading = false;
      notifyListeners();
      onError('حدث خطأ أثناء إرسال رمز التحقق');
    }
  }

  Future<void> verifyOtpAndSignIn({
    required String otp,
    String? name,
  }) async {
    if (_verificationId == null) {
      throw 'لم يتم إرسال رمز التحقق بعد';
    }

    isLoading = true;
    notifyListeners();

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Set display name if provided (first time registration)
      if (name != null && name.trim().isNotEmpty) {
        await userCredential.user?.updateDisplayName(name.trim());
        await userCredential.user?.reload();
      }
    } on FirebaseAuthException catch (e) {
      throw _mapPhoneAuthError(e);
    } catch (_) {
      throw 'حدث خطأ أثناء التحقق من الرمز';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _mapPhoneAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صحيح';
      case 'too-many-requests':
        return 'تمت محاولات كثيرة، حاولي لاحقًا';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح';
      case 'session-expired':
        return 'انتهت صلاحية الرمز، أعيدي الإرسال';
      case 'quota-exceeded':
        return 'تم تجاوز الحد المسموح، حاولي لاحقًا';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      default:
        return e.message ?? 'حدث خطأ في التحقق';
    }
  }

  // ── Logout ────────────────────────────────────────────

  Future<void> logout() async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. مسح الـ FCM token من Firestore قبل الـ signOut
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .update({'fcmToken': FieldValue.delete()});
      }

      // 2. مسح الـ token من الجهاز
      await FirebaseMessaging.instance.deleteToken();

      // 3. Sign out
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {
      throw 'تعذر تسجيل الخروج';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await logout();
  }

  // ── User Data ─────────────────────────────────────────

  Future<Map<String, dynamic>?> getUserData() async {
    final user = _auth.currentUser;

    if (user == null) {
      return {
        'uid': '',
        'name': 'زائر',
        'email': '',
        'phone': '',
        'isLoggedIn': false,
      };
    }

    await user.reload();
    final refreshedUser = _auth.currentUser;

    return {
      'uid': refreshedUser?.uid ?? '',
      'name': (refreshedUser?.displayName != null &&
              refreshedUser!.displayName!.trim().isNotEmpty)
          ? refreshedUser.displayName!.trim()
          : 'مستخدم',
      'email': refreshedUser?.email ?? '',
      'phone': refreshedUser?.phoneNumber ?? '',
      'isLoggedIn': true,
    };
  }

  Future<void> updateUserName(String newName) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw 'لا يوجد مستخدم مسجل حاليًا';
    }

    final name = newName.trim();
    if (name.isEmpty) {
      throw 'الاسم لا يمكن أن يكون فارغًا';
    }

    isLoading = true;
    notifyListeners();

    try {
      await user.updateDisplayName(name);
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthError(e);
    } catch (_) {
      throw 'تعذر تحديث الاسم';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserPhoto(String photoUrl) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.updatePhotoURL(photoUrl);
      await user.reload();
      notifyListeners();
    } catch (_) {
      // Silently fail — photo is optional
    }
  }

  // ── Helpers ───────────────────────────────────────────

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح';
      case 'user-not-found':
        return 'هذا الحساب غير موجود';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جدًا';
      case 'invalid-credential':
        return 'بيانات تسجيل الدخول غير صحيحة';
      case 'network-request-failed':
        return 'تحقق من اتصال الإنترنت';
      case 'too-many-requests':
        return 'تمت محاولات كثيرة، حاولي لاحقًا';
      case 'account-exists-with-different-credential':
        return 'هذا الحساب مسجل بطريقة أخرى';
      default:
        return e.message ?? 'حدث خطأ في المصادقة';
    }
  }
}
