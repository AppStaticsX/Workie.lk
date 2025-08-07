import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dark_mode.dart';
import 'light_mode.dart';

enum ThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  // Theme storage key
  static const String themeModeKey = 'theme_mode';

  // Current theme mode (light, dark, or system)
  ThemeMode _themeMode = ThemeMode.system;

  // Current theme data
  ThemeData _themeData = lightMode;

  // Get Current Theme Mode
  ThemeMode get themeMode => _themeMode;

  // Get Current Theme Data
  ThemeData get themeData => _themeData;

  // Check if current theme is dark
  bool get isDarkMode => _themeData == darkMode;

  // Check if system theme mode is selected
  bool get isSystemMode => _themeMode == ThemeMode.system;

  // Initialize theme provider and load saved theme
  ThemeProvider() {
    loadTheme();
  }

  // Load saved theme from SharedPreferences
  Future<void> loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedMode = prefs.getString(themeModeKey);

    // Parse saved theme mode or default to system
    switch (savedMode) {
      case 'light':
        _themeMode = ThemeMode.light;
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    _updateThemeData();
    notifyListeners();
  }

  // Save theme mode to SharedPreferences
  Future<void> _saveThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String modeString = _themeMode.toString().split('.').last;
    await prefs.setString(themeModeKey, modeString);
  }

  // Update theme data based on current mode and system brightness
  void _updateThemeData() {
    switch (_themeMode) {
      case ThemeMode.light:
        _themeData = lightMode;
        break;
      case ThemeMode.dark:
        _themeData = darkMode;
        break;
      case ThemeMode.system:
      // Get system brightness
        final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        _themeData = brightness == Brightness.dark ? darkMode : lightMode;
        break;
    }
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      _updateThemeData();
      await _saveThemeMode();
      notifyListeners();
    }
  }

  // Toggle between light, dark, and system themes
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
    }
  }

  // Update theme when system brightness changes
  void updateSystemTheme() {
    if (_themeMode == ThemeMode.system) {
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      final newThemeData = brightness == Brightness.dark ? darkMode : lightMode;

      if (_themeData != newThemeData) {
        _themeData = newThemeData;
        notifyListeners();
      }
    }
  }

  // Get theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Get appropriate icon for current theme mode
  IconData get themeIcon {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}