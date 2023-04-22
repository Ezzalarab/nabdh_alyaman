// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/donor.dart';
import '../../domain/repositories/search_repository.dart';

class SearchDonorsUseCase {
  final SearchRepository searchRepository;
  SearchDonorsUseCase({
    required this.searchRepository,
  });
  Future<Either<Failure, List<Donor>>> call({
    required String state,
    required String district,
  }) async {
    return await searchRepository.searchDonors(
      state: state,
      district: district,
    );
  }
}
