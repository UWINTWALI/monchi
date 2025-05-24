import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  double _fontSize = 16.0;

  static const double smallFontSize = 14.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 20.0;

  ThemeMode get themeMode => _themeMode;
  double get fontSize => _fontSize;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setFontSize(double size) {
    // Only allow specific font sizes
    if (size == smallFontSize ||
        size == mediumFontSize ||
        size == largeFontSize) {
      _fontSize = size;
      notifyListeners();
    }
  }

  TextTheme getAdjustedTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontSize: _fontSize * 2.5),
      displayMedium: base.displayMedium?.copyWith(fontSize: _fontSize * 2.0),
      displaySmall: base.displaySmall?.copyWith(fontSize: _fontSize * 1.75),
      headlineLarge: base.headlineLarge?.copyWith(fontSize: _fontSize * 1.5),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: _fontSize * 1.25),
      headlineSmall: base.headlineSmall?.copyWith(fontSize: _fontSize * 1.15),
      titleLarge: base.titleLarge?.copyWith(fontSize: _fontSize * 1.1),
      titleMedium: base.titleMedium?.copyWith(fontSize: _fontSize),
      titleSmall: base.titleSmall?.copyWith(fontSize: _fontSize * 0.9),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: _fontSize),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: _fontSize * 0.9),
      bodySmall: base.bodySmall?.copyWith(fontSize: _fontSize * 0.8),
      labelLarge: base.labelLarge?.copyWith(fontSize: _fontSize),
      labelMedium: base.labelMedium?.copyWith(fontSize: _fontSize * 0.9),
      labelSmall: base.labelSmall?.copyWith(fontSize: _fontSize * 0.8),
    );
  }
}
