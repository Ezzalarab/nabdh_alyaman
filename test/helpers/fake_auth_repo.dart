import 'package:dartz/dartz.dart';

import 'package:nabdh_alyaman/core/error/failures.dart';
import 'package:nabdh_alyaman/domain/entities/auth_session.dart';
import 'package:nabdh_alyaman/domain/entities/blood_center.dart';
import 'package:nabdh_alyaman/domain/entities/donor_registration_params.dart';
import 'package:nabdh_alyaman/domain/repositories/auth_repo.dart';

class FakeAuthRepo implements AuthRepo {
  AuthenticatedSession? persistedSession;
  Either<Failure, AuthenticatedSession>? loginResult;
  Either<Failure, AuthenticatedSession>? registerResult;
  Either<Failure, AuthenticatedSession>? completeEmailResult;
  Either<Failure, Unit>? sendVerificationResult;
  Either<Failure, AuthenticatedSession>? verifyEmailResult;

  @override
  Future<Either<Failure, AuthenticatedSession>> login({
    required String identifier,
    required String password,
  }) async {
    return loginResult ??
        const Right(
          AuthenticatedSession(userId: '1', role: 'DONOR'),
        );
  }

  @override
  Future<Either<Failure, AuthenticatedSession>> registerDonor(
    DonorRegistrationParams params,
  ) async {
    return registerResult ??
        const Right(
          AuthenticatedSession(userId: '2', role: 'DONOR'),
        );
  }

  @override
  Future<Either<Failure, Unit>> logout() async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> forgotPassword({
    required String identifier,
  }) async =>
      const Right(unit);

  @override
  Future<Either<Failure, String>> verifyOtpForReset({
    required String identifier,
    required String code,
  }) async =>
      const Right('reset-token');

  @override
  Future<Either<Failure, Unit>> resetPasswordWithToken({
    required String resetToken,
    required String newPassword,
  }) async =>
      const Right(unit);

  @override
  Future<Either<Failure, AuthenticatedSession>> completeProfileEmail({
    required String email,
  }) async {
    return completeEmailResult ??
        Right(
          AuthenticatedSession(
            userId: '1',
            role: 'DONOR',
            email: email,
            emailMissing: false,
          ),
        );
  }

  @override
  Future<Either<Failure, Unit>> sendEmailVerification() async {
    return sendVerificationResult ?? const Right(unit);
  }

  @override
  Future<Either<Failure, AuthenticatedSession>> verifyEmail({
    required String code,
  }) async {
    return verifyEmailResult ??
        const Right(
          AuthenticatedSession(
            userId: '1',
            role: 'DONOR',
            emailVerified: true,
          ),
        );
  }

  @override
  Future<Either<Failure, Unit>> registerDeviceIfPossible() async =>
      const Right(unit);

  @override
  Future<bool> hasPersistedSession() async => persistedSession != null;

  @override
  Future<AuthenticatedSession?> readPersistedSessionMeta() async =>
      persistedSession;

  @override
  Future<Either<Failure, Unit>> signUpCenter({required BloodCenter center}) async =>
      Left(ValidationFailure(message: 'disabled'));
}
