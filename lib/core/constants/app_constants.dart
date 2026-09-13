class AppConstants {
  AppConstants._();

  /// Enables the floating debug overlay that captures and displays API
  /// traffic and app errors. Enable with `--dart-define=DEBUG_MODE=true`.
  static const bool isDebugMode = bool.fromEnvironment(
    'DEBUG_MODE',
    defaultValue: false,
  );

  /// Set to false to hide the Authorization header from the debug log panel
  /// and its copy-all text.
  static const bool debugShowAuthHeader = bool.fromEnvironment(
    'DEBUG_SHOW_AUTH_HEADER',
    defaultValue: false,
  );
}
