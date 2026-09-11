import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.deepGreen,
      onPrimary: Colors.white,
      primaryContainer: AppColors.deepGreenDark,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.goldLight,
      onSecondaryContainer: AppColors.ink,
      tertiary: AppColors.maroon,
      onTertiary: Colors.white,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: AppColors.ink,
      surfaceContainerHighest: Color(0xFFF0EDE4),
      outline: Color(0xFFBFC7C1),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.goldLight.withValues(alpha: 0.55),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? AppColors.deepGreen
                : AppColors.ink.withValues(alpha: 0.6),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected
                ? AppColors.deepGreen
                : AppColors.ink.withValues(alpha: 0.55),
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.deepGreen,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.ink,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.goldLight.withValues(alpha: 0.4),
        labelStyle: const TextStyle(color: AppColors.ink),
        side: BorderSide.none,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.deepGreen, width: 2),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Minimum touch target per CLAUDE.md accessibility rules (44 logical px).
  static const double minTouchTarget = 44;
}
