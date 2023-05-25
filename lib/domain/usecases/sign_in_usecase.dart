// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/error/failures.dart';
import '../repositories/auth_repo.dart';

class SignInUseCase {
  final AuthRepo authRepository;
  SignInUseCase({
    required this.authRepository,
  });
  Future<Either<Failure, UserCredential>> call({
    required String email,
    required String password,
  }) async {
    return await authRepository.signInWithEmail(
        email: email, password: password);
  }
}
