// ignore_for_file: public_member_api_docs, sort_constructors_first
import '../../core/error/failures.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';

class SignUpCenterUseCase {
  final AuthRepository authRepository;
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
