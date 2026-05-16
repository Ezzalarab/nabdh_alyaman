import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class NotificationsUseCase {
  NotificationsUseCase({required NotificationsRepository repository})
      : _repository = repository;

  final NotificationsRepository _repository;

  Future<Either<Failure, NotificationPageResult>> load({
    String? cursor,
    int? limit,
  }) =>
      _repository.load(cursor: cursor, limit: limit);

  Future<Either<Failure, Unit>> markRead(int id) => _repository.markRead(id);

  Future<Either<Failure, Unit>> markAllRead() => _repository.markAllRead();
}
