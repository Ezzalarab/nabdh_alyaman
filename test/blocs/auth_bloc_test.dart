import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:nabdh_alyaman/core/error/failures.dart';
import 'package:nabdh_alyaman/core/session/session_lifecycle.dart';
import 'package:nabdh_alyaman/domain/entities/auth_session.dart';
import 'package:nabdh_alyaman/domain/entities/donor_registration_params.dart';
import 'package:nabdh_alyaman/core/constants/storage_keys.dart';
import 'package:nabdh_alyaman/presentation/blocs/auth/auth_bloc.dart';
import 'package:nabdh_alyaman/presentation/blocs/auth/auth_event.dart';
import 'package:nabdh_alyaman/presentation/blocs/auth/auth_state.dart';
import '../helpers/fake_auth_repo.dart';

void main() {
  late FakeAuthRepo authRepo;
  late SessionLifecycle sessionLifecycle;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final dir = await Directory.systemTemp.createTemp('nabdh_hive_test');
    Hive.init(dir.path);
    await Hive.openBox(dataBoxName);
  });

  setUp(() {
    authRepo = FakeAuthRepo();
    sessionLifecycle = SessionLifecycle();
  });

  AuthBloc buildBloc() => AuthBloc(
        authRepo: authRepo,
        sessionLifecycle: sessionLifecycle,
      );

  const session = AuthenticatedSession(
    userId: '1',
    role: 'DONOR',
    phone: '967771234567',
  );

  blocTest<AuthBloc, AuthState>(
    'AuthCheckRequested restores persisted session',
    build: buildBloc,
    act: (bloc) => bloc.add(AuthCheckRequested()),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      AuthLoading(),
      AuthAuthenticated(session),
    ],
    setUp: () {
      authRepo.persistedSession = session;
    },
  );

  blocTest<AuthBloc, AuthState>(
    'AuthCheckRequested without session emits unauthenticated',
    build: buildBloc,
    act: (bloc) => bloc.add(AuthCheckRequested()),
    wait: const Duration(milliseconds: 100),
    expect: () => [
      AuthLoading(),
      AuthUnauthenticated(),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'login BLOCKED shows Arabic message',
    build: buildBloc,
    act: (bloc) => bloc.add(
      AuthLoginSubmitted(identifier: '967771234567', password: 'secret'),
    ),
    expect: () => [
      AuthLoading(),
      isA<AuthFailure>().having(
        (s) => s.message,
        'message',
        contains('حظر'),
      ),
      AuthUnauthenticated(),
    ],
    setUp: () {
      authRepo.loginResult = Left(
        ForbiddenFailure(
          apiCode: 'BLOCKED',
          message: 'تم حظر حسابك',
        ),
      );
    },
  );

  blocTest<AuthBloc, AuthState>(
    'register ValidationFailure suggests sign-in or forgot password',
    build: buildBloc,
    act: (bloc) => bloc.add(
      AuthRegisterDonorSubmitted(
        DonorRegistrationParams(
          fullName: 'Test',
          phone: '967771234567',
          password: 'secret12',
          bloodType: 'O+',
          gender: 'MALE',
          stateId: 1,
          districtId: 1,
          locationId: 1,
        ),
      ),
    ),
    expect: () => [
      AuthLoading(),
      isA<AuthFailure>().having(
        (s) => s.message,
        'message',
        contains('مسجّل'),
      ),
      AuthUnauthenticated(),
    ],
    setUp: () {
      authRepo.registerResult = Left(ValidationFailure());
    },
  );

  blocTest<AuthBloc, AuthState>(
    'NEEDS_FIREBASE_PASSWORD sets forgot-password redirect flag',
    build: buildBloc,
    act: (bloc) => bloc.add(
      AuthLoginSubmitted(identifier: '967771234567', password: 'secret'),
    ),
    expect: () => [
      AuthLoading(),
      isA<AuthFailure>().having(
        (s) => s.needsForgotPasswordRedirect,
        'redirect',
        true,
      ),
      AuthUnauthenticated(),
    ],
    setUp: () {
      authRepo.loginResult = Left(
        ForbiddenFailure(apiCode: 'NEEDS_FIREBASE_PASSWORD'),
      );
    },
  );
}
