part of 'blood_request_bloc.dart';

sealed class BloodRequestEvent extends Equatable {
  const BloodRequestEvent();

  @override
  List<Object?> get props => [];
}

class BloodRequestCreateSubmitted extends BloodRequestEvent {
  const BloodRequestCreateSubmitted(this.params);

  final BloodRequestCreateParams params;

  @override
  List<Object?> get props => [params];
}

class BloodRequestListLoadRequested extends BloodRequestEvent {
  const BloodRequestListLoadRequested({
    this.bloodType,
    this.stateId,
    this.cursor,
    this.limit = 50,
  });

  final String? bloodType;
  final int? stateId;
  final String? cursor;
  final int limit;

  @override
  List<Object?> get props => [bloodType, stateId, cursor, limit];
}

class BloodRequestDetailLoadRequested extends BloodRequestEvent {
  const BloodRequestDetailLoadRequested({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class BloodRequestStatusUpdateSubmitted extends BloodRequestEvent {
  const BloodRequestStatusUpdateSubmitted({
    required this.id,
    required this.status,
  });

  final String id;
  final String status;

  @override
  List<Object?> get props => [id, status];
}
