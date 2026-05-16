import 'package:equatable/equatable.dart';

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
  AuthForgotPasswordSubmitted(this.phone);
  final String phone;

  @override
  List<Object?> get props => [phone];
}

class AuthOtpVerified extends AuthEvent {
  AuthOtpVerified({required this.phone, required this.code});
  final String phone;
  final String code;

  @override
  List<Object?> get props => [phone, code];
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

/// From [SessionLifecycle] when refresh fails after 401.
class AuthSessionExpired extends AuthEvent {}
