class BloodRequest {
  const BloodRequest({
    required this.id,
    required this.bloodType,
    required this.locationId,
    required this.hospitalName,
    required this.lat,
    required this.lon,
    required this.unitsNeeded,
    required this.urgency,
    required this.status,
    this.patientName,
    this.expiresAt,
    this.createdAt,
    this.requesterId,
  });

  final String id;
  final String bloodType;
  final int locationId;
  final String hospitalName;
  final double lat;
  final double lon;
  final int unitsNeeded;
  final String urgency;
  final String status;
  final String? patientName;
  final String? expiresAt;
  final String? createdAt;
  final String? requesterId;

  bool get isOpen => status.toUpperCase() == 'OPEN';
}

class BloodRequestCreateParams {
  const BloodRequestCreateParams({
    required this.bloodType,
    required this.locationId,
    required this.hospitalName,
    required this.lat,
    required this.lon,
    required this.unitsNeeded,
    this.patientName,
    this.urgency = 'NORMAL',
  });

  final String bloodType;
  final int locationId;
  final String hospitalName;
  final double lat;
  final double lon;
  final int unitsNeeded;
  final String? patientName;
  final String urgency;
}

class BloodRequestPageResult {
  const BloodRequestPageResult({
    required this.items,
    this.nextCursor,
  });

  final List<BloodRequest> items;
  final String? nextCursor;
}
