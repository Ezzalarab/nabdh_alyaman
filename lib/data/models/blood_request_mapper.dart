import '../../domain/entities/blood_request.dart';

BloodRequest bloodRequestFromApiJson(Map<String, dynamic> json) {
  final lat = _readDouble(json['lat']);
  final lon = _readDouble(json['lon']);
  return BloodRequest(
    id: json['id']?.toString() ?? '',
    bloodType: json['bloodType']?.toString() ?? '',
    locationId: _readInt(json['locationId']),
    hospitalName: json['hospitalName']?.toString() ?? '',
    lat: lat,
    lon: lon,
    unitsNeeded: _readInt(json['unitsNeeded'], fallback: 1),
    urgency: json['urgency']?.toString() ?? 'NORMAL',
    status: json['status']?.toString() ?? 'OPEN',
    patientName: json['patientName']?.toString(),
    expiresAt: json['expiresAt']?.toString() ?? json['expires_at']?.toString(),
    createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
    requesterId: json['requesterId']?.toString() ??
        json['userId']?.toString() ??
        json['ownerId']?.toString() ??
        json['createdBy']?.toString(),
  );
}

int _readInt(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _readDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

List<Map<String, dynamic>> extractBloodRequestItems(dynamic data) {
  if (data is List) {
    return data
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }
  if (data is Map<String, dynamic>) {
    final raw = data['items'] ?? data['data'] ?? data['bloodRequests'];
    if (raw is List) {
      return raw
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    }
  }
  return [];
}

String? bloodRequestNextCursor(dynamic data) {
  if (data is! Map) return null;
  final map = Map<String, dynamic>.from(data);
  return map['nextCursor']?.toString() ?? map['cursor']?.toString();
}
