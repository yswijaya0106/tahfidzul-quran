import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_constants.dart';
import 'core/network/debug_error_log_service.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_settings.dart';
import 'core/theme/app_settings_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/debug_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (AppConstants.isDebugMode) _setupDebugErrorHooks();
  await initializeDateFormatting('id_ID');
  runApp(const ProviderScope(child: TahfidzQuranApp()));
}

void _setupDebugErrorHooks() {
  // Capture Flutter framework errors (widget build errors, layout errors, etc.)
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    DebugErrorLogService.instance.add(
      DebugErrorEntry(
        time: DateTime.now(),
        source: DebugErrorSource.flutter,
        message: details.exceptionAsString(),
        stackTrace: details.stack?.toString(),
      ),
    );
    originalOnError?.call(details); // still log to console
  };

  // Capture unhandled Dart errors (async errors outside the Flutter zone)
  PlatformDispatcher.instance.onError = (error, stack) {
    DebugErrorLogService.instance.add(
      DebugErrorEntry(
        time: DateTime.now(),
        source: DebugErrorSource.dart,
        message: error.toString(),
        stackTrace: stack.toString(),
      ),
    );
    return false; // let it propagate normally
  };
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
        child: DebugOverlay(child: child!),
      ),
    );
  }
}
