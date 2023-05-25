// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../repositories/auth_repo.dart';

class ResetPasswordUseCase {
  final AuthRepo resetPasswordRepository;
  ResetPasswordUseCase({
    required this.resetPasswordRepository,
  });

  Future<Either<Failure, void>> call({required String email}) async {
    return await resetPasswordRepository.resetPassword(email: email);
  }
}
