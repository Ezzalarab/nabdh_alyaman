import 'package:nabdh_alyaman/data/datasources/local/preferences_local_datasource.dart';

class FakePreferences implements PreferencesLocalDataSource {
  final Map<String, bool> _emailDismissed = {};

  @override
  Future<String> getOrCreateDeviceId() async => 'test-device-id';

  @override
  Future<bool> isOnboardingDone() async => true;

  @override
  Future<void> setOnboardingDone(bool value) async {}

  @override
  Future<bool> isEmailCompletionPromptDismissed(String userId) async =>
      _emailDismissed[userId] ?? false;

  @override
  Future<void> setEmailCompletionPromptDismissed(
    String userId,
    bool value,
  ) async {
    _emailDismissed[userId] = value;
  }
}
