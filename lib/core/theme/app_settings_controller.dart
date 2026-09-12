import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

const _themeModeKey = 'settings.themeMode';
const _fontScaleKey = 'settings.fontScale';

/// Persists theme/font preferences to on-device storage (SharedPreferences)
/// so they survive app restarts. Per-device only, not synced to the account.
class AppSettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return AppSettings(
      themeMode: appThemeModeFromName(prefs.getString(_themeModeKey)),
      fontScale: appFontScaleFromName(prefs.getString(_fontScaleKey)),
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    final current = state.valueOrNull ?? AppSettings.defaults;
    state = AsyncData(current.copyWith(themeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode.name);
  }

  Future<void> setFontScale(AppFontScale scale) async {
    final current = state.valueOrNull ?? AppSettings.defaults;
    state = AsyncData(current.copyWith(fontScale: scale));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontScaleKey, scale.name);
  }
}

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );
