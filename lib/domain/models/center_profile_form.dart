import '../entities/blood_center.dart';

/// Stock + profile fields edited in center UI.
class ProfileCenterData {
  ProfileCenterData({
    this.aPlus,
    this.aMinus,
    this.bPlus,
    this.bMinus,
    this.abPlus,
    this.abMinus,
    this.oPlus,
    this.oMinus,
    this.name,
    this.phone,
    this.district,
    this.state,
    this.neighborhood,
    this.stateId,
    this.districtId,
    this.locationId,
  });

  int? aPlus;
  int? aMinus;
  int? bPlus;
  int? bMinus;
  int? abPlus;
  int? abMinus;
  int? oPlus;
  int? oMinus;

  String? name;
  String? phone;
  String? district;
  String? state;
  String? neighborhood;
  int? stateId;
  int? districtId;
  int? locationId;

  static ProfileCenterData fromBloodCenter(BloodCenter center) {
    return ProfileCenterData(
      aPlus: center.aPlus,
      aMinus: center.aMinus,
      bPlus: center.bPlus,
      bMinus: center.bMinus,
      abPlus: center.abPlus,
      abMinus: center.abMinus,
      oPlus: center.oPlus,
      oMinus: center.oMinus,
      name: center.name,
      phone: center.phone,
      state: center.state,
      district: center.district,
      neighborhood: center.neighborhood,
      stateId: center.stateId,
      districtId: center.districtId,
      locationId: center.locationId,
    );
  }

  static const bloodTypes = [
    BloodCenterFields.aPlus,
    BloodCenterFields.aMinus,
    BloodCenterFields.bPlus,
    BloodCenterFields.bMinus,
    BloodCenterFields.abPlus,
    BloodCenterFields.abMinus,
    BloodCenterFields.oPlus,
    BloodCenterFields.oMinus,
  ];

  static int? getProfileCenterDataBlodTyeb(
    String bloodType,
    ProfileCenterData profileCenterData,
  ) {
    switch (bloodType) {
      case BloodCenterFields.aPlus:
        return profileCenterData.aPlus;
      case BloodCenterFields.aMinus:
        return profileCenterData.aMinus;
      case BloodCenterFields.abPlus:
        return profileCenterData.abPlus;
      case BloodCenterFields.abMinus:
        return profileCenterData.abMinus;
      case BloodCenterFields.oPlus:
        return profileCenterData.oPlus;
      case BloodCenterFields.oMinus:
        return profileCenterData.oMinus;
      case BloodCenterFields.bPlus:
        return profileCenterData.bPlus;
      case BloodCenterFields.bMinus:
        return profileCenterData.bMinus;
    }
    return null;
  }

  static int? incressProfileCenterDataBlodTyeb(
    String bloodType,
    ProfileCenterData profileCenterData,
    int value,
  ) {
    switch (bloodType) {
      case BloodCenterFields.aPlus:
        profileCenterData.aPlus = value;
        return profileCenterData.aPlus;
      case BloodCenterFields.aMinus:
        profileCenterData.aMinus = value;
        return profileCenterData.aMinus;
      case BloodCenterFields.abPlus:
        profileCenterData.abPlus = value;
        return profileCenterData.abPlus;
      case BloodCenterFields.abMinus:
        profileCenterData.abMinus = value;
        return profileCenterData.abMinus;
      case BloodCenterFields.oPlus:
        profileCenterData.oPlus = value;
        return profileCenterData.oPlus;
      case BloodCenterFields.oMinus:
        profileCenterData.oMinus = value;
        return profileCenterData.oMinus;
      case BloodCenterFields.bPlus:
        profileCenterData.bPlus = value;
        return profileCenterData.bPlus;
      case BloodCenterFields.bMinus:
        profileCenterData.bMinus = value;
        return profileCenterData.bMinus;
    }
    return null;
  }

  Map<String, int> stockSnapshot() {
    return {
      for (final type in bloodTypes)
        type: getProfileCenterDataBlodTyeb(type, this) ?? 0,
    };
  }

  Iterable<MapEntry<String, int>> stockDeltas(Map<String, int> baseline) sync* {
    for (final type in bloodTypes) {
      final oldQty = baseline[type] ?? 0;
      final newQty = getProfileCenterDataBlodTyeb(type, this) ?? 0;
      final change = newQty - oldQty;
      if (change != 0) {
        yield MapEntry(type, change);
      }
    }
  }
}
