// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

// ignore: must_be_immutable
class ProfileGetData extends ProfileState {
  Donor donors;
  ProfileGetData({
    required this.donors,
  });
}

// ignore: must_be_immutable
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
