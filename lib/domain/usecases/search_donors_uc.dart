import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/donor.dart';
import '../repositories/search_repo.dart';

class SearchDonorsUC {
  SearchDonorsUC({required this.searchRepository});

  final SearchRepo searchRepository;

  Future<Either<Failure, List<Donor>>> call({
    required String bloodType,
    required int stateId,
    required int districtId,
  }) {
    return searchRepository.searchDonors(
      bloodType: bloodType,
      stateId: stateId,
      districtId: districtId,
    );
  }
}
