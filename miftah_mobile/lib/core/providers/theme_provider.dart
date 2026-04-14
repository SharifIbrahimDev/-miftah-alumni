import 'package:flutter/material.dart';
import '../utils/shared_prefs_manager.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'isDarkMode';
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    SharedPrefsManager.setBool(_themeKey, _isDarkMode);
    notifyListeners();
  }

  void _loadTheme() {
    _isDarkMode = SharedPrefsManager.getBool(_themeKey) ?? false;
    notifyListeners();
  }
}
