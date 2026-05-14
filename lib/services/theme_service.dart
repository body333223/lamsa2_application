import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'themeMode'; // 'system', 'light', 'dark'
  String _mode = 'system';

  String get mode => _mode;

  bool get isDarkMode => _mode == 'dark';

  ThemeMode get themeMode {
    switch (_mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = prefs.getString(_themeKey) ?? 'system';
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_mode == 'dark') {
      await setThemeMode('light');
    } else {
      await setThemeMode('dark');
    }
  }
}
