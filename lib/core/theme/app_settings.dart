import 'package:flutter/material.dart';

/// User's theme preference. [system] follows the device setting.
enum AppThemeMode { system, light, dark }

extension AppThemeModeX on AppThemeMode {
  ThemeMode toFlutter() => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };

  String get label => switch (this) {
    AppThemeMode.system => 'Ikuti Sistem',
    AppThemeMode.light => 'Terang',
    AppThemeMode.dark => 'Gelap',
  };
}

AppThemeMode appThemeModeFromName(String? name) => AppThemeMode.values.firstWhere(
  (mode) => mode.name == name,
  orElse: () => AppThemeMode.system,
);

/// Font size preference, applied as a text-scale multiplier app-wide.
enum AppFontScale { small, medium, large, extraLarge }

extension AppFontScaleX on AppFontScale {
  double get scaleFactor => switch (this) {
    AppFontScale.small => 0.9,
    AppFontScale.medium => 1.0,
    AppFontScale.large => 1.15,
    AppFontScale.extraLarge => 1.3,
  };

  String get label => switch (this) {
    AppFontScale.small => 'Kecil',
    AppFontScale.medium => 'Sedang',
    AppFontScale.large => 'Besar',
    AppFontScale.extraLarge => 'Sangat Besar',
  };
}

AppFontScale appFontScaleFromName(String? name) => AppFontScale.values.firstWhere(
  (scale) => scale.name == name,
  orElse: () => AppFontScale.medium,
);

class AppSettings {
  final AppThemeMode themeMode;
  final AppFontScale fontScale;

  const AppSettings({required this.themeMode, required this.fontScale});

  static const defaults = AppSettings(
    themeMode: AppThemeMode.system,
    fontScale: AppFontScale.medium,
  );

  AppSettings copyWith({AppThemeMode? themeMode, AppFontScale? fontScale}) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        fontScale: fontScale ?? this.fontScale,
      );
}
