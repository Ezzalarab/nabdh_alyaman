/// Environment configuration for the REST API (Phase 0).
///
/// Run with e.g.:
/// `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1`
class AppConfig {
  const AppConfig();

  /// Base URL including `/api/v1` path (no trailing slash).
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
    // defaultValue: 'https://nabdh.telqaia.com/api/v1',
  );
}
