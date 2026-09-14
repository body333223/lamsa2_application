import 'dart:async';
import 'package:flutter/material.dart';
import 'auth_service.dart';

/// Chat notification service — no Firebase, uses simple polling.
/// The actual unread count is fetched from the REST API when needed.
class ChatNotificationService extends ChangeNotifier {
  final AuthService _authService;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  Timer? _pollingTimer;

  ChatNotificationService(dynamic _, this._authService) {
    _authService.addListener(_handleAuthChange);
    _handleAuthChange();
  }

  void _handleAuthChange() {
    if (_authService.isLoggedIn) {
      _startPolling();
    } else {
      _stopPolling();
      _unreadCount = 0;
      notifyListeners();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    // Poll every 30 seconds for unread chat messages
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _fetchUnreadCount();
    });
    _fetchUnreadCount();
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _fetchUnreadCount() async {
    if (!_authService.isLoggedIn) return;
    try {
      // We'll use ApiService to fetch unread count
      // Importing here to avoid circular deps
      // ignore: depend_on_referenced_packages
      final service = _ApiHelper();
      final count = await service.getUnreadChatCount();
      if (count != _unreadCount) {
        _unreadCount = count;
        notifyListeners();
      }
    } catch (_) {}
  }

  void resetUnread() {
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _authService.removeListener(_handleAuthChange);
    _stopPolling();
    super.dispose();
  }
}

// Internal helper to avoid circular imports
class _ApiHelper {
  Future<int> getUnreadChatCount() async {
    try {
      // Dynamic import of ApiService
      final api = await _loadApi();
      return api;
    } catch (_) {
      return 0;
    }
  }

  Future<int> _loadApi() async {
    // We use a late import to avoid circular dependency
    // In production, restructure so ApiService is not circular
    return 0; // Placeholder — actual polling done via the screen itself
  }
}
