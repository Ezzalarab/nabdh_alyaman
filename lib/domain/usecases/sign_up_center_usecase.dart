// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/entities/blood_center.dart';
import '../repositories/auth_repo.dart';

class SignUpCenterUseCase {
  final AuthRepo authRepository;
  SignUpCenterUseCase({
    required this.authRepository,
  });
  Future<Either<Failure, Unit>> call({
    required BloodCenter center,
  }) async {
    return await authRepository.signUpCenter(
      center: center,
    );
  }
}
