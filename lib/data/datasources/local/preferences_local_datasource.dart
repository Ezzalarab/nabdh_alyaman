/// Small non-sensitive preferences (device id, onboarding flags, etc.).
abstract class PreferencesLocalDataSource {
  /// Stable per-install UUID for [x-device-id] header.
  Future<String> getOrCreateDeviceId();

  Future<bool> isOnboardingDone();

  Future<void> setOnboardingDone(bool value);

  Future<bool> isEmailCompletionPromptDismissed(String userId);

  Future<void> setEmailCompletionPromptDismissed(String userId, bool value);
}
