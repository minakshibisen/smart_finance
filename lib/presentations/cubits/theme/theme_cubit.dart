import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  static const String _themeKey = 'theme_mode';

  // Load saved theme
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;

    switch (themeIndex) {
      case 0:
        emit(ThemeMode.light);
        break;
      case 1:
        emit(ThemeMode.dark);
        break;
      case 2:
        emit(ThemeMode.system);
        break;
    }
  }

  // Toggle theme
  Future<void> toggleTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    int themeIndex = 0;
    switch (mode) {
      case ThemeMode.light:
        themeIndex = 0;
        break;
      case ThemeMode.dark:
        themeIndex = 1;
        break;
      case ThemeMode.system:
        themeIndex = 2;
        break;
    }

    await prefs.setInt(_themeKey, themeIndex);
    emit(mode);
  }

  // Get current theme name
  String getThemeName() {
    switch (state) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}