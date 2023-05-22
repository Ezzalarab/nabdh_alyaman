import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/notfication_data.dart';

abstract class SendNotficationRepository {
  Future<Either<Failure, Unit>> senNotficationToGroup(
      {required SendNotificationData sendNotificationData});
}
