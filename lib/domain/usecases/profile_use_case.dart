// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/donor.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../presentation/pages/profile_center.dart';
import '../../presentation/widgets/setting/profile_body.dart';
import '../entities/blood_center.dart';

class ProfileUseCase {
  final ProfileRepository profileRepository;
  ProfileUseCase({
    required this.profileRepository,
  });

  Future<Either<Failure, Donor>> call() {
    return profileRepository.getDataToProfilePage();
  }

  Future<Either<Failure, BloodCenter>> callCenterData() {
    return profileRepository.getProfileCenterData();
  }

  Future<Either<Failure, Unit>> callsendDataSectionOne(
      {required ProfileLocalData profileLocalData}) {
    return profileRepository.sendDataProfileSectionOne(
        profileLocalData: profileLocalData);
  }

  Future<Either<Failure, Unit>> callsendBasicDataProfileSectionOne(
      {required ProfileLocalData profileLocalData}) {
    return profileRepository.sendBasicDataProfileSectionOne(
        profileLocalData: profileLocalData);
  }

  Future<Either<Failure, Unit>> callsendBasicCenterDataProfile(
      {required ProfileCenterData profileCenterData}) {
    return profileRepository.sendBasicCenterDataProfile(
        profileCenterData: profileCenterData);
  }

  Future<Either<Failure, Unit>> callsendProfileCenterData(
      {required ProfileCenterData profileCenterData}) {
    return profileRepository.sendProfileCenterData(
        profileCenterData: profileCenterData);
  }
}
