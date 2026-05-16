// Drift schema (run codegen locally):
//   dart run build_runner build --delete-conflicting-outputs
//
// Tables: CachedStates(stateId, nameAr), CachedDistricts(districtId, stateId, nameAr)
//
// Until [app_database.g.dart] exists, locations cache uses SharedPreferences via
// [LocationsLocalDataSourceImpl].
