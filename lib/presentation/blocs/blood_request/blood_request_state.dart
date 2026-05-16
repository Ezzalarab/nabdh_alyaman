part of 'blood_request_bloc.dart';

sealed class BloodRequestState {}

class BloodRequestInitial extends BloodRequestState {}

class BloodRequestLoading extends BloodRequestState {}

class BloodRequestListLoaded extends BloodRequestState {
  BloodRequestListLoaded({required this.items});

  final List<BloodRequest> items;
}

class BloodRequestDetailLoaded extends BloodRequestState {
  BloodRequestDetailLoaded({required this.request});

  final BloodRequest request;
}

class BloodRequestSuccess extends BloodRequestState {
  BloodRequestSuccess({this.request, this.createdId});

  final BloodRequest? request;
  final String? createdId;
}

class BloodRequestFailure extends BloodRequestState {
  BloodRequestFailure(this.message);

  final String message;
}
