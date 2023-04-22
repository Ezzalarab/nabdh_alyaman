import '../../../core/error/failures.dart';
import '../../../domain/entities/notfication_data.dart';
import '../../../domain/usecases/send_notfication_.dart';
import 'package:dartz/dartz.dart';

abstract class SendNotficationRepository {
  Future<Either<Failure, Unit>> senNotficationToGroup(
      {required SendNotificationData sendNotificationData});
}
