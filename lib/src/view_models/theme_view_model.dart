import 'package:flutter/material.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;

  void setThemeMode(ThemeMode themeMode) {
    this.themeMode = themeMode;
    notifyListeners();
  }
}
