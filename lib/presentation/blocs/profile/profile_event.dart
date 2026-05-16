part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class ProfileLoadRequested extends ProfileEvent {}

class ProfileSectionOneUpdateSubmitted extends ProfileEvent {
  ProfileSectionOneUpdateSubmitted(this.data);
  final ProfileLocalData data;
}

class ProfileBasicDataUpdateSubmitted extends ProfileEvent {
  ProfileBasicDataUpdateSubmitted(this.data);
  final ProfileLocalData data;
}

class ProfileImageUploadRequested extends ProfileEvent {
  ProfileImageUploadRequested(this.file);
  final File file;
}
