part of 'profile_bloc.dart';

abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoadingBeforFetch extends ProfileState {}

class ProfileGetData extends ProfileState {
  ProfileGetData({required this.donors});
  final Donor donors;
}

class ProfileLoading extends ProfileState {}

class ProfileSuccess extends ProfileState {}

class ProfileFailure extends ProfileState {
  ProfileFailure({required this.error});
  final String error;
}
