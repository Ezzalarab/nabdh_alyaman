import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/remote/notifications_remote_datasource.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({
    required this.networkInfo,
    required this.remote,
  });

  final NetworkInfo networkInfo;
  final NotificationsRemoteDataSource remote;

  @override
  Future<Either<Failure, NotificationPageResult>> load({
    String? cursor,
    int? limit,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    try {
      final page = await remote.fetchNotifications(cursor: cursor, limit: limit);
      return Right(page);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(DoesnotSaveData());
    }
  }

  @override
  Future<Either<Failure, Unit>> markRead(int id) async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    try {
      await remote.markRead(id);
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(DoesnotSaveData());
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllRead() async {
    if (!await networkInfo.isConnected) {
      return Left(OffLineFailure());
    }
    try {
      await remote.markAllRead();
      return const Right(unit);
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(DoesnotSaveData());
    }
  }
}
