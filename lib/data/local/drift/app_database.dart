import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class CachedStates extends Table {
  IntColumn get stateId => integer()();
  TextColumn get nameAr => text()();

  @override
  Set<Column<Object>> get primaryKey => {stateId};
}

class CachedDistricts extends Table {
  IntColumn get districtId => integer()();
  IntColumn get stateId => integer()();
  TextColumn get nameAr => text()();

  @override
  Set<Column<Object>> get primaryKey => {districtId};
}

class CacheMeta extends Table {
  TextColumn get key => text()();
  IntColumn get fetchedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(tables: [CachedStates, CachedDistricts, CacheMeta])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'nabdh_locations'));

  @override
  int get schemaVersion => 1;
}
