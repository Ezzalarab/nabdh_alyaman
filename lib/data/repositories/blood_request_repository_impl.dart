import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/remote/blood_request_remote_datasource.dart';
import '../../domain/entities/blood_request.dart';
import '../../domain/repositories/blood_request_repository.dart';

class BloodRequestRepositoryImpl implements BloodRequestRepository {
  BloodRequestRepositoryImpl({
    required this.networkInfo,
    required this.remote,
  });

  final NetworkInfo networkInfo;
  final BloodRequestRemoteDataSource remote;

  @override
  Future<Either<Failure, BloodRequest>> create(
    BloodRequestCreateParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    try {
      final request = await remote.create(params);
      return Right(request);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(DoesnotSaveData());
    }
  }

  @override
  Future<Either<Failure, BloodRequestPageResult>> loadList({
    String? bloodType,
    int? stateId,
    String? cursor,
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    try {
      final page = await remote.fetchList(
        bloodType: bloodType,
        stateId: stateId,
        cursor: cursor,
        limit: limit,
      );
      return Right(page);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(EmptyCacheFailure());
    }
  }

  @override
  Future<Either<Failure, BloodRequest>> loadDetail(String id) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    try {
      final request = await remote.fetchById(id);
      return Right(request);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(EmptyCacheFailure());
    }
  }

  @override
  Future<Either<Failure, BloodRequest>> updateStatus({
    required String id,
    required String status,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    try {
      final request = await remote.updateStatus(id: id, status: status);
      return Right(request);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(DoesnotSaveData());
    }
  }
}
