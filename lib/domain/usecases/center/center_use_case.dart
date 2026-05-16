import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../data/models/center_profile_dto.dart';
import '../../entities/blood_center.dart';
import '../../models/center_profile_form.dart';
import '../../repositories/center_repository.dart';

class CenterUseCase {
  CenterUseCase({required CenterRepository centerRepository})
      : _centerRepository = centerRepository;

  final CenterRepository _centerRepository;

  Future<Either<Failure, BloodCenter>> loadProfile() =>
      _centerRepository.getMe();

  Future<Either<Failure, BloodCenter>> updateProfile({
    required ProfileCenterData data,
  }) =>
      _centerRepository.updateProfile(data: data);

  Future<Either<Failure, Unit>> applyStockDeltas({
    required ProfileCenterData current,
    required Map<String, int> baseline,
    String? reason,
  }) =>
      _centerRepository.applyStockDeltas(
        current: current,
        baseline: baseline,
        reason: reason,
      );

  Future<Either<Failure, CenterDonationResult>> recordDonation({
    required int donorId,
    String? notes,
  }) =>
      _centerRepository.recordDonation(donorId: donorId, notes: notes);

  Future<Either<Failure, CenterStockHistoryPage>> loadStockHistory({
    String? cursor,
    int? limit,
  }) =>
      _centerRepository.getStockHistory(cursor: cursor, limit: limit);
}
