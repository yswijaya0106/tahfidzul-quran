import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_settings.dart';
import 'core/theme/app_settings_controller.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: TahfidzQuranApp()));
}

class TahfidzQuranApp extends ConsumerWidget {
  const TahfidzQuranApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final settings = ref.watch(appSettingsProvider).valueOrNull ?? AppSettings.defaults;

    return MaterialApp.router(
      title: 'Program 300 Hari Tahfidzul Quran',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode.toFlutter(),
      routerConfig: router,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(settings.fontScale.scaleFactor),
        ),
        child: child!,
      ),
    );
  }
}
