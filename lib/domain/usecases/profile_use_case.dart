// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/donor.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../presentation/widgets/setting/profile_body.dart';

class ProfileUseCase {
  final ProfileRepository profileRepository;
  ProfileUseCase({
    required this.profileRepository,
  });

  Future<Either<Failure, Donor>> call() {
    return profileRepository.getDataToProfilePage();
  }

  Future<Either<Failure, Unit>> callsendDataSectionOne({
    required ProfileLocalData profileLocalData,
  }) {
    return profileRepository.sendDataProfileSectionOne(
      profileLocalData: profileLocalData,
    );
  }

  Future<Either<Failure, Unit>> callsendBasicDataProfileSectionOne({
    required ProfileLocalData profileLocalData,
  }) {
    return profileRepository.sendBasicDataProfileSectionOne(
      profileLocalData: profileLocalData,
    );
  }

  Future<Either<Failure, Donor>> uploadDonorProfileImage({required File file}) {
    return profileRepository.uploadDonorProfileImage(file: file);
  }
}
