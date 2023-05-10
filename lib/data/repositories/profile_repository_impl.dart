// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/donor.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/entities/blood_center.dart';
import '../../presentation/pages/profile_center.dart';
import '../../core/network/network_info.dart';
import '../../presentation/widgets/setting/profile_body.dart';

class ProfileReopsitoryImpl implements ProfileRepository {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth currentUser = FirebaseAuth.instance;

  final NetworkInfo networkInfo;
  Donor? donors;
  BloodCenter? bloodCenter;
  ProfileReopsitoryImpl({
    required this.networkInfo,
    this.donors,
  });
  @override
  Future<Either<Failure, Donor>> getDataToProfilePage() async {
    if (await networkInfo.isConnected) {
      try {
        if (currentUser != null) {
          return await _fireStore
              .collection('donors')
              .doc(currentUser.currentUser!.uid.toString())
              .get()
              .then((value) async {
            donors = Donor.fromMap(value.data()!);
            return Right(donors!);
          });
        } else {
          return Left(DoesnotSaveData());
        }
      } catch (e) {
        return Left(DoesnotSaveData());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendDataProfileSectionOne(
      {required ProfileLocalData profileLocalData}) async {
    if (await networkInfo.isConnected) {
      try {
        if (currentUser != null) {
          return await _fireStore
              .collection('donors')
              .doc(currentUser.currentUser!.uid.toString())
              .update({
            DonorFields.isGpsOn: profileLocalData.isGpsOn,
            DonorFields.isShown: profileLocalData.isShown,
            DonorFields.isShownPhone: profileLocalData.isShownPhone,
            DonorFields.brithDate: profileLocalData.date,
          }).then((value) async {
            return const Right(unit);
          });
        } else {
          return Left(DoesnotSaveData());
          // emit(ProfileFailure(
          //     error: "لم يتم حفظ البيانات تاكد من الاتصال بالانترنت"));
        }
      } catch (e) {
        return Left(DoesnotSaveData());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendBasicDataProfileSectionOne(
      {required ProfileLocalData profileLocalData}) async {
    if (await networkInfo.isConnected) {
      try {
        if (currentUser != null) {
          return await _fireStore
              .collection('donors')
              .doc(currentUser.currentUser!.uid.toString())
              .update({
            DonorFields.name: profileLocalData.name,
            DonorFields.bloodType: profileLocalData.bloodType,
            DonorFields.state: profileLocalData.state,
            DonorFields.district: profileLocalData.district,
            DonorFields.neighborhood: profileLocalData.neighborhood,
          }).then((value) async {
            return const Right(unit);
          });
        } else {
          return Left(DoesnotSaveData());
          // emit(ProfileFailure(
          //     error: "لم يتم حفظ البيانات تاكد من الاتصال بالانترنت"));
        }
      } catch (e) {
        return Left(DoesnotSaveData());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendBasicCenterDataProfile(
      {required ProfileCenterData profileCenterData}) async {
    if (await networkInfo.isConnected) {
      try {
        if (currentUser != null) {
          return await _fireStore
              .collection('centers')
              .doc(currentUser.currentUser!.uid.toString())
              .update({
            DonorFields.name: profileCenterData.name,
            DonorFields.phone: profileCenterData.phone,
            DonorFields.state: profileCenterData.state,
            DonorFields.district: profileCenterData.district,
            DonorFields.neighborhood: profileCenterData.neighborhood,
          }).then((value) async {
            return const Right(unit);
          });
        } else {
          return Left(DoesnotSaveData());
          // emit(ProfileFailure(
          //     error: "لم يتم حفظ البيانات تاكد من الاتصال بالانترنت"));
        }
      } catch (e) {
        return Left(DoesnotSaveData());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendProfileCenterData(
      {required ProfileCenterData profileCenterData}) async {
    if (await networkInfo.isConnected) {
      try {
        if (currentUser != null) {
          return await _fireStore
              .collection('centers')
              .doc(currentUser.currentUser!.uid.toString())
              .update({
            BloodCenterFields.aPlus: profileCenterData.aPlus,
            BloodCenterFields.aMinus: profileCenterData.aMinus,
            BloodCenterFields.abPlus: profileCenterData.abPlus,
            BloodCenterFields.abMinus: profileCenterData.abMinus,
            BloodCenterFields.oPlus: profileCenterData.oPlus,
            BloodCenterFields.oMinus: profileCenterData.oMinus,
            BloodCenterFields.bPlus: profileCenterData.bPlus,
            BloodCenterFields.bMinus: profileCenterData.bMinus,
            BloodCenterFields.lastUpdate: DateTime.now().toString(),
          }).then((value) async {
            return const Right(unit);
          });
        } else {
          return Left(DoesnotSaveData());
          // emit(ProfileFailure(
          //     error: "لم يتم حفظ البيانات تاكد من الاتصال بالانترنت"));
        }
      } catch (e) {
        return Left(DoesnotSaveData());
      }
    } else {
      return Left(OffLineFailure());
    }
  }

  @override
  Future<Either<Failure, BloodCenter>> getProfileCenterData() async {
    if (await networkInfo.isConnected) {
      try {
        if (currentUser != null) {
          return await _fireStore
              .collection('centers')
              .doc(currentUser.currentUser!.uid.toString())
              .get()
              .then((value) async {
            print(value.id);
            bloodCenter = BloodCenter.fromMap(value.data()!);
            print(bloodCenter!.name);

            return Right(bloodCenter!);
          });
        } else {
          return Left(DoesnotSaveData());
        }
      } catch (e) {
        return Left(DoesnotSaveData());
      }
    } else {
      return Left(OffLineFailure());
    }
  }
}
