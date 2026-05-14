import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected;

  bool get isConnected => _isConnected;

  /// Creates the service. Pass initial connectivity status from main().
  ConnectivityService({bool initiallyConnected = true})
      : _isConnected = initiallyConnected {
    _listenToChanges();
  }

  void _listenToChanges() {
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> result) {
    final connected = result.any((r) => r != ConnectivityResult.none);
    if (_isConnected != connected) {
      _isConnected = connected;
      notifyListeners();
    }
  }

  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final connected = result.any((r) => r != ConnectivityResult.none);
      if (_isConnected != connected) {
        _isConnected = connected;
        notifyListeners();
      }
      return connected;
    } catch (e) {
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  /// Static helper to check connectivity before creating the service
  static Future<bool> checkInitialConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result.any((r) => r != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
