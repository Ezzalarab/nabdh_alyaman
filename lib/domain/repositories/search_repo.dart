import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/blood_center.dart';
import '../entities/donor.dart';

abstract class SearchRepo {
  Future<Either<Failure, List<Donor>>> searchDonors({
    required String bloodType,
    required int stateId,
    required int districtId,
  });

  Future<Either<Failure, List<BloodCenter>>> searchCenters({
    required int stateId,
    required int districtId,
  });
}
