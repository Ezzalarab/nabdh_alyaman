import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/auth/auth_identifier.dart';
import '../../../core/error/failures.dart';
import '../../../core/session/session_lifecycle.dart';
import '../../../data/datasources/local/preferences_local_datasource.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/repositories/auth_repo.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Global session Bloc (lazySingleton in GetIt).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepo authRepo,
    required SessionLifecycle sessionLifecycle,
    required PreferencesLocalDataSource preferences,
  })  : _authRepo = authRepo,
        _sessionLifecycle = sessionLifecycle,
        _preferences = preferences,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthRegisterDonorSubmitted>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthForgotPasswordSubmitted>(_onForgot);
    on<AuthOtpVerified>(_onOtp);
    on<AuthPasswordResetSubmitted>(_onReset);
    on<AuthCompleteEmailSubmitted>(_onCompleteEmail);
    on<AuthCompleteEmailSkipped>(_onCompleteEmailSkipped);
    on<AuthSendEmailVerificationRequested>(_onSendEmailVerification);
    on<AuthVerifyEmailSubmitted>(_onVerifyEmail);
    on<AuthSessionExpired>(_onSessionExpired);

    _expiredListener = () => add(AuthSessionExpired());
    _sessionLifecycle.addSessionExpiredListener(_expiredListener);
  }

  final AuthRepo _authRepo;
  final SessionLifecycle _sessionLifecycle;
  final PreferencesLocalDataSource _preferences;
  late final void Function() _expiredListener;

  Future<void> _emitAfterAuth(
    Emitter<AuthState> emit,
    AuthenticatedSession session,
  ) async {
    await _authRepo.registerDeviceIfPossible();
    if (session.emailMissing &&
        !await _preferences.isEmailCompletionPromptDismissed(session.userId)) {
      emit(AuthNeedsEmailCompletion(session));
      return;
    }
    emit(AuthAuthenticated(session));
  }

  Future<void> _onCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final session = await _authRepo.readPersistedSessionMeta();
    if (session == null) {
      emit(AuthUnauthenticated());
      return;
    }
    await _emitAfterAuth(emit, session);
  }

  Future<void> _onLogin(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final id = normalizeAuthIdentifier(event.identifier);
    if (id == null || id.isEmpty) {
      emit(AuthFailure('تأكد من صحة رقم الهاتف أو البريد الإلكتروني'));
      emit(AuthUnauthenticated());
      return;
    }
    final res = await _authRepo.login(
      identifier: id,
      password: event.password,
    );
    await res.fold(
      (failure) async {
        if (failure is ForbiddenFailure &&
            failure.apiCode == 'NEEDS_FIREBASE_PASSWORD') {
          emit(
            AuthFailure(
              failure.message ??
                  'يُرجى تعيين كلمة المرور المحلية عبر «نسيت كلمة المرور»',
              needsForgotPasswordRedirect: true,
            ),
          );
          emit(AuthUnauthenticated());
          return;
        }
        if (failure is ForbiddenFailure && failure.apiCode == 'BLOCKED') {
          emit(
            AuthFailure(
              failure.message ?? 'تم حظر حسابك. يُرجى التواصل مع الدعم.',
            ),
          );
          emit(AuthUnauthenticated());
          return;
        }
        emit(AuthFailure(_mapFailureMessage(failure)));
        emit(AuthUnauthenticated());
      },
      (session) async => _emitAfterAuth(emit, session),
    );
  }

  Future<void> _onRegister(
    AuthRegisterDonorSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _authRepo.registerDonor(event.params);
    await res.fold(
      (failure) async {
        emit(AuthFailure(_mapRegisterFailureMessage(failure)));
        emit(AuthUnauthenticated());
      },
      (session) async => _emitAfterAuth(emit, session),
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authRepo.logout();
    emit(AuthUnauthenticated());
  }

  Future<void> _onForgot(
    AuthForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final identifier = normalizeAuthIdentifier(event.identifier);
    if (identifier == null || identifier.isEmpty) {
      emit(AuthFailure('تأكد من صحة رقم الهاتف أو البريد الإلكتروني'));
      return;
    }
    final res = await _authRepo.forgotPassword(identifier: identifier);
    await res.fold(
      (failure) async => emit(AuthFailure(_mapFailureMessage(failure))),
      (_) async => emit(AuthForgotOtpSentNotice()),
    );
  }

  Future<void> _onOtp(AuthOtpVerified event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final identifier = normalizeAuthIdentifier(event.identifier);
    if (identifier == null || identifier.isEmpty) {
      emit(AuthFailure('تأكد من صحة رقم الهاتف أو البريد الإلكتروني'));
      return;
    }
    final res = await _authRepo.verifyOtpForReset(
      identifier: identifier,
      code: event.code.trim(),
    );
    await res.fold(
      (failure) async => emit(AuthFailure(_mapFailureMessage(failure))),
      (resetToken) async => emit(AuthReadyToChooseNewPassword(resetToken)),
    );
  }

  Future<void> _onReset(
    AuthPasswordResetSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _authRepo.resetPasswordWithToken(
      resetToken: event.resetToken,
      newPassword: event.newPassword,
    );
    await res.fold(
      (failure) async => emit(AuthFailure(_mapFailureMessage(failure))),
      (_) async => emit(AuthPasswordResetFinishedNotice()),
    );
  }

  Future<void> _onCompleteEmail(
    AuthCompleteEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _authRepo.completeProfileEmail(email: event.email);
    await res.fold(
      (failure) async {
        emit(AuthFailure(_mapFailureMessage(failure)));
        emit(AuthNeedsEmailCompletion(event.session));
      },
      (session) async => emit(AuthAuthenticated(session)),
    );
  }

  Future<void> _onCompleteEmailSkipped(
    AuthCompleteEmailSkipped event,
    Emitter<AuthState> emit,
  ) async {
    await _preferences.setEmailCompletionPromptDismissed(
      event.session.userId,
      true,
    );
    emit(AuthAuthenticated(event.session));
  }

  Future<void> _onSendEmailVerification(
    AuthSendEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _authRepo.sendEmailVerification();
    await res.fold(
      (failure) async => emit(AuthFailure(_mapFailureMessage(failure))),
      (_) async => emit(AuthEmailVerificationSent()),
    );
  }

  Future<void> _onVerifyEmail(
    AuthVerifyEmailSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final res = await _authRepo.verifyEmail(code: event.code);
    await res.fold(
      (failure) async => emit(AuthFailure(_mapFailureMessage(failure))),
      (session) async {
        emit(AuthEmailVerifiedSuccess());
        emit(AuthAuthenticated(session));
      },
    );
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepo.logout();
    emit(AuthUnauthenticated());
  }

  static String _mapFailureMessage(Failure f) => switch (f) {
        UnauthorizedFailure(:final message) =>
          message ?? 'بيانات الدخول غير صحيحة',
        ForbiddenFailure(:final apiCode, :final message) =>
          apiCode == 'BLOCKED'
              ? (message ?? 'تم حظر حسابك. يُرجى التواصل مع الدعم.')
              : (message ?? 'تم رفض الطلب'),
        ValidationFailure(:final message) =>
          message ?? 'تأكد من صحة البيانات المدخلة',
        ThrottledFailure(:final message) =>
          message ?? 'تم تجاوز الحد المسموح، حاول لاحقاً',
        ServerFailure() => 'خطأ في الخادم، حاول لاحقاً',
        OffLineFailure() => 'لا يوجد إنترنت',
        _ => 'حدث خطأ غير متوقع',
      };

  static String _mapRegisterFailureMessage(Failure f) {
    if (f is ValidationFailure) {
      return 'هذا الرقم أو البريد مسجّل مسبقاً. سجّل الدخول أو استخدم «نسيت كلمة المرور».';
    }
    return _mapFailureMessage(f);
  }

  @override
  Future<void> close() {
    _sessionLifecycle.removeSessionExpiredListener(_expiredListener);
    return super.close();
  }
}
