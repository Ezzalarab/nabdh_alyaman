import 'package:drift/drift.dart';

import '../../local/drift/app_database.dart';
import '../../models/cached_location_row.dart';

/// Offline cache for locations (Drift SQLite).
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
  LocationsLocalDataSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<void> replaceStates(List<CachedLocationState> rows) async {
    await _db.transaction(() async {
      await _db.delete(_db.cachedStates).go();
      if (rows.isNotEmpty) {
        await _db.batch((batch) {
          batch.insertAll(
            _db.cachedStates,
            rows
                .map(
                  (r) => CachedStatesCompanion.insert(
                    stateId: Value(r.stateId),
                    nameAr: r.nameAr,
                  ),
                )
                .toList(growable: false),
          );
        });
      }
    });
    await setCacheFetchedAt('locations', DateTime.now().toUtc());
  }

  @override
  Future<void> replaceDistricts(List<CachedLocationDistrict> rows) async {
    if (rows.isEmpty) return;
    final stateIds = rows.map((r) => r.stateId).toSet();
    await _db.transaction(() async {
      for (final sid in stateIds) {
        await (_db.delete(_db.cachedDistricts)
              ..where((t) => t.stateId.equals(sid)))
            .go();
      }
      await _db.batch((batch) {
        batch.insertAll(
          _db.cachedDistricts,
          rows
              .map(
                (r) => CachedDistrictsCompanion.insert(
                  districtId: Value(r.districtId),
                  stateId: r.stateId,
                  nameAr: r.nameAr,
                ),
              )
              .toList(growable: false),
        );
      });
    });
    await setCacheFetchedAt('districts', DateTime.now().toUtc());
  }

  @override
  Future<List<CachedLocationState>> getStates() async {
    final rows = await _db.select(_db.cachedStates).get();
    return rows
        .map((r) => CachedLocationState(stateId: r.stateId, nameAr: r.nameAr))
        .toList(growable: false);
  }

  @override
  Future<List<CachedLocationDistrict>> getDistrictsForState(int stateId) async {
    final query = _db.select(_db.cachedDistricts)
      ..where((t) => t.stateId.equals(stateId));
    final rows = await query.get();
    return rows
        .map(
          (r) => CachedLocationDistrict(
            districtId: r.districtId,
            stateId: r.stateId,
            nameAr: r.nameAr,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<DateTime?> cacheFetchedAt(String key) async {
    final row = await (_db.select(_db.cacheMeta)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    if (row == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(row.fetchedAtMillis, isUtc: true);
  }

  @override
  Future<void> setCacheFetchedAt(String key, DateTime at) async {
    await _db.into(_db.cacheMeta).insertOnConflictUpdate(
          CacheMetaCompanion.insert(
            key: key,
            fetchedAtMillis: at.toUtc().millisecondsSinceEpoch,
          ),
        );
  }

  @override
  Future<void> clearLocationCache() async {
    await _db.transaction(() async {
      await _db.delete(_db.cachedStates).go();
      await _db.delete(_db.cachedDistricts).go();
      await _db.delete(_db.cacheMeta).go();
    });
  }
}
