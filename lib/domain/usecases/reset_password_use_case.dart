// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository resetPasswordRepository;
  ResetPasswordUseCase({
    required this.resetPasswordRepository,
  });

  Future<Either<Failure, void>> call({required String email}) async {
    return await resetPasswordRepository.resetPassword(email: email);
  }
}
