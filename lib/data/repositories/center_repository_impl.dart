import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/local/session_local_datasource.dart';
import '../../data/datasources/remote/center_remote_datasource.dart';
import '../../data/models/center_profile_dto.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/models/center_profile_form.dart';
import '../../domain/repositories/center_repository.dart';

class CenterRepositoryImpl implements CenterRepository {
  CenterRepositoryImpl({
    required this.networkInfo,
    required this.remote,
    required this.sessionLocal,
  });

  final NetworkInfo networkInfo;
  final CenterRemoteDataSource remote;
  final SessionLocalDataSource sessionLocal;

  Future<bool> _isCenterSession() async {
    final role = await sessionLocal.getRole();
    return role == 'CENTER';
  }

  Future<Either<Failure, T>> _guardCenter<T>(
    Future<Either<Failure, T>> Function() action,
  ) async {
    if (!await _isCenterSession()) {
      return Left(ForbiddenFailure(message: 'هذه العملية متاحة لحساب المركز فقط'));
    }
    return action();
  }

  @override
  Future<Either<Failure, BloodCenter>> getMe() {
    return _guardCenter(() async {
      if (!await networkInfo.isConnected) {
        return Left(OffLineFailure());
      }
      try {
        final dto = await remote.getMe();
        return Right(dto.center);
      } on Failure catch (f) {
        return Left(f);
      } catch (_) {
        return Left(DoesnotSaveData());
      }
    });
  }

  @override
  Future<Either<Failure, BloodCenter>> updateProfile({
    required ProfileCenterData data,
  }) {
    return _guardCenter(() async {
      if (!await networkInfo.isConnected) {
        return Left(OffLineFailure());
      }
      try {
        final body = <String, dynamic>{};
        if (data.name != null && data.name!.trim().isNotEmpty) {
          body['name'] = data.name!.trim();
        }
        if (data.phone != null && data.phone!.trim().isNotEmpty) {
          body['phone'] = data.phone!.trim();
        }
        if (data.stateId != null) body['stateId'] = data.stateId;
        if (data.districtId != null) body['districtId'] = data.districtId;
        if (data.locationId != null) {
          body['locationId'] = data.locationId;
        }
        if (body.isEmpty) {
          return Left(ValidationFailure(message: 'لا توجد بيانات للتحديث'));
        }
        final dto = await remote.patchMe(body);
        return Right(dto.center);
      } on Failure catch (f) {
        return Left(f);
      } catch (_) {
        return Left(DoesnotSaveData());
      }
    });
  }

  @override
  Future<Either<Failure, Unit>> adjustStock({
    required String bloodType,
    required int change,
    String? reason,
  }) {
    return _guardCenter(() async {
      if (!await networkInfo.isConnected) {
        return Left(OffLineFailure());
      }
      if (change == 0) return const Right(unit);
      try {
        await remote.adjustStock(
          bloodType: bloodType,
          change: change,
          reason: reason,
        );
        return const Right(unit);
      } on Failure catch (f) {
        return Left(f);
      } catch (_) {
        return Left(DoesnotSaveData());
      }
    });
  }

  @override
  Future<Either<Failure, CenterDonationResult>> recordDonation({
    required int donorId,
    String? notes,
  }) {
    return _guardCenter(() async {
      if (!await networkInfo.isConnected) {
        return Left(OffLineFailure());
      }
      try {
        final result = await remote.recordDonation(
          donorId: donorId,
          notes: notes,
        );
        return Right(result);
      } on Failure catch (f) {
        return Left(f);
      } catch (_) {
        return Left(DoesnotSaveData());
      }
    });
  }

  @override
  Future<Either<Failure, CenterStockHistoryPage>> getStockHistory({
    String? cursor,
    int? limit,
  }) {
    return _guardCenter(() async {
      if (!await networkInfo.isConnected) {
        return Left(OffLineFailure());
      }
      try {
        final page = await remote.getStockHistory(cursor: cursor, limit: limit);
        return Right(page);
      } on Failure catch (f) {
        return Left(f);
      } catch (_) {
        return Left(DoesnotSaveData());
      }
    });
  }

  @override
  Future<Either<Failure, Unit>> applyStockDeltas({
    required ProfileCenterData current,
    required Map<String, int> baseline,
    String? reason,
  }) {
    return _guardCenter(() async {
      for (final entry in current.stockDeltas(baseline)) {
        final result = await adjustStock(
          bloodType: entry.key,
          change: entry.value,
          reason: reason,
        );
        if (result.isLeft()) return result;
      }
      return const Right(unit);
    });
  }
}
