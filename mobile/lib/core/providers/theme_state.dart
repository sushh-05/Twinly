import 'package:flutter/material.dart';

class ThemeModeState extends ChangeNotifier {
  ThemeMode mode = ThemeMode.dark;

  bool get isDarkMode => mode == ThemeMode.dark;

  void toggle() {
    mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    this.mode = mode;
    notifyListeners();
  }
}
