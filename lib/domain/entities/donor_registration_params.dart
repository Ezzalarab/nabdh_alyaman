import 'package:equatable/equatable.dart';
class DonorRegistrationParams extends Equatable {
  const DonorRegistrationParams({
    required this.fullName,
    required this.phone,
    required this.password,
    required this.bloodType,
    required this.gender,
    this.email,
    required this.stateId,
    required this.districtId,
    required this.locationId,
    this.lat,
    this.lon,
  });

  final String fullName;
  final String phone;
  final String password;
  final String bloodType;
  final String gender;
  final String? email;
  final int stateId;
  final int districtId;
  final int locationId;
  final double? lat;
  final double? lon;

  @override
  List<Object?> get props => [
        fullName,
        phone,
        password,
        bloodType,
        gender,
        email,
        stateId,
        districtId,
        locationId,
        lat,
        lon,
      ];
}
