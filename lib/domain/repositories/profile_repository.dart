import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../presentation/pages/profile_center.dart';
import '../../presentation/widgets/setting/profile_body.dart';
import '../entities/blood_center.dart';
import '../entities/donor.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Donor>> getDataToProfilePage();

  Future<Either<Failure, BloodCenter>> getProfileCenterData();

  Future<Either<Failure, Unit>> sendDataProfileSectionOne(
      {required ProfileLocalData profileLocalData});

  Future<Either<Failure, Unit>> sendBasicDataProfileSectionOne(
      {required ProfileLocalData profileLocalData});

  Future<Either<Failure, Unit>> sendBasicCenterDataProfile(
      {required ProfileCenterData profileCenterData});

  Future<Either<Failure, Unit>> sendProfileCenterData(
      {required ProfileCenterData profileCenterData});
}
