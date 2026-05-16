import '../../domain/entities/donor.dart';

class DonorSearchResult {
  const DonorSearchResult({
    required this.userId,
    required this.fullName,
    required this.bloodType,
    this.phone,
    this.imageFileId,
    this.distanceKm,
    this.lat,
    this.lon,
    this.districtLabel,
  });

  final String userId;
  final String fullName;
  final String bloodType;
  final String? phone;
  final String? imageFileId;
  final double? distanceKm;
  final double? lat;
  final double? lon;
  final String? districtLabel;

  factory DonorSearchResult.fromJson(Map<String, dynamic> json) {
    double? readDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return DonorSearchResult(
      userId: (json['userId'] ?? json['id']).toString(),
      fullName: json['fullName']?.toString() ?? '',
      bloodType: json['bloodType']?.toString() ?? '',
      phone: json['phone']?.toString(),
      imageFileId: json['imageUrl']?.toString(),
      distanceKm: readDouble(json['distanceKm'] ?? json['distance_km']),
      lat: readDouble(json['lat']),
      lon: readDouble(json['lon']),
      districtLabel: json['districtName']?.toString(),
    );
  }

  Donor toDonor() {
    final neighborhood = distanceKm != null
        ? '${distanceKm!.toStringAsFixed(1)} كم'
        : (districtLabel ?? '');
    return Donor(
      id: userId,
      email: '',
      name: fullName,
      phone: phone ?? '',
      bloodType: bloodType,
      state: '',
      district: '',
      neighborhood: neighborhood,
      lat: lat?.toString() ?? '',
      lon: lon?.toString() ?? '',
      brithDate: '',
      image: imageFileId ?? '',
      isShown: '1',
      isShownPhone: phone != null ? '1' : '0',
      isGpsOn: '1',
      token: '',
    );
  }
}
