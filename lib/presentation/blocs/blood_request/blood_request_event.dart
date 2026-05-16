part of 'blood_request_bloc.dart';

sealed class BloodRequestEvent {}

class BloodRequestCreateSubmitted extends BloodRequestEvent {
  BloodRequestCreateSubmitted(this.params);

  final BloodRequestCreateParams params;
}

class BloodRequestListLoadRequested extends BloodRequestEvent {
  BloodRequestListLoadRequested({
    this.bloodType,
    this.stateId,
    this.cursor,
    this.limit = 50,
  });

  final String? bloodType;
  final int? stateId;
  final String? cursor;
  final int limit;
}

class BloodRequestDetailLoadRequested extends BloodRequestEvent {
  BloodRequestDetailLoadRequested({required this.id});

  final String id;
}

class BloodRequestStatusUpdateSubmitted extends BloodRequestEvent {
  BloodRequestStatusUpdateSubmitted({
    required this.id,
    required this.status,
  });

  final String id;
  final String status;
}
