/// Runtime configuration for the API base URL. Override at build/run time
/// with `--dart-define=API_BASE_URL=https://api.example.com/api/v1`.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );
}
