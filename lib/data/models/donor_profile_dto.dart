import '../../domain/entities/donor.dart';

/// REST `DonorProfile` + nested `User` from `GET /donors/me`.
class DonorProfileDto {
  DonorProfileDto({
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.bloodType,
    this.email = '',
    this.birthDate = '',
    this.isShown = true,
    this.isPhoneShown = true,
    this.isGpsOn = true,
    this.stateId,
    this.districtId,
    this.locationId,
    this.stateLabel = '',
    this.districtLabel = '',
    this.neighborhoodLabel = '',
    this.lat = '',
    this.lon = '',
    this.imageFileId = '',
  });

  final String userId;
  final String fullName;
  final String phone;
  final String email;
  final String bloodType;
  final String birthDate;
  final bool isShown;
  final bool isPhoneShown;
  final bool isGpsOn;
  final int? stateId;
  final int? districtId;
  final int? locationId;
  final String stateLabel;
  final String districtLabel;
  final String neighborhoodLabel;
  final String lat;
  final String lon;
  final String imageFileId;

  factory DonorProfileDto.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userMap = user is Map ? Map<String, dynamic>.from(user) : null;

    String readString(String key) => json[key]?.toString() ?? '';

    final stateObj = json['state'];
    final districtObj = json['district'];
    final locationObj = json['location'];

    return DonorProfileDto(
      userId: _readId(json['userId'] ?? json['id'] ?? userMap?['id']),
      fullName: readString('fullName').isNotEmpty
          ? readString('fullName')
          : (userMap?['fullName']?.toString() ?? ''),
      phone: userMap?['phone']?.toString() ?? readString('phone'),
      email: userMap?['email']?.toString() ?? readString('email'),
      bloodType: readString('bloodType'),
      birthDate: readString('birthDate'),
      isShown: _readBool(json['isShown'], defaultValue: true),
      isPhoneShown: _readBool(json['isPhoneShown'], defaultValue: true),
      isGpsOn: _readBool(json['isGpsOn'], defaultValue: true),
      stateId: _readInt(json['stateId']),
      districtId: _readInt(json['districtId']),
      locationId: _readInt(json['locationId']),
      stateLabel: _locationName(stateObj) ?? readString('stateName'),
      districtLabel: _locationName(districtObj) ?? readString('districtName'),
      neighborhoodLabel:
          _locationName(locationObj) ?? readString('locationName'),
      lat: json['lat']?.toString() ?? '',
      lon: json['lon']?.toString() ?? '',
      imageFileId: json['imageUrl']?.toString() ?? '',
    );
  }

  Donor toDonor() {
    final stateValue = stateId?.toString() ?? stateLabel;
    final districtValue = districtId?.toString() ?? districtLabel;
    final neighborhoodValue =
        locationId?.toString() ?? neighborhoodLabel;

    return Donor(
      id: userId,
      email: email,
      name: fullName,
      phone: phone,
      bloodType: bloodType,
      state: stateValue,
      district: districtValue,
      neighborhood: neighborhoodValue,
      lat: lat,
      lon: lon,
      brithDate: birthDate,
      image: imageFileId,
      isShown: isShown ? '1' : '0',
      isShownPhone: isPhoneShown ? '1' : '0',
      isGpsOn: isGpsOn ? '1' : '0',
    );
  }

  static String _readId(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static int? _readInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool _readBool(dynamic value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final s = value.toString().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return defaultValue;
  }

  static String? _locationName(dynamic obj) {
    if (obj is! Map) return null;
    final map = Map<String, dynamic>.from(obj);
    return map['nameAr']?.toString() ??
        map['name']?.toString() ??
        map['nameEn']?.toString();
  }
}
