import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/blood_request.dart';
import '../repositories/blood_request_repository.dart';

class BloodRequestUseCase {
  BloodRequestUseCase({required BloodRequestRepository repository})
      : _repository = repository;

  final BloodRequestRepository _repository;

  Future<Either<Failure, BloodRequest>> create(
    BloodRequestCreateParams params,
  ) =>
      _repository.create(params);

  Future<Either<Failure, BloodRequestPageResult>> loadList({
    String? bloodType,
    int? stateId,
    String? cursor,
    int? limit,
  }) =>
      _repository.loadList(
        bloodType: bloodType,
        stateId: stateId,
        cursor: cursor,
        limit: limit,
      );

  Future<Either<Failure, BloodRequest>> loadDetail(String id) =>
      _repository.loadDetail(id);

  Future<Either<Failure, BloodRequest>> updateStatus({
    required String id,
    required String status,
  }) =>
      _repository.updateStatus(id: id, status: status);
}
