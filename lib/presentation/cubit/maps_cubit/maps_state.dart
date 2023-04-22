// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'maps_cubit.dart';

abstract class MapsState extends Equatable {
  const MapsState();

  @override
  List<Object> get props => [];
}

class MapsInitial extends MapsState {}

class MapsLoading extends MapsState {}

class MapsSuccess extends MapsState {
  final List<DonorPoint> nearbyDonors;
  final Position position;
  const MapsSuccess({
    required this.nearbyDonors,
    required this.position,
  });
}
