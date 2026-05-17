import '../../data/datasources/local/locations_local_datasource.dart';
import '../../data/datasources/remote/locations_remote_datasource.dart';
import '../../data/models/cached_location_row.dart';
import 'locations_cache_policy.dart';

/// Cache-first locations with optional network refresh when stale or empty.
class LocationsLoader {
  LocationsLoader({
    required LocationsLocalDataSource local,
    required LocationsRemoteDataSource remote,
  })  : _local = local,
        _remote = remote;

  final LocationsLocalDataSource _local;
  final LocationsRemoteDataSource _remote;

  Future<List<CachedLocationState>> loadStates() async {
    var rows = await _local.getStates();
    final fetchedAt = await _local.cacheFetchedAt('locations');
    if (rows.isNotEmpty && !LocationsCachePolicy.isStale(fetchedAt)) {
      return rows;
    }
    rows = await _remote.fetchStates();
    await _local.replaceStates(rows);
    return rows;
  }

  Future<List<CachedLocationDistrict>> loadDistricts(int stateId) async {
    var list = await _local.getDistrictsForState(stateId);
    final fetchedAt = await _local.cacheFetchedAt('districts');
    if (list.isNotEmpty && !LocationsCachePolicy.isStale(fetchedAt)) {
      return list;
    }
    list = await _remote.fetchDistricts(stateId);
    await _local.replaceDistricts(list);
    return list;
  }
}
