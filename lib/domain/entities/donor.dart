// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

// ignore: must_be_immutable
class Donor {
  String id;
  String email;
  String password;
  String name;
  String phone;
  String bloodType;
  String state;
  String district;
  String neighborhood;
  String image;
  String brithDate;
  String isShown;
  String isShownPhone;
  String isGpsOn;
  String token;
  String lat;
  String lon;
  String status;
  bool isExpanded;

  Donor({
    this.id = '',
    required this.email,
    this.password = '',
    required this.name,
    required this.phone,
    required this.bloodType,
    required this.state,
    required this.district,
    required this.neighborhood,
    this.lat = '',
    this.lon = '',
    this.token = '',
    this.brithDate = '',
    this.image = '',
    this.isShown = "1",
    this.isShownPhone = "1",
    this.isGpsOn = "1",
    this.status = "ACTIVE",
    this.isExpanded = false,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      DonorFields.email: email,
      DonorFields.name: name,
      DonorFields.password: password,
      DonorFields.phone: phone,
      DonorFields.bloodType: bloodType,
      DonorFields.state: state,
      DonorFields.district: district,
      DonorFields.neighborhood: neighborhood,
      DonorFields.image: image,
      DonorFields.brithDate: brithDate,
      DonorFields.isShown: isShown,
      DonorFields.isShownPhone: isShownPhone,
      DonorFields.isGpsOn: isGpsOn,
      DonorFields.token: token,
      DonorFields.lat: lat,
      DonorFields.lon: lon,
      DonorFields.status: status,
    };
  }

  factory Donor.fromMap(Map<String, dynamic> map) {
    return Donor(
      email: map[DonorFields.email]?.toString() ?? "",
      name: map[DonorFields.name]?.toString() ?? "",
      password: map[DonorFields.password]?.toString() ?? "",
      phone: map[DonorFields.phone]?.toString() ?? "",
      bloodType: map[DonorFields.bloodType]?.toString() ?? "",
      state: map[DonorFields.state]?.toString() ?? "",
      district: map[DonorFields.district]?.toString() ?? "",
      neighborhood: map[DonorFields.neighborhood]?.toString() ?? "",
      image: map[DonorFields.image]?.toString() ?? "",
      brithDate: map[DonorFields.brithDate]?.toString() ?? "",
      isShown: map[DonorFields.isShown]?.toString() ?? "1",
      isShownPhone: map[DonorFields.isShownPhone]?.toString() ?? "1",
      isGpsOn: map[DonorFields.isGpsOn]?.toString() ?? "1",
      token: map[DonorFields.token]?.toString() ?? "",
      lat: map[DonorFields.lat]?.toString() ?? "",
      lon: map[DonorFields.lon]?.toString() ?? "",
      status: map[DonorFields.status]?.toString() ?? "ACTIVE",
    );
  }

  String toJson() => json.encode(toMap());

  factory Donor.fromJson(String source) =>
      Donor.fromMap(json.decode(source) as Map<String, dynamic>);

  // @override
  // List<Object?> get props => [
  //       id,
  //       name,
  //       email,
  //       password,
  //       phone,
  //       state,
  //       district,
  //       neighborhood,
  //       image,
  //       brithDate,
  //       isShown,
  //       isShownPhone,
  //       isGpsOn,
  //       token,
  //       lat,
  //       lon,
  //       status,
  //       isExpanded,
  //     ];
}

class DonorFields {
  static const String collectionName = 'donors';
  static const String email = 'email';
  static const String password = 'password';
  static const String name = 'name';
  static const String phone = 'phone';
  static const String bloodType = 'blood_type';
  static const String state = 'state';
  static const String district = 'district';
  static const String neighborhood = 'neighborhood';
  static const String image = 'image';
  static const String brithDate = 'brith_date';
  static const String isShown = 'is_shown';
  static const String isShownPhone = 'is_shown_phone';
  static const String isGpsOn = 'is_gps_on';
  static const String token = 'token';
  static const String lat = 'lat';
  static const String lon = 'lon';
  static const String status = 'status';
}
