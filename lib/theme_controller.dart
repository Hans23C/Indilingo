import 'package:flutter/material.dart';

class AppThemeController {
  const AppThemeController._();

  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  static void setDarkMode(bool value) {
    isDarkMode.value = value;
  }
}
