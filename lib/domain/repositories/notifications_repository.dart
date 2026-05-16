import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<Either<Failure, NotificationPageResult>> load({
    String? cursor,
    int? limit,
  });

  Future<Either<Failure, Unit>> markRead(int id);

  Future<Either<Failure, Unit>> markAllRead();
}
