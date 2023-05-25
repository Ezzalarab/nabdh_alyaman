// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/donor.dart';
import '../repositories/search_repo.dart';

class SearchStateDonorsUC {
  final SearchRepo searchRepository;
  SearchStateDonorsUC({
    required this.searchRepository,
  });
  Future<Either<Failure, List<Donor>>> call({
    required String state,
  }) async {
    return await searchRepository.searchStateDonors(
      state: state,
    );
  }
}
