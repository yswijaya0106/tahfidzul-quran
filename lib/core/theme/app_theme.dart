import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Minimum touch target per CLAUDE.md accessibility rules (44 logical px).
  static const double minTouchTarget = 44;
}
