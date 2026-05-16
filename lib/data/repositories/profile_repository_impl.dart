// ignore_for_file: public_member_api_docs, sort_constructors_first, unnecessary_null_comparison
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/local/session_local_datasource.dart';
import '../../data/datasources/remote/donor_remote_datasource.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/entities/donor.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../presentation/pages/profile_center.dart';
import '../../presentation/widgets/setting/profile_body.dart';

class ProfileReopsitoryImpl implements ProfileRepository {
  ProfileReopsitoryImpl({
    required this.networkInfo,
    required this.donorRemote,
    required this.sessionLocal,
    this.donors,
  });

  final NetworkInfo networkInfo;
  final DonorRemoteDataSource donorRemote;
  final SessionLocalDataSource sessionLocal;

  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Donor? donors;
  BloodCenter? bloodCenter;

  Future<bool> _isDonorSession() async {
    final role = await sessionLocal.getRole();
    return role == 'DONOR';
  }

  @override
  Future<Either<Failure, Donor>> getDataToProfilePage() async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    if (!await _isDonorSession()) {
      return Left(DoesnotSaveData());
    }
    try {
      final dto = await donorRemote.getMe();
      donors = dto.toDonor();
      return Right(donors!);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(DoesnotSaveData());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendDataProfileSectionOne({
    required ProfileLocalData profileLocalData,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    if (!await _isDonorSession()) {
      return Left(DoesnotSaveData());
    }
    try {
      await donorRemote.patchMe({
        'isShown': profileLocalData.isShown == '1',
        'isGpsOn': profileLocalData.isGpsOn == '1',
        if (profileLocalData.isShownPhone != null)
          'isPhoneShown': profileLocalData.isShownPhone == '1',
        if (profileLocalData.date != null &&
            profileLocalData.date!.trim().isNotEmpty)
          'birthDate': profileLocalData.date!.trim(),
      });
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(DoesnotSaveData());
    }
  }

  @override
  Future<Either<Failure, Unit>> sendBasicDataProfileSectionOne({
    required ProfileLocalData profileLocalData,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    if (!await _isDonorSession()) {
      return Left(DoesnotSaveData());
    }
    try {
      final body = <String, dynamic>{};
      if (profileLocalData.name != null &&
          profileLocalData.name!.trim().isNotEmpty) {
        body['fullName'] = profileLocalData.name!.trim();
      }
      if (profileLocalData.bloodType != null &&
          profileLocalData.bloodType!.trim().isNotEmpty) {
        body['bloodType'] = profileLocalData.bloodType!.trim();
      }
      final stateId = int.tryParse(profileLocalData.state ?? '');
      final districtId = int.tryParse(profileLocalData.district ?? '');
      if (stateId != null) body['stateId'] = stateId;
      if (districtId != null) body['districtId'] = districtId;
      if (body.isEmpty) {
        return Left(ValidationFailure(message: 'لا توجد بيانات للتحديث'));
      }
      await donorRemote.patchMe(body);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(DoesnotSaveData());
    }
  }

  // —— Center profile (Firestore until phase 3) ——

  @override
  Future<Either<Failure, Unit>> sendBasicCenterDataProfile({
    required ProfileCenterData profileCenterData,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          return await _fireStore.collection('centers').doc(user.uid).update({
            DonorFields.name: profileCenterData.name,
            DonorFields.phone: profileCenterData.phone,
            DonorFields.state: profileCenterData.state,
            DonorFields.district: profileCenterData.district,
            DonorFields.neighborhood: profileCenterData.neighborhood,
          }).then((_) async => const Right(unit));
        }
        return Left(DoesnotSaveData());
      } catch (e) {
        return Left(DoesnotSaveData());
      }
    }
    return Left(OffLineFailure());
  }

  @override
  Future<Either<Failure, Unit>> sendProfileCenterData({
    required ProfileCenterData profileCenterData,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          return await _fireStore.collection('centers').doc(user.uid).update({
            BloodCenterFields.aPlus: profileCenterData.aPlus,
            BloodCenterFields.aMinus: profileCenterData.aMinus,
            BloodCenterFields.abPlus: profileCenterData.abPlus,
            BloodCenterFields.abMinus: profileCenterData.abMinus,
            BloodCenterFields.oPlus: profileCenterData.oPlus,
            BloodCenterFields.oMinus: profileCenterData.oMinus,
            BloodCenterFields.bPlus: profileCenterData.bPlus,
            BloodCenterFields.bMinus: profileCenterData.bMinus,
            BloodCenterFields.lastUpdate: DateTime.now().toString(),
          }).then((_) async => const Right(unit));
        }
        return Left(DoesnotSaveData());
      } catch (e) {
        return Left(DoesnotSaveData());
      }
    }
    return Left(OffLineFailure());
  }

  @override
  Future<Either<Failure, BloodCenter>> getProfileCenterData() async {
    if (await networkInfo.isConnected) {
      try {
        final user = _firebaseAuth.currentUser;
        if (user != null) {
          return await _fireStore
              .collection('centers')
              .doc(user.uid)
              .get()
              .then((value) async {
            bloodCenter = BloodCenter.fromMap(value.data()!);
            if (kDebugMode) {
              print(value.id);
              print(bloodCenter!.name);
            }
            return Right(bloodCenter!);
          });
        }
        return Left(DoesnotSaveData());
      } catch (e) {
        return Left(DoesnotSaveData());
      }
    }
    return Left(OffLineFailure());
  }
}
