// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/blood_center.dart';
import '../repositories/search_repo.dart';

class SearchCentersUC {
  final SearchRepo searchRepository;
  SearchCentersUC({
    required this.searchRepository,
  });
  Future<Either<Failure, List<BloodCenter>>> call({
    required int stateId,
    required int districtId,
  }) async {
    return searchRepository.searchCenters(
      stateId: stateId,
      districtId: districtId,
    );
  }
}
