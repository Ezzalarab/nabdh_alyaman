import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/blood_request.dart';

abstract class BloodRequestRepository {
  Future<Either<Failure, BloodRequest>> create(BloodRequestCreateParams params);

  Future<Either<Failure, BloodRequestPageResult>> loadList({
    String? bloodType,
    int? stateId,
    String? cursor,
    int? limit,
  });

  Future<Either<Failure, BloodRequest>> loadDetail(String id);

  Future<Either<Failure, BloodRequest>> updateStatus({
    required String id,
    required String status,
  });
}
