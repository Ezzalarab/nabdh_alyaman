// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CachedStatesTable extends CachedStates
    with TableInfo<$CachedStatesTable, CachedState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _stateIdMeta = const VerificationMeta(
    'stateId',
  );
  @override
  late final GeneratedColumn<int> stateId = GeneratedColumn<int>(
    'state_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
    'name_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [stateId, nameAr];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('state_id')) {
      context.handle(
        _stateIdMeta,
        stateId.isAcceptableOrUnknown(data['state_id']!, _stateIdMeta),
      );
    }
    if (data.containsKey('name_ar')) {
      context.handle(
        _nameArMeta,
        nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {stateId};
  @override
  CachedState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedState(
      stateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state_id'],
      )!,
      nameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ar'],
      )!,
    );
  }

  @override
  $CachedStatesTable createAlias(String alias) {
    return $CachedStatesTable(attachedDatabase, alias);
  }
}

class CachedState extends DataClass implements Insertable<CachedState> {
  final int stateId;
  final String nameAr;
  const CachedState({required this.stateId, required this.nameAr});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['state_id'] = Variable<int>(stateId);
    map['name_ar'] = Variable<String>(nameAr);
    return map;
  }

  CachedStatesCompanion toCompanion(bool nullToAbsent) {
    return CachedStatesCompanion(
      stateId: Value(stateId),
      nameAr: Value(nameAr),
    );
  }

  factory CachedState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedState(
      stateId: serializer.fromJson<int>(json['stateId']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stateId': serializer.toJson<int>(stateId),
      'nameAr': serializer.toJson<String>(nameAr),
    };
  }

  CachedState copyWith({int? stateId, String? nameAr}) => CachedState(
    stateId: stateId ?? this.stateId,
    nameAr: nameAr ?? this.nameAr,
  );
  CachedState copyWithCompanion(CachedStatesCompanion data) {
    return CachedState(
      stateId: data.stateId.present ? data.stateId.value : this.stateId,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedState(')
          ..write('stateId: $stateId, ')
          ..write('nameAr: $nameAr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(stateId, nameAr);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedState &&
          other.stateId == this.stateId &&
          other.nameAr == this.nameAr);
}

class CachedStatesCompanion extends UpdateCompanion<CachedState> {
  final Value<int> stateId;
  final Value<String> nameAr;
  const CachedStatesCompanion({
    this.stateId = const Value.absent(),
    this.nameAr = const Value.absent(),
  });
  CachedStatesCompanion.insert({
    this.stateId = const Value.absent(),
    required String nameAr,
  }) : nameAr = Value(nameAr);
  static Insertable<CachedState> custom({
    Expression<int>? stateId,
    Expression<String>? nameAr,
  }) {
    return RawValuesInsertable({
      if (stateId != null) 'state_id': stateId,
      if (nameAr != null) 'name_ar': nameAr,
    });
  }

  CachedStatesCompanion copyWith({Value<int>? stateId, Value<String>? nameAr}) {
    return CachedStatesCompanion(
      stateId: stateId ?? this.stateId,
      nameAr: nameAr ?? this.nameAr,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (stateId.present) {
      map['state_id'] = Variable<int>(stateId.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedStatesCompanion(')
          ..write('stateId: $stateId, ')
          ..write('nameAr: $nameAr')
          ..write(')'))
        .toString();
  }
}

class $CachedDistrictsTable extends CachedDistricts
    with TableInfo<$CachedDistrictsTable, CachedDistrict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedDistrictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _districtIdMeta = const VerificationMeta(
    'districtId',
  );
  @override
  late final GeneratedColumn<int> districtId = GeneratedColumn<int>(
    'district_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateIdMeta = const VerificationMeta(
    'stateId',
  );
  @override
  late final GeneratedColumn<int> stateId = GeneratedColumn<int>(
    'state_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
    'name_ar',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [districtId, stateId, nameAr];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_districts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedDistrict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('district_id')) {
      context.handle(
        _districtIdMeta,
        districtId.isAcceptableOrUnknown(data['district_id']!, _districtIdMeta),
      );
    }
    if (data.containsKey('state_id')) {
      context.handle(
        _stateIdMeta,
        stateId.isAcceptableOrUnknown(data['state_id']!, _stateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_stateIdMeta);
    }
    if (data.containsKey('name_ar')) {
      context.handle(
        _nameArMeta,
        nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta),
      );
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {districtId};
  @override
  CachedDistrict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedDistrict(
      districtId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}district_id'],
      )!,
      stateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state_id'],
      )!,
      nameAr: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_ar'],
      )!,
    );
  }

  @override
  $CachedDistrictsTable createAlias(String alias) {
    return $CachedDistrictsTable(attachedDatabase, alias);
  }
}

class CachedDistrict extends DataClass implements Insertable<CachedDistrict> {
  final int districtId;
  final int stateId;
  final String nameAr;
  const CachedDistrict({
    required this.districtId,
    required this.stateId,
    required this.nameAr,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['district_id'] = Variable<int>(districtId);
    map['state_id'] = Variable<int>(stateId);
    map['name_ar'] = Variable<String>(nameAr);
    return map;
  }

  CachedDistrictsCompanion toCompanion(bool nullToAbsent) {
    return CachedDistrictsCompanion(
      districtId: Value(districtId),
      stateId: Value(stateId),
      nameAr: Value(nameAr),
    );
  }

  factory CachedDistrict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedDistrict(
      districtId: serializer.fromJson<int>(json['districtId']),
      stateId: serializer.fromJson<int>(json['stateId']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'districtId': serializer.toJson<int>(districtId),
      'stateId': serializer.toJson<int>(stateId),
      'nameAr': serializer.toJson<String>(nameAr),
    };
  }

  CachedDistrict copyWith({int? districtId, int? stateId, String? nameAr}) =>
      CachedDistrict(
        districtId: districtId ?? this.districtId,
        stateId: stateId ?? this.stateId,
        nameAr: nameAr ?? this.nameAr,
      );
  CachedDistrict copyWithCompanion(CachedDistrictsCompanion data) {
    return CachedDistrict(
      districtId: data.districtId.present
          ? data.districtId.value
          : this.districtId,
      stateId: data.stateId.present ? data.stateId.value : this.stateId,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedDistrict(')
          ..write('districtId: $districtId, ')
          ..write('stateId: $stateId, ')
          ..write('nameAr: $nameAr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(districtId, stateId, nameAr);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedDistrict &&
          other.districtId == this.districtId &&
          other.stateId == this.stateId &&
          other.nameAr == this.nameAr);
}

class CachedDistrictsCompanion extends UpdateCompanion<CachedDistrict> {
  final Value<int> districtId;
  final Value<int> stateId;
  final Value<String> nameAr;
  const CachedDistrictsCompanion({
    this.districtId = const Value.absent(),
    this.stateId = const Value.absent(),
    this.nameAr = const Value.absent(),
  });
  CachedDistrictsCompanion.insert({
    this.districtId = const Value.absent(),
    required int stateId,
    required String nameAr,
  }) : stateId = Value(stateId),
       nameAr = Value(nameAr);
  static Insertable<CachedDistrict> custom({
    Expression<int>? districtId,
    Expression<int>? stateId,
    Expression<String>? nameAr,
  }) {
    return RawValuesInsertable({
      if (districtId != null) 'district_id': districtId,
      if (stateId != null) 'state_id': stateId,
      if (nameAr != null) 'name_ar': nameAr,
    });
  }

  CachedDistrictsCompanion copyWith({
    Value<int>? districtId,
    Value<int>? stateId,
    Value<String>? nameAr,
  }) {
    return CachedDistrictsCompanion(
      districtId: districtId ?? this.districtId,
      stateId: stateId ?? this.stateId,
      nameAr: nameAr ?? this.nameAr,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (districtId.present) {
      map['district_id'] = Variable<int>(districtId.value);
    }
    if (stateId.present) {
      map['state_id'] = Variable<int>(stateId.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedDistrictsCompanion(')
          ..write('districtId: $districtId, ')
          ..write('stateId: $stateId, ')
          ..write('nameAr: $nameAr')
          ..write(')'))
        .toString();
  }
}

class $CacheMetaTable extends CacheMeta
    with TableInfo<$CacheMetaTable, CacheMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CacheMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMillisMeta = const VerificationMeta(
    'fetchedAtMillis',
  );
  @override
  late final GeneratedColumn<int> fetchedAtMillis = GeneratedColumn<int>(
    'fetched_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, fetchedAtMillis];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cache_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<CacheMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('fetched_at_millis')) {
      context.handle(
        _fetchedAtMillisMeta,
        fetchedAtMillis.isAcceptableOrUnknown(
          data['fetched_at_millis']!,
          _fetchedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  CacheMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CacheMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      fetchedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at_millis'],
      )!,
    );
  }

  @override
  $CacheMetaTable createAlias(String alias) {
    return $CacheMetaTable(attachedDatabase, alias);
  }
}

class CacheMetaData extends DataClass implements Insertable<CacheMetaData> {
  final String key;
  final int fetchedAtMillis;
  const CacheMetaData({required this.key, required this.fetchedAtMillis});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['fetched_at_millis'] = Variable<int>(fetchedAtMillis);
    return map;
  }

  CacheMetaCompanion toCompanion(bool nullToAbsent) {
    return CacheMetaCompanion(
      key: Value(key),
      fetchedAtMillis: Value(fetchedAtMillis),
    );
  }

  factory CacheMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CacheMetaData(
      key: serializer.fromJson<String>(json['key']),
      fetchedAtMillis: serializer.fromJson<int>(json['fetchedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'fetchedAtMillis': serializer.toJson<int>(fetchedAtMillis),
    };
  }

  CacheMetaData copyWith({String? key, int? fetchedAtMillis}) => CacheMetaData(
    key: key ?? this.key,
    fetchedAtMillis: fetchedAtMillis ?? this.fetchedAtMillis,
  );
  CacheMetaData copyWithCompanion(CacheMetaCompanion data) {
    return CacheMetaData(
      key: data.key.present ? data.key.value : this.key,
      fetchedAtMillis: data.fetchedAtMillis.present
          ? data.fetchedAtMillis.value
          : this.fetchedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CacheMetaData(')
          ..write('key: $key, ')
          ..write('fetchedAtMillis: $fetchedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, fetchedAtMillis);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CacheMetaData &&
          other.key == this.key &&
          other.fetchedAtMillis == this.fetchedAtMillis);
}

class CacheMetaCompanion extends UpdateCompanion<CacheMetaData> {
  final Value<String> key;
  final Value<int> fetchedAtMillis;
  final Value<int> rowid;
  const CacheMetaCompanion({
    this.key = const Value.absent(),
    this.fetchedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CacheMetaCompanion.insert({
    required String key,
    required int fetchedAtMillis,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       fetchedAtMillis = Value(fetchedAtMillis);
  static Insertable<CacheMetaData> custom({
    Expression<String>? key,
    Expression<int>? fetchedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (fetchedAtMillis != null) 'fetched_at_millis': fetchedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CacheMetaCompanion copyWith({
    Value<String>? key,
    Value<int>? fetchedAtMillis,
    Value<int>? rowid,
  }) {
    return CacheMetaCompanion(
      key: key ?? this.key,
      fetchedAtMillis: fetchedAtMillis ?? this.fetchedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (fetchedAtMillis.present) {
      map['fetched_at_millis'] = Variable<int>(fetchedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CacheMetaCompanion(')
          ..write('key: $key, ')
          ..write('fetchedAtMillis: $fetchedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CachedStatesTable cachedStates = $CachedStatesTable(this);
  late final $CachedDistrictsTable cachedDistricts = $CachedDistrictsTable(
    this,
  );
  late final $CacheMetaTable cacheMeta = $CacheMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    cachedStates,
    cachedDistricts,
    cacheMeta,
  ];
}

typedef $$CachedStatesTableCreateCompanionBuilder =
    CachedStatesCompanion Function({
      Value<int> stateId,
      required String nameAr,
    });
typedef $$CachedStatesTableUpdateCompanionBuilder =
    CachedStatesCompanion Function({Value<int> stateId, Value<String> nameAr});

class $$CachedStatesTableFilterComposer
    extends Composer<_$AppDatabase, $CachedStatesTable> {
  $$CachedStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get stateId => $composableBuilder(
    column: $table.stateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedStatesTable> {
  $$CachedStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get stateId => $composableBuilder(
    column: $table.stateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedStatesTable> {
  $$CachedStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get stateId =>
      $composableBuilder(column: $table.stateId, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);
}

class $$CachedStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedStatesTable,
          CachedState,
          $$CachedStatesTableFilterComposer,
          $$CachedStatesTableOrderingComposer,
          $$CachedStatesTableAnnotationComposer,
          $$CachedStatesTableCreateCompanionBuilder,
          $$CachedStatesTableUpdateCompanionBuilder,
          (
            CachedState,
            BaseReferences<_$AppDatabase, $CachedStatesTable, CachedState>,
          ),
          CachedState,
          PrefetchHooks Function()
        > {
  $$CachedStatesTableTableManager(_$AppDatabase db, $CachedStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> stateId = const Value.absent(),
                Value<String> nameAr = const Value.absent(),
              }) => CachedStatesCompanion(stateId: stateId, nameAr: nameAr),
          createCompanionCallback:
              ({
                Value<int> stateId = const Value.absent(),
                required String nameAr,
              }) => CachedStatesCompanion.insert(
                stateId: stateId,
                nameAr: nameAr,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedStatesTable,
      CachedState,
      $$CachedStatesTableFilterComposer,
      $$CachedStatesTableOrderingComposer,
      $$CachedStatesTableAnnotationComposer,
      $$CachedStatesTableCreateCompanionBuilder,
      $$CachedStatesTableUpdateCompanionBuilder,
      (
        CachedState,
        BaseReferences<_$AppDatabase, $CachedStatesTable, CachedState>,
      ),
      CachedState,
      PrefetchHooks Function()
    >;
typedef $$CachedDistrictsTableCreateCompanionBuilder =
    CachedDistrictsCompanion Function({
      Value<int> districtId,
      required int stateId,
      required String nameAr,
    });
typedef $$CachedDistrictsTableUpdateCompanionBuilder =
    CachedDistrictsCompanion Function({
      Value<int> districtId,
      Value<int> stateId,
      Value<String> nameAr,
    });

class $$CachedDistrictsTableFilterComposer
    extends Composer<_$AppDatabase, $CachedDistrictsTable> {
  $$CachedDistrictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get districtId => $composableBuilder(
    column: $table.districtId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stateId => $composableBuilder(
    column: $table.stateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedDistrictsTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedDistrictsTable> {
  $$CachedDistrictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get districtId => $composableBuilder(
    column: $table.districtId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stateId => $composableBuilder(
    column: $table.stateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameAr => $composableBuilder(
    column: $table.nameAr,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedDistrictsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedDistrictsTable> {
  $$CachedDistrictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get districtId => $composableBuilder(
    column: $table.districtId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stateId =>
      $composableBuilder(column: $table.stateId, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);
}

class $$CachedDistrictsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedDistrictsTable,
          CachedDistrict,
          $$CachedDistrictsTableFilterComposer,
          $$CachedDistrictsTableOrderingComposer,
          $$CachedDistrictsTableAnnotationComposer,
          $$CachedDistrictsTableCreateCompanionBuilder,
          $$CachedDistrictsTableUpdateCompanionBuilder,
          (
            CachedDistrict,
            BaseReferences<
              _$AppDatabase,
              $CachedDistrictsTable,
              CachedDistrict
            >,
          ),
          CachedDistrict,
          PrefetchHooks Function()
        > {
  $$CachedDistrictsTableTableManager(
    _$AppDatabase db,
    $CachedDistrictsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedDistrictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedDistrictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedDistrictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> districtId = const Value.absent(),
                Value<int> stateId = const Value.absent(),
                Value<String> nameAr = const Value.absent(),
              }) => CachedDistrictsCompanion(
                districtId: districtId,
                stateId: stateId,
                nameAr: nameAr,
              ),
          createCompanionCallback:
              ({
                Value<int> districtId = const Value.absent(),
                required int stateId,
                required String nameAr,
              }) => CachedDistrictsCompanion.insert(
                districtId: districtId,
                stateId: stateId,
                nameAr: nameAr,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedDistrictsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedDistrictsTable,
      CachedDistrict,
      $$CachedDistrictsTableFilterComposer,
      $$CachedDistrictsTableOrderingComposer,
      $$CachedDistrictsTableAnnotationComposer,
      $$CachedDistrictsTableCreateCompanionBuilder,
      $$CachedDistrictsTableUpdateCompanionBuilder,
      (
        CachedDistrict,
        BaseReferences<_$AppDatabase, $CachedDistrictsTable, CachedDistrict>,
      ),
      CachedDistrict,
      PrefetchHooks Function()
    >;
typedef $$CacheMetaTableCreateCompanionBuilder =
    CacheMetaCompanion Function({
      required String key,
      required int fetchedAtMillis,
      Value<int> rowid,
    });
typedef $$CacheMetaTableUpdateCompanionBuilder =
    CacheMetaCompanion Function({
      Value<String> key,
      Value<int> fetchedAtMillis,
      Value<int> rowid,
    });

class $$CacheMetaTableFilterComposer
    extends Composer<_$AppDatabase, $CacheMetaTable> {
  $$CacheMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAtMillis => $composableBuilder(
    column: $table.fetchedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CacheMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $CacheMetaTable> {
  $$CacheMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAtMillis => $composableBuilder(
    column: $table.fetchedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CacheMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $CacheMetaTable> {
  $$CacheMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<int> get fetchedAtMillis => $composableBuilder(
    column: $table.fetchedAtMillis,
    builder: (column) => column,
  );
}

class $$CacheMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CacheMetaTable,
          CacheMetaData,
          $$CacheMetaTableFilterComposer,
          $$CacheMetaTableOrderingComposer,
          $$CacheMetaTableAnnotationComposer,
          $$CacheMetaTableCreateCompanionBuilder,
          $$CacheMetaTableUpdateCompanionBuilder,
          (
            CacheMetaData,
            BaseReferences<_$AppDatabase, $CacheMetaTable, CacheMetaData>,
          ),
          CacheMetaData,
          PrefetchHooks Function()
        > {
  $$CacheMetaTableTableManager(_$AppDatabase db, $CacheMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CacheMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CacheMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CacheMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<int> fetchedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CacheMetaCompanion(
                key: key,
                fetchedAtMillis: fetchedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required int fetchedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => CacheMetaCompanion.insert(
                key: key,
                fetchedAtMillis: fetchedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CacheMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CacheMetaTable,
      CacheMetaData,
      $$CacheMetaTableFilterComposer,
      $$CacheMetaTableOrderingComposer,
      $$CacheMetaTableAnnotationComposer,
      $$CacheMetaTableCreateCompanionBuilder,
      $$CacheMetaTableUpdateCompanionBuilder,
      (
        CacheMetaData,
        BaseReferences<_$AppDatabase, $CacheMetaTable, CacheMetaData>,
      ),
      CacheMetaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CachedStatesTableTableManager get cachedStates =>
      $$CachedStatesTableTableManager(_db, _db.cachedStates);
  $$CachedDistrictsTableTableManager get cachedDistricts =>
      $$CachedDistrictsTableTableManager(_db, _db.cachedDistricts);
  $$CacheMetaTableTableManager get cacheMeta =>
      $$CacheMetaTableTableManager(_db, _db.cacheMeta);
}
