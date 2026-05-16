import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/remote/search_remote_datasource.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/entities/donor.dart';
import '../../domain/repositories/search_repo.dart';

class SearchRepoImpl implements SearchRepo {
  SearchRepoImpl({
    required this.networkInfo,
    required this.remote,
  });

  final NetworkInfo networkInfo;
  final SearchRemoteDataSource remote;

  @override
  Future<Either<Failure, List<Donor>>> searchDonors({
    required String bloodType,
    required int stateId,
    required int districtId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    try {
      final position = await tryCurrentPosition();
      List<Donor> donors;
      if (position != null) {
        final results = await remote.searchDonorsGeo(
          bloodType: bloodType,
          lat: position.latitude,
          lon: position.longitude,
          stateId: stateId,
          includeCompatible: true,
        );
        donors = results.map((r) => r.toDonor()).toList(growable: false);
      } else {
        final results = await remote.searchDonorsManual(
          bloodType: bloodType,
          stateId: stateId,
          districtId: districtId,
          includeCompatible: true,
        );
        donors = results.map((r) => r.toDonor()).toList(growable: false);
      }
      return Right(donors);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(UnknownFailure());
    }
  }

  @override
  Future<Either<Failure, List<BloodCenter>>> searchCenters({
    required int stateId,
    required int districtId,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    try {
      final position = await tryCurrentPosition();
      final centers = await remote.fetchCenters(
        stateId: stateId,
        districtId: districtId,
        lat: position?.latitude,
        lon: position?.longitude,
      );
      return Right(centers);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(UnknownFailure());
    }
  }
}
