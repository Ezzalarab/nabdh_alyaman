// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/notfication_data.dart';
import '../../domain/repositories/notfication_repository.dart';

class SendNotficationUseCase {
  final SendNotficationRepository sendNotificationRepository;
  SendNotficationUseCase({
    required this.sendNotificationRepository,
  });

  Future<Either<Failure, Unit>> call(
      {required SendNotificationData sendNotficationData}) async {
    return sendNotificationRepository.senNotficationToGroup(
        sendNotificationData: sendNotficationData);
  }
}
