/// Small non-sensitive preferences (device id, onboarding flags, etc.).
abstract class PreferencesLocalDataSource {
  /// Stable per-install UUID for [x-device-id] header.
  Future<String> getOrCreateDeviceId();
}
