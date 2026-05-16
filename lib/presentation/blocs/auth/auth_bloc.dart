import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

import '../../../core/auth/auth_identifier.dart';
import '../../../core/error/failures.dart';
import '../../../core/session/session_lifecycle.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/repositories/auth_repo.dart';
import '../../../presentation/pages/setting_page.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Global session Bloc (lazySingleton in GetIt).
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required AuthRepo authRepo,
    required SessionLifecycle sessionLifecycle,
  })  : _authRepo = authRepo,
        _sessionLifecycle = sessionLifecycle,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheck);
    on<AuthLoginSubmitted>(_onLogin);
    on<AuthRegisterDonorSubmitted>(_onRegister);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthForgotPasswordSubmitted>(_onForgot);
    on<AuthOtpVerified>(_onOtp);
    on<AuthPasswordResetSubmitted>(_onReset);
    on<AuthSessionExpired>(_onSessionExpired);

    _expiredListener = () => add(AuthSessionExpired());
    _sessionLifecycle.addSessionExpiredListener(_expiredListener);
  }

  final AuthRepo _authRepo;
  final SessionLifecycle _sessionLifecycle;
  late final void Function() _expiredListener;

  Future<void> _syncHiveUserMarker(AuthenticatedSession? session) async {
    final box = Hive.box(dataBoxName);
    if (session == null) {
      await box.put('user', '0');
      return;
    }
    await box.put(
      'user',
      session.role == 'CENTER' ? '2' : '1',
    );
  }

  Future<void> _onCheck(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final session = await _authRepo.readPersistedSessionMeta();
    if (session == null) {
      await _syncHiveUserMarker(null);
      emit(AuthUnauthenticated());
      return;
    }
    await _syncHiveUserMarker(session);
    await _authRepo.registerDeviceIfPossible();
    emit(AuthAuthenticated(session));
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
        emit(AuthFailure(_mapFailureMessage(failure)));
        emit(AuthUnauthenticated());
      },
      (session) async {
        await _syncHiveUserMarker(session);
        await _authRepo.registerDeviceIfPossible();
        emit(AuthAuthenticated(session));
      },
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
        emit(AuthFailure(_mapFailureMessage(failure)));
        emit(AuthUnauthenticated());
      },
      (session) async {
        await _syncHiveUserMarker(session);
        await _authRepo.registerDeviceIfPossible();
        emit(AuthAuthenticated(session));
      },
    );
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authRepo.logout();
    await _syncHiveUserMarker(null);
    emit(AuthUnauthenticated());
  }

  Future<void> _onForgot(
    AuthForgotPasswordSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final phone = normalizeAuthIdentifier(event.phone);
    if (phone == null || phone.contains('@')) {
      emit(AuthFailure('استخدم رقم الهاتف اليمني فقط مع نسيت كلمة المرور'));
      emit(AuthUnauthenticated());
      return;
    }
    final res = await _authRepo.forgotPassword(phone: phone);
    await res.fold(
      (failure) async {
        emit(AuthFailure(_mapFailureMessage(failure)));
        emit(AuthUnauthenticated());
      },
      (_) async {
        emit(AuthForgotSmsSentNotice());
      },
    );
  }

  Future<void> _onOtp(AuthOtpVerified event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final phone = normalizeAuthIdentifier(event.phone);
    if (phone == null || phone.contains('@')) {
      emit(AuthFailure('رقم الهاتف غير صالح'));
      emit(AuthUnauthenticated());
      return;
    }
    final res = await _authRepo.verifyOtpForReset(
      phone: phone,
      code: event.code.trim(),
    );
    await res.fold(
      (failure) async {
        emit(AuthFailure(_mapFailureMessage(failure)));
        emit(AuthUnauthenticated());
      },
      (resetToken) async {
        emit(AuthReadyToChooseNewPassword(resetToken));
      },
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
      (failure) async {
        emit(AuthFailure(_mapFailureMessage(failure)));
        emit(AuthUnauthenticated());
      },
      (_) async {
        emit(AuthPasswordResetFinishedNotice());
      },
    );
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepo.logout();
    await _syncHiveUserMarker(null);
    emit(AuthUnauthenticated());
  }

  static String _mapFailureMessage(Failure f) => switch (f) {
        UnauthorizedFailure(:final message) =>
          message ?? 'بيانات الدخول غير صحيحة',
        ForbiddenFailure(:final message) => message ?? 'تم رفض الطلب',
        ValidationFailure(:final message) =>
          message ?? 'تأكد من صحة البيانات المدخلة',
        ThrottledFailure(:final message) =>
          message ?? 'تم تجاوز الحد المسموح، حاول لاحقاً',
        OffLineFailure() => 'لا يوجد إنترنت',
        ServerFailure() => 'خطأ في الخادم، حاول لاحقاً',
        _ => 'حدث خطأ غير متوقع',
      };

  @override
  Future<void> close() {
    _sessionLifecycle.removeSessionExpiredListener(_expiredListener);
    return super.close();
  }
}
