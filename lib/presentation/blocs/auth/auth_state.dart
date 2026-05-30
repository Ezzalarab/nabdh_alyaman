import 'package:equatable/equatable.dart';

import '../../../domain/entities/auth_session.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  AuthAuthenticated(this.session);
  final AuthenticatedSession session;

  @override
  List<Object?> get props => [session];
}

/// Legacy account without email — optional completion prompt.
class AuthNeedsEmailCompletion extends AuthState {
  AuthNeedsEmailCompletion(this.session);
  final AuthenticatedSession session;

  @override
  List<Object?> get props => [session];
}

class AuthUnauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  AuthFailure(this.message, {this.needsForgotPasswordRedirect = false});
  final String message;
  final bool needsForgotPasswordRedirect;

  @override
  List<Object?> get props => [message, needsForgotPasswordRedirect];
}

/// Forgot-password OTP request accepted — show OTP step.
class AuthForgotOtpSentNotice extends AuthState {}

/// OTP verified — UI prompts for new password (uses [resetToken]).
class AuthReadyToChooseNewPassword extends AuthState {
  AuthReadyToChooseNewPassword(this.resetToken);
  final String resetToken;

  @override
  List<Object?> get props => [resetToken];
}

/// Password reset succeeded — navigate to sign-in.
class AuthPasswordResetFinishedNotice extends AuthState {}

/// Email verification OTP sent to registered address.
class AuthEmailVerificationSent extends AuthState {}

/// Email address verified successfully.
class AuthEmailVerifiedSuccess extends AuthState {}
