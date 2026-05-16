// ignore_for_file: public_member_api_docs, sort_constructors_first, unnecessary_null_comparison
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/local/session_local_datasource.dart';
import '../../data/datasources/remote/donor_remote_datasource.dart';
import '../../data/datasources/remote/files_remote_datasource.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/donor.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../presentation/widgets/setting/profile_body.dart';

class ProfileReopsitoryImpl implements ProfileRepository {
  ProfileReopsitoryImpl({
    required this.networkInfo,
    required this.donorRemote,
    required this.filesRemote,
    required this.sessionLocal,
    this.donors,
  });

  final NetworkInfo networkInfo;
  final DonorRemoteDataSource donorRemote;
  final FilesRemoteDataSource filesRemote;
  final SessionLocalDataSource sessionLocal;

  Donor? donors;

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
      if (profileLocalData.stateId != null) {
        body['stateId'] = profileLocalData.stateId;
      }
      if (profileLocalData.districtId != null) {
        body['districtId'] = profileLocalData.districtId;
      }
      if (profileLocalData.locationId != null) {
        body['locationId'] = profileLocalData.locationId;
      }
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

  @override
  Future<Either<Failure, Donor>> uploadDonorProfileImage({
    required File file,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    if (!await _isDonorSession()) {
      return Left(DoesnotSaveData());
    }
    try {
      final compressed = await _compressImage(file);
      final fileId = await filesRemote.uploadPublicImage(compressed);
      final dto = await donorRemote.patchMe({'imageUrl': fileId});
      donors = dto.toDonor();
      return Right(donors!);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(DoesnotSaveData());
    }
  }

  Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final target = '${dir.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      target,
      quality: 75,
      minWidth: 1024,
      minHeight: 1024,
    );
    if (result == null) return file;
    return File(result.path);
  }
}
