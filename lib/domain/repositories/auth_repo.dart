import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/auth_session.dart';
import '../entities/donor_registration_params.dart';
import '../entities/blood_center.dart';

abstract class AuthRepo {
  Future<Either<Failure, AuthenticatedSession>> login({
    required String identifier,
    required String password,
  });

  Future<Either<Failure, AuthenticatedSession>> registerDonor(
    DonorRegistrationParams params,
  );

  Future<Either<Failure, Unit>> logout();

  Future<Either<Failure, Unit>> forgotPassword({required String identifier});

  Future<Either<Failure, String>> verifyOtpForReset({
    required String identifier,
    required String code,
  });

  Future<Either<Failure, Unit>> resetPasswordWithToken({
    required String resetToken,
    required String newPassword,
  });

  Future<Either<Failure, AuthenticatedSession>> completeProfileEmail({
    required String email,
  });

  Future<Either<Failure, Unit>> sendEmailVerification();

  Future<Either<Failure, AuthenticatedSession>> verifyEmail({
    required String code,
  });

  Future<Either<Failure, Unit>> registerDeviceIfPossible();

  Future<bool> hasPersistedSession();

  /// When tokens exist, restores [AuthenticatedSession] from secure meta (no API call).
  Future<AuthenticatedSession?> readPersistedSessionMeta();

  Future<Either<Failure, Unit>> signUpCenter({required BloodCenter center});
}
