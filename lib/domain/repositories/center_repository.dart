import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../data/models/center_profile_dto.dart';
import '../entities/blood_center.dart';
import '../models/center_profile_form.dart';

abstract class CenterRepository {
  Future<Either<Failure, BloodCenter>> getMe();

  Future<Either<Failure, BloodCenter>> updateProfile({
    required ProfileCenterData data,
  });

  Future<Either<Failure, Unit>> adjustStock({
    required String bloodType,
    required int change,
    String? reason,
  });

  Future<Either<Failure, CenterDonationResult>> recordDonation({
    required int donorId,
    String? notes,
  });

  Future<Either<Failure, CenterStockHistoryPage>> getStockHistory({
    String? cursor,
    int? limit,
  });

  Future<Either<Failure, Unit>> applyStockDeltas({
    required ProfileCenterData current,
    required Map<String, int> baseline,
    String? reason,
  });
}
