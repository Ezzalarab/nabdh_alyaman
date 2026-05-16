import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cached_location_row.dart';

/// Offline cache for locations (temporary JSON-backed store until Drift codegen is enabled).
abstract class LocationsLocalDataSource {
  Future<void> replaceStates(List<CachedLocationState> rows);

  Future<void> replaceDistricts(List<CachedLocationDistrict> rows);

  Future<List<CachedLocationState>> getStates();

  Future<List<CachedLocationDistrict>> getDistrictsForState(int stateId);

  Future<DateTime?> cacheFetchedAt(String key);

  Future<void> setCacheFetchedAt(String key, DateTime at);

  Future<void> clearLocationCache();
}

class LocationsLocalDataSourceImpl implements LocationsLocalDataSource {
  LocationsLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;

  static const _kStates = 'locations_cache_states_v1';
  static const _kDistricts = 'locations_cache_districts_v1';
  static const _kMetaPrefix = 'locations_cache_meta_';

  List<Map<String, dynamic>> _decodeList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> replaceStates(List<CachedLocationState> rows) async {
    final encoded =
        jsonEncode(rows.map((e) => e.toJson()).toList(growable: false));
    await _prefs.setString(_kStates, encoded);
  }

  @override
  Future<void> replaceDistricts(List<CachedLocationDistrict> rows) async {
    final encoded =
        jsonEncode(rows.map((e) => e.toJson()).toList(growable: false));
    await _prefs.setString(_kDistricts, encoded);
  }

  @override
  Future<List<CachedLocationState>> getStates() async {
    final raw = _prefs.getString(_kStates);
    return _decodeList(raw)
        .map(CachedLocationState.fromJson)
        .toList(growable: false);
  }

  @override
  Future<List<CachedLocationDistrict>> getDistrictsForState(int stateId) async {
    final raw = _prefs.getString(_kDistricts);
    final all = _decodeList(raw).map(CachedLocationDistrict.fromJson);
    return all.where((d) => d.stateId == stateId).toList(growable: false);
  }

  String _metaKey(String key) => '$_kMetaPrefix$key';

  @override
  Future<DateTime?> cacheFetchedAt(String key) async {
    final millis = _prefs.getInt(_metaKey(key));
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
  }

  @override
  Future<void> setCacheFetchedAt(String key, DateTime at) async {
    await _prefs.setInt(_metaKey(key), at.toUtc().millisecondsSinceEpoch);
  }

  @override
  Future<void> clearLocationCache() async {
    await _prefs.remove(_kStates);
    await _prefs.remove(_kDistricts);
    await _prefs.remove(_metaKey('locations'));
    await _prefs.remove(_metaKey('districts'));
  }
}
