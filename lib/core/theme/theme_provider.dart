import 'dart:ui';
import 'package:apodel_restorant/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModeOption { on, off, system }

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = lightMode;
  ThemeModeOption _themeMode = ThemeModeOption.system;

  ThemeData get themeData => _themeData;
  ThemeModeOption get themeMode => _themeMode;

  set themeMode(ThemeModeOption mode) {
    _themeMode = mode;
    _setThemeBasedOnMode();
    notifyListeners();
  }

  Future<void> _setThemeBasedOnMode() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', _themeMode.toString().split('.').last);

    if (_themeMode == ThemeModeOption.on) {
      _themeData = darkMode;
    } else if (_themeMode == ThemeModeOption.off) {
      _themeData = lightMode;
    } else {
      // Handle system theme
      final brightness = PlatformDispatcher.instance.platformBrightness;
      _themeData = brightness == Brightness.dark ? darkMode : lightMode;
    }
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getString('themeMode') ?? 'system';
    _themeMode = ThemeModeOption.values.firstWhere(
      (option) => option.toString().split('.').last == themeValue,
    );
    await _setThemeBasedOnMode();
  }
}
