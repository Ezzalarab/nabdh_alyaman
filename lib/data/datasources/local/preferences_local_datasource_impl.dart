import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

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
}
