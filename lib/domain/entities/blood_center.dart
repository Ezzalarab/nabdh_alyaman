import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class BloodCenter {
  String name;
  String email;
  String password;
  String phone;
  String state;
  String district;
  String neighborhood;
  String image;
  String lastUpdate;
  String lat;
  String lon;
  String token;
  String status;
  int aPlus;
  int aMinus;
  int bPlus;
  int bMinus;
  int abPlus;
  int abMinus;
  int oPlus;
  int oMinus;
  bool isExpanded;
  BloodCenter({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.state,
    required this.district,
    required this.neighborhood,
    required this.image,
    required this.lastUpdate,
    required this.lat,
    required this.lon,
    required this.token,
    required this.status,
    required this.aPlus,
    required this.aMinus,
    required this.bPlus,
    required this.bMinus,
    required this.abPlus,
    required this.abMinus,
    required this.oPlus,
    required this.oMinus,
    this.isExpanded = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      BloodCenterFields.name: name,
      BloodCenterFields.email: email,
      BloodCenterFields.password: password,
      BloodCenterFields.phone: phone,
      BloodCenterFields.state: state,
      BloodCenterFields.district: district,
      BloodCenterFields.neighborhood: neighborhood,
      BloodCenterFields.image: image,
      BloodCenterFields.lastUpdate: lastUpdate,
      BloodCenterFields.lat: lat,
      BloodCenterFields.lon: lon,
      BloodCenterFields.token: token,
      BloodCenterFields.status: status,
      BloodCenterFields.aPlus: aPlus,
      BloodCenterFields.aMinus: aMinus,
      BloodCenterFields.bPlus: bPlus,
      BloodCenterFields.bMinus: bMinus,
      BloodCenterFields.abPlus: abPlus,
      BloodCenterFields.abMinus: abMinus,
      BloodCenterFields.oPlus: oPlus,
      BloodCenterFields.oMinus: oMinus,
    };
  }

  factory BloodCenter.fromMap(Map<String, dynamic> map) {
    return BloodCenter(
      name: map[BloodCenterFields.name]?.toString() ?? "",
      email: map[BloodCenterFields.email]?.toString() ?? "",
      password: map[BloodCenterFields.password]?.toString() ?? "",
      phone: map[BloodCenterFields.phone]?.toString() ?? "",
      state: map[BloodCenterFields.state]?.toString() ?? "",
      district: map[BloodCenterFields.district]?.toString() ?? "",
      neighborhood: map[BloodCenterFields.neighborhood]?.toString() ?? "",
      image: map[BloodCenterFields.image]?.toString() ?? "",
      lastUpdate: map[BloodCenterFields.lastUpdate]?.toString() ?? "",
      lat: map[BloodCenterFields.lat]?.toString() ?? "",
      lon: map[BloodCenterFields.lon]?.toString() ?? "",
      token: map[BloodCenterFields.token]?.toString() ?? "",
      status: map[BloodCenterFields.status]?.toString() ?? "",
      aPlus: map[BloodCenterFields.aPlus] ?? 0,
      aMinus: map[BloodCenterFields.aMinus] ?? 0,
      bPlus: map[BloodCenterFields.bPlus] ?? 0,
      bMinus: map[BloodCenterFields.bMinus] ?? 0,
      abPlus: map[BloodCenterFields.abPlus] ?? 0,
      abMinus: map[BloodCenterFields.abMinus] ?? 0,
      oPlus: map[BloodCenterFields.oPlus] ?? 0,
      oMinus: map[BloodCenterFields.oMinus] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory BloodCenter.fromJson(String source) =>
      BloodCenter.fromMap(json.decode(source) as Map<String, dynamic>);
}

class BloodCenterFields {
  static const String collectionName = "centers";
  static const String name = "name";
  static const String email = "email";
  static const String password = "password";
  static const String phone = "phone";
  static const String state = "state";
  static const String district = "district";
  static const String neighborhood = "neighborhood";
  static const String image = "image";
  static const String lastUpdate = "last_update";
  static const String lat = "lat";
  static const String lon = "lon";
  static const String token = "token";
  static const String status = "status";
  static const String aPlus = "A+";
  static const String aMinus = "A-";
  static const String bPlus = "B+";
  static const String bMinus = "B-";
  static const String abPlus = "AB+";
  static const String abMinus = "AB-";
  static const String oPlus = "O+";
  static const String oMinus = "O-";
}
