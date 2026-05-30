import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/storage_keys.dart';
import 'preferences_local_datasource.dart';

class PreferencesLocalDataSourceImpl implements PreferencesLocalDataSource {
  PreferencesLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _deviceIdKey = 'x_device_id';

  @override
  Future<String> getOrCreateDeviceId() async {
    final existing = _prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final id = const Uuid().v4();
    await _prefs.setString(_deviceIdKey, id);
    return id;
  }

  @override
  Future<bool> isOnboardingDone() =>
      Future.value(_prefs.getBool(StorageKeys.onboardingDone) ?? false);

  @override
  Future<void> setOnboardingDone(bool value) =>
      _prefs.setBool(StorageKeys.onboardingDone, value);

  String _emailCompletionDismissKey(String userId) =>
      'email_completion_prompt_dismissed_$userId';

  @override
  Future<bool> isEmailCompletionPromptDismissed(String userId) async =>
      _prefs.getBool(_emailCompletionDismissKey(userId)) ?? false;

  @override
  Future<void> setEmailCompletionPromptDismissed(
    String userId,
    bool value,
  ) async =>
      _prefs.setBool(_emailCompletionDismissKey(userId), value);
}
