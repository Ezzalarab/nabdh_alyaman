import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/entities/donor.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<Donor>>> searchDonors({
    required String state,
    required String district,
  });
  Future<Either<Failure, List<BloodCenter>>> searchCenters({
    required String state,
    required String district,
  });
  Future<Either<Failure, List<Donor>>> searchStateDonors({
    required String state,
  });
}
