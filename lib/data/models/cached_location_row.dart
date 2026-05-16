/// Local row for governorates cached from `/locations` (Drift SQLite).
class CachedLocationState {
  const CachedLocationState({required this.stateId, required this.nameAr});

  final int stateId;
  final String nameAr;

  Map<String, dynamic> toJson() => {'stateId': stateId, 'nameAr': nameAr};

  static CachedLocationState fromJson(Map<String, dynamic> j) =>
      CachedLocationState(
        stateId: j['stateId'] as int,
        nameAr: j['nameAr'] as String,
      );
}

/// District row belonging to [stateId].
class CachedLocationDistrict {
  const CachedLocationDistrict({
    required this.districtId,
    required this.stateId,
    required this.nameAr,
  });

  final int districtId;
  final int stateId;
  final String nameAr;

  Map<String, dynamic> toJson() => {
        'districtId': districtId,
        'stateId': stateId,
        'nameAr': nameAr,
      };

  static CachedLocationDistrict fromJson(Map<String, dynamic> j) =>
      CachedLocationDistrict(
        districtId: j['districtId'] as int,
        stateId: j['stateId'] as int,
        nameAr: j['nameAr'] as String,
      );
}
