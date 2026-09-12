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
      // Solid brand-colored app bar by default so title/icon text stays
      // legible everywhere. Screens with their own decorative hero header
      // (e.g. the dashboard) explicitly override this to a transparent bar.
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.deepGreen,
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

  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.goldLight,
      onPrimary: AppColors.ink,
      primaryContainer: AppColors.deepGreenDark,
      onPrimaryContainer: Colors.white,
      secondary: AppColors.gold,
      onSecondary: AppColors.ink,
      secondaryContainer: Color(0xFF3A3216),
      onSecondaryContainer: AppColors.goldLight,
      tertiary: Color(0xFFE0918A),
      onTertiary: AppColors.ink,
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      surface: Color(0xFF14201B),
      onSurface: Color(0xFFE2E6E1),
      surfaceContainerHighest: Color(0xFF232E28),
      outline: Color(0xFF889089),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF0F1712),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.deepGreenDark,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF14201B),
        indicatorColor: AppColors.goldLight.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.goldLight : Colors.white70,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.goldLight : Colors.white70,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.goldLight,
          foregroundColor: AppColors.ink,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.gold,
        foregroundColor: AppColors.ink,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF3A3216),
        labelStyle: const TextStyle(color: AppColors.goldLight),
        side: BorderSide.none,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.goldLight, width: 2),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  /// Minimum touch target per CLAUDE.md accessibility rules (44 logical px).
  static const double minTouchTarget = 44;
}
