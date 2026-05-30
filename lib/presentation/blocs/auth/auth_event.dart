import 'package:equatable/equatable.dart';

import '../../../domain/entities/auth_session.dart';
import '../../../domain/entities/donor_registration_params.dart';

sealed class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginSubmitted extends AuthEvent {
  AuthLoginSubmitted({required this.identifier, required this.password});
  final String identifier;
  final String password;

  @override
  List<Object?> get props => [identifier, password];
}

class AuthRegisterDonorSubmitted extends AuthEvent {
  AuthRegisterDonorSubmitted(this.params);
  final DonorRegistrationParams params;

  @override
  List<Object?> get props => [params];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthForgotPasswordSubmitted extends AuthEvent {
  AuthForgotPasswordSubmitted(this.identifier);
  final String identifier;

  @override
  List<Object?> get props => [identifier];
}

class AuthOtpVerified extends AuthEvent {
  AuthOtpVerified({required this.identifier, required this.code});
  final String identifier;
  final String code;

  @override
  List<Object?> get props => [identifier, code];
}

class AuthPasswordResetSubmitted extends AuthEvent {
  AuthPasswordResetSubmitted({
    required this.resetToken,
    required this.newPassword,
  });
  final String resetToken;
  final String newPassword;

  @override
  List<Object?> get props => [resetToken, newPassword];
}

class AuthCompleteEmailSubmitted extends AuthEvent {
  AuthCompleteEmailSubmitted({
    required this.email,
    required this.session,
  });
  final String email;
  final AuthenticatedSession session;

  @override
  List<Object?> get props => [email, session];
}

class AuthCompleteEmailSkipped extends AuthEvent {
  AuthCompleteEmailSkipped(this.session);
  final AuthenticatedSession session;

  @override
  List<Object?> get props => [session];
}

class AuthSendEmailVerificationRequested extends AuthEvent {}

class AuthVerifyEmailSubmitted extends AuthEvent {
  AuthVerifyEmailSubmitted(this.code);
  final String code;

  @override
  List<Object?> get props => [code];
}

/// From [SessionLifecycle] when refresh fails after 401.
class AuthSessionExpired extends AuthEvent {}
