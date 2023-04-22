// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../core/error/failures.dart';
import '../../domain/entities/donor.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SignUpDonorUseCase {
  final AuthRepository authRepository;
  SignUpDonorUseCase({
    required this.authRepository,
  });
  Future<Either<Failure, Unit>> call({
    required Donor donor,
  }) async {
    return await authRepository.signUpDonor(
      donor: donor,
    );
  }
}
