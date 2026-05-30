import 'package:dartz/dartz.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../data/datasources/local/session_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/models/auth_tokens_result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/blood_center.dart';
import '../../domain/entities/donor_registration_params.dart';
import '../../domain/repositories/auth_repo.dart';

class AuthRepositoryImpl implements AuthRepo {
  AuthRepositoryImpl({
    required NetworkInfo networkInfo,
    required AuthRemoteDataSource remote,
    required SessionLocalDataSource sessionLocal,
  })  : _networkInfo = networkInfo,
        _remote = remote,
        _sessionLocal = sessionLocal;

  final NetworkInfo _networkInfo;
  final AuthRemoteDataSource _remote;
  final SessionLocalDataSource _sessionLocal;

  Future<Either<Failure, T>> _online<T>(Future<T> Function() run) async {
    if (!(await _networkInfo.isConnected)) return Left(OffLineFailure());
    try {
      return Right(await run());
    } catch (e) {
      if (e is Failure) return Left(e);
      if (kDebugMode) {
        print(e);
      }
      return Left(UnknownFailure());
    }
  }

  Future<void> _persistSession(AuthTokensResult r) async {
    await _sessionLocal.saveTokens(
      accessToken: r.accessToken,
      refreshToken: r.refreshToken,
    );
    await _persistSessionMeta(r.session);
  }

  Future<void> _persistSessionMeta(AuthenticatedSession session) async {
    await _sessionLocal.saveUserMeta(
      userId: session.userId,
      role: session.role,
      phone: session.phone,
      email: session.email,
      emailMissing: session.emailMissing,
      emailVerified: session.emailVerified,
    );
  }

  Future<AuthenticatedSession?> _readSessionMeta() async {
    if (!await hasPersistedSession()) return null;
    final id = await _sessionLocal.getUserId();
    final role = await _sessionLocal.getRole();
    if (id == null || id.isEmpty || role == null || role.isEmpty) {
      return null;
    }
    return AuthenticatedSession(
      userId: id,
      role: role,
      phone: await _sessionLocal.getPhone(),
      email: await _sessionLocal.getEmail(),
      emailMissing: await _sessionLocal.getEmailMissing(),
      emailVerified: await _sessionLocal.getEmailVerified(),
    );
  }

  @override
  Future<Either<Failure, AuthenticatedSession>> login({
    required String identifier,
    required String password,
  }) async {
    return _online(() async {
      final result = await _remote.login(
        identifier: identifier,
        password: password,
      );
      await _persistSession(result);
      return result.session;
    });
  }

  @override
  Future<Either<Failure, AuthenticatedSession>> registerDonor(
    DonorRegistrationParams params,
  ) async {
    return _online(() async {
      final result = await _remote.registerDonor(params);
      await _persistSession(result);
      return result.session;
    });
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    final refresh = await _sessionLocal.getRefreshToken();
    String deviceToken = '';
    try {
      deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
    } catch (_) {}
    if (refresh != null &&
        refresh.isNotEmpty &&
        await _networkInfo.isConnected) {
      try {
        await _remote.logout(
          refreshToken: refresh,
          deviceToken: deviceToken,
        );
      } catch (_) {
        // Best-effort: still clear locally.
      }
    }
    await _sessionLocal.clearSession();
    return const Right(unit);
  }

  @override
  Future<Either<Failure, Unit>> forgotPassword({
    required String identifier,
  }) async {
    return _online(() async {
      await _remote.forgotPassword(identifier: identifier);
      return unit;
    });
  }

  @override
  Future<Either<Failure, String>> verifyOtpForReset({
    required String identifier,
    required String code,
  }) async {
    return _online(() async {
      return await _remote.verifyOtp(identifier: identifier, code: code);
    });
  }

  @override
  Future<Either<Failure, Unit>> resetPasswordWithToken({
    required String resetToken,
    required String newPassword,
  }) async {
    return _online(() async {
      await _remote.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
      );
      return unit;
    });
  }

  @override
  Future<Either<Failure, AuthenticatedSession>> completeProfileEmail({
    required String email,
  }) async {
    return _online(() async {
      await _remote.completeProfileEmail(email: email);
      final current = await _readSessionMeta();
      if (current == null) throw WrongDataFailure();
      final updated = current.copyWith(
        email: email.trim(),
        emailMissing: false,
      );
      await _persistSessionMeta(updated);
      return updated;
    });
  }

  @override
  Future<Either<Failure, Unit>> sendEmailVerification() async {
    return _online(() async {
      await _remote.sendEmailVerification();
      return unit;
    });
  }

  @override
  Future<Either<Failure, AuthenticatedSession>> verifyEmail({
    required String code,
  }) async {
    return _online(() async {
      await _remote.verifyEmail(code: code);
      final current = await _readSessionMeta();
      if (current == null) throw WrongDataFailure();
      final updated = current.copyWith(emailVerified: true);
      await _persistSessionMeta(updated);
      return updated;
    });
  }

  @override
  Future<Either<Failure, Unit>> registerDeviceIfPossible() async {
    if (!(await _networkInfo.isConnected)) return const Right(unit);
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return const Right(unit);
      final platform = switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'ios',
        TargetPlatform.android => 'android',
        TargetPlatform.linux ||
        TargetPlatform.macOS ||
        TargetPlatform.windows ||
        TargetPlatform.fuchsia =>
          kIsWeb ? 'web' : 'android',
      };
      await _remote.registerDevice(token: token, platform: platform);
    } catch (_) {}
    return const Right(unit);
  }

  @override
  Future<bool> hasPersistedSession() async {
    final a = await _sessionLocal.getAccessToken();
    final r = await _sessionLocal.getRefreshToken();
    return a != null &&
        a.isNotEmpty &&
        r != null &&
        r.isNotEmpty;
  }

  @override
  Future<AuthenticatedSession?> readPersistedSessionMeta() async {
    return _readSessionMeta();
  }

  @override
  Future<Either<Failure, Unit>> signUpCenter({
    required BloodCenter center,
  }) async {
    return Left(
      ValidationFailure(
        message:
            'إنشاء حساب المركز يتم من الإدارة فقط. تواصل مع فريق نبض اليمن للحصول على بيانات الدخول.',
      ),
    );
  }
}
