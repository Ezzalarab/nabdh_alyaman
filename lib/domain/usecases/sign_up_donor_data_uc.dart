// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/donor.dart';
import '../repositories/auth_repo.dart';

class SignUpDonorDataUseCase {
  final AuthRepo authRepository;
  SignUpDonorDataUseCase({
    required this.authRepository,
  });

  Future<Either<Failure, Unit>> call(
      {required Donor donor, required String uid}) async {
    return await authRepository.signUpDonorData(
      donor: donor,
      uid: uid,
    );
  }
}
