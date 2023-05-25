// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/donor.dart';
import '../repositories/auth_repo.dart';

class SignUpDonorAuthUseCase {
  final AuthRepo authRepository;
  SignUpDonorAuthUseCase({
    required this.authRepository,
  });
  Future<Either<Failure, UserCredential>> call({
    required Donor donor,
  }) async {
    return await authRepository.signUpDonorAuth(
      donor: donor,
    );
  }
}
