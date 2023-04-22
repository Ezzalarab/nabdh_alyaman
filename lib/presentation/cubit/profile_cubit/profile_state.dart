// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileGetData extends ProfileState {
  Donor donors;
  ProfileGetData({
    required this.donors,
  });
}

class ProfileGetCenterData extends ProfileState {
  BloodCenter bloodCenter;
  ProfileGetCenterData({
    required this.bloodCenter,
  });
}

class ProfileSuccess extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoadingBeforFetch extends ProfileState {}

class ProfileFailure extends ProfileState {
  final String error;
  ProfileFailure({required this.error});
}
