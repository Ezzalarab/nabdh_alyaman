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

  @override
  Future<Either<Failure, AuthenticatedSession>> login({
    required String identifier,
    required String password,
  }) async {
    return loginResult ?? const Right(
          AuthenticatedSession(userId: '1', role: 'DONOR'),
        );
  }

  @override
  Future<Either<Failure, AuthenticatedSession>> registerDonor(
    DonorRegistrationParams params,
  ) async {
    return registerResult ?? const Right(
          AuthenticatedSession(userId: '2', role: 'DONOR'),
        );
  }

  @override
  Future<Either<Failure, Unit>> logout() async => const Right(unit);

  @override
  Future<Either<Failure, Unit>> forgotPassword({required String phone}) async =>
      const Right(unit);

  @override
  Future<Either<Failure, String>> verifyOtpForReset({
    required String phone,
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
