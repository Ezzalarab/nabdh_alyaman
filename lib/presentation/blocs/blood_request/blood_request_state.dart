part of 'blood_request_bloc.dart';

sealed class BloodRequestState extends Equatable {
  const BloodRequestState();

  @override
  List<Object?> get props => [];
}

class BloodRequestInitial extends BloodRequestState {
  const BloodRequestInitial();
}

class BloodRequestLoading extends BloodRequestState {
  const BloodRequestLoading();
}

class BloodRequestListLoaded extends BloodRequestState {
  const BloodRequestListLoaded({required this.items});

  final List<BloodRequest> items;

  @override
  List<Object?> get props => [items];
}

class BloodRequestDetailLoaded extends BloodRequestState {
  const BloodRequestDetailLoaded({required this.request});

  final BloodRequest request;

  @override
  List<Object?> get props => [request];
}

class BloodRequestSuccess extends BloodRequestState {
  const BloodRequestSuccess({this.request, this.createdId});

  final BloodRequest? request;
  final String? createdId;

  @override
  List<Object?> get props => [request, createdId];
}

class BloodRequestFailure extends BloodRequestState {
  const BloodRequestFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
