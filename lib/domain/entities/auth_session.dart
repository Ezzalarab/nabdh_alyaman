import 'package:equatable/equatable.dart';

/// Authenticated REST session snapshot.
class AuthenticatedSession extends Equatable {
  const AuthenticatedSession({
    required this.userId,
    required this.role,
    this.phone,
    this.email,
    this.emailMissing = false,
    this.emailVerified = false,
  });

  final String userId;
  /// `DONOR` or `CENTER` from API `role`.
  final String role;
  final String? phone;
  final String? email;
  final bool emailMissing;
  final bool emailVerified;

  AuthenticatedSession copyWith({
    String? userId,
    String? role,
    String? phone,
    String? email,
    bool? emailMissing,
    bool? emailVerified,
  }) {
    return AuthenticatedSession(
      userId: userId ?? this.userId,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      emailMissing: emailMissing ?? this.emailMissing,
      emailVerified: emailVerified ?? this.emailVerified,
    );
  }

  @override
  List<Object?> get props =>
      [userId, role, phone, email, emailMissing, emailVerified];
}
